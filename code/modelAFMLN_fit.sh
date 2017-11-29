#!/bin/bash

#
# AFM fit
declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")
declare -a datasets=("ALL")
declare -a ABCD=("A" "B" "C" "D" "Alm" "Arfe")
declare -a ABCD_column=("17" "62" "63" "64" "65" "66") # concepts column
for dataset in ${datasets[@]}
do
    fname=./data/${dataset}_allsubmitABCDAlmArfe.txt
	NG=`wc -l <./data/${dataset}_voc/${dataset}_allsubmit_voc_student.txt`
    for abcd in {0..5}
    do
		echo ${dataset} ${ABCD[$abcd]} LN
        lldata=./data/${dataset}_liblineardata/${dataset}_allsubmit_llafm${ABCD[$abcd]}LN.txt
        llmodel=./model/${dataset}_allsubmit_llafm${ABCD[$abcd]}LN_model.txt
        llpredict=./predict/${dataset}_allsubmit_llafm${ABCD[$abcd]}LN_predict.txt
        NK=`wc -l <./data/${dataset}_voc/${dataset}_allsubmit_voc_skill${ABCD[$abcd]}.txt`
        ./bin/train -q -s 14 -g 1:1-$(($NG-1)) "${lldata}" "${llmodel}"
        ./bin/predict -b 1 "${lldata}" "${llmodel}" "${llpredict}"
    done
done
