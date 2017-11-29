#!/bin/sh

#  
#
#  Created by Roya Hosseini on 12/3/16.
#
# ========= start of behaviour labeling and merging that with the data =======
cd ./code/

declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")
#compiling the behaviour labeling java file
rm -rf "./java/source_codes/progMooc/classes" # remove if directory exists
mkdir "./java/source_codes/progMooc/classes" # recreate it
javac -d "./java/source_codes/progMooc/classes" "./java/source_codes/progMooc/src/progMooc/BehavLbl_PS12.java"
for dataset in ${datasets[@]} # for all datasets
do
    # remove if file exists
    rm -f "../data/${dataset}_behavLbl_log_PS12.txt"
    rm -f "../data/${dataset}_all_behavLbl.txt"
    # create an empty file for storing warnings generated during the labeling process
    echo "" > "../data/${dataset}_behavLbl_log_PS12.txt"
    #running the behaviour labeling java file
    java -cp "./java/source_codes/progMooc/classes/" progMooc.BehavLbl_PS12 "../data/${dataset}_all.txt" "../data/${dataset}_all_behavLbl.txt" $dataset >>  "../data/${dataset}_behavLbl_log_PS12.txt"
done # for all datasets
printf "Finished labeling behaviours.\n"

mkdir ../temp_behav
for dataset in ${datasets[@]} # for all datasets
do
    datasetFile="../data/${dataset}_all.txt" # dataset file
    behavFile="../data/${dataset}_all_behavLbl.txt" # behaviour file name for the current dataset
    awk 'BEGIN{FS=";"} NR==FNR {a[$1]=$2 FS $3 FS $4 FS $5 FS $6 FS $7 FS $8 FS $9 FS $10 FS $11 FS $12 FS $13 FS $14 FS $15 FS $16 FS $17 FS $18 FS $19 FS $20 FS $21 FS $22 FS $23 FS $24 FS $25} NR>FNR {if (a[$1]) print $0 FS a[$1]; else print $0 FS FS FS FS FS FS FS FS FS FS FS FS FS FS FS FS FS FS FS FS FS FS FS FS}' $behavFile $datasetFile > "../temp_behav/${dataset}_all.txt"
    cp -f "../temp_behav/${dataset}_all.txt" "../data/${dataset}_all_PS12.txt" # repalace the original dataset file with the dataset merged with behaviour labels
done # for all datasets

rm -rf ../temp_behav # remove the temp directory
printf "Finished adding behaviours to the data.\n"

for dataset in ${datasets[@]} # for all datasets
do
# create directory for storing behaviour data
    rm -f "../data/${dataset}_all_behavLbl.txt" # remove if file exists
done


# Lump data into one file, leave only submission rows (_allsubmit_behav)
declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")
for dataset in ${datasets[@]}
do
    rm -rf ../data/${dataset}_allsubmit_behav_PS12.txt
    fname="../data/${dataset}_all_PS12.txt"
    grep -v ";GENERIC;" "${fname}" >> ../data/${dataset}_allsubmit_behav_PS12.txt
    wc -l ../data/${dataset}_all_PS12.txt
    wc -l ../data/${dataset}_allsubmit_behav_PS12.txt
done # all datasets
# 133370 ../data/s2014-ohpe_all_PS12.txt
# 107143 ../data/s2014-ohpe_allsubmit_behav_PS12.txt
# 115560 ../data/s2015-ohpe_all_PS12.txt
# 92591 ../data/s2015-ohpe_allsubmit_behav_PS12.txt
# 338685 ../data/k2015-mooc_all_PS12.txt
# 274456 ../data/k2015-mooc_allsubmit_behav_PS12.txt
# 418890 ../data/k2014-mooc_all_PS12.txt
# 340206 ../data/k2014-mooc_allsubmit_behav_PS12.txt

cd ..

# ========= end of of behaviour labeling and merging that with the data =======
# <<<Roya Finished Here>>>
