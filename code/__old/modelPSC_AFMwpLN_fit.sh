#!/bin/bash

#
# AFM fit
export prefix=/pylon2/ca4s8ip/yudelson/pittuohmooc
export prefixR=/pylon1/ca4s8ip/yudelson/pittuohmooc

declare -a datasets=("ALL")
declare -a ABCD=("A")
declare -a ABCD_column=("17") # concepts column
# declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")
# declare -a ABCD=("A" "B" "C" "D")
# declare -a ABCD_column=("17" "26" "27" "28") # concepts column
for dataset in ${datasets[@]}
do
	echo ${dataset}
    fname=${prefixR}/data/${dataset}_allsubmitABCD.txt
	NG=`wc -l <${prefixR}/data/${dataset}_voc/${dataset}_allsubmit_voc_student.txt`
    for abcd in {0..0} #0..3
    do
        lldata=${prefixR}/data/${dataset}_liblineardata/${dataset}_allsubmit_llafm${ABCD[$abcd]}wpLN.txt
        llmodel=${prefixR}/model/${dataset}_allsubmit_llafm${ABCD[$abcd]}wpLN_model.txt
        llpredict=${prefixR}/predict/${dataset}_allsubmit_llafm${ABCD[$abcd]}wpLN_predict.txt
        llout=${prefixR}/out/${dataset}_allsubmit_llafm${ABCD[$abcd]}wpLN_out.txt
	    NG=`wc -l <${prefixR}/data/${dataset}_voc/${dataset}_allsubmit_voc_student.txt`
        NK=`wc -l <${prefixR}/data/${dataset}_voc/${dataset}_allsubmit_voc_skill${ABCD[$abcd]}.txt`
        ./bin/train -q -s 14 -g 1:1-$(($NG-1)) "${lldata}" "${llmodel}"
        ./bin/predict -b 1 "${lldata}" "${llmodel}" "${llpredict}" | tee "${llout}"
    done
done
