#!/bin/bash

#
# IRT prep data
declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")
declare -a datasets=("ALL")
for dataset in ${datasets[@]}
do
    fname=./data/${dataset}_allsubmitABCDAlmArfe.txt
    vocstu=./data/${dataset}_voc/${dataset}_allsubmit_voc_student.txt
    vocitm=./data/${dataset}_voc/${dataset}_allsubmit_voc_item.txt
    lldata=./data/${dataset}_liblineardata/${dataset}_allsubmit_llirt.txt
    if [ ! -d "./data/${dataset}_liblineardata" ]; then
		mkdir ./data/${dataset}_liblineardata
	fi
    awk -F"\t|;" 'BEGIN{fn=0;}{
        if(FNR==1) { fn++;}
        if(fn==1) {
            G[$1] = $2;
            ng++;
        }
        if(fn==2){
            I[$1] = $2;
            ni++;
        }
        if(fn==3){
            print (($12=="1.0")?"+1":"-1")""((G[$2]<ng)?" "G[$2]":1":"")""((I[$4]<ni)?" "(I[$4]+ng-1)":1":"")" "(ng+ni-1)":1";
        }
    }' "${vocstu}" "${vocitm}" "${fname}" > "${lldata}"
done
