#!/bin/bash

#
# uncompressing _all files
#
# un-compress
declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")
for dataset in ${datasets[@]} # for all dataset names in datasets array
do
    tar -xjvf ../data/${dataset}_all.tar.bz --directory ../
done

declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")

declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")


#finding the median of time spent for an snapshot in a problem
rm -f "./java/source_codes/progMooc/resource/ProblemComplexity.txt"
ofname="./java/source_codes/progMooc/resource/ProblemComplexity.txt"
javac -d "./java/source_codes/progMooc/classes" "./java/source_codes/progMooc/src/progMooc/ProblemComplexityEstimation.java"
for dataset in ${datasets[@]} # for all datasets
do
    fname="../data/${dataset}_all.txt" # problem file name in a dataset
    java -cp "./java/source_codes/progMooc/classes/" progMooc.ProblemComplexityEstimation $fname $ofname ${dataset}
done # all datasets
printf "finished estimating problems' complexity.\n"


#Step 5: delete uncompressed _all files
declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")
for dataset in ${datasets[@]} # for all dataset names in datasets array
do
 	rm -rf ../data/${dataset}_all.txt
done

