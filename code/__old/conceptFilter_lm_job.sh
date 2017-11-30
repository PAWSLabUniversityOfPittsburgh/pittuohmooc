#!/bin/bash

#Step 1: generating input files for concept filtering
declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")
declare -a ABC=("A" "B" "C" "D")

export prefix=/pylon2/ca4s8ip/yudelson/pittuohmooc
export prefixR=/pylon1/ca4s8ip/yudelson/pittuohmooc

rm -rf ${prefixR}/temp # remove if directory exists
mkdir ${prefixR}/temp # recreate it
mkdir ${prefixR}/data/fc_lm #create directory fc_lm if not exists

for dataset in ${datasets[@]} # for all datasets
do
    mkdir -p ${prefixR}/data/fc_lm/${dataset}_problems
    fname="${prefixR}/data/${dataset}_allsubmitABCD.txt" # problem file name in a dataset
    while read -r line || [[ -n $line ]]; do # for al problem files, look at "done" line below to see that we are reading a *_problem.txt file line bby line

        #take subset of data that is for the current problem, exercise column is (4)
        #create columns for skills in A,B,C,D by droping the concepts counts from columns 17,62,63,64 respectively
        awk -F";" '{if($4 =="'$line'"){ print $0; }}' $fname > ${prefixR}/temp/temp.txt
        perl -pe 's/:-*[0-9]{1,4}//g' ${prefixR}/temp/temp.txt | perl -pe 's/,$//g'  > ${prefixR}/temp/data.txt

        #skill and test vocab for the problem,     individualPassedTests(14), originalConcepts(17), changedConceptsB(62),changedConceptsC(63),changedConceptsD(64)
        awk -F";" 'BEGIN{OFS=";";}{N++;n=split($17,skills,",");for(i=1;i<=n;i++)A[skills[i]]++;}END{for(a in A) if(a!="")print a,A[a],N,A[a]/N;}' ${prefixR}/temp/data.txt > ${prefixR}/temp/data_skillsA.txt
        awk -F";" 'BEGIN{OFS=";";}{N++;n=split($62,skills,",");for(i=1;i<=n;i++)A[skills[i]]++;}END{for(a in A) if(a!="")print a,A[a],N,A[a]/N;}' ${prefixR}/temp/data.txt > ${prefixR}/temp/data_skillsB.txt
        awk -F";" 'BEGIN{OFS=";";}{N++;n=split($63,skills,",");for(i=1;i<=n;i++)A[skills[i]]++;}END{for(a in A) if(a!="")print a,A[a],N,A[a]/N;}' ${prefixR}/temp/data.txt > ${prefixR}/temp/data_skillsC.txt
        awk -F";" 'BEGIN{OFS=";";}{N++;n=split($64,skills,",");for(i=1;i<=n;i++)A[skills[i]]++;}END{for(a in A) if(a!="")print a,A[a],N,A[a]/N;}' ${prefixR}/temp/data.txt > ${prefixR}/temp/data_skillsD.txt
        #awk -F";" 'BEGIN{OFS=";";}{    n=split($14,tests,","); for(i=1;i<=n;i++) A[tests[i]]++;}END{for(a in A) if(a!="")print a;}' ${prefixR}/temp/data.txt > ${prefixR}/temp/data_tests.txt

       for abc in {0..0}
       do
            #fnfcdataAvgTs_AvgCs="${prefixR}/data/fc_lm/"${dataset}"_problems/"$line"_"${ABC[$abc]}"_AvgTs_AvgCs_FCT_input.txt" # the data for concept selection algorithm will be stored here
            #awk -v param="${abc}" -F";" -f ${prefixR}/cutData2_AvgTs_AvgCs.awk "${prefixR}/temp/data_skills"${ABC[$abc]}".txt" ${prefixR}/temp/data_tests.txt ${prefixR}/temp/data.txt | perl -pe 's/^\t//g' > $fnfcdataAvgTs_AvgCs
            fnfcdataAvgT_AvgCs="${prefixR}/data/fc_lm/"${dataset}"_problems/"$line"_"${ABC[$abc]}"_AvgT_AvgCs_FCT_input.txt" # the data for concept selection algorithm will be stored here
            awk -v param="${abc}" -F";" -f ${prefix}/code/cutData2_AvgT_AvgCs.awk "${prefixR}/temp/data_skills"${ABC[$abc]}".txt" ${prefixR}/temp/data.txt | perl -pe 's/^\t//g' > $fnfcdataAvgT_AvgCs

       done
    done < ${prefixR}/data/${dataset}_problems.txt # this is where we are reading the problem list files line by line
done # all datasets
rm -rf ${prefixR}/temp # remove the directory temp
printf "finished generating input files for concept filtering.\n"

#Step 2: running concept filtering methods
declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")
declare -a ABC=("A" "B" "C" "D")
declare -a method=("lm")


# create suffix for the name of the log name file
function join { local IFS="$1"; shift; echo "$*"; }
suffix=$(join _ ${datasets[@]})
#rm -f "${prefixR}/data/fc_lm/logAvgTs_AvgCs_FCT_${suffix}.txt" # remove if exist
rm -f "${prefixR}/data/fc_lm/logAvgT_AvgCs_FCT_${suffix}.txt" # remove if exist
rm -f "${prefixR}/data/fc_lm/errors_FCT_${suffix}.txt"
fclogAvgT_AvgCs="logAvgT_AvgCs_FCT_${suffix}.txt"
#fclogAvgTs_AvgCs="logAvgTs_AvgCs_FCT_${suffix}.txt"
errorfname="${prefixR}/data/fc_lm/errors_FCT_${suffix}.txt"

module load R # for PSC
for dataset in ${datasets[@]} # for all datasets
do
    while read -r line || [[ -n $line ]]; do # for al problem files, look at "done" line below to see that we are reading a *_problem.txt file line bby line
        for abc in {0..0}
        do
            for m in {0..0}
            do
                #if [[ -s "${prefixR}/data/fc_lm/"${dataset}"_problems/"$line"_"${ABC[$abc]}"_AvgTs_AvgCs_FCT_input.txt" ]] ; then
                    #Rscript ${prefixR}/filterConcept.R "${prefixR}/data/fc_lm/"${dataset}"_problems" $line"_"${ABC[$abc]}"_AvgTs_AvgCs_FCT_input.txt"  ${method[$m]} ${dataset} $fclogAvgTs_AvgCs $errorfname
                #fi
                if [[ -s "${prefixR}/data/fc_lm/"${dataset}"_problems/"$line"_"${ABC[$abc]}"_AvgT_AvgCs_FCT_input.txt" ]] ; then
                    Rscript ${prefix}/code/filterConcept.R "${prefixR}/data/fc_lm/"${dataset}"_problems" $line"_"${ABC[$abc]}"_AvgT_AvgCs_FCT_input.txt"  ${method[$m]} ${dataset} $fclogAvgT_AvgCs $errorfname
#                     R --slave < ${prefix}/code/filterConcept.R "${prefixR}/data/fc_lm/"${dataset}"_problems" $line"_"${ABC[$abc]}"_AvgT_AvgCs_FCT_input.txt"  ${method[$m]} ${dataset} $fclogAvgT_AvgCs $errorfname
                fi
            done
        done
    done < ${prefixR}/data/${dataset}_problems.txt # this is where we are reading the problem list files line by line
done # all datasets
printf "finished concept filtering.\n"
