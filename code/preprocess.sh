#!/bin/bash


#
#
# Preprocess
#
#

# Dependencies:
# - data/source/** - source data


#
# DECLARATION: array of dataset names, so far these are old
#
declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")


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

# 

