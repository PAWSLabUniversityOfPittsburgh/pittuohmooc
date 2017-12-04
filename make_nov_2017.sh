#!/bin/bash

#
#
# Top-level make file for the PittUoHMOOC project
#
#


#
# Sync data with a remote machine 
#

# refer to this script for notes on how to sync the data portion of the project
# ./code/sync.sh


#
# Preprocess data
#
./code/preprocess.sh
# OR, via batch command
./code/preprocess.sh >> temp/temp_preprocess.txt 2>&1
# Last ran 2017-12-01 11:40

#
# Behaviors markup
#
./code/behavior.sh




#
# Vocabularies and Concept Differences
#

# Create vocabularies of students, items, and concepts (various concept list types).
# Concept list types
# - A - all concepts in the snapshot
# - B - only new concepts in the snapshot
# - C - new concepts in the snapshot as well as deletions
# - D - all concepts in the snapshot as well as deletions
./code/vocab_concept.sh
# OR, via batch command
./code/vocab_concept.sh >> temp/temp_vocab_concept.txt 2>&1






# =====================================================================================
# below old unstructured stuff








#
# Concept filtering @Roya
# Instructions: To run the following scripts, the following files should be in the data folder:
# /data/${dataset}_allsubmitABCD.txt
# /data/${dataset}_problems.txt

# create /data/${dataset}_problems.txt files
declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")
for dataset in ${datasets[@]}
do
    awk -F";" '{A[$4]++;}END{for(a in A)print a;}' ./data/${dataset}_allsubmitABCD.txt > ./data/${dataset}_problems.txt
done # all datasets

# uncompress *_allsubmit_ABCD.txt
declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")
for dataset in ${datasets[@]}
do
    tar -xvjf ./data/${dataset}_allsubmitABCD.tar.bz
done # all datasets

# output files including log/error files will be generated in the data/fc folder. Reduced concepts will be in:
# ./data/fc/[DATASET]_problems/[PROBLEM]_[ABCD]_AvgT_AvgCs_FCT_lm.txt and ./data/fc/[DATASET]_problems/[PROBLEM]_[ABCD]_AvgT_AvgCs_FCT_rfe.txt
# see format.txt for the format of the files.

./code/conceptFilter_lm.sh
./code/conceptFilter_rfe.sh
# OR
sbatch -p RM -t 48:00:00 -N 1 --mem 4400MB ./code/conceptFilter_lm.job
sbatch -p RM -t 48:00:00 -N 1 --mem 4400MB ./code/conceptFilter_rfe.job
#
# OR 
# step 1
./code/conceptFilter_job_step1.sh 
# or
./code/conceptFilter_step1.sh
# copy _fc into _fc_lm and _fc_rfe
# step 2
sbatch -p RM -t 48:00:00 -N 1 --mem 4400MB ./code/conceptFilter_lm_job_step2.sh
sbatch -p RM -t 48:00:00 -N 1 --mem 4400MB ./code/conceptFilter_rfe_job_step2.sh
# or
sbatch -p RM -A tr4s85p -t 48:00:00 -N 1 --mem 4400MB ./code/conceptFilter_lm_job_step2.sh
sbatch -p RM -A tr4s85p -t 48:00:00 -N 1 --mem 4400MB ./code/conceptFilter_rfe_job_step2.sh
# or 
sbatch -p RM -A ca4s8ip -t 48:00:00 -N 1 --mem 4400MB ./code/conceptFilter_lm_job_step2.sh
sbatch -p RM -A ca4s8ip -t 48:00:00 -N 1 --mem 4400MB ./code/conceptFilter_rfe_job_step2.sh

# check _input.txt files for FC for negatives of the percent correct of tests after step 1
declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")
declare -a ABC=("A" "B" "C" "D")
rm -rf temp.txt
for dataset in ${datasets[@]} # for all datasets
do
    while read -r line || [[ -n $line ]]; 
    do # for al problem files, look at "done" line below to see that we are 
	    fname="./data/fc/${dataset}_problems/${line}_A_AvgT_AvgCs_FCT_input.txt" # problem file name in a dataset
        awk -F"\t" '{if($1 < 0){ print "'${dataset}'","'${line}'",$1; }}' $fname >> temp.txt
    done < ./data/${dataset}_problems.txt # this is where we are reading the problem list files line by line
done # all datasets

# lump all filterConcept results into 1 file
declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")
method="_lm"
rm -rf ./data/fc${method}_all.txt
for dataset in ${datasets[@]} # for all datasets
do
	find ./data/fc${method}/${dataset}_problems/ -type f -print | \
    while read -r line || [[ -n $line ]]; do # for al problem files, look at "done" line below to see that we are reading a *_problem.txt file line bby line
		echo -ne $line"\t" >> ./data/fc${method}_all.txt
		cat $line >> ./data/fc${method}_all.txt
    done 
done
# convert file path (first column) into dataset and problem name
perl -i -p -e 's/\.\/data\/fc_lm\///g' ./data/fc${method}_all.txt
perl -i -p -e 's/_problems\//\t/g' ./data/fc${method}_all.txt
perl -i -p -e 's/_A_AvgT_AvgCs_FCT_lm\.txt//g' ./data/fc${method}_all.txt
wc -l ./data/fc${method}_all.txt
# 433 -- CORRECT
declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")
method="_rfe"
rm -rf ./data/fc${method}_all.txt
for dataset in ${datasets[@]} # for all datasets
do
	find ./data/fc${method}/${dataset}_problems/ -type f -print | \
    while read -r line || [[ -n $line ]]; do # for al problem files, look at "done" line below to see that we are reading a *_problem.txt file line bby line
		echo -ne $line"\t" >> ./data/fc${method}_all.txt
		cat $line >> ./data/fc${method}_all.txt
    done 
done
# convert file path (first column) into dataset and problem name
perl -i -p -e 's/\.\/data\/fc_rfe\///g' ./data/fc${method}_all.txt
perl -i -p -e 's/_problems\//\t/g' ./data/fc${method}_all.txt
perl -i -p -e 's/_A_AvgT_AvgCs_FCT_rfe\.txt//g' ./data/fc${method}_all.txt
wc -l ./data/fc${method}_all.txt
# 433 -- CORRECT


#
# Modeling @Michael
#
#

#
# Maj class
declare -a datasets=("ALL")
for dataset in ${datasets[@]}
do
    fname=./data/${dataset}_allsubmit.txt
    awk -F";" '{N++; W+=($12!="1.0"); sse+=($12=="1.0")^2} END{print "All="N"  Wrong="W"  Acc="W/N"  RMSE="sqrt(sse/N)}' "${fname}"
done
# All=814396  Wrong=642549  Acc=0.788988  RMSE=0.45936

rm -rf ./data/ALL_voc
mkdir ./data/ALL_voc
export vocstu=./data/ALL_voc/ALL_allsubmit_voc_student.txt
export vocite=./data/ALL_voc/ALL_allsubmit_voc_item.txt
awk -F";" -f ./code/all2studitemvoc.awk ./data/ALL_allsubmit.txt
wc -l ./data/ALL_voc/ALL_allsubmit_voc_student.txt
wc -l ./data/ALL_voc/ALL_allsubmit_voc_item.txt
# 1788 ./data/ALL_voc/ALL_allsubmit_voc_student.txt
# 241 ./data/ALL_voc/ALL_allsubmit_voc_item.txt

# Add B, C, and D sets of concepts at the end
declare -a datasets=("ALL")
for dataset in ${datasets[@]}
do
    fin=./data/${dataset}_allsubmit.txt
    fout=./data/${dataset}_allsubmitABCD.txt
    fouttar=./data/${dataset}_allsubmitABCD.tar.bz
    awk -F";" -f ./code/dataAtoABCD.awk "${fin}" > "${fout}"
    tar -cvjf "${fouttar}" "${fout}"
done # all datasets
head -n 1 ./data/ALL_allsubmitABCD.txt | awk -F";" '{print NF;}'
# 64 -- as it should be, 21 base +8+8+24 = 61 + 3 <<< BCD = 64

# add A concepts filtered with "lm" and "rfe" method (columns 65 and 66)
awk -F"\t|;" 'BEGIN{fn=0;OFS=";"}{
	if(FNR==1) fn++;
	if(fn==1) {
		d=$1; # dataset
		p=$2; # problem
		for(i=4;i<=NF;i++) { # all concepts
			FClm[d"__"p"__"$(i)]++; # add dataset-probelm-filtered concept to the map
		}
	}
	if(fn==2) {
		d=$1; # dataset
		p=$2; # problem
		for(i=4;i<=NF;i++) { # all concepts
			FCrfe[d"__"p"__"$(i)]++; # add dataset-probelm-filtered concept to the map
		}
	}
	if(fn==3) {
		d=$3;
		p=$4;
		n=split($17,cc,","); # cc - concepts and counts
		cc_lm_new="";
		for(i=1;i<=n;i++) {
			split(cc[i],arcc,":");
			if(d"__"p"__"arcc[1] in FClm) {
				cc_lm_new=cc_lm_new""( (length(cc_lm_new)>0)?",":"" )""cc[i];
			}
		}
		cc_rfe_new="";
		for(i=1;i<=n;i++) {
			split(cc[i],arcc,":");
			if(d"__"p"__"arcc[1] in FCrfe) {
				cc_rfe_new=cc_rfe_new""( (length(cc_rfe_new)>0)?",":"" )""cc[i];
			}
		}
		print $0,cc_lm_new,cc_rfe_new;
	}
}' ./data/fc_lm_all.txt  ./data/fc_rfe_all.txt ./data/ALL_allsubmitABCD.txt > ./data/ALL_allsubmitABCDAlmArfe.txt
wc -l ./data/ALL_allsubmitABCDAlmArfe.txt
# 814396
tar -cvjf ./data/ALL_allsubmitABCDAlmArfe.tar.bz ./data/ALL_allsubmitABCDAlmArfe.txt



#
# operating on PSC, instead of ./data/... we specify /pylon2/{group}/{user}/{folder}/data/...
# where group = ca4s8ip, user = yudelson, folder = pittuohmooc
# for ease, we set prefix variable for data store
export prefix=/pylon2/ca4s8ip/yudelson/pittuohmooc
# for running, /pylon1 data root is used
export prefixR=/pylon1/ca4s8ip/yudelson/pittuohmooc

export vocski=./data/ALL_voc/ALL_allsubmit_voc_skill
awk -F";" -f ./code/all2skillvoc.awk ./data/ALL_allsubmitABCDAlmArfe.txt
wc -l ./data/ALL_voc/ALL_allsubmit_voc_skillA.txt
wc -l ./data/ALL_voc/ALL_allsubmit_voc_skillB.txt
wc -l ./data/ALL_voc/ALL_allsubmit_voc_skillC.txt
wc -l ./data/ALL_voc/ALL_allsubmit_voc_skillD.txt
wc -l ./data/ALL_voc/ALL_allsubmit_voc_skillAlm.txt
wc -l ./data/ALL_voc/ALL_allsubmit_voc_skillArfe.txt
# 155 ./data/ALL_voc/ALL_allsubmit_voc_skillA.txt
# 155 ./data/ALL_voc/ALL_allsubmit_voc_skillB.txt
# 309 ./data/ALL_voc/ALL_allsubmit_voc_skillC.txt
# 327 ./data/ALL_voc/ALL_allsubmit_voc_skillD.txt
# 141 ./data/ALL_voc/ALL_allsubmit_voc_skillAlm.txt
# 133 ./data/ALL_voc/ALL_allsubmit_voc_skillArfe.txt

# IRT ALL
./code/modelIRT_prep.sh >> temp_irt.txt 2>&1
./code/modelIRT_fit.sh >> temp_irt.txt 2>&1
# Accuracy = 0.842753 (686335/814396), RMSE = 0.396543


# For AFM and PFA, the following versions are done (2x3x6 = 36)
# - concepts global, concepts within problem (wp)
# - opportunities count, opportunities and their occurence (N), opportunities and log1p of their occurence (LN)
# - all skills (A), changed skills (B), changed with removals (C), all with removals (D), all sparsed by lm (Alm), all sparsed by rfe (Arfe)
# 36 AFM models, 36 PFA models = 72

# AFM
./code/modelAFM_prep_all_versions.sh >> temp.txt 2>&1
./code/modelAFM_fit_all_versions.sh >> temp.txt 2>&1
# AFM 
# Accuracy = 0.789286 (642791/814396), RMSE = 0.459036 # concepts A
# Accuracy = 0.816423 (664892/814396), RMSE = 0.428458 # concepts B
# Accuracy = 0.817208 (665531/814396), RMSE = 0.427542 # concepts C
# Accuracy = 0.787043 (640965/814396), RMSE = 0.461472 # concepts D
# Accuracy = 0.789815 (643222/814396), RMSE = 0.458460 # concepts A with lm concept filter
# Accuracy = 0.794287 (646864/814396), RMSE = 0.453556 # concepts A with rfe concept filter
# AFM N
# Accuracy = 0.789298 (642801/814396), RMSE = 0.459023 # concepts A
# Accuracy = 0.804124 (654875/814396), RMSE = 0.442579 # concepts B
# Accuracy = 0.794736 (647230/814396), RMSE = 0.453060 # concepts C
# Accuracy = 0.785117 (639396/814396), RMSE = 0.463555 # concepts D
# Accuracy = 0.789275 (642782/814396), RMSE = 0.459048 # concepts A with lm concept filter
# Accuracy = 0.788603 (642235/814396), RMSE = 0.459779 # concepts A with rfe concept filter
# AFM LN
# Accuracy = 0.832595 (678062/814396), RMSE = 0.409152 # concepts A
# Accuracy = 0.824375 (671368/814396), RMSE = 0.419076 # concepts B
# Accuracy = 0.824970 (671852/814396), RMSE = 0.418366 # concepts C
# Accuracy = 0.826109 (672780/814396), RMSE = 0.417002 # concepts D
# Accuracy = 0.812546 (661734/814396), RMSE = 0.432960 # concepts A with lm concept filter
# Accuracy = 0.810133 (659769/814396), RMSE = 0.435737 # concepts A with rfe concept filter
# AFM wp 
# Accuracy = 0.870271 (708745/814396), RMSE = 0.360179 # concepts A
# Accuracy = 0.857180 (698084/814396), RMSE = 0.377915 # concepts B
# Accuracy = 0.860996 (701192/814396), RMSE = 0.372832 # concepts C
# Accuracy = 0.795965 (648231/814396), RMSE = 0.451702 # concepts D
# Accuracy = 0.819508 (667404/814396), RMSE = 0.424844 # concepts A with lm concept filter
# Accuracy = 0.823624 (670756/814396), RMSE = 0.419972 # concepts A with rfe concept filter
# AFM wp N
# Accuracy = 0.803176 (654103/814396), RMSE = 0.443649 # concepts A
# Accuracy = 0.832045 (677614/814396), RMSE = 0.409823 # concepts B
# Accuracy = 0.832045 (677614/814396), RMSE = 0.409823 # concepts C
# Accuracy = 0.796761 (648879/814396), RMSE = 0.450820 # concepts D
# Accuracy = 0.790296 (643614/814396), RMSE = 0.457934 # concepts A with lm concept filter
# Accuracy = 0.805393 (655909/814396), RMSE = 0.441143 # concepts A with rfe concept filter
# AFM wp LN
# Accuracy = 0.899469 (732524/814396), RMSE = 0.317066 # concepts A
# Accuracy = 0.860317 (700639/814396), RMSE = 0.373741 # concepts B
# Accuracy = 0.862348 (702293/814396), RMSE = 0.371014 # concepts C
# Accuracy = 0.883031 (719137/814396), RMSE = 0.342007 # concepts D
# Accuracy = 0.836998 (681648/814396), RMSE = 0.403735 # concepts A with lm concept filter
# Accuracy = 0.836830 (681511/814396), RMSE = 0.403943 # concepts A with rfe concept filter

# PFA
./code/modelPFA_prep_all_versions.sh >> temp_pfa.txt 2>&1
./code/modelPFA_fit_all_versions.sh >> temp_pfa.txt 2>&1
>>

./code/modelPSC_setup.sh
# Accuracy = 0.842753 (686335/814396), RMSE = 0.396543
# run as job on PSC
sbatch -p RM -t 1:00:00 -N 1 --mem 4400MB ./code/modelPSC_IRT_fit.job




# AFMwpLN ALL
sbatch -p RM -t 1:00:00 -N 1 --mem 4400MB ./code/modelPSC_AFMwpLN_fit.job
# Accuracy = 0.900891 (733682/814396), RMSE = 0.314816

# PFAwpLN ALL
sbatch -p RM -t 1:00:00 -N 1 --mem 4400MB ./code/modelPSC_PFAwpLN_fit.job
# Accuracy = 0.908583 (739946/814396), RMSE = 0.302353


# The Fullest Model 1 TFM1 ALL
./code/modelPSC_TFMcountPSS4_prep.sh >> temp.txt 2>&1
# features 141634
# signature  0-0,outcome;1:1787,student intercept;1788:1790,behavior 4 intercept;1791:3578,behavior 1 intercept across students;3579:5366,behavior 2 intercept across students;5367:7154,behavior 3 intercept across students;7155:7395,behavior 1 intercept across problems;7396:7636,behavior 2 intercept across problems;7637:7877,behavior 3 intercept across problems;7878:7881,behavior slope;7882:7885,behavior user slope;7886:7889,behavior problem slope;7890:9677,behavior 1 slope since submission for users;9678:11465,behavior 2 slope since submission for users;11466:13253,behavior 3 slope since submission for users;13254:15041,behavior 4 slope since submission for users;15042:16829,behavior 1 slope since start of work for users;16830:18617,behavior 2 slope since start of work for users;18618:20405,behavior 3 slope since start of work for users;20406:22193,behavior 4 slope since start of work for users;22194:23981,behavior 1 slope since start of work for problems;23982:25769,behavior 2 slope since start of work for problems;25770:27557,behavior 3 slope since start of work for problems;27558:29345,behavior 4 slope since start of work for problems;29346:29499,skill intercepts;29500:66613,skill-problem intercepts;66614:66768,skill slopes;66769:66923,skill failure slopes;66924:104278,skill-problem slopes;104279:141633,skill-problem failure slopes;141634:141634,bias
# pools 16,1:1787,1791:3578,3579:5366,5367:7154,7890:9677,9678:11465,11466:13253,13254:15041,15042:16829,16830:18617,18618:20405,20406:22193,22194:23981,23982:25769,25770:27557,27558:29345
./code/modelPSC_TFMtimePSS4_prep.sh >> temp.txt 2>&1
# features 141634
# signature  0-0,outcome;1:1787,student intercept;1788:1790,behavior 4 intercept;1791:3578,behavior 1 intercept across students;3579:5366,behavior 2 intercept across students;5367:7154,behavior 3 intercept across students;7155:7395,behavior 1 intercept across problems;7396:7636,behavior 2 intercept across problems;7637:7877,behavior 3 intercept across problems;7878:7881,behavior slope;7882:7885,behavior user slope;7886:7889,behavior problem slope;7890:9677,behavior 1 slope since submission for users;9678:11465,behavior 2 slope since submission for users;11466:13253,behavior 3 slope since submission for users;13254:15041,behavior 4 slope since submission for users;15042:16829,behavior 1 slope since start of work for users;16830:18617,behavior 2 slope since start of work for users;18618:20405,behavior 3 slope since start of work for users;20406:22193,behavior 4 slope since start of work for users;22194:23981,behavior 1 slope since start of work for problems;23982:25769,behavior 2 slope since start of work for problems;25770:27557,behavior 3 slope since start of work for problems;27558:29345,behavior 4 slope since start of work for problems;29346:29499,skill intercepts;29500:66613,skill-problem intercepts;66614:66768,skill slopes;66769:66923,skill failure slopes;66924:104278,skill-problem slopes;104279:141633,skill-problem failure slopes;141634:141634,bias
# pools 16,1:1787,1791:3578,3579:5366,5367:7154,7890:9677,9678:11465,11466:13253,13254:15041,15042:16829,16830:18617,18618:20405,20406:22193,22194:23981,23982:25769,25770:27557,27558:29345
./code/modelPSC_TFMcountPS4_prep.sh >> temp.txt 2>&1
# features 141634
# signature  0-0,outcome;1:1787,student intercept;1788:1790,behavior 4 intercept;1791:3578,behavior 1 intercept across students;3579:5366,behavior 2 intercept across students;5367:7154,behavior 3 intercept across students;7155:7395,behavior 1 intercept across problems;7396:7636,behavior 2 intercept across problems;7637:7877,behavior 3 intercept across problems;7878:7881,behavior slope;7882:7885,behavior user slope;7886:7889,behavior problem slope;7890:9677,behavior 1 slope since submission for users;9678:11465,behavior 2 slope since submission for users;11466:13253,behavior 3 slope since submission for users;13254:15041,behavior 4 slope since submission for users;15042:16829,behavior 1 slope since start of work for users;16830:18617,behavior 2 slope since start of work for users;18618:20405,behavior 3 slope since start of work for users;20406:22193,behavior 4 slope since start of work for users;22194:23981,behavior 1 slope since start of work for problems;23982:25769,behavior 2 slope since start of work for problems;25770:27557,behavior 3 slope since start of work for problems;27558:29345,behavior 4 slope since start of work for problems;29346:29499,skill intercepts;29500:66613,skill-problem intercepts;66614:66768,skill slopes;66769:66923,skill failure slopes;66924:104278,skill-problem slopes;104279:141633,skill-problem failure slopes;141634:141634,bias
# pools 16,1:1787,1791:3578,3579:5366,5367:7154,7890:9677,9678:11465,11466:13253,13254:15041,15042:16829,16830:18617,18618:20405,20406:22193,22194:23981,23982:25769,25770:27557,27558:29345
./code/modelPSC_TFMtimePS4_prep.sh >> temp.txt 2>&1
# features 141634
# signature  0-0,outcome;1:1787,student intercept;1788:1790,behavior 4 intercept;1791:3578,behavior 1 intercept across students;3579:5366,behavior 2 intercept across students;5367:7154,behavior 3 intercept across students;7155:7395,behavior 1 intercept across problems;7396:7636,behavior 2 intercept across problems;7637:7877,behavior 3 intercept across problems;7878:7881,behavior slope;7882:7885,behavior user slope;7886:7889,behavior problem slope;7890:9677,behavior 1 slope since submission for users;9678:11465,behavior 2 slope since submission for users;11466:13253,behavior 3 slope since submission for users;13254:15041,behavior 4 slope since submission for users;15042:16829,behavior 1 slope since start of work for users;16830:18617,behavior 2 slope since start of work for users;18618:20405,behavior 3 slope since start of work for users;20406:22193,behavior 4 slope since start of work for users;22194:23981,behavior 1 slope since start of work for problems;23982:25769,behavior 2 slope since start of work for problems;25770:27557,behavior 3 slope since start of work for problems;27558:29345,behavior 4 slope since start of work for problems;29346:29499,skill intercepts;29500:66613,skill-problem intercepts;66614:66768,skill slopes;66769:66923,skill failure slopes;66924:104278,skill-problem slopes;104279:141633,skill-problem failure slopes;141634:141634,bias
# pools 16,1:1787,1791:3578,3579:5366,5367:7154,7890:9677,9678:11465,11466:13253,13254:15041,15042:16829,16830:18617,18618:20405,20406:22193,22194:23981,23982:25769,25770:27557,27558:29345
./code/modelPSC_TFMcountPS12_prep.sh >> temp.txt 2>&1
# features 200810
# signature  0-0,outcome;1:1787,student intercept;1788:1798,behavior 12 intercept;1799:3586,behavior 1 intercept across students;3587:5374,behavior 2 intercept across students;5375:7162,behavior 3 intercept across students;7163:8950,behavior 4 intercept across students;8951:10738,behavior 5 intercept across students;10739:12526,behavior 6 intercept across students;12527:14314,behavior 7 intercept across students;14315:16102,behavior 8 intercept across students;16103:17890,behavior 9 intercept across students;17891:19678,behavior 10 intercept across students;19679:21466,behavior 11 intercept across students;21467:21707,behavior 1 intercept across problems;21708:21948,behavior 2 intercept across problems;21949:22189,behavior 3 intercept across problems;22190:22430,behavior 4 intercept across problems;22431:22671,behavior 5 intercept across problems;22672:22912,behavior 6 intercept across problems;22913:23153,behavior 7 intercept across problems;23154:23394,behavior 8 intercept across problems;23395:23635,behavior 9 intercept across problems;23636:23876,behavior 10 intercept across problems;23877:24117,behavior 11 intercept across problems;24118:24129,behavior slope;24130:24141,behavior user slope;24142:24153,behavior problem slope;24154:25941,behavior 1 slope since submission for users;25942:27729,behavior 2 slope since submission for users;27730:29517,behavior 3 slope since submission for users;29518:31305,behavior 4 slope since submission for users;31306:33093,behavior 5 slope since submission for users;33094:34881,behavior 6 slope since submission for users;34882:36669,behavior 7 slope since submission for users;36670:38457,behavior 8 slope since submission for users;38458:40245,behavior 9 slope since submission for users;40246:42033,behavior 10 slope since submission for users;42034:43821,behavior 11 slope since submission for users;43822:45609,behavior 12 slope since submission for users;45610:47397,behavior 1 slope since start of work for users;47398:49185,behavior 2 slope since start of work for users;49186:50973,behavior 3 slope since start of work for users;50974:52761,behavior 4 slope since start of work for users;52762:54549,behavior 5 slope since start of work for users;54550:56337,behavior 6 slope since start of work for users;56338:58125,behavior 7 slope since start of work for users;58126:59913,behavior 8 slope since start of work for users;59914:61701,behavior 9 slope since start of work for users;61702:63489,behavior 10 slope since start of work for users;63490:65277,behavior 11 slope since start of work for users;65278:67065,behavior 12 slope since start of work for users;67066:68853,behavior 1 slope since start of work for problems;68854:70641,behavior 2 slope since start of work for problems;70642:72429,behavior 3 slope since start of work for problems;72430:74217,behavior 4 slope since start of work for problems;74218:76005,behavior 5 slope since start of work for problems;76006:77793,behavior 6 slope since start of work for problems;77794:79581,behavior 7 slope since start of work for problems;79582:81369,behavior 8 slope since start of work for problems;81370:83157,behavior 9 slope since start of work for problems;83158:84945,behavior 10 slope since start of work for problems;84946:86733,behavior 11 slope since start of work for problems;86734:88521,behavior 12 slope since start of work for problems;88522:88675,skill intercepts;88676:125789,skill-problem intercepts;125790:125944,skill slopes;125945:126099,skill failure slopes;126100:163454,skill-problem slopes;163455:200809,skill-problem failure slopes;200810:200810,bias
# pools 48,1:1787,1799:3586,3587:5374,5375:7162,7163:8950,8951:10738,10739:12526,12527:14314,14315:16102,16103:17890,17891:19678,19679:21466,24154:25941,25942:27729,27730:29517,29518:31305,31306:33093,33094:34881,34882:36669,36670:38457,38458:40245,40246:42033,42034:43821,43822:45609,45610:47397,47398:49185,49186:50973,50974:52761,52762:54549,54550:56337,56338:58125,58126:59913,59914:61701,61702:63489,63490:65277,65278:67065,67066:68853,68854:70641,70642:72429,72430:74217
./code/modelPSC_TFMtimePS12_prep.sh >> temp.txt 2>&1
# features 200810
# signature  0-0,outcome;1:1787,student intercept;1788:1798,behavior 12 intercept;1799:3586,behavior 1 intercept across students;3587:5374,behavior 2 intercept across students;5375:7162,behavior 3 intercept across students;7163:8950,behavior 4 intercept across students;8951:10738,behavior 5 intercept across students;10739:12526,behavior 6 intercept across students;12527:14314,behavior 7 intercept across students;14315:16102,behavior 8 intercept across students;16103:17890,behavior 9 intercept across students;17891:19678,behavior 10 intercept across students;19679:21466,behavior 11 intercept across students;21467:21707,behavior 1 intercept across problems;21708:21948,behavior 2 intercept across problems;21949:22189,behavior 3 intercept across problems;22190:22430,behavior 4 intercept across problems;22431:22671,behavior 5 intercept across problems;22672:22912,behavior 6 intercept across problems;22913:23153,behavior 7 intercept across problems;23154:23394,behavior 8 intercept across problems;23395:23635,behavior 9 intercept across problems;23636:23876,behavior 10 intercept across problems;23877:24117,behavior 11 intercept across problems;24118:24129,behavior slope;24130:24141,behavior user slope;24142:24153,behavior problem slope;24154:25941,behavior 1 slope since submission for users;25942:27729,behavior 2 slope since submission for users;27730:29517,behavior 3 slope since submission for users;29518:31305,behavior 4 slope since submission for users;31306:33093,behavior 5 slope since submission for users;33094:34881,behavior 6 slope since submission for users;34882:36669,behavior 7 slope since submission for users;36670:38457,behavior 8 slope since submission for users;38458:40245,behavior 9 slope since submission for users;40246:42033,behavior 10 slope since submission for users;42034:43821,behavior 11 slope since submission for users;43822:45609,behavior 12 slope since submission for users;45610:47397,behavior 1 slope since start of work for users;47398:49185,behavior 2 slope since start of work for users;49186:50973,behavior 3 slope since start of work for users;50974:52761,behavior 4 slope since start of work for users;52762:54549,behavior 5 slope since start of work for users;54550:56337,behavior 6 slope since start of work for users;56338:58125,behavior 7 slope since start of work for users;58126:59913,behavior 8 slope since start of work for users;59914:61701,behavior 9 slope since start of work for users;61702:63489,behavior 10 slope since start of work for users;63490:65277,behavior 11 slope since start of work for users;65278:67065,behavior 12 slope since start of work for users;67066:68853,behavior 1 slope since start of work for problems;68854:70641,behavior 2 slope since start of work for problems;70642:72429,behavior 3 slope since start of work for problems;72430:74217,behavior 4 slope since start of work for problems;74218:76005,behavior 5 slope since start of work for problems;76006:77793,behavior 6 slope since start of work for problems;77794:79581,behavior 7 slope since start of work for problems;79582:81369,behavior 8 slope since start of work for problems;81370:83157,behavior 9 slope since start of work for problems;83158:84945,behavior 10 slope since start of work for problems;84946:86733,behavior 11 slope since start of work for problems;86734:88521,behavior 12 slope since start of work for problems;88522:88675,skill intercepts;88676:125789,skill-problem intercepts;125790:125944,skill slopes;125945:126099,skill failure slopes;126100:163454,skill-problem slopes;163455:200809,skill-problem failure slopes;200810:200810,bias
# pools 48,1:1787,1799:3586,3587:5374,5375:7162,7163:8950,8951:10738,10739:12526,12527:14314,14315:16102,16103:17890,17891:19678,19679:21466,24154:25941,25942:27729,27730:29517,29518:31305,31306:33093,33094:34881,34882:36669,36670:38457,38458:40245,40246:42033,42034:43821,43822:45609,45610:47397,47398:49185,49186:50973,50974:52761,52762:54549,54550:56337,56338:58125,58126:59913,59914:61701,61702:63489,63490:65277,65278:67065,67066:68853,68854:70641,70642:72429,72430:74217

# C=1.0
sbatch -p RM -t 1:00:00 -N 1 --mem 4400MB ./code/modelPSC_TFMcountPSS4_fit.job
# Accuracy = 0.929545 (757018/814396), RMSE = 0.265433
sbatch -p RM -t 1:00:00 -N 1 --mem 4400MB ./code/modelPSC_TFMtimePSS4_fit.job
# Accuracy = 0.932769 (759643/814396), RMSE = 0.259290
sbatch -p RM -t 1:00:00 -N 1 --mem 4400MB ./code/modelPSC_TFMcountPS4_fit.job
# Accuracy = 0.926512 (754548/814396), RMSE = 0.271086
sbatch -p RM -t 1:00:00 -N 1 --mem 4400MB ./code/modelPSC_TFMtimePS4_fit.job
# Accuracy = 0.926985 (754933/814396), RMSE = 0.270213
sbatch -p RM -t 1:00:00 -N 1 --mem 4400MB ./code/modelPSC_TFMcountPS12_fit.job
# Accuracy = 0.939049 (764758/814396), RMSE = 0.246882
sbatch -p RM -t 1:00:00 -N 1 --mem 4400MB ./code/modelPSC_TFMtimePS12_fit.job
# Accuracy = 0.934791 (761290/814396), RMSE = 0.255361



# C=0.0
# Accuracy = 0.928466 (756139/814396), RMSE = 0.267458
# C=0.1
# Accuracy = 0.929103 (756658/814396), RMSE = 0.266264
# C=0.2
# Accuracy = 0.930736 (757988/814396), RMSE = 0.263180
# C=0.3
# Accuracy = 0.928142 (755875/814396), RMSE = 0.268064
# C=0.4
# Accuracy = 0.928540 (756199/814396), RMSE = 0.267321
# C=0.5
# Accuracy = 0.929392 (756893/814396), RMSE = 0.265722
# C=0.6
# Accuracy = 0.920831 (749921/814396), RMSE = 0.281370
# C=0.7
# Accuracy = 0.928696 (756326/814396), RMSE = 0.267029
# C=0.8
# Accuracy = 0.930756 (758004/814396), RMSE = 0.263142
# C=0.9
# Accuracy = 0.928780 (756395/814396), RMSE = 0.266870
# C=1.0
# Accuracy = 0.928376 (756066/814396), RMSE = 0.267626
# C=1.1
# Accuracy = 0.932077 (759080/814396), RMSE = 0.260620
# C=1.2
# Accuracy = 0.921166 (750194/814396), RMSE = 0.280774
# C=1.3
# Accuracy = 0.927997 (755757/814396), RMSE = 0.268334
# C=1.4
# Accuracy = 0.929144 (756691/814396), RMSE = 0.266188
# C=1.5
# Accuracy = 0.929144 (756691/814396), RMSE = 0.266188
# C=1.6
# Accuracy = 0.932611 (759515/814396), RMSE = 0.259593
# C=1.7
# Accuracy = 0.927204 (755111/814396), RMSE = 0.269808
# C=1.8
# Accuracy = 0.930535 (757824/814396), RMSE = 0.263562
# C=1.9
# Accuracy = 0.928556 (756212/814396), RMSE = 0.267291
# C=2.0
# Accuracy = 0.929801 (757226/814396), RMSE = 0.264951

# Best C for no-hierarchy
# Best C = 0.0078125  CV accuracy = 91.0447%


# tar lldata and delete folders
declare -a datasets=("ALL")
for dataset in ${datasets[@]}
do
    tar -cvjf ./data/${dataset}_liblineardata.tar.bz ./data/${dataset}_liblineardata/
    rm -rf ./data/${dataset}_liblineardata/
done


#
# Predicting path to successful solution of problems.
# - how many course-student-problem's are there, how many are solved
#
awk -F";" 'BEGIN{OFS="";}{
	s = ($12=="1.0")?1:0; # success
	g = $2; # student
	p = $4; # problem
	c = $3; # course
	cgp = c"__"g"__"p;
	if(A[cgp]=="") {
		N++;
		A[cgp]=0;
	}
	if(A[cgp]<1 && s==1) {
		A[cgp] = 1;
		C++;
	}
}END{print "course-student-problems "N", solved "C" (",C/N,"%)"}' ./data/ALL_allsubmit.txt
# course-student-problems 143365, solved 122833 (0.856785%)
# total rows 814396: 814396/143365 = 5.68 per problem

# create a file for a simple R regression
awk -F";" 'BEGIN{OFS="\t";}{
	s = ($12=="1.0")?1:0; # success
	g = $2; # student
	p = $4; # problem
	c = $3; # course
	cgp = c"__"g"__"p;

	if(A[cgp]!=1) {
		N[cgp]++;
		A[cgp] = (s==1)?1:0;
	}
}END{
	print "solved\tcourse\tstudent\tproblem\tsubmits";
	for(cgp in A) {
		split(cgp,ar_cgp,"__");
		print A[cgp],ar_cgp[1],ar_cgp[1]"__"ar_cgp[2],ar_cgp[3],N[cgp];
	}
}' ./data/ALL_allsubmit.txt > ./data/ALL_CourseStudProb_submits.txt

#
#
# PARAMETER STABILITY
# Create 20 subsets of 500 of 1788 students 
#
#
gawk -v nrun=20 -v nstud=500 -v nstud_total=`wc -l <./data/ALL_voc/ALL_allsubmit_voc_student.txt` -F"\t" '
BEGIN{ratio=nstud/nstud_total; srand(); }{
	s=$1;
	for(i=1; i<=nrun; i++) s=s"\t"((rand()<=ratio)?"1":"0");
	print s;
}' ./data/ALL_voc/ALL_allsubmit_voc_student.txt > ./data/ALL_allsubmit_studrepruns_nrun${nrun}_nstud${nstud}.txt
# turn student design into row design
gawk -v nrun=20 -F"\t" 'BEGIN{fn=0;}{
	if(FNR==1) {fn++;}
	if(fn==1) {
		for(i=1; i<=nrun; i++) G[$1,i] = $(i+1);
	}
	if(fn==2) {
		g=$2;
		s = g;
		for(i=1; i<=nrun; i++) s=s"\t"G[g,i];
		print s;
	}
}' ./data/ALL_allsubmit_studrepruns_nrun${nrun}_nstud${nstud}.txt ./data/ALL_allsubmit.txt > ./data/ALL_allsubmit_rowrepruns_nrun${nrun}_nstud${nstud}.txt

# 
mkdir -p ./data/ALL_allsubmit_repruns/data
mkdir -p ./data/ALL_allsubmit_repruns/predict
mkdir -p ./data/ALL_allsubmit_repruns/model
rm -rf ./data/ALL_allsubmit_repruns/data/*.txt
# create data subsets
nrun=20
nstud=500
declare -a ftags=("llTFMcountPSS4" "llTFMcountPS4" "llTFMcountPS12" "llTFMtimePSS4" "llTFMtimePS4" "llTFMtimePS12")
fstud_design=./data/ALL_allsubmit_studrepruns_nrun${nrun}_nstud${nstud}.txt
forig_data=./data/ALL_allsubmit.txt
for ftag in ${ftags[@]} # for all dataset names in datasets array
do
	echo $ftag
	fn=./data/ALL_liblineardata/ALL_allsubmit_${ftag}.txt
	awk -F"\t" -v nrun=20 -v fnout=./data/ALL_allsubmit_repruns/data/ALL_liblineardata_${ftag}_run 'BEGIN{fn=0;}{
		if(FNR==1) {fn++;}
		if(fn==1) {
			for(i=1; i<=nrun; i++) G[$1,i] = $(i+1);
		}
		if(fn==2) {
			for(i=1; i<=nrun; i++)
				if( G[$1,i]==1 ) 
					print $2 >> fnout""i".txt";
		}
	}' ${fstud_design} <(paste <(cut -d";" -f 2-2 ./data/ALL_allsubmit.txt) ${fn})
done
# fit models, predict, report fit
nrun=20
nstud=500
declare -a ftags=("llTFMcountPSS4" "llTFMcountPS4" "llTFMcountPS12" "llTFMtimePSS4" "llTFMtimePS4" "llTFMtimePS12")
pools4="16,1:1787,1791:3578,3579:5366,5367:7154,7890:9677,9678:11465,11466:13253,13254:15041,15042:16829,16830:18617,18618:20405,20406:22193,22194:23981,23982:25769,25770:27557,27558:29345"
pools12="48,1:1787,1799:3586,3587:5374,5375:7162,7163:8950,8951:10738,10739:12526,12527:14314,14315:16102,16103:17890,17891:19678,19679:21466,24154:25941,25942:27729,27730:29517,29518:31305,31306:33093,33094:34881,34882:36669,36670:38457,38458:40245,40246:42033,42034:43821,43822:45609,45610:47397,47398:49185,49186:50973,50974:52761,52762:54549,54550:56337,56338:58125,58126:59913,59914:61701,61702:63489,63490:65277,65278:67065,67066:68853,68854:70641,70642:72429,72430:74217"
declare -a fpools=("${pools4}" "${pools4}" "${pools12}" "${pools4}" "${pools4}" "${pools12}")

fstud_design=./data/ALL_allsubmit_studrepruns_nrun${nrun}_nstud${nstud}.txt
forig_data=./data/ALL_allsubmit.txt
for f in {0..5} # for all dataset names in datasets array
do
	echo ${ftags[$f]} fit
	for i in `seq 1 $nrun`
	do
		fdata=./data/ALL_allsubmit_repruns/data/ALL_liblineardata_${ftags[$f]}_run${i}.txt
		fmodel=./data/ALL_allsubmit_repruns/model/ALL_liblinear_model_${ftags[$f]}_run${i}.txt
		fpredict=./data/ALL_allsubmit_repruns/predict/ALL_liblinear_predict_${ftags[$f]}_run${i}.txt
		fout=./data/ALL_allsubmit_repruns/out/ALL_liblinear_out_${ftags[$f]}_run${i}.txt
		./bin/train -s 14 -q -g "${fpools[$f]}" "${fdata}" "${fmodel}"
		./bin/predict -b 1 "${fdata}" "${fmodel}" "${fpredict}" | tee "${fout}"
	done
done
# "unite" models
# [ ] parameter non-zero in 15/20 runs
# [ ] parameter mean and SE
# [x] average accuracy and RMSE
nrun=20
nstud=500
declare -a ftags=("llTFMcountPSS4" "llTFMcountPS4" "llTFMcountPS12" "llTFMtimePSS4" "llTFMtimePS4" "llTFMtimePS12")
for f in {0..5} # for all dataset names in datasets array
do
	funited=./data/ALL_allsubmit_repruns/result/ALL_liblinear_result_${ftags[$f]}_run${i}_stud${nstud}.txt
	rm -rf ${funited}
	echo ${ftags[$f]} fit
	for i in `seq 1 $nrun`
	do
		fout=./data/ALL_allsubmit_repruns/out/ALL_liblinear_out_${ftags[$f]}_run${i}.txt
		cat ${fout} >> ${funited}
	done
	perl -i -p -e 's/ /\t/g' ${funited}
	summacc=`awk -F"\t" '{n++; a+=$3; r+=$7;}END{print "Accuracy\t"a/n"\tRMSE\t"r/n;}' ${funited}`
	echo ${summacc} >> ${funited}
done

#
#
# PARAMETER STABILITY
# Create 20 subsets of 500 of 1788 students 
#
#



#
# Compensatory BKT test
#

# export to hmm format
awk -F";" 'BEGIN{OFS="\t";}{
	s = ($12=="1.0")?1:2; # success
	g = $2; # student
	p = $4; # problem
	c = $3; # course
	k = $17;
	n = split(k,ar_k,",");
	kstr = "";
	for(i=1; i<=n; i++) {
		split(ar_k[i],arar_k,":");
		kstr = kstr""((kstr=="")?"":"~")""p"__"arar_k[1];
	}
	kstr=(kstr!="")?kstr:".";
	print s,c"__"g,p,kstr;
}' ./data/ALL_allsubmit.txt > ./data/ALL_allsubmit_hmm.txt
wc -l ./data/ALL_allsubmit_hmm.txt
# 814396
# 1.18 Gb
tar -cvjf ./data/ALL_allsubmit_hmm.tar.bz ./data/ALL_allsubmit_hmm.txt

./bin/inputconvert -s t -t b -d ~ ./data/ALL_allsubmit_hmm.txt ./data/ALL_allsubmit_hmm.bin
# overall time running is 17.166991 seconds
# 94.9Mb
# EM - ok
./bin/trainhmm -s 1.1 -d ~ -b 1 -m 1 ./data/ALL_allsubmit_hmm.bin ./model/ALL_allsubmit_hmm_modelEM.txt  ./predict/ALL_allsubmit_hmm_predictEM.txt
# input read, nO=2, nG=1865, nK=15823, nI=241, nZ=1
# trained model LL= 275023.7718906 ( 274843.5244511), AIC=676631.543781, BIC=1411464.449599, RMSE=0.329047 (0.328642), Acc=0.840230 (0.840591)
# timing: overall 76.000000 seconds, read 1.585053, fit 63.459243, predict 10.267391
# GD - shit!
./bin/trainhmm -s 1.2 -d ~ -b 1 -m 1 ./data/ALL_allsubmit_hmm.bin ./model/ALL_allsubmit_hmm_modelGD.txt  ./predict/ALL_allsubmit_hmm_predictGD.txt
# input read, nO=2, nG=1865, nK=15823, nI=241, nZ=1
# trained model LL= 570272.0192349 ( 570091.7717954), AIC=1267128.038470, BIC=2001960.944288, RMSE=0.504170 (0.503982), Acc=0.324972 (0.325064)
# timing: overall 65.000000 seconds, read 1.602422, fit 53.037284, predict 9.853637
# GDlag - better
./bin/trainhmm -s 1.4 -d ~ -b 1 -m 1 ./data/ALL_allsubmit_hmm.bin ./model/ALL_allsubmit_hmm_modelGDlag.txt  ./predict/ALL_allsubmit_hmm_predictGDlag.txt
# trained model LL= 237858.5614987 ( 237678.3140592), AIC=602301.122997, BIC=1337134.028815, RMSE=0.304152 (0.303700), Acc=0.870623 (0.871000)
# timing: overall 50.000000 seconds, read 1.970096, fit 37.813390, predict 9.614310 
# Co-GDlag
bin/trainhmm -s 13.4 -d ~ -b 1 -m 1 -p 1 -P 1 -l 0,0,1,0,0,0,0.5,0,0,0.5 -u 1,1,1,0,1,1,1,0.5,0.5,1 ./data/ALL_allsubmit_hmm.bin ./model/ALL_allsubmit_hmm_modelCoGDlag.txt  ./predict/ALL_allsubmit_hmm_predictCoGDlag.txt > temp.txt 2>&1
# over 150 runs, try to use regularization
bin/trainhmm -s 13.4 -d ~ -b 1 -m 1 -p 1 -P 1 -c 1,0.5,0.5,1.0,0.0,0.5,0.5,1,0,0,1 -l 0,0,1,0,0,0,0.5,0,0,0.5 -u 1,1,1,0,1,1,1,0.5,0.5,1 ./data/ALL_allsubmit_hmm.bin ./model/ALL_allsubmit_hmm_modelCoGDlag.txt  ./predict/ALL_allsubmit_hmm_predictCoGDlag.txt > temp.txt 2>&1
trainhmm -s 13.4 -d ~ -b 1 -m 1 -p 1 -P 1 -c 1,0.5,0.5,1.0,0.0,0.5,0.5,1,0,0,1 -l 0,0,1,0,0,0,0.5,0,0,0.5 -u 1,1,1,0,1,1,1,0.5,0.5,1 /Users/yudelson/Documents/pitt/pittuohmooc/data/ALL_allsubmit_hmm.bin model_CoBKT.txt predict_CoBKT.txt
# trained model LL= 497385.5672145 ( 497205.3197750), AIC=1121355.134429, BIC=1856188.040247, RMSE=0.469465 (0.469244), Acc=0.330645 (0.330739)
# timing: overall 364.680797 sec, read 1.533921 sec, fit 294.609441 sec, predict 67.763386 sec
trainhmm -s 13.2 -d ~ -b 1 -m 1 -p 1 -P 1 -c 1,0.5,0.5,1.0,0.0,0.5,0.5,1,0,0,1 -l 0,0,1,0,0,0,0.5,0,0,0.5 -u 1,1,1,0,1,1,1,0.5,0.5,1 /Users/yudelson/Documents/pitt/pittuohmooc/data/ALL_allsubmit_hmm.bin model_CoBKT.txt predict_CoBKT.txt
# trained model LL= 564395.7586855 ( 564215.5112460), AIC=1255375.517371, BIC=1990208.423189, RMSE=0.500264 (0.500072), Acc=0.264035 (0.264094)
# timing: overall 13678.348918 sec, read 1.551658 sec, fit 13605.344261 sec, predict 70.516447 sec

# fit all traditionally first and then multi-skills
./trainhmm -s 13.4 -d ~ -b 1 -m 1 -p 1 -P 1 -c 1,0.5,0.5,1.0,0.0,0.5,0.5,1,0,0,1 -l 0,0,1,0,0,0,0.5,0,0,0.5 -u 1,1,1,0,1,1,1,0.5,0.5,1 /Users/yudelson/Documents/pitt/pittuohmooc/data/ALL_allsubmit_hmm.bin model_CoBKT.txt predict_CoBKT.txt
# still shitty lol

# fit multi as multi only :), but start at 0.5 where ever possible, and regularize
./bin/trainhmm -s 13.4 -d ~ -b 1 -m 1 -p 1 -P 1 -0 0.5,1.0,0.5,0.7,0.3 -c 1,0.5,0.5,1.0,0.0,0.5,0.5,1,0,0,1 -l 0,0,1,0,0,0,0.5,0,0,0.5 -u 1,1,1,0,1,1,1,0.5,0.5,1 ./data/ALL_allsubmit_hmm.bin ./model/model_CoBKT.txt ./predict/predict_CoBKT.txt | tee temp.txt
# trained model LL= 498503.5824632 ( 498323.3350237), AIC=1123591.164926, BIC=1858424.070744, RMSE=0.469976 (0.469756), Acc=0.330290 (0.330384)
# negative p(O) too :(

#
# Negative log-likelihood, and PRECICELY ONE iteration. Weird! TRACE!
#

#
# OLDER STUFF
#








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

