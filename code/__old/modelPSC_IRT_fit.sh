#!/bin/bash

export prefix=/pylon2/ca4s8ip/yudelson/pittuohmooc
export prefixR=/pylon1/ca4s8ip/yudelson/pittuohmooc

#
# IRT fit
declare -a datasets=("ALL")
for dataset in ${datasets[@]}
do
	echo ${dataset}
    lldata=${prefixR}/data/${dataset}_liblineardata/${dataset}_allsubmit_llirt.txt
    llmodel=${prefixR}/model/${dataset}_allsubmit_llirt_model.txt
    llpredict=${prefixR}/predict/${dataset}_allsubmit_llirt_predict.txt
    llout=${prefixR}/out/${dataset}_allsubmit_llirt_out.txt
    NG=`wc -l <${prefixR}/data/${dataset}_voc/${dataset}_allsubmit_voc_student.txt`
    NI=`wc -l <${prefixR}/data/${dataset}_voc/${dataset}_allsubmit_voc_item.txt`
    ./bin/train -q -s 14 -g 2:1-$(($NG-1)),$(($NG-1+1))-$(($NG-1+$NI-1)) "${lldata}" "${llmodel}"
    ./bin/predict -b 1 "${lldata}" "${llmodel}" "${llpredict}" | tee "${llout}"
done
