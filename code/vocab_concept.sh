#!/bin/bash

#
#
# Vocabularies and Concept Differences
#
#

# Dependencies
# - preprocess
# 	- behaviors


# Create vocabularies of students, items, and concepts (various concept list types).
# Concept list types
# - A - all concepts in the snapshot
# - B - only new concepts in the snapshot
# - C - new concepts in the snapshot as well as deletions
# - D - all concepts in the snapshot as well as deletions

# uncompress
# declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")
# for dataset in ${datasets[@]} # for all dataset names in datasets array
# do
# 	tar -xvjf data/preprocess/${dataset}_allsubmit.tar.bz 
# done

# Student and item vocabularies first
declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")
for dataset in ${datasets[@]}
do
    rm -rf ./data/vocab_concept/${dataset}
    mkdir ./data/vocab_concept/${dataset}
    export vocstu=./data/vocab_concept/${dataset}/${dataset}_allsubmit_voc_student.txt
    export vocite=./data/vocab_concept/${dataset}/${dataset}_allsubmit_voc_item.txt
	# item voc vocabulary
	export col=4
	awk -F";" -f ./code/vocab_concept/createSimpleVoc.awk ./data/preprocess/${dataset}_allsubmit.txt > ./data/vocab_concept/${dataset}/${dataset}_allsubmit_voc_item.txt
	# student vocabulary
	export col=2
	awk -F";" -f ./code/vocab_concept/createSimpleVoc.awk ./data/preprocess/${dataset}_allsubmit.txt > ./data/vocab_concept/${dataset}/${dataset}_allsubmit_voc_student.txt
    wc -l ./data/vocab_concept/${dataset}/${dataset}_allsubmit_voc_student.txt
    wc -l ./data/vocab_concept/${dataset}/${dataset}_allsubmit_voc_item.txt
done # all datasets
# 220 ./data/vocab_concept/s2014-ohpe/s2014-ohpe_allsubmit_voc_student.txt
# 104 ./data/vocab_concept/s2014-ohpe/s2014-ohpe_allsubmit_voc_item.txt
# 180 ./data/vocab_concept/s2015-ohpe/s2015-ohpe_allsubmit_voc_student.txt
# 116 ./data/vocab_concept/s2015-ohpe/s2015-ohpe_allsubmit_voc_item.txt
# 613 ./data/vocab_concept/k2015-mooc/k2015-mooc_allsubmit_voc_student.txt
# 116 ./data/vocab_concept/k2015-mooc/k2015-mooc_allsubmit_voc_item.txt
# 852 ./data/vocab_concept/k2014-mooc/k2014-mooc_allsubmit_voc_student.txt
#  97 ./data/vocab_concept/k2014-mooc/k2014-mooc_allsubmit_voc_item.txt
 

# Create B, C, and D sets of concepts as a 3-column addition file
declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")
for dataset in ${datasets[@]}
do
    fin=./data/preprocess/${dataset}_allsubmit.txt
    fout=./data/vocab_concept/${dataset}/${dataset}_allsubmitBCD.txt
    fouttar=./data/vocab_concept/${dataset}/${dataset}_allsubmitBCD.tar.bz
    awk -F";" -f ./code/vocab_concept/dataAtoBCD.awk "${fin}" > "${fout}"
    tar -cvjf "${fouttar}" "${fout}"
done # all datasets

#
# create vocabularies of concepts
#
declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")
for dataset in ${datasets[@]}
do
    export vocski=./data/vocab_concept/${dataset}/${dataset}_allsubmit_voc_skill
#     pre=./data/preprocess/${dataset}_allsubmit.txt
#     bcd=./data/vocab_concept/${dataset}/${dataset}_allsubmitBCD.txt
# 	awk -F";" -f ./code/vocab_concept/all2skillvoc.awk <(paste -d";" ${pre} ${bcd})
    # A skill vocabulary
    export col=17
    awk -F";" -f ./code/vocab_concept/createListedVoc.awk ./data/preprocess/${dataset}_allsubmit.txt > ./data/vocab_concept/${dataset}/${dataset}_allsubmit_voc_skillA.txt
    # B skill vocabulary
    export col=1
    awk -F";" -f ./code/vocab_concept/createListedVoc.awk ./data/vocab_concept/${dataset}/${dataset}_allsubmitBCD.txt > ./data/vocab_concept/${dataset}/${dataset}_allsubmit_voc_skillB.txt
    # C skill vocabulary
    export col=2
    awk -F";" -f ./code/vocab_concept/createListedVoc.awk ./data/vocab_concept/${dataset}/${dataset}_allsubmitBCD.txt > ./data/vocab_concept/${dataset}/${dataset}_allsubmit_voc_skillC.txt
    # D skill vocabulary
    export col=3
    awk -F";" -f ./code/vocab_concept/createListedVoc.awk ./data/vocab_concept/${dataset}/${dataset}_allsubmitBCD.txt > ./data/vocab_concept/${dataset}/${dataset}_allsubmit_voc_skillD.txt
    wc -l ./data/vocab_concept/${dataset}/${dataset}_allsubmit_voc_skillA.txt
    wc -l ./data/vocab_concept/${dataset}/${dataset}_allsubmit_voc_skillB.txt
    wc -l ./data/vocab_concept/${dataset}/${dataset}_allsubmit_voc_skillC.txt
    wc -l ./data/vocab_concept/${dataset}/${dataset}_allsubmit_voc_skillD.txt
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

# --