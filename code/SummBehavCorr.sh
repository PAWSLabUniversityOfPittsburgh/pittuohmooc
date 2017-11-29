#!/bin/bash

#uncompress _allsubmit_behav files
declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")
for dataset in ${datasets[@]} # for all dataset names in datasets array
do
    tar -xjvf ../data/${dataset}_allsubmit_behav.tar.bz --directory ../
done

declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")

rm -rf "./java/source_codes/progMooc/resource/sumBehavCorrectness.txt"
ofname="./java/source_codes/progMooc/resource/sumBehavCorrectness.txt"
javac -d "./java/source_codes/progMooc/classes" "./java/source_codes/progMooc/src/progMooc/SummerizeBehavCorrectness.java"
for dataset in ${datasets[@]} # for all datasets
do
    fname="../data/${dataset}_allsubmit_behav.txt" # problem file name in a dataset
    java -cp "./java/source_codes/progMooc/classes/" progMooc.SummerizeBehavCorrectness $fname $ofname
done # all datasets

printf "finished.\n"

#delete the uncompressed _allsubmit_behav files
declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")
for dataset in ${datasets[@]} # for all dataset names in datasets array
do
 	rm -rf ../data/${dataset}_allsubmit_behav.txt
done
