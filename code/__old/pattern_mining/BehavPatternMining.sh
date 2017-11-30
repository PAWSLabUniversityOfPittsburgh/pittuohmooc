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
rm -f "./java/source_codes/progMooc/resource/MedianTimeSnapshotPerExercise.txt"
ofname="./java/source_codes/progMooc/resource/MedianTimeSnapshotPerExercise.txt"
thresholdIndx=1 #1 for userAdaptiveMedians, 3 for problemAdaptiveMedian
javac -d "./java/source_codes/progMooc/classes" "./java/source_codes/progMooc/src/progMooc/GenerateMedianTimeSnapshotPerExercise.java"
for dataset in ${datasets[@]} # for all datasets
do
    fname="../data/${dataset}_all.txt" # problem file name in a dataset
    java -cp "./java/source_codes/progMooc/classes/" progMooc.GenerateMedianTimeSnapshotPerExercise $fname $ofname ${dataset} $thresholdIndx
done # all datasets
printf "finished finding medians of time on clmn[${thresholdIndx}] (clmn[1]--user adaptive, clmn[3]--problem).\n"


#Step 1: storing behaviour patterns for exercise-student
rm -f "./java/source_codes/progMooc/resource/BehavPatternExercise.txt"
ofname="./java/source_codes/progMooc/resource/BehavPatternExercise.txt"
pathToMedianFile="./java/source_codes/progMooc/resource/MedianTimeSnapshotPerExercise.txt"
pathToValdusrcourseFile="./java/source_codes/progMooc/resource/student_courses_earliestCourse.txt"
thresholdIndx=1 #1 for userAdaptiveMedians, 3 for problemAdaptiveMedian
javac -d "./java/source_codes/progMooc/classes" "./java/source_codes/progMooc/src/progMooc/BehavPatternExercise_twelveLBL_prevsnapshot.java"
for dataset in ${datasets[@]} # for all datasets
do
    fname="../data/${dataset}_all.txt" # problem file name in a dataset
    java -cp "./java/source_codes/progMooc/classes/" progMooc.BehavPatternExercise_twelveLBL_prevsnapshot $fname $ofname ${dataset} $pathToMedianFile $pathToValdusrcourseFile $thresholdIndx
done # all datasets

printf "finished stroing behaviour pattern.\n"

#Step 2: encoding the patterns for sequential pattern mining
rm -f "./java/source_codes/progMooc/resource/BehavPatternExerciseSPMF.txt"
ofname="./java/source_codes/progMooc/resource/BehavPatternExerciseSPMF.txt"
fname="./java/source_codes/progMooc/resource/BehavPatternExercise.txt"
javac -d "./java/source_codes/progMooc/classes" "./java/source_codes/progMooc/src/progMooc/CreateSequenceSPMF_twelveLBL.java"
java -cp "./java/source_codes/progMooc/classes/" progMooc.CreateSequenceSPMF_twelveLBL $fname $ofname
printf "finished encoding behaviour pattern.\n"

#Step 3: running sequential pattern mining
fname="./java/source_codes/progMooc/resource/BehavPatternExerciseSPMF.txt"
rm -f "./java/source_codes/progMooc/resource/OutputSPMF.txt"
ofname="./java/source_codes/progMooc/resource/OutputSPMF.txt"

#order of arguments for spam
#1. minsup (a value in [0,1] representing a percentage), current support is 1%, genome uses 1%
#2. minimum number of items that patterns found should contain
#3. maximum number of items that patterns found should contain
#4. max gap, if set to 1, no gap is allowed
#5. "show sequences ids?" (true/false) sequence ids of sequences containing a pattern should be output for each pattern found.
java -jar ./java/source_codes/progMooc/lib/spmf.jar run SPAM $fname $ofname 0.01 2 100 1 false
printf "finished sequential pattern mining of behaviour pattern.\n"

#Step 4: process the output of the spam
rm -f "./java/source_codes/progMooc/resource/OutputSPMFProcessed.txt"
ofname="./java/source_codes/progMooc/resource/OutputSPMFProcessed.txt"
fname="./java/source_codes/progMooc/resource/OutputSPMF.txt"
N=$(wc -l < "./java/source_codes/progMooc/resource/BehavPatternExerciseSPMF.txt")
javac -d "./java/source_codes/progMooc/classes" "./java/source_codes/progMooc/src/progMooc/ProcessSPAMOutput_twelveLBL.java"
java -cp "./java/source_codes/progMooc/classes/" progMooc.ProcessSPAMOutput_twelveLBL $fname $ofname $N
printf "finished processing the output of spam.\n"

#Step 5: delete uncompressed _all files
declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")
for dataset in ${datasets[@]} # for all dataset names in datasets array
do
 	rm -rf ../data/${dataset}_all.txt
done
