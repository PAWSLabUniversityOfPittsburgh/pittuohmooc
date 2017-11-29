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


#Step 2: encoding the patterns for sequential pattern mining
rm -f "./java/source_codes/progMooc/resource/BehavPatternExerciseSPMF.txt"
ofname="./java/source_codes/progMooc/resource/BehavPatternExerciseSPMF.txt"
fname="./java/source_codes/progMooc/resource/BehavPatternExercise.txt"
javac -d "./java/source_codes/progMooc/classes" "./java/source_codes/progMooc/src/progMooc/CreateSequenceSPMF.java"
java -cp "./java/source_codes/progMooc/classes/" progMooc.CreateSequenceSPMF $fname $ofname
printf "finished encoding behaviour pattern.\n"

#Step 3: running sequential pattern mining
fname="./java/source_codes/progMooc/resource/BehavPatternExerciseSPMF.txt"
rm -f "./java/source_codes/progMooc/resource/OutputSPMF.txt"
ofname="./java/source_codes/progMooc/resource/OutputSPMF.txt"

#order of arguments for spam
#1. minsup (a value in [0,1] representing a percentage), we get same frequent patterns for 0.5-0.9
#2. minimum number of items that patterns found should contain
#3. maximum number of items that patterns found should contain
#4. max gap, if set to 1, no gap is allowed
#5. "show sequences ids?" (true/false) sequence ids of sequences containing a pattern should be output for each pattern found.
java -jar ./java/source_codes/progMooc/lib/spmf.jar run SPAM $fname $ofname 0.6 1 100 1 false
printf "finished sequential pattern mining of behaviour pattern.\n"


#Step 4: delete uncompressed _all files
declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")
for dataset in ${datasets[@]} # for all dataset names in datasets array
do
 	rm -rf ../data/${dataset}_all.txt
done
