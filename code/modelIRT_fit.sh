#!/bin/bash

#
# IRT fit
declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")
declare -a datasets=("ALL")
for dataset in ${datasets[@]}
do
	echo ${dataset}
    lldata=./data/${dataset}_liblineardata/${dataset}_allsubmit_llirt.txt
    llmodel=./model/${dataset}_allsubmit_llirt_model.txt
    llpredict=./predict/${dataset}_allsubmit_llirt_predict.txt
    NG=`wc -l <./data/${dataset}_voc/${dataset}_allsubmit_voc_student.txt`
    NI=`wc -l <./data/${dataset}_voc/${dataset}_allsubmit_voc_item.txt`
    ./bin/train -q -s 14 -g 2:1-$(($NG-1)),$(($NG-1+1))-$(($NG-1+$NI-1)) "${lldata}" "${llmodel}"
    ./bin/predict -b 1 "${lldata}" "${llmodel}" "${llpredict}"
done
