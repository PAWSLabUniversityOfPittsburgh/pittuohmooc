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

rm -f "./java/source_codes/progMooc/resource/User2ndPart.txt"
ofname="./java/source_codes/progMooc/resource/User2ndPart.txt"
validUsrCourse="./java/source_codes/progMooc/resource/student_courses_earliestCourse.txt"
javac -d "./java/source_codes/progMooc/classes" "./java/source_codes/progMooc/src/progMooc/GenerateUserSecondPart.java"
for dataset in ${datasets[@]} # for all datasets
do
    fname="../data/${dataset}_all.txt" # problem file name in a dataset
    java -cp "./java/source_codes/progMooc/classes/" progMooc.GenerateUserSecondPart $fname $ofname ${dataset} ${validUsrCourse}
done # all datasets
printf "finished user 2ndpart rowid generation.\n"


rm -f "./java/source_codes/progMooc/resource/UserPerformanceSummarySecondPart.txt"
ofname="./java/source_codes/progMooc/resource/UserPerformanceSummarySecondPart.txt"
validUsrCourse="./java/source_codes/progMooc/resource/student_courses_earliestCourse.txt"
userPart2RowIdfile="./java/source_codes/progMooc/resource/User2ndPart.txt"
javac -d "./java/source_codes/progMooc/classes" "./java/source_codes/progMooc/src/progMooc/UserPerformanceGenerationSecondPart.java"
for dataset in ${datasets[@]} # for all datasets
do
fname="../data/${dataset}_all.txt" # problem file name in a dataset
java -cp "./java/source_codes/progMooc/classes/" progMooc.UserPerformanceGenerationSecondPart $fname $ofname ${dataset} ${validUsrCourse} ${userPart2RowIdfile}
done # all datasets
printf "finished summarizing user performance in the second part.\n"



#Step 5: delete uncompressed _all files
declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")
for dataset in ${datasets[@]} # for all dataset names in datasets array
do
 	rm -rf ../data/${dataset}_all.txt
done

