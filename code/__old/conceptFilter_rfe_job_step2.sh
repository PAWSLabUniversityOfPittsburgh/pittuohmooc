#!/bin/bash

#Step 1: generating input files for concept filtering
declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")
declare -a ABC=("A" "B" "C" "D")

export prefix=/pylon2/ca4s8ip/yudelson/pittuohmooc
export prefixR=/pylon1/ca4s8ip/yudelson/pittuohmooc

#Step 2: running concept filtering methods
declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")
declare -a ABC=("A" "B" "C" "D")
declare -a method=("rfe")


# create suffix for the name of the log name file
function join { local IFS="$1"; shift; echo "$*"; }
suffix=$(join _ ${datasets[@]})
#rm -f "${prefixR}/data/fc_rfe/logAvgTs_AvgCs_FCT_${suffix}.txt" # remove if exist
rm -f "${prefixR}/data/fc_rfe/logAvgT_AvgCs_FCT_${suffix}.txt" # remove if exist
rm -f "${prefixR}/data/fc_rfe/errors_FCT_${suffix}.txt"
fclogAvgT_AvgCs="logAvgT_AvgCs_FCT_${suffix}.txt"
#fclogAvgTs_AvgCs="logAvgTs_AvgCs_FCT_${suffix}.txt"
errorfname="${prefixR}/data/fc_rfe/errors_FCT_${suffix}.txt"

module load R # for PSC
for dataset in ${datasets[@]} # for all datasets
do
    while read -r line || [[ -n $line ]]; do # for al problem files, look at "done" line below to see that we are reading a *_problem.txt file line bby line
        for abc in {0..0}
        do
            for m in {0..0}
            do
                #if [[ -s "${prefixR}/data/fc_rfe/"${dataset}"_problems/"$line"_"${ABC[$abc]}"_AvgTs_AvgCs_FCT_input.txt" ]] ; then
                    #Rscript ${prefixR}/filterConcept.R "${prefixR}/data/fc_rfe/"${dataset}"_problems" $line"_"${ABC[$abc]}"_AvgTs_AvgCs_FCT_input.txt"  ${method[$m]} ${dataset} $fclogAvgTs_AvgCs $errorfname
                #fi
                if [[ -s "${prefixR}/data/fc_rfe/"${dataset}"_problems/"$line"_"${ABC[$abc]}"_AvgT_AvgCs_FCT_input.txt" ]] ; then
                    Rscript ${prefix}/code/filterConcept.R "${prefixR}/data/fc_rfe/"${dataset}"_problems" $line"_"${ABC[$abc]}"_AvgT_AvgCs_FCT_input.txt"  ${method[$m]} ${dataset} $fclogAvgT_AvgCs $errorfname
                fi
            done
        done
    done < ${prefixR}/data/${dataset}_problems.txt # this is where we are reading the problem list files line by line
done # all datasets
printf "finished concept filtering.\n"
