#!/bin/bash

#
#
# Sync data with remote Columbus machine
#
# 

# Note: these commands are set in "dry run" mode. Run them and see if anything
# looks weird. To sync remove --dry-run. Whatever you delete will be deleted too.

# first connect to Pitt VPN if necessary
# remote rsync (for Michael's mac mini) 
rsync -avhW --progress --update --exclude-from ./rsync-excludes.txt --dry-run /Users/research/Documents/myudelson/ProgMOOC/ developers@columbus.exp.sis.pitt.edu:/home/developers/ProgMOOC/

# TO Columbus rsync (for Michael's macbookpro) 
rsync -avhW --progress --update --exclude-from ./rsync-excludes.txt --dry-run /Users/yudelson/Documents/pitt/pittuohmooc/ developers@columbus.exp.sis.pitt.edu:/home/developers/ProgMOOC/
# FROM Columbus rsync (for Michael's macbookpro) 
rsync -avhW --progress --update --exclude-from ./rsync-excludes.txt --dry-run developers@columbus.exp.sis.pitt.edu:/home/developers/ProgMOOC/ /Users/yudelson/Documents/pitt/pittuohmooc/ 


# TO  and FROM PAWSComc 2
rsync -avhW --progress --update --exclude-from ./rsync-excludes.txt --dry-run /Users/yudelson/Documents/pitt/pittuohmooc/ myudelson@pawscomp2.sis.pitt.edu:/home/myudelson/pittuohmooc/
rsync -avhW --progress --update --exclude-from ./rsync-excludes.txt --dry-run myudelson@pawscomp2.sis.pitt.edu:/home/myudelson/pittuohmooc/ /Users/yudelson/Documents/pitt/pittuohmooc/


# TO Columbus rsync (for Roya) -- FILL IN THE BLANK
rsync -avhW --progress --update --exclude-from=/Users/roya/Desktop/ProgMOOC/rsync-excludes.txt --dry-run /Users/roya/Desktop/ProgMOOC/ developers@columbus.exp.sis.pitt.edu:/home/developers/ProgMOOC/

# FROM Columbus rsync (for Roya) -- FILL IN THE BLANK
rsync -avhW --progress --update --exclude-from=/Users/roya/Desktop/ProgMOOC/rsync-excludes.txt --dry-run developers@columbus.exp.sis.pitt.edu:/home/developers/ProgMOOC/ /Users/roya/Desktop/ProgMOOC/


# password to columbus machine is d3v3l0p3rs

# copy from PSC to PAWS Comp 2
scp -r yudelson@bridges.psc.xsede.org:/home/yudelson/pittuohmooc /home/myudelson/



#
# DECLARATION: array of dataset names, so far these are old
#
declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")


#
# Preprocess
#

# 0. Uncompress
# 1. Find problems that are always right/wrong
# 2. Break into per-student files
# 3. Sort per-student files by time
# 4. Redo timediff column 7 and add concept count
# 5. Merge consecutive RUN/TEST/SUBMIT without concept changes
# 6. Throw out problems with always right/wrong
# 7. Merge back into one file per dataset
# 8. cleanup (delete temporary files

for dataset in ${datasets[@]} # for all dataset names in datasets array
do
 	# 0. Uncompress source data
    tar -zxvf data/${dataset}.tar.gz -O > data/${dataset}-snapshot-out_tmp.csv
    wc -l data/${dataset}-snapshot-out_tmp.csv
    # 1. Find problems that are always right/wrong
    awk -F";" '{ if(PO[$4,$14]=="" || PO[$4,$14]==0) {P[$4]++; PT[$4]=PT[$4]""$14","; } PO[$4,$14]++; PN[$4]++; }END{for(p in P) if(P[p]<2) print p"\t"PT[p]"\t"PN[p];}' data/${dataset}-snapshot-out_tmp.csv > data/${dataset}-problemsSameOutcome.txt
    # 2. Break into per-student files
    cut -f2,2 -d';' ./data/${dataset}-snapshot-out_tmp.csv | sort -u > data/${dataset}_students.txt
	    # remove problem directory and all its content, if any exits
    rm -rf 'data/'${dataset}'_students'
    	# make folder for each dataset and split into individual problem files (by 4th column in the source file)
    mkdir data/${dataset}_students
    awk -F';' 'BEGIN{OFS="\t";}{fn="./data/'${dataset}'_students/"$2".txt"; print $0 >> fn; close(fn);}' ./data/${dataset}-snapshot-out_tmp.csv
	# 3. Sort per-student files by time
    while read -r line || [[ -n $line ]]; do # for al problem files, look at "done" line below to see that we are reading a *_problem.txt file line bby line
        fnstud="./data/${dataset}_students/"$line".txt" # problem file name in a dataset
        fnstud_sorted="./data/${dataset}_students/"$line"_sorted.txt" # problem file name in a dataset
        sort -t";" -k6,6 "${fnstud}" > "${fnstud_sorted}"
    done < data/${dataset}_students.txt
	# 4. Redo timediff column 7 and add concept count
    while read -r line || [[ -n $line ]]; do # for al problem files, look at "done" line below to see that we are reading a *_problem.txt file line bby line
        fnstud_sorted="./data/${dataset}_students/"$line"_sorted.txt" # problem file name in a dataset
        fnstud_sortedDiff="./data/${dataset}_students/"$line"_sortedDiff.txt" # problem file name in a dataset
        awk -F";" 'BEGIN{OFS=";";pprev="";}{
			k=split($17,ar,","); 
			if(FNR==1) {
				print $0,k;
			} else {
				diff=t-tprev;
				print $1,$2,$3,$4,$5,$6,$6-tprev,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,k;
			}
			tprev=$6;
		}' "${fnstud_sorted}" > "${fnstud_sortedDiff}"
    done < data/${dataset}_students.txt
	# 5. Merge (collapse) consecutive RUN/TEST/SUBMIT without concept changes
    while read -r line || [[ -n $line ]]; do # for al problem files, look at "done" line below to see that we are reading a *_problem.txt file line bby line
        fnstud_sortedDiff="./data/${dataset}_students/"$line"_sortedDiff.txt" # problem file name in a dataset
        fnstud_sortedDiffCollapse="./data/${dataset}_students/"$line"_sortedDiffCollapse.txt" # problem file name in a dataset
		awk -F";" '{
			if(FNR==1) {
				print $0;
			} else {
				c =( ((g_p==$2) && (p_p==$4) && (c_p==$8) && (r_p==$12"__"$14) && (k_p==$17)) || ($17==$18) );
				if(c==0) print $0;
			}
			g_p=$2; p_p=$4; c_p=$8; r_p=$12"__"$14; k_p=$17;
		}' "${fnstud_sortedDiff}" > "${fnstud_sortedDiffCollapse}"
    done < data/${dataset}_students.txt
	# 6. Throw out problems with always right/wrong
	# 7. Merge back into one file per dataset
	rm -rf data/${dataset}_all.txt
	rm -rf data/${dataset}_allsubmit.txt
    while read -r line || [[ -n $line ]]; do # for al problem files, look at "done" line below to see that we are reading a *_problem.txt file line bby line
        fnstud_sortedDiffCollapse="./data/${dataset}_students/"$line"_sortedDiffCollapse.txt" # problem file name in a dataset
        problems_to_remove="./data/${dataset}-problemsSameOutcome.txt"
		awk -F";|\t" 'BEGIN{fn=0;}{if(FNR==1)fn++; if(fn==1) P[$1]++; if(fn==2 && !($4 in P)) print $0; }' "${problems_to_remove}" "${fnstud_sortedDiffCollapse}" >> data/${dataset}_all.txt
    done < data/${dataset}_students.txt
    grep -v ";GENERIC;" data/${dataset}_all.txt > data/${dataset}_allsubmit.txt
    wc -l data/${dataset}_all.txt
    wc -l data/${dataset}_allsubmit.txt
    # 8. cleanup
	rm -rf data/${dataset}-snapshot-out_tmp.csv
	rm -rf data/${dataset}_students/
	rm -rf data/${dataset}_students.txt
	rm -rf data/${dataset}-problemsSameOutcome.txt
done
#   351073 data/s2014-ohpe-snapshot-out_tmp.csv
#   133370 data/s2014-ohpe_all.txt
#   107143 data/s2014-ohpe_allsubmit.txt
#   298992 data/s2015-ohpe-snapshot-out_tmp.csv
#   115560 data/s2015-ohpe_all.txt
#    92591 data/s2015-ohpe_allsubmit.txt
#   910009 data/k2015-mooc-snapshot-out_tmp.csv
#   338685 data/k2015-mooc_all.txt
#   274456 data/k2015-mooc_allsubmit.txt
#  1122475 data/k2014-mooc-snapshot-out_tmp.csv
#   418890 data/k2014-mooc_all.txt
#   340206 data/k2014-mooc_allsubmit.txt
# problems to delete 11,11,11,11


# Check Compiled X RatioTestsPassed table
declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")
for dataset in ${datasets[@]} # for all dataset names in datasets array
do
	echo ${dataset}
	awk -F";" '{A[$8"__"$12]++;}END{for(a in A)print a" "A[a];}' data/${dataset}_all.txt | grep "true__-1"
done
# s2014-ohpe
# true__-1 225
# s2015-ohpe
# true__-1 202
# k2015-mooc
# true__-1 547
# k2014-mooc
# true__-1 679

#
# compressing and uncompressing _all and _allsubmit files
#
# compress
declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")
for dataset in ${datasets[@]} # for all dataset names in datasets array
do
	tar -cvjf data/${dataset}_all.tar.bz data/${dataset}_all.txt
	tar -cvjf data/${dataset}_allsubmit.tar.bz data/${dataset}_allsubmit.txt
# 	rm -rf data/${dataset}_all.txt
# 	rm -rf data/${dataset}_allsubmit.txt
done
# _all.txt and _allsubmit.txt files before compression are 3,216,247,231 bytes (3.22 GB on disk)
# _all.tar.bz and _allsubmit.tar.bz files before compression are 99,918,440 bytes (99.9 MB on disk)
# un-compress
declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")
for dataset in ${datasets[@]} # for all dataset names in datasets array
do
	tar -xjvf data/${dataset}_all.tar.bz
	tar -xjvf data/${dataset}_allsubmit.tar.bz
done

# ========= end of pre-processing =======


# ========= start of behaviour labeling and merging that with the data =======

# un-compress _allsubmit_behav files
declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")
for dataset in ${datasets[@]} # for all dataset names in datasets array
do
   tar -xjvf data/${dataset}_all.tar.bz
done

declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")
#compiling the behaviour labeling java file
rm -rf "./code/java/source_codes/progMooc/classes" # remove if directory exists
mkdir "./code/java/source_codes/progMooc/classes" # recreate it
javac -d "./code/java/source_codes/progMooc/classes" "./code/java/source_codes/progMooc/src/progMooc/BehavLbl.java"
for dataset in ${datasets[@]} # for all datasets
do
    # remove if file exists
    rm -f "./data/${dataset}_behavLbl_log.txt"
    rm -f "./data/${dataset}_all_behavLbl.txt"
    # create an empty file for storing warnings generated during the labeling process
    echo "" > "./data/${dataset}_behavLbl_log.txt"
    #running the behaviour labeling java file
    java -cp "./code/java/source_codes/progMooc/classes/" progMooc.BehavLbl "./data/${dataset}_all.txt" "./data/${dataset}_all_behavLbl.txt" $dataset >>  "./data/${dataset}_behavLbl_log.txt"
done # for all datasets
printf "Finished labeling behaviours.\n"

mkdir temp_behav
for dataset in ${datasets[@]} # for all datasets
do
    datasetFile="./data/${dataset}_all.txt" # dataset file
    behavFile="./data/${dataset}_all_behavLbl.txt" # behaviour file name for the current dataset
    awk 'BEGIN{FS=";"} NR==FNR {a[$1]=$2 FS $3 FS $4 FS $5 FS $6 FS $7 FS $8 FS $9} NR>FNR {if (a[$1]) print $0 FS a[$1]; else print $0 FS FS FS FS FS FS FS FS}' $behavFile $datasetFile > "./temp_behav/${dataset}_all.txt"
    cp -f "./temp_behav/${dataset}_all.txt" "./data/${dataset}_all.txt" # repalace the original dataset file with the dataset merged with behaviour labels
done # for all datasets

rm -rf temp_behav # remove the temp directory
printf "Finished adding behaviours to the data.\n"

for dataset in ${datasets[@]} # for all datasets
do
# create directory for storing behaviour data
    rm -f "./data/${dataset}_all_behavLbl.txt" # remove if file exists
done


# Lump data into one file, leave only submission rows (_allsubmit_behav)
declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")
for dataset in ${datasets[@]}
do
    rm -rf ./data/${dataset}_allsubmit_behav.txt
    fname="./data/${dataset}_all.txt"
    grep -v ";GENERIC;" "${fname}" >> ./data/${dataset}_allsubmit_behav.txt
    wc -l ./data/${dataset}_all.txt
    wc -l ./data/${dataset}_allsubmit_behav.txt
done # all datasets
#  151914 ./data/s2014-ohpe_all.txt
#  122988 ./data/s2014-ohpe_allsubmit_behav.txt
#  129487 ./data/s2015-ohpe_all.txt
#  104554 ./data/s2015-ohpe_allsubmit_behav.txt
#  387811 ./data/k2015-mooc_all.txt
#  317707 ./data/k2015-mooc_allsubmit_behav.txt
#  487408 ./data/k2014-mooc_all.txt
#  399357 ./data/k2014-mooc_allsubmit_behav.txt

#
# compressing _allsubmit_behav and log files
#
declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")
for dataset in ${datasets[@]} # for all dataset names in datasets array
do
	tar -cvjf data/${dataset}_allsubmit_behav.tar.bz data/${dataset}_allsubmit_behav.txt
    tar -cvjf data/${dataset}_behavLbl_log.tar.bz data/${dataset}_behavLbl_log.txt
 	rm -rf data/${dataset}_all.txt
 	rm -rf data/${dataset}_allsubmit_behav.txt
    rm -rf data/${dataset}_behavLbl_log.txt
done


# ========= end of of behaviour labeling and merging that with the data =======
# <<<Roya Finished Here>>>

#
# Exploratory
#
# for dataset in ${datasets[@]} # for all dataset names in datasets array
# do
# 	tar -xvjf data/${dataset}_allsubmit_behav.tar.bz data/${dataset}_allsubmit_behav.txt
# done
# 
# # people with 1 (2 or 3) snapshot per problem
# declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")
# rm -rf tmp_student_problem_only_xtimes.txt
# for dataset in ${datasets[@]} # for all dataset names in datasets array
# do
# 	awk -F";" '{T[$2,$4]++; C[$2,$4]+=($12==1); if(T[$2,$4]==1) N++;}END{for(t in T) {if(T[t]<=3) print t,T[t],C[t];} print N;}' data/${dataset}_allsubmit_behav.txt >> tmp_student_problem_only_xtimes.txt
# done
# # approximate number of student-problem cases
# grep -E "^[0-9]+$" tmp_student_problem_only_xtimes.txt
# # counts
# # 20806
# # 18123
# # 52156
# # 67749
# # = 158834
# wc -l tmp_student_problem_only_xtimes.txt
# # 55126 - 0.35
# # 2 is threshold
# grep -E " (1|2)$" tmp_student_problem_only_xtimes.txt | wc -l
# # 71404 - 0.45
# grep -E " (1|2|3)$" tmp_student_problem_only_xtimes.txt | wc -l
# # 83877 - 0.53
# 
# # student min and max attempts oer problem
# declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")
# rm -rf tmp_student_problem_only_xtimes.txt
# for dataset in ${datasets[@]} # for all dataset names in datasets array
# do
# 	# tar -xvjf data/${dataset}_allsubmit_behav.tar.bz data/${dataset}_allsubmit_behav.txt
# 	awk -F";" '{T[$2,$4]++; if($12==1) C[$2,$4]=1;}END{for(t in T) {if(T[t]<=3) print t,T[t],C[t];} print N;}' data/${dataset}_allsubmit_behav.txt >> tmp_student_problem_only_xtimes.txt
# done
# 
# 
# 
# # people with 1:10+ snapshots
# declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")
# for dataset in ${datasets[@]} # for all dataset names in datasets array
# do
# 	# tar -xvjf data/${dataset}_allsubmit_behav.tar.bz data/${dataset}_allsubmit_behav.txt
# 	awk -F";" '{T[$2,$4]++; C[$2,$4]+=($12==1); if(T[$2,$4]==1) N++;}END{ for(t in T){ if(T[t]<20) NS[ T[t] ]++; else NS[20]++; }for(n in NS) print n,NS[n]; }' data/${dataset}_allsubmit_behav.txt
# done

# ============================================== Documented and checked until here


# # deleting column 22 that was a duplicate of column 21
# declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")
# for dataset in ${datasets[@]}
# do
# 	tar -xvjf data/${dataset}_all.tar.bz data/${dataset}_all.txt
# 	tar -xvjf data/${dataset}_allsubmit.tar.bz data/${dataset}_allsubmit.txt
# 	mv data/${dataset}_all.txt data/${dataset}_all0.txt
# 	mv data/${dataset}_allsubmit.txt data/${dataset}_allsubmit0.txt
# 	cut -d";" -f 1-21 data/${dataset}_all0.txt > data/${dataset}_all.txt
# 	cut -d";" -f 1-21 data/${dataset}_allsubmit0.txt > data/${dataset}_allsubmit.txt
# 	tar -cvjf data/${dataset}_all.tar.bz data/${dataset}_all.txt
# 	tar -cvjf data/${dataset}_allsubmit.tar.bz data/${dataset}_allsubmit.txt
# 	rm -rf data/${dataset}_*0.txt
# 	rm -rf data/${dataset}_all*.txt
# done


#
# Prepare data for modeling:
# - create vocabularies for students, skills, items ./data/${dataset}_voc_{student|skill|item}.txt

# uncompress
for dataset in ${datasets[@]} # for all dataset names in datasets array
do
	tar -xvjf data/${dataset}_allsubmit.tar.bz data/${dataset}_allsubmit.txt
done

# Student and item vocabularies first
declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")
for dataset in ${datasets[@]}
do
    rm -rf ./data/${dataset}_voc
    mkdir ./data/${dataset}_voc
    export vocstu=./data/${dataset}_voc/${dataset}_allsubmit_voc_student.txt
    export vocite=./data/${dataset}_voc/${dataset}_allsubmit_voc_item.txt
    awk -F";" -f ./code/all2studitemvoc.awk ./data/${dataset}_allsubmit.txt
    wc -l ./data/${dataset}_voc/${dataset}_allsubmit_voc_student.txt
    wc -l ./data/${dataset}_voc/${dataset}_allsubmit_voc_item.txt
done # all datasets
#      220 ./data/s2014-ohpe_voc/s2014-ohpe_allsubmit_voc_student.txt
#      104 ./data/s2014-ohpe_voc/s2014-ohpe_allsubmit_voc_item.txt
#      180 ./data/s2015-ohpe_voc/s2015-ohpe_allsubmit_voc_student.txt
#      116 ./data/s2015-ohpe_voc/s2015-ohpe_allsubmit_voc_item.txt
#      613 ./data/k2015-mooc_voc/k2015-mooc_allsubmit_voc_student.txt
#      116 ./data/k2015-mooc_voc/k2015-mooc_allsubmit_voc_item.txt
#      852 ./data/k2014-mooc_voc/k2014-mooc_allsubmit_voc_student.txt
#       97 ./data/k2014-mooc_voc/k2014-mooc_allsubmit_voc_item.txt

# Add B and C sets of concepts at the end
declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")
for dataset in ${datasets[@]}
do
    fin=./data/${dataset}_allsubmit.txt
    fout=./data/${dataset}_allsubmitABCD.txt
    fouttar=./data/${dataset}_allsubmitABCD.tar.bz
    awk -F";" -f ./code/dataAtoABCD.awk "${fin}" > "${fout}"
    tar -cvjf "${fouttar}" "${fout}"
done # all datasets

#
# create vocabularies of concepts
#
declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")
for dataset in ${datasets[@]}
do
    export vocski=./data/${dataset}_voc/${dataset}_allsubmit_voc_skill
    awk -F";" -f ./code/all2skillvoc.awk ./data/${dataset}_allsubmitABCD.txt
    wc -l ./data/${dataset}_voc/${dataset}_allsubmit_voc_skillA.txt
    wc -l ./data/${dataset}_voc/${dataset}_allsubmit_voc_skillB.txt
    wc -l ./data/${dataset}_voc/${dataset}_allsubmit_voc_skillC.txt
    wc -l ./data/${dataset}_voc/${dataset}_allsubmit_voc_skillD.txt
done # all datasets
#      136 ./data/s2014-ohpe_voc/s2014-ohpe_allsubmit_voc_skillA.txt # s2014-ohpe
#      136 ./data/s2014-ohpe_voc/s2014-ohpe_allsubmit_voc_skillB.txt
#      270 ./data/s2014-ohpe_voc/s2014-ohpe_allsubmit_voc_skillC.txt
#      278 ./data/s2014-ohpe_voc/s2014-ohpe_allsubmit_voc_skillD.txt
#      135 ./data/s2015-ohpe_voc/s2015-ohpe_allsubmit_voc_skillA.txt # s2015-ohpe
#      135 ./data/s2015-ohpe_voc/s2015-ohpe_allsubmit_voc_skillB.txt
#      269 ./data/s2015-ohpe_voc/s2015-ohpe_allsubmit_voc_skillC.txt
#      268 ./data/s2015-ohpe_voc/s2015-ohpe_allsubmit_voc_skillD.txt
#      151 ./data/k2015-mooc_voc/k2015-mooc_allsubmit_voc_skillA.txt # k2015-mooc
#      151 ./data/k2015-mooc_voc/k2015-mooc_allsubmit_voc_skillB.txt
#      301 ./data/k2015-mooc_voc/k2015-mooc_allsubmit_voc_skillC.txt
#      302 ./data/k2015-mooc_voc/k2015-mooc_allsubmit_voc_skillD.txt
#      147 ./data/k2014-mooc_voc/k2014-mooc_allsubmit_voc_skillA.txt # k2014-mooc
#      147 ./data/k2014-mooc_voc/k2014-mooc_allsubmit_voc_skillB.txt
#      293 ./data/k2014-mooc_voc/k2014-mooc_allsubmit_voc_skillC.txt
#      294 ./data/k2014-mooc_voc/k2014-mooc_allsubmit_voc_skillD.txt


#
# Concept filtering @Roya
#
./code/conceptFilter.sh

#
#
# Modeling @Michael
#
#

#
# Maj class
declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")
for dataset in ${datasets[@]}
do
    fname=./data/${dataset}_allsubmit.txt
    awk -F";" '{N++; W+=($12!="1.0"); sse+=($12=="1.0")^2} END{print "All="N"  Wrong="W"  Acc="W/N"  RMSE="sqrt(sse/N)}' "${fname}"
done
# old filtering
# All=104800  Wrong= 84570  Acc=0.806966  RMSE=0.439357
# All= 90972  Wrong= 71529  Acc=0.786275  RMSE=0.462304
# All=269471  Wrong=209605  Acc=0.777839  RMSE=0.47134
# All=333244  Wrong=270246  Acc=0.810955  RMSE=0.434793
# new filtering - checked
# All=107143  Wrong= 85567  Acc=0.798624  RMSE=0.448749
# All= 92591  Wrong= 72346  Acc=0.781350  RMSE=0.467600
# All=274456  Wrong=211709  Acc=0.771377  RMSE=0.478146
# All=340206  Wrong=272927  Acc=0.802240  RMSE=0.444702

# uncompress
declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")
for dataset in ${datasets[@]} # for all dataset names in datasets array
do
	tar -xvjf data/${dataset}_allsubmit.tar.bz data/${dataset}_allsubmit.txt
	tar -xvjf data/${dataset}_allsubmitABCD.tar.bz data/${dataset}_allsubmitABCD.txt
done

#
# IRT 
./code/modelIRT_prep.sh
./code/modelIRT_fit.sh
# s2014-ohpe
# Accuracy = 0.837124 ( 89692/107143), RMSE = 0.403579
# s2015-ohpe
# Accuracy = 0.841637 (  77928/92591), RMSE = 0.397949
# k2015-mooc
# Accuracy = 0.839238 (230334/274456), RMSE = 0.400951
# k2014-mooc
# Accuracy = 0.848689 (288729/340206), RMSE = 0.388987

#
# AFM prep data
./code/modelAFM_prep.sh
./code/modelAFM_fit.sh
# s2014-ohpe
# Accuracy = 0.803459 (86085/107143), RMSE = 0.443330
# Accuracy = 0.799828 (85696/107143), RMSE = 0.447406
# Accuracy = 0.799828 (85696/107143), RMSE = 0.447406
# Accuracy = 0.799828 (85696/107143), RMSE = 0.447406
# s2015-ohpe
# Accuracy = 0.791524 (73288/92591), RMSE = 0.456592
# Accuracy = 0.783381 (72534/92591), RMSE = 0.465424
# Accuracy = 0.783381 (72534/92591), RMSE = 0.465424
# Accuracy = 0.783381 (72534/92591), RMSE = 0.465424
# k2015-mooc
# Accuracy = 0.780438 (214196/274456), RMSE = 0.468574
# Accuracy = 0.776172 (213025/274456), RMSE = 0.473105
# Accuracy = 0.776172 (213025/274456), RMSE = 0.473105
# Accuracy = 0.776172 (213025/274456), RMSE = 0.473105
# k2014-mooc
# Accuracy = 0.804369 (273651/340206), RMSE = 0.442302
# Accuracy = 0.804615 (273735/340206), RMSE = 0.442023
# Accuracy = 0.804615 (273735/340206), RMSE = 0.442023
# Accuracy = 0.804615 (273735/340206), RMSE = 0.442023
 
#
# PFA prep data
./code/modelPFA_prep.sh
./code/modelPFA_fit.sh
s2014-ohpe
# Accuracy = 0.821099 (87975/107143), RMSE = 0.422967
# Accuracy = 0.799828 (85696/107143), RMSE = 0.447406
# Accuracy = 0.799828 (85696/107143), RMSE = 0.447406
# Accuracy = 0.799828 (85696/107143), RMSE = 0.447406
# s2015-ohpe
# Accuracy = 0.814766 (75440/92591), RMSE = 0.430388
# Accuracy = 0.783381 (72534/92591), RMSE = 0.465424
# Accuracy = 0.783381 (72534/92591), RMSE = 0.465424
# Accuracy = 0.783381 (72534/92591), RMSE = 0.465424
# k2015-mooc
# Accuracy = 0.805973 (221204/274456), RMSE = 0.440485
# Accuracy = 0.776172 (213025/274456), RMSE = 0.473105
# Accuracy = 0.776172 (213025/274456), RMSE = 0.473105
# Accuracy = 0.776172 (213025/274456), RMSE = 0.473105
# k2014-mooc
# Accuracy = 0.820106 (279005/340206), RMSE = 0.424139
# Accuracy = 0.804615 (273735/340206), RMSE = 0.442023
# Accuracy = 0.804615 (273735/340206), RMSE = 0.442023
# Accuracy = 0.804615 (273735/340206), RMSE = 0.442023


#
# AFM prep data - wp - skills Within Problems
./code/modelAFMwp_prep.sh
./code/modelAFMwp_fit.sh
# s2014-ohpe
# Accuracy = 0.885275 (94851/107143), RMSE = 0.338711
# Accuracy = 0.799828 (85696/107143), RMSE = 0.447406
# Accuracy = 0.799828 (85696/107143), RMSE = 0.447406
# Accuracy = 0.799828 (85696/107143), RMSE = 0.447406
# s2015-ohpe
# Accuracy = 0.890799 (82480/92591), RMSE = 0.330455
# Accuracy = 0.783381 (72534/92591), RMSE = 0.465424
# Accuracy = 0.783381 (72534/92591), RMSE = 0.465424
# Accuracy = 0.783381 (72534/92591), RMSE = 0.465424
# k2015-mooc
# Accuracy = 0.883173 (242392/274456), RMSE = 0.341800
# Accuracy = 0.776172 (213025/274456), RMSE = 0.473105
# Accuracy = 0.776172 (213025/274456), RMSE = 0.473105
# Accuracy = 0.776172 (213025/274456), RMSE = 0.473105
# k2014-mooc
# Accuracy = 0.870026 (295988/340206), RMSE = 0.360519
# Accuracy = 0.804615 (273735/340206), RMSE = 0.442023
# Accuracy = 0.804615 (273735/340206), RMSE = 0.442023
# Accuracy = 0.804615 (273735/340206), RMSE = 0.442023


#
# PFA prep data - wp - skills Within Problems
./code/modelPFAwp_prep.sh
./code/modelPFAwp_fit.sh
# s2014-ohpe
# Accuracy = 0.895681 (95966/107143), RMSE = 0.322984
# Accuracy = 0.799828 (85696/107143), RMSE = 0.447406
# Accuracy = 0.799828 (85696/107143), RMSE = 0.447406
# Accuracy = 0.799828 (85696/107143), RMSE = 0.447406
# s2015-ohpe
# Accuracy = 0.905401 (83832/92591), RMSE = 0.307569
# Accuracy = 0.783381 (72534/92591), RMSE = 0.465424
# Accuracy = 0.783381 (72534/92591), RMSE = 0.465424
# Accuracy = 0.783381 (72534/92591), RMSE = 0.465424
# k2015-mooc
# Accuracy = 0.893608 (245256/274456), RMSE = 0.326178
# Accuracy = 0.776172 (213025/274456), RMSE = 0.473105
# Accuracy = 0.776172 (213025/274456), RMSE = 0.473105
# Accuracy = 0.776172 (213025/274456), RMSE = 0.473105
# k2014-mooc
# Accuracy = 0.874823 (297620/340206), RMSE = 0.353804
# Accuracy = 0.804615 (273735/340206), RMSE = 0.442023
# Accuracy = 0.804615 (273735/340206), RMSE = 0.442023
# Accuracy = 0.804615 (273735/340206), RMSE = 0.442023
# 

# tar lldata and delete folders
declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")
for dataset in ${datasets[@]}
do
    tar -cvjf ./data/${dataset}_liblineardata.tar.bz ./data/${dataset}_liblineardata/
    rm -rf ./data/${dataset}_liblineardata/
done

    
#
# Lump all four datasets and create ABCD splits and vocabularies
#    
declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")
rm -rf ./data/ALL_allsubmit.txt
for dataset in ${datasets[@]}
do
    cat ./data/${dataset}_allsubmit.txt >> ./data/ALL_allsubmit.txt
done
wc -l ./data/ALL_allsubmit.txt
# 814396 ./data/ALL_allsubmit.txt
rm -rf ./data/ALL_voc
mkdir ./data/ALL_voc
export vocstu=./data/ALL_voc/ALL_allsubmit_voc_student.txt
export vocite=./data/ALL_voc/ALL_allsubmit_voc_item.txt
awk -F";" -f ./code/all2studitemvoc.awk ./data/ALL_allsubmit.txt
wc -l ./data/ALL_voc/ALL_allsubmit_voc_student.txt
wc -l ./data/ALL_voc/ALL_allsubmit_voc_item.txt
# 1788 ./data/ALL_voc/ALL_allsubmit_voc_student.txt
# 241 ./data/ALL_voc/ALL_allsubmit_voc_item.txt

export vocski=./data/ALL_voc/ALL_allsubmit_voc_skill
awk -F";" -f ./code/all2skillvoc.awk ./data/ALL_allsubmitABCD.txt
wc -l ./data/ALL_voc/ALL_allsubmit_voc_skillA.txt
wc -l ./data/ALL_voc/ALL_allsubmit_voc_skillB.txt
wc -l ./data/ALL_voc/ALL_allsubmit_voc_skillC.txt
wc -l ./data/ALL_voc/ALL_allsubmit_voc_skillD.txt
# 155 ./data/ALL_voc/ALL_allsubmit_voc_skillA.txt
# 155 ./data/ALL_voc/ALL_allsubmit_voc_skillB.txt
# 309 ./data/ALL_voc/ALL_allsubmit_voc_skillC.txt
# 327 ./data/ALL_voc/ALL_allsubmit_voc_skillD.txt

# IRT ALL
# Accuracy = 0.842753 (686335/814396), RMSE = 0.396543

# AFM ALL
# Accuracy = 0.789105 (642644/814396), RMSE = 0.459233
# Accuracy = 0.791641 (644709/814396), RMSE = 0.456464
# Accuracy = 0.791641 (644709/814396), RMSE = 0.456464
# Accuracy = 0.791641 (644709/814396), RMSE = 0.456464

# PFA ALL
# Accuracy = 0.810969 (660450/814396), RMSE = 0.434777
# Accuracy = 0.791641 (644709/814396), RMSE = 0.456464
# Accuracy = 0.791641 (644709/814396), RMSE = 0.456464
# Accuracy = 0.791641 (644709/814396), RMSE = 0.456464

# AFMwp ALL
# Accuracy = 0.871528 (709769/814396), RMSE = 0.358430
# Accuracy = 0.791641 (644709/814396), RMSE = 0.456464
# Accuracy = 0.791641 (644709/814396), RMSE = 0.456464
# Accuracy = 0.791641 (644709/814396), RMSE = 0.456464

# PFAwp ALL
# Accuracy = 0.880665 (717210/814396), RMSE = 0.345449
# Accuracy = 0.791641 (644709/814396), RMSE = 0.456464
# Accuracy = 0.791641 (644709/814396), RMSE = 0.456464
# Accuracy = 0.791641 (644709/814396), RMSE = 0.456464

# tar lldata and delete folders
declare -a datasets=("ALL")
for dataset in ${datasets[@]}
do
    tar -cvjf ./data/${dataset}_liblineardata.tar.bz ./data/${dataset}_liblineardata/
    rm -rf ./data/${dataset}_liblineardata/
done


# how many students have background data
awk -F"\t|;" 'BEGIN{fn=0;}{if(FNR==1)fn++; if(fn==1 && (FNR>1)) G[$1]++; if(fn==2 && $2 in G){ N++; DG[$2]++; if(DG[$2]==1) NG++; } }END{print "Students matching bg data "NG" have "N" rows";}' ./data/backgrounds-encoded.tsv ./data/ALL_allsubmitABCD.txt
# Students matching bg data 798 have 409102 rows
wc -l ./data/ALL_allsubmitABCD.txt
# 814396 ./data/ALL_allsubmitABCD.txt
wc -l ./data/backgrounds-encoded.tsv
# 1006 ./data/backgrounds-encoded.tsv
# 409102/814396 = 0.50 data
# 798/1005 = 0.79 of users with BG data
# 798/1788 = 0.45 of users in the data

#
# subset to BG users, be sure to only add the first course of a student
#

# get {student, {course ids}}
awk -F";" '{C[$3]++;}END{for(c in C) print c,C[c];}' ./data/ALL_allsubmitABCD.txt
# k2014-mooc        340206 1<-- temporal order, Autumn - Syksy, Spring - Kevät
# hy-s2015-ohpe      92591 4
# k2015-ohjelmointi 274456 3
# s2014-ohpe        107143 2

gawk -F";" 'BEGIN{ OFS="\t"; M["k2014-mooc"]=1; M["s2014-ohpe"]=2; M["k2015-ohjelmointi"]=3; M["hy-s2015-ohpe"]=4; }
{GC[$2][$3]++;}
END{
	for(g in GC){ 
		rchosen=5;
		cchosen="";
		all = ""
		for(c in GC[g]){
			all = all""c",";
			r = M[c];
			if(r<rchosen) {
				rchosen = r;
				cchosen = c;
			}
		} 
		print g,all,cchosen;
	} 
}' ./data/ALL_allsubmitABCD.txt > ./data/student_courses_earliestCourse.txt
wc -l ./data/student_courses_earliestCourse.txt
# 1788

awk -F"\t|;" 'BEGIN{fn=0;}{
	if(FNR==1)fn++; 
	if(fn==1 && (FNR>1)) G[$1]++;
	if(fn==2) GC[$1]=$3;
	if(fn==3 && ($2 in G) && ($2 in GC) && (GC[$2]==$3)){ print $0; } 
}' ./data/backgrounds-encoded.tsv ./data/student_courses_earliestCourse.txt ./data/ALL_allsubmitABCD.txt > ./data/ALLBG_allsubmitABCD.txt
wc -l ./data/ALLBG_allsubmitABCD.txt
# 391801 - checked
tar -cvjf ./data/ALLBG_allsubmitABCD.tar.bz ./data/ALLBG_allsubmitABCD.txt

rm -rf ./data/ALLBG_voc
mkdir ./data/ALLBG_voc
export vocstu=./data/ALLBG_voc/ALLBG_allsubmit_voc_student.txt
export vocite=./data/ALLBG_voc/ALLBG_allsubmit_voc_item.txt
awk -F";" -f ./code/all2studitemvoc.awk ./data/ALLBG_allsubmitABCD.txt
wc -l ./data/ALLBG_voc/ALLBG_allsubmit_voc_student.txt
wc -l ./data/ALLBG_voc/ALLBG_allsubmit_voc_item.txt
# 798 ./data/ALLBG_voc/ALLBG_allsubmit_voc_student.txt
# 240 ./data/ALLBG_voc/ALLBG_allsubmit_voc_item.txt

export vocski=./data/ALLBG_voc/ALLBG_allsubmit_voc_skill
awk -F";" -f ./code/all2skillvoc.awk ./data/ALLBG_allsubmitABCD.txt
wc -l ./data/ALLBG_voc/ALLBG_allsubmit_voc_skillA.txt
wc -l ./data/ALLBG_voc/ALLBG_allsubmit_voc_skillB.txt
wc -l ./data/ALLBG_voc/ALLBG_allsubmit_voc_skillC.txt
wc -l ./data/ALLBG_voc/ALLBG_allsubmit_voc_skillD.txt
# 143 ./data/ALLBG_voc/ALLBG_allsubmit_voc_skillA.txt
# 143 ./data/ALLBG_voc/ALLBG_allsubmit_voc_skillB.txt
# 284 ./data/ALLBG_voc/ALLBG_allsubmit_voc_skillC.txt
# 302 ./data/ALLBG_voc/ALLBG_allsubmit_voc_skillD.txt
# remove BCD, actually
declare -a datasets=("ALLBG")
declare -a ABCD=("A")
declare -a ABCD_column=("17")
# IRT
# AFM WP A
# PFA WP A
# AFM WP N A
# PFA WP N A
# AFM WP logN A
# PFA WP logN A -- generate this data

# Actual number of concepts
declare -a datasets=("ALLBG")
declare -a ABCD=("A")
declare -a ABCD_column=("17")
export vocski=./data/ALLBG_voc/ALLBG_allsubmit_voc_skillByProb
awk -F";" -f ./code/all2skillvoc_byProb.awk ./data/ALLBG_allsubmitABCD.txt



tar -cvjf data/ALLBG_liblineardata.tar.bz data/ALLBG_liblineardata/

#
# generate random clusters, one value per row of data, but here generate for students
#

# test randomness
awk -v seed=$RANDOM 'BEGIN {srand(seed); for(i=1;i<=10;i++) { a=rand(); print a,((a>=0.5)?1:0)} exit; }'

# per data row
# awk -F"\t|;" -v seed=$RANDOM 'BEGIN {srand(seed); fn=0;}{
# 	if(FNR==1) fn++;
# 	if(fn==1) {
# 		a = rand();
# 		G[$1] = ((a>=2/3)?3:((a<1/3)?1:2));
# 	}
# 	if(fn==2) {
# 		print $1"\t"G[$2];
# 	}
# }' data/ALLBG_voc/ALLBG_allsubmit_voc_student.txt data/ALLBG_allsubmitABCD.txt > data/ALLBG_allsubmitABCD_clusterRowRand.txt
# wc -l data/ALLBG_allsubmitABCD_clusterRowRand.txt
# # 409102 data/ALLBG_allsubmitABCD_clusterRowRand.txt
# awk -F"\t" '{A[$2]++;}END{for(a in A) print a,A[a];}' data/ALLBG_allsubmitABCD_clusterRowRand.txt
# # 1 145535
# # 2 136859
# # 3 126708

# per student
awk -F"\t|;" -v seed=$RANDOM 'BEGIN {srand(seed);}{
	a = rand();
	c = ((a>=2/3)?3:((a<1/3)?1:2));
	print $1"\t"c;
}' data/ALLBG_voc/ALLBG_allsubmit_voc_student.txt > data/ALLBG_allsubmitABCD_clusterStuRand.txt
wc -l data/ALLBG_allsubmitABCD_clusterStuRand.txt
# 798 data/ALLBG_allsubmitABCD_clusterStuRand.txt
awk -F"\t" '{A[$2]++;}END{for(a in A) print a,A[a];}' data/ALLBG_allsubmitABCD_clusterStuRand.txt
# 1 278
# 2 265
# 3 255
 
# generate the design N validation rounds with F fit and T test instances of a cluster
Rscript ./code/cluster2Design.R data/ALLBG_allsubmitABCD_clusterStuRand.txt 20 80 20 data/ALLBG_allsubmitABCD_designStuRand.txt
# deploy the validation design into a temporary directory
rm -rf ./data/ALLBG_crossStuRand_r20f80t20/
mkdir ./data/ALLBG_crossStuRand_r20f80t20/
mkdir ./data/ALLBG_crossStuRand_r20f80t20/data/
mkdir ./data/ALLBG_crossStuRand_r20f80t20/model/
mkdir ./data/ALLBG_crossStuRand_r20f80t20/predict/
gawk -v runs=20 -v fname="ALLBG_crossStuRand_r20f80t20" -F"\t" -f ./code/implementDesignByStudent.awk data/ALLBG_allsubmitABCD_designStuRand.txt <(paste <(cut -d";" -f 2-2 data/ALLBG_allsubmitABCD.txt) data/ALLBG_liblineardata/ALLBG_allsubmit_llpfaAwpLN.txt)
chmod 755 ./data/ALLBG_crossStuRand_r20f80t20/make.sh
./data/ALLBG_crossStuRand_r20f80t20/make.sh
tar -cvjf ./data/ALLBG_crossStuRand_r20f80t20.tag.bz ./data/ALLBG_crossStuRand_r20f80t20/

#
# number of rows clusters
#
gawk -F";" '{G[$2]++;}END{for(g in G) print g"\t"G[g];}' data/ALLBG_allsubmitABCD.txt > data/ALLBG_student_nrows.txt
wc -l data/ALLBG_student_nrows.txt
# 798 data/ALLBG_student_nrows.txt
# process file in nrows_explore.R
# produce data/ALLBG_allsubmitABCD_clusterNRows.txt
wc -l data/ALLBG_allsubmitABCD_clusterNRows.txt
tag=NRows
Rscript ./code/cluster2Design.R data/ALLBG_allsubmitABCD_cluster"${tag}".txt 20 80 20 data/ALLBG_allsubmitABCD_design"${tag}".txt
# deploy the validation design into a temporary directory
rm -rf ./data/ALLBG_cross"${tag}"_r20f80t20/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/data/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/model/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/predict/
gawk -v runs=20 -v fname="ALLBG_cross"${tag}"_r20f80t20" -F"\t" -f ./code/implementDesignByStudent.awk data/ALLBG_allsubmitABCD_design"${tag}".txt <(paste <(cut -d";" -f 2-2 data/ALLBG_allsubmitABCD.txt) data/ALLBG_liblineardata/ALLBG_allsubmit_llpfaAwpLN.txt)
chmod 755 ./data/ALLBG_cross"${tag}"_r20f80t20/make.sh
./data/ALLBG_cross"${tag}"_r20f80t20/make.sh
tar -cvjf ./data/ALLBG_cross"${tag}"_r20f80t20.tag.bz ./data/ALLBG_cross"${tag}"_r20f80t20/




#
# gender clusters
#
awk -F"\t|;" 'BEGIN {fn=0;}{
	if(FNR==1) fn++;
	if(fn==1) if(FNR>1) G[$1]=2-($6=="Male");
	if(fn==2) print $1"\t"G[$1];
}' data/backgrounds-encoded.tsv data/ALLBG_voc/ALLBG_allsubmit_voc_student.txt > data/ALLBG_allsubmitABCD_clusterGen.txt
wc -l data/ALLBG_allsubmitABCD_clusterGen.txt

# cluster file
awk -F"\t|;" 'BEGIN {fn=0;}{
	if(FNR==1) fn++;
	if(fn==1) if(FNR>1) G[$1]=2-($6=="Male");
	if(fn==2) print $1"\t"G[$1];
}' data/backgrounds-encoded.tsv data/ALLBG_voc/ALLBG_allsubmit_voc_student.txt > data/ALLBG_allsubmitABCD_clusterGen.txt
wc -l data/ALLBG_allsubmitABCD_clusterGen.txt
# 798 data/ALLBG_allsubmitABCD_clusterGen.txt
awk -F"\t" '{A[$2]++;}END{for(a in A) print a,A[a];}' data/ALLBG_allsubmitABCD_clusterGen.txt
# 1 570 - male
# 2 228
# generate the design N validation rounds with F fit and T test instances of a cluster
Rscript ./code/cluster2Design.R data/ALLBG_allsubmitABCD_clusterGen.txt 20 80 20 data/ALLBG_allsubmitABCD_designGen.txt
# deploy the validation design into a temporary directory
rm -rf ./data/ALLBG_crossGen_r20f80t20/
mkdir ./data/ALLBG_crossGen_r20f80t20/
mkdir ./data/ALLBG_crossGen_r20f80t20/data/
mkdir ./data/ALLBG_crossGen_r20f80t20/model/
mkdir ./data/ALLBG_crossGen_r20f80t20/predict/
gawk -v runs=20 -v fname="ALLBG_crossGen_r20f80t20" -F"\t" -f ./code/implementDesignByStudent.awk data/ALLBG_allsubmitABCD_designGen.txt <(paste <(cut -d";" -f 2-2 data/ALLBG_allsubmitABCD.txt) data/ALLBG_liblineardata/ALLBG_allsubmit_llpfaAwpLN.txt)
chmod 755 ./data/ALLBG_crossGen_r20f80t20/make.sh
./data/ALLBG_crossGen_r20f80t20/make.sh
tar -cvjf ./data/ALLBG_crossGen_r20f80t20.tag.bz ./data/ALLBG_crossGen_r20f80t20/


#
# Education clusters
#

# cluster file
awk -F"\t|;" 'BEGIN {fn=0;}{
	if(FNR==1) fn++;
	if(fn==1) if(FNR>1) {
		G[$1] = 3
		if($2=="PrimaryEducation" || $2=="SecondaryEducation") G[$1]=1;
		if($2=="HigherEducationUnderCollege" || $2=="HigherEducationUnderGraduateStudies") G[$1]=2;
	}
	if(fn==2) print $1"\t"G[$1];
}' data/backgrounds-encoded.tsv data/ALLBG_voc/ALLBG_allsubmit_voc_student.txt > data/ALLBG_allsubmitABCD_clusterEduc.txt
wc -l data/ALLBG_allsubmitABCD_clusterEduc.txt
# 798 data/ALLBG_allsubmitABCD_clusterEduc.txt
awk -F"\t" '{A[$2]++;}END{for(a in A) print a,A[a];}' data/ALLBG_allsubmitABCD_clusterEduc.txt
# 1 524
# 2 154
# 3 120
# Educerate the design N validation rounds with F fit and T test instances of a cluster
Rscript ./code/cluster2Design.R data/ALLBG_allsubmitABCD_clusterEduc.txt 20 80 20 data/ALLBG_allsubmitABCD_designEduc.txt
# deploy the validation design into a temporary directory
rm -rf ./data/ALLBG_crossEduc_r20f80t20/
mkdir ./data/ALLBG_crossEduc_r20f80t20/
mkdir ./data/ALLBG_crossEduc_r20f80t20/data/
mkdir ./data/ALLBG_crossEduc_r20f80t20/model/
mkdir ./data/ALLBG_crossEduc_r20f80t20/predict/
gawk -v runs=20 -v fname="ALLBG_crossEduc_r20f80t20" -F"\t" -f ./code/implementDesignByStudent.awk data/ALLBG_allsubmitABCD_designEduc.txt <(paste <(cut -d";" -f 2-2 data/ALLBG_allsubmitABCD.txt) data/ALLBG_liblineardata/ALLBG_allsubmit_llpfaAwpLN.txt)
chmod 755 ./data/ALLBG_crossEduc_r20f80t20/make.sh
./data/ALLBG_crossEduc_r20f80t20/make.sh
tar -cvjf ./data/ALLBG_crossEduc_r20f80t20.tag.bz ./data/ALLBG_crossEduc_r20f80t20/


#
# Completion clusters
#

# max ratio of tests passed per problem: 0, (0, 1), 1
gawk -F";" '{
	if(maxGP[$2][$4]=="") maxGP[$2][$4]==0;
	if(minGP[$2][$4]=="") minGP[$2][$4]==0;
	if(maxGP[$2][$4] < $12 ) maxGP[$2][$4] = $12;
	if(minGP[$2][$4] > $12 ) minGP[$2][$4] = $12;
	W[$2]=$3;
}END{
	for(g in maxGP) {
		for(p in maxGP[g]){
			GP[g]["0"] += (maxGP[g][p]==0);
			GP[g]["01"] += (maxGP[g][p]>0 && maxGP[g][p]<1);
			GP[g]["1"] += (maxGP[g][p]==1);
		}
	}
	for(g in GP) print g"\t"W[g]"\t"GP[g]["0"]"\t"GP[g]["01"]"\t"GP[g]["1"];
}' data/ALLBG_allsubmitABCD.txt > data/ALLBG_student_problem_completion.txt
# handle in Excel, to get problems that were never attempted
# write an updated txt file and look at it in code/problem_completion_explore.R
# get data/ALLBG_allsubmitABCD_clusterPSolve.txt file
Rscript ./code/cluster2Design.R data/ALLBG_allsubmitABCD_clusterPSolve.txt 20 80 20 data/ALLBG_allsubmitABCD_designPSolve.txt
# deploy the validation design into a temporary directory
rm -rf ./data/ALLBG_crossPSolve_r20f80t20/
mkdir ./data/ALLBG_crossPSolve_r20f80t20/
mkdir ./data/ALLBG_crossPSolve_r20f80t20/data/
mkdir ./data/ALLBG_crossPSolve_r20f80t20/model/
mkdir ./data/ALLBG_crossPSolve_r20f80t20/predict/
gawk -v runs=20 -v fname="ALLBG_crossPSolve_r20f80t20" -F"\t" -f ./code/implementDesignByStudent.awk data/ALLBG_allsubmitABCD_designPSolve.txt <(paste <(cut -d";" -f 2-2 data/ALLBG_allsubmitABCD.txt) data/ALLBG_liblineardata/ALLBG_allsubmit_llpfaAwpLN.txt)
chmod 755 ./data/ALLBG_crossPSolve_r20f80t20/make.sh
./data/ALLBG_crossPSolve_r20f80t20/make.sh
tar -cvjf ./data/ALLBG_crossPSolve_r20f80t20.tag.bz ./data/ALLBG_crossPSolve_r20f80t20/


#
# Percent corrects
#
gawk -F";" '{if($12<0) $12=0; GP[$2][$4]+=$12; GPn[$2][$4]++;}END{
	for(g in GP) {
		for(p in GP[g]) {
			G[g] += GP[g][p]/GPn[g][p]
			Gn[g]++;
		}
	}
	for(g in G) {
		print g"\t"G[g]/Gn[g];
	}
}' data/ALLBG_allsubmitABCD.txt > data/ALLBG_student_avgProbCorrect.txt
# process file in submission_correctness_explore.R
# produce data/ALLBG_allsubmitABCD_clusterPCorr.txt
Rscript ./code/cluster2Design.R data/ALLBG_allsubmitABCD_clusterPCorr.txt 20 80 20 data/ALLBG_allsubmitABCD_designPCorr.txt
# deploy the validation design into a temporary directory
rm -rf ./data/ALLBG_crossPCorr_r20f80t20/
mkdir ./data/ALLBG_crossPCorr_r20f80t20/
mkdir ./data/ALLBG_crossPCorr_r20f80t20/data/
mkdir ./data/ALLBG_crossPCorr_r20f80t20/model/
mkdir ./data/ALLBG_crossPCorr_r20f80t20/predict/
gawk -v runs=20 -v fname="ALLBG_crossPCorr_r20f80t20" -F"\t" -f ./code/implementDesignByStudent.awk data/ALLBG_allsubmitABCD_designPCorr.txt <(paste <(cut -d";" -f 2-2 data/ALLBG_allsubmitABCD.txt) data/ALLBG_liblineardata/ALLBG_allsubmit_llpfaAwpLN.txt)
chmod 755 ./data/ALLBG_crossPCorr_r20f80t20/make.sh
./data/ALLBG_crossPCorr_r20f80t20/make.sh
tar -cvjf ./data/ALLBG_crossPCorr_r20f80t20.tag.bz ./data/ALLBG_crossPCorr_r20f80t20/


#
# Roya's 2 Hierarchical Clusters with Cosine Similarity
#
tag=Hier2Cos
Rscript ./code/cluster2Design.R data/ALLBG_allsubmitABCD_cluster"${tag}".txt 20 80 20 data/ALLBG_allsubmitABCD_design"${tag}".txt
# deploy the validation design into a temporary directory
rm -rf ./data/ALLBG_cross"${tag}"_r20f80t20/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/data/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/model/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/predict/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/result/
gawk -v runs=20 -v fname="ALLBG_cross"${tag}"_r20f80t20" -F"\t" -f ./code/implementDesignByStudent.awk data/ALLBG_allsubmitABCD_design"${tag}".txt <(paste <(cut -d";" -f 2-2 data/ALLBG_allsubmitABCD.txt) data/ALLBG_liblineardata/ALLBG_allsubmit_llpfaAwpLN.txt)
chmod 755 ./data/ALLBG_cross"${tag}"_r20f80t20/make.sh
./data/ALLBG_cross"${tag}"_r20f80t20/make.sh
perl -00 -077 -p -e 's/^\..+$//g' ./data/ALLBG_cross"${tag}"_r20f80t20/result/tmp.txt | perl -00 -077 -p -e 's/\n+/\n/g'  | awk -F" " '{print $3"\t"$7;}' > ./data/ALLBG_cross"${tag}"_r20f80t20/result/ALLBG_cross"${tag}".txt
tar -cvjf ./data/ALLBG_cross"${tag}"_r20f80t20.tag.bz ./data/ALLBG_cross"${tag}"_r20f80t20/


#
# Roya's 3 Hierarchical Clusters with Cosine Similarity
#
tag=Hier3Cos
Rscript ./code/cluster2Design.R data/ALLBG_allsubmitABCD_cluster"${tag}".txt 20 80 20 data/ALLBG_allsubmitABCD_design"${tag}".txt
# deploy the validation design into a temporary directory
rm -rf ./data/ALLBG_cross"${tag}"_r20f80t20/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/data/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/model/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/predict/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/result/
gawk -v runs=20 -v fname="ALLBG_cross"${tag}"_r20f80t20" -F"\t" -f ./code/implementDesignByStudent.awk data/ALLBG_allsubmitABCD_design"${tag}".txt <(paste <(cut -d";" -f 2-2 data/ALLBG_allsubmitABCD.txt) data/ALLBG_liblineardata/ALLBG_allsubmit_llpfaAwpLN.txt)
chmod 755 ./data/ALLBG_cross"${tag}"_r20f80t20/make.sh
./data/ALLBG_cross"${tag}"_r20f80t20/make.sh
perl -00 -077 -p -e 's/^\..+$//g' ./data/ALLBG_cross"${tag}"_r20f80t20/result/tmp.txt | perl -00 -077 -p -e 's/\n+/\n/g'  | awk -F" " '{print $3"\t"$7;}' > ./data/ALLBG_cross"${tag}"_r20f80t20/result/ALLBG_cross"${tag}".txt
tar -cvjf ./data/ALLBG_cross"${tag}"_r20f80t20.tag.bz ./data/ALLBG_cross"${tag}"_r20f80t20/


#
# Roya's 4 Hierarchical Clusters with Cosine Similarity
#
tag=Hier4Cos
Rscript ./code/cluster2Design.R data/ALLBG_allsubmitABCD_cluster"${tag}".txt 20 80 20 data/ALLBG_allsubmitABCD_design"${tag}".txt
# deploy the validation design into a temporary directory
rm -rf ./data/ALLBG_cross"${tag}"_r20f80t20/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/data/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/model/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/predict/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/result/
gawk -v runs=20 -v fname="ALLBG_cross"${tag}"_r20f80t20" -F"\t" -f ./code/implementDesignByStudent.awk data/ALLBG_allsubmitABCD_design"${tag}".txt <(paste <(cut -d";" -f 2-2 data/ALLBG_allsubmitABCD.txt) data/ALLBG_liblineardata/ALLBG_allsubmit_llpfaAwpLN.txt)
chmod 755 ./data/ALLBG_cross"${tag}"_r20f80t20/make.sh
./data/ALLBG_cross"${tag}"_r20f80t20/make.sh
perl -00 -077 -p -e 's/^\..+$//g' ./data/ALLBG_cross"${tag}"_r20f80t20/result/tmp.txt | perl -00 -077 -p -e 's/\n+/\n/g'  | awk -F" " '{print $3"\t"$7;}' > ./data/ALLBG_cross"${tag}"_r20f80t20/result/ALLBG_cross"${tag}".txt
tar -cvjf ./data/ALLBG_cross"${tag}"_r20f80t20.tag.bz ./data/ALLBG_cross"${tag}"_r20f80t20/


#
# Hier Cos Prev Snap 2
#
tag=CosPrevSnap2
Rscript ./code/cluster2Design.R data/ALLBG_allsubmitABCD_cluster"${tag}".txt 20 80 20 data/ALLBG_allsubmitABCD_design"${tag}".txt
# deploy the validation design into a temporary directory
rm -rf ./data/ALLBG_cross"${tag}"_r20f80t20/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/data/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/model/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/predict/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/result/
gawk -v runs=20 -v fname="ALLBG_cross"${tag}"_r20f80t20" -F"\t" -f ./code/implementDesignByStudent.awk data/ALLBG_allsubmitABCD_design"${tag}".txt <(paste <(cut -d";" -f 2-2 data/ALLBG_allsubmitABCD.txt) data/ALLBG_liblineardata/ALLBG_allsubmit_llpfaAwpLN.txt)
chmod 755 ./data/ALLBG_cross"${tag}"_r20f80t20/make.sh
./data/ALLBG_cross"${tag}"_r20f80t20/make.sh
perl -00 -077 -p -e 's/^\..+$//g' ./data/ALLBG_cross"${tag}"_r20f80t20/result/tmp.txt | perl -00 -077 -p -e 's/\n+/\n/g'  | awk -F" " '{print $3"\t"$7;}' > ./data/ALLBG_cross"${tag}"_r20f80t20/result/ALLBG_cross"${tag}".txt
tar -cvjf ./data/ALLBG_cross"${tag}"_r20f80t20.tag.bz ./data/ALLBG_cross"${tag}"_r20f80t20/


#
# Hier Cos Prev Snap Time 2
#
tag=CosPrevSnapTime2
Rscript ./code/cluster2Design.R data/ALLBG_allsubmitABCD_cluster"${tag}".txt 20 80 20 data/ALLBG_allsubmitABCD_design"${tag}".txt
# deploy the validation design into a temporary directory
rm -rf ./data/ALLBG_cross"${tag}"_r20f80t20/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/data/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/model/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/predict/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/result/
gawk -v runs=20 -v fname="ALLBG_cross"${tag}"_r20f80t20" -F"\t" -f ./code/implementDesignByStudent.awk data/ALLBG_allsubmitABCD_design"${tag}".txt <(paste <(cut -d";" -f 2-2 data/ALLBG_allsubmitABCD.txt) data/ALLBG_liblineardata/ALLBG_allsubmit_llpfaAwpLN.txt)
chmod 755 ./data/ALLBG_cross"${tag}"_r20f80t20/make.sh
./data/ALLBG_cross"${tag}"_r20f80t20/make.sh
perl -00 -077 -p -e 's/^\..+$//g' ./data/ALLBG_cross"${tag}"_r20f80t20/result/tmp.txt | perl -00 -077 -p -e 's/\n+/\n/g'  | awk -F" " '{print $3"\t"$7;}' > ./data/ALLBG_cross"${tag}"_r20f80t20/result/ALLBG_cross"${tag}".txt
tar -cvjf ./data/ALLBG_cross"${tag}"_r20f80t20.tag.bz ./data/ALLBG_cross"${tag}"_r20f80t20/


#
# Hier Cos Prev Snap Time 3 -- ABANDON
#
tag=CosPrevSnapTime3
Rscript ./code/cluster2Design.R data/ALLBG_allsubmitABCD_cluster"${tag}".txt 20 80 20 data/ALLBG_allsubmitABCD_design"${tag}".txt
# deploy the validation design into a temporary directory
rm -rf ./data/ALLBG_cross"${tag}"_r20f80t20/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/data/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/model/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/predict/
gawk -v runs=20 -v fname="ALLBG_cross"${tag}"_r20f80t20" -F"\t" -f ./code/implementDesignByStudent.awk data/ALLBG_allsubmitABCD_design"${tag}".txt <(paste <(cut -d";" -f 2-2 data/ALLBG_allsubmitABCD.txt) data/ALLBG_liblineardata/ALLBG_allsubmit_llpfaAwpLN.txt)
chmod 755 ./data/ALLBG_cross"${tag}"_r20f80t20/make.sh
./data/ALLBG_cross"${tag}"_r20f80t20/make.sh
tar -cvjf ./data/ALLBG_cross"${tag}"_r20f80t20.tag.bz ./data/ALLBG_cross"${tag}"_r20f80t20/


#
# Hier Cos Prev Snap Time 4 -- ABANDON
#
tag=CosPrevSnapTime4
Rscript ./code/cluster2Design.R data/ALLBG_allsubmitABCD_cluster"${tag}".txt 20 80 20 data/ALLBG_allsubmitABCD_design"${tag}".txt
# deploy the validation design into a temporary directory
rm -rf ./data/ALLBG_cross"${tag}"_r20f80t20/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/data/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/model/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/predict/
gawk -v runs=20 -v fname="ALLBG_cross"${tag}"_r20f80t20" -F"\t" -f ./code/implementDesignByStudent.awk data/ALLBG_allsubmitABCD_design"${tag}".txt <(paste <(cut -d";" -f 2-2 data/ALLBG_allsubmitABCD.txt) data/ALLBG_liblineardata/ALLBG_allsubmit_llpfaAwpLN.txt)
chmod 755 ./data/ALLBG_cross"${tag}"_r20f80t20/make.sh
./data/ALLBG_cross"${tag}"_r20f80t20/make.sh
tar -cvjf ./data/ALLBG_cross"${tag}"_r20f80t20.tag.bz ./data/ALLBG_cross"${tag}"_r20f80t20/


#
# Hier Cos Prev Snap Time 2 support 1%
#
tag=CosPrevSnapTime2Sup1
Rscript ./code/cluster2Design.R data/ALLBG_allsubmitABCD_cluster"${tag}".txt 20 80 20 data/ALLBG_allsubmitABCD_design"${tag}".txt
# deploy the validation design into a temporary directory
rm -rf ./data/ALLBG_cross"${tag}"_r20f80t20/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/data/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/model/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/predict/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/result/
gawk -v runs=20 -v fname="ALLBG_cross"${tag}"_r20f80t20" -F"\t" -f ./code/implementDesignByStudent.awk data/ALLBG_allsubmitABCD_design"${tag}".txt <(paste <(cut -d";" -f 2-2 data/ALLBG_allsubmitABCD.txt) data/ALLBG_liblineardata/ALLBG_allsubmit_llpfaAwpLN.txt)
chmod 755 ./data/ALLBG_cross"${tag}"_r20f80t20/make.sh
./data/ALLBG_cross"${tag}"_r20f80t20/make.sh
perl -00 -077 -p -e 's/^\..+$//g' ./data/ALLBG_cross"${tag}"_r20f80t20/result/tmp.txt | perl -00 -077 -p -e 's/\n+/\n/g'  | awk -F" " '{print $3"\t"$7;}' > ./data/ALLBG_cross"${tag}"_r20f80t20/result/ALLBG_cross"${tag}".txt
tar -cvjf ./data/ALLBG_cross"${tag}"_r20f80t20.tag.bz ./data/ALLBG_cross"${tag}"_r20f80t20/



#
# Hier Cos Prev Snap Time 3 support 1%
#
tag=CosPrevSnapTime3Sup1
Rscript ./code/cluster2Design.R data/ALLBG_allsubmitABCD_cluster"${tag}".txt 20 80 20 data/ALLBG_allsubmitABCD_design"${tag}".txt
# deploy the validation design into a temporary directory
rm -rf ./data/ALLBG_cross"${tag}"_r20f80t20/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/data/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/model/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/predict/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/result/
gawk -v runs=20 -v fname="ALLBG_cross"${tag}"_r20f80t20" -F"\t" -f ./code/implementDesignByStudent.awk data/ALLBG_allsubmitABCD_design"${tag}".txt <(paste <(cut -d";" -f 2-2 data/ALLBG_allsubmitABCD.txt) data/ALLBG_liblineardata/ALLBG_allsubmit_llpfaAwpLN.txt)
chmod 755 ./data/ALLBG_cross"${tag}"_r20f80t20/make.sh
./data/ALLBG_cross"${tag}"_r20f80t20/make.sh
perl -00 -077 -p -e 's/^\..+$//g' ./data/ALLBG_cross"${tag}"_r20f80t20/result/tmp.txt | perl -00 -077 -p -e 's/\n+/\n/g'  | awk -F" " '{print $3"\t"$7;}' > ./data/ALLBG_cross"${tag}"_r20f80t20/result/ALLBG_cross"${tag}".txt
tar -cvjf ./data/ALLBG_cross"${tag}"_r20f80t20.tag.bz ./data/ALLBG_cross"${tag}"_r20f80t20/
>>>

#
# Spectral Cos Prev Snap Time 2 support 1%
#
tag=SpecClustPrevSnapTime2Sup1
Rscript ./code/cluster2Design.R data/ALLBG_allsubmitABCD_cluster"${tag}".txt 20 80 20 data/ALLBG_allsubmitABCD_design"${tag}".txt
# deploy the validation design into a temporary directory
rm -rf ./data/ALLBG_cross"${tag}"_r20f80t20/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/data/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/model/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/predict/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/result/
gawk -v runs=20 -v fname="ALLBG_cross"${tag}"_r20f80t20" -F"\t" -f ./code/implementDesignByStudent.awk data/ALLBG_allsubmitABCD_design"${tag}".txt <(paste <(cut -d";" -f 2-2 data/ALLBG_allsubmitABCD.txt) data/ALLBG_liblineardata/ALLBG_allsubmit_llpfaAwpLN.txt)
chmod 755 ./data/ALLBG_cross"${tag}"_r20f80t20/make.sh
./data/ALLBG_cross"${tag}"_r20f80t20/make.sh
perl -00 -077 -p -e 's/^\..+$//g' ./data/ALLBG_cross"${tag}"_r20f80t20/result/tmp.txt | perl -00 -077 -p -e 's/\n+/\n/g'  | awk -F" " '{print $3"\t"$7;}' > ./data/ALLBG_cross"${tag}"_r20f80t20/result/ALLBG_cross"${tag}".txt
tar -cvjf ./data/ALLBG_cross"${tag}"_r20f80t20.tag.bz ./data/ALLBG_cross"${tag}"_r20f80t20/


#
# Spectral Cos Prev Snap Time 3 support 1%
#
tag=SpecClustPrevSnapTime3Sup1
Rscript ./code/cluster2Design.R data/ALLBG_allsubmitABCD_cluster"${tag}".txt 20 80 20 data/ALLBG_allsubmitABCD_design"${tag}".txt
# deploy the validation design into a temporary directory
rm -rf ./data/ALLBG_cross"${tag}"_r20f80t20/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/data/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/model/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/predict/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/result/
gawk -v runs=20 -v fname="ALLBG_cross"${tag}"_r20f80t20" -F"\t" -f ./code/implementDesignByStudent.awk data/ALLBG_allsubmitABCD_design"${tag}".txt <(paste <(cut -d";" -f 2-2 data/ALLBG_allsubmitABCD.txt) data/ALLBG_liblineardata/ALLBG_allsubmit_llpfaAwpLN.txt)
chmod 755 ./data/ALLBG_cross"${tag}"_r20f80t20/make.sh
./data/ALLBG_cross"${tag}"_r20f80t20/make.sh
perl -00 -077 -p -e 's/^\..+$//g' ./data/ALLBG_cross"${tag}"_r20f80t20/result/tmp.txt | perl -00 -077 -p -e 's/\n+/\n/g'  | awk -F" " '{print $3"\t"$7;}' > ./data/ALLBG_cross"${tag}"_r20f80t20/result/ALLBG_cross"${tag}".txt
tar -cvjf ./data/ALLBG_cross"${tag}"_r20f80t20.tag.bz ./data/ALLBG_cross"${tag}"_r20f80t20/


#
# Hier Cos Prev Snap Adaptive (Student) Time 2 support 1% -- TO REDO
# 
tag=CosPrevSnapAdaptTime2Sup1
Rscript ./code/cluster2Design.R data/ALLBG_allsubmitABCD_cluster"${tag}".txt 20 80 20 data/ALLBG_allsubmitABCD_design"${tag}".txt
# deploy the validation design into a temporary directory
rm -rf ./data/ALLBG_cross"${tag}"_r20f80t20/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/data/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/model/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/predict/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/result/
gawk -v runs=20 -v fname="ALLBG_cross"${tag}"_r20f80t20" -F"\t" -f ./code/implementDesignByStudent.awk data/ALLBG_allsubmitABCD_design"${tag}".txt <(paste <(cut -d";" -f 2-2 data/ALLBG_allsubmitABCD.txt) data/ALLBG_liblineardata/ALLBG_allsubmit_llpfaAwpLN.txt)
chmod 755 ./data/ALLBG_cross"${tag}"_r20f80t20/make.sh
./data/ALLBG_cross"${tag}"_r20f80t20/make.sh
perl -00 -077 -p -e 's/^\..+$//g' ./data/ALLBG_cross"${tag}"_r20f80t20/result/tmp.txt | perl -00 -077 -p -e 's/\n+/\n/g'  | awk -F" " '{print $3"\t"$7;}' > ./data/ALLBG_cross"${tag}"_r20f80t20/result/ALLBG_cross"${tag}".txt
tar -cvjf ./data/ALLBG_cross"${tag}"_r20f80t20.tag.bz ./data/ALLBG_cross"${tag}"_r20f80t20/



#
# Hier Cos Prev Snap Adaptive (Student) Time 3 support 1%
# 
tag=CosPrevSnapAdaptTime3Sup1
Rscript ./code/cluster2Design.R data/ALLBG_allsubmitABCD_cluster"${tag}".txt 20 80 20 data/ALLBG_allsubmitABCD_design"${tag}".txt
# deploy the validation design into a temporary directory
rm -rf ./data/ALLBG_cross"${tag}"_r20f80t20/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/data/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/model/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/predict/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/result/
gawk -v runs=20 -v fname="ALLBG_cross"${tag}"_r20f80t20" -F"\t" -f ./code/implementDesignByStudent.awk data/ALLBG_allsubmitABCD_design"${tag}".txt <(paste <(cut -d";" -f 2-2 data/ALLBG_allsubmitABCD.txt) data/ALLBG_liblineardata/ALLBG_allsubmit_llpfaAwpLN.txt)
chmod 755 ./data/ALLBG_cross"${tag}"_r20f80t20/make.sh
./data/ALLBG_cross"${tag}"_r20f80t20/make.sh
perl -00 -077 -p -e 's/^\..+$//g' ./data/ALLBG_cross"${tag}"_r20f80t20/result/tmp.txt | perl -00 -077 -p -e 's/\n+/\n/g'  | awk -F" " '{print $3"\t"$7;}' > ./data/ALLBG_cross"${tag}"_r20f80t20/result/ALLBG_cross"${tag}".txt
tar -cvjf ./data/ALLBG_cross"${tag}"_r20f80t20.tag.bz ./data/ALLBG_cross"${tag}"_r20f80t20/



#
# Spectral Prev Snap Adaptive (Student) Time 2 support 1% -- TO REDO
# 
tag=SpecPrevSnapAdaptTime2Sup1
Rscript ./code/cluster2Design.R data/ALLBG_allsubmitABCD_cluster"${tag}".txt 20 80 20 data/ALLBG_allsubmitABCD_design"${tag}".txt
# deploy the validation design into a temporary directory
rm -rf ./data/ALLBG_cross"${tag}"_r20f80t20/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/data/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/model/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/predict/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/result/
gawk -v runs=20 -v fname="ALLBG_cross"${tag}"_r20f80t20" -F"\t" -f ./code/implementDesignByStudent.awk data/ALLBG_allsubmitABCD_design"${tag}".txt <(paste <(cut -d";" -f 2-2 data/ALLBG_allsubmitABCD.txt) data/ALLBG_liblineardata/ALLBG_allsubmit_llpfaAwpLN.txt)
chmod 755 ./data/ALLBG_cross"${tag}"_r20f80t20/make.sh
./data/ALLBG_cross"${tag}"_r20f80t20/make.sh
perl -00 -077 -p -e 's/^\..+$//g' ./data/ALLBG_cross"${tag}"_r20f80t20/result/tmp.txt | perl -00 -077 -p -e 's/\n+/\n/g'  | awk -F" " '{print $3"\t"$7;}' > ./data/ALLBG_cross"${tag}"_r20f80t20/result/ALLBG_cross"${tag}".txt
tar -cvjf ./data/ALLBG_cross"${tag}"_r20f80t20.tag.bz ./data/ALLBG_cross"${tag}"_r20f80t20/



#
# Spectral Prev Snap Adaptive (Student) Time 3 support 1%
# 
tag=SpecPrevSnapAdaptTime3Sup1
Rscript ./code/cluster2Design.R data/ALLBG_allsubmitABCD_cluster"${tag}".txt 20 80 20 data/ALLBG_allsubmitABCD_design"${tag}".txt
# deploy the validation design into a temporary directory
rm -rf ./data/ALLBG_cross"${tag}"_r20f80t20/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/data/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/model/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/predict/
mkdir ./data/ALLBG_cross"${tag}"_r20f80t20/result/
gawk -v runs=20 -v fname="ALLBG_cross"${tag}"_r20f80t20" -F"\t" -f ./code/implementDesignByStudent.awk data/ALLBG_allsubmitABCD_design"${tag}".txt <(paste <(cut -d";" -f 2-2 data/ALLBG_allsubmitABCD.txt) data/ALLBG_liblineardata/ALLBG_allsubmit_llpfaAwpLN.txt)
chmod 755 ./data/ALLBG_cross"${tag}"_r20f80t20/make.sh
./data/ALLBG_cross"${tag}"_r20f80t20/make.sh
perl -00 -077 -p -e 's/^\..+$//g' ./data/ALLBG_cross"${tag}"_r20f80t20/result/tmp.txt | perl -00 -077 -p -e 's/\n+/\n/g'  | awk -F" " '{print $3"\t"$7;}' > ./data/ALLBG_cross"${tag}"_r20f80t20/result/ALLBG_cross"${tag}".txt
tar -cvjf ./data/ALLBG_cross"${tag}"_r20f80t20.tag.bz ./data/ALLBG_cross"${tag}"_r20f80t20/





#
# Model parameter stability
#

# Random clusters
dataset=ALLBG
declare -a tags=("StuRand" "Gen" "Educ" "NRows" "PSolve" "PCorr" "Hier2Cos" "Hier3Cos" "Hier4Cos" "CosPrevSnap2" "CosPrevSnapTime2" "CosPrevSnapTime2Sup1" "CosPrevSnapTime3Sup1" "SpecClustPrevSnapTime2Sup1" "SpecClustPrevSnapTime3Sup1" "CosPrevSnapAdaptTime2Sup1" "CosPrevSnapAdaptTime3Sup1" "SpecPrevSnapAdaptTime2Sup1" "SpecPrevSnapAdaptTime3Sup1")
declare -a clusters=("3" "2" "3" "3" "3" "3" "2" "3" "4" "2" "2" "2" "3" "2" "3" "2" "3" "2" "3")
NG=`wc -l <./data/${dataset}_voc/${dataset}_allsubmit_voc_student.txt`
NI=`wc -l <./data/${dataset}_voc/${dataset}_allsubmit_voc_item.txt`
NK=`wc -l <./data/${dataset}_voc/${dataset}_allsubmit_voc_skillA.txt`
# for i in {0..22} 
# do
# 	tar -xvjf ./data/ALLBG_cross"${tags[$i]}"_r20f80t20.tag.bz
# done
for i in {0..18} 
do
	folder=./data/ALLBG_cross"${tags[$i]}"_r20f80t20/model/
	nclusters=${clusters[$i]}
	fout=./result/ALLBG_cross"${tags[$i]}"_r20f80t20_clusterModelComparison.txt
	Rscript ./code/clusterModelCompare.R "${folder}" "${NG}" "${NI}" "${NK}" "${nclusters}" "${fout}"
done


# <<<Michael Finished Here>>> 

