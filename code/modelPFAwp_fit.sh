#!/bin/bash

#
# PFA fit
declare -a datasets=("ALL")
declare -a ABCD=("A")
declare -a ABCD_column=("17") # concepts column
# declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")
# declare -a ABCD=("A" "B" "C" "D")
# declare -a ABCD_column=("17" "26" "27" "28") # concepts column
for dataset in ${datasets[@]}
do
	echo ${dataset}
    fname=./data/${dataset}_allsubmitABCDAlmArfe.txt
	NG=`wc -l <./data/${dataset}_voc/${dataset}_allsubmit_voc_student.txt`
    for abcd in {0..5}
    do
        lldata=./data/${dataset}_liblineardata/${dataset}_allsubmit_llpfa${ABCD[$abcd]}wp.txt
        llmodel=./model/${dataset}_allsubmit_llpfa${ABCD[$abcd]}wp_model.txt
        llpredict=./predict/${dataset}_allsubmit_llpfa${ABCD[$abcd]}wp_predict.txt
        ./bin/train -q -s 14 -g 1:1-$(($NG-1)) "${lldata}" "${llmodel}"
        ./bin/predict -b 1 "${lldata}" "${llmodel}" "${llpredict}"
    done
done
