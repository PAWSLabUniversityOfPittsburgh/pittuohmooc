#!/bin/bash

#Step 1: generating input files for concept filtering
declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")
declare -a ABC=("A" "B" "C" "D")

rm -rf ./temp # remove if directory exists
mkdir ./temp # recreate it
mkdir ./data/fc #create directory fc if not exists

for dataset in ${datasets[@]} # for all datasets
do
    mkdir -p ./data/fc/${dataset}_problems
    fname="./data/${dataset}_allsubmitABCD.txt" # problem file name in a dataset
    while read -r line || [[ -n $line ]]; do # for al problem files, look at "done" line below to see that we are reading a *_problem.txt file line bby line

        #take subset of data that is for the current problem, exercise column is (4)
        #create columns for skills in A,B,C,D by droping the concepts counts from columns 17,62,63,64 respectively
        awk -F";" '{if($4 =="'$line'"){ print $0; }}' $fname > ./temp/temp.txt
        perl -pe 's/:-*[0-9]{1,4}//g' ./temp/temp.txt | perl -pe 's/,$//g'  > ./temp/data.txt

        #skill and test vocab for the problem,     individualPassedTests(14), originalConcepts(17), changedConceptsB(62),changedConceptsC(63),changedConceptsD(64)
        awk -F";" 'BEGIN{OFS=";";}{N++;n=split($17,skills,",");for(i=1;i<=n;i++)A[skills[i]]++;}END{for(a in A) if(a!="")print a,A[a],N,A[a]/N;}' ./temp/data.txt > ./temp/data_skillsA.txt
        awk -F";" 'BEGIN{OFS=";";}{N++;n=split($62,skills,",");for(i=1;i<=n;i++)A[skills[i]]++;}END{for(a in A) if(a!="")print a,A[a],N,A[a]/N;}' ./temp/data.txt > ./temp/data_skillsB.txt
        awk -F";" 'BEGIN{OFS=";";}{N++;n=split($63,skills,",");for(i=1;i<=n;i++)A[skills[i]]++;}END{for(a in A) if(a!="")print a,A[a],N,A[a]/N;}' ./temp/data.txt > ./temp/data_skillsC.txt
        awk -F";" 'BEGIN{OFS=";";}{N++;n=split($64,skills,",");for(i=1;i<=n;i++)A[skills[i]]++;}END{for(a in A) if(a!="")print a,A[a],N,A[a]/N;}' ./temp/data.txt > ./temp/data_skillsD.txt
        #awk -F";" 'BEGIN{OFS=";";}{    n=split($14,tests,","); for(i=1;i<=n;i++) A[tests[i]]++;}END{for(a in A) if(a!="")print a;}' ./temp/data.txt > ./temp/data_tests.txt

       for abc in {0..0}
       do
            #fnfcdataAvgTs_AvgCs="./data/fc/"${dataset}"_problems/"$line"_"${ABC[$abc]}"_AvgTs_AvgCs_FCT_input.txt" # the data for concept selection algorithm will be stored here
            #awk -v param="${abc}" -F";" -f ./cutData2_AvgTs_AvgCs.awk "./temp/data_skills"${ABC[$abc]}".txt" ./temp/data_tests.txt ./temp/data.txt | perl -pe 's/^\t//g' > $fnfcdataAvgTs_AvgCs
            fnfcdataAvgT_AvgCs="./data/fc/"${dataset}"_problems/"$line"_"${ABC[$abc]}"_AvgT_AvgCs_FCT_input.txt" # the data for concept selection algorithm will be stored here
            awk -v param="${abc}" -F";" -f ./code/cutData2_AvgT_AvgCs.awk "./temp/data_skills"${ABC[$abc]}".txt" ./temp/data.txt | perl -pe 's/^\t//g' > $fnfcdataAvgT_AvgCs

       done
    done < ./data/${dataset}_problems.txt # this is where we are reading the problem list files line by line
done # all datasets
rm -rf ./temp # remove the directory temp
printf "finished generating input files for concept filtering.\n"

