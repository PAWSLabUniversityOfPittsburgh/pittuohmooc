#!/bin/bash

#
# The Fullest Model 1 prep data
# 4 behaviors
export prefix=/pylon2/ca4s8ip/yudelson/pittuohmooc
export prefixR=/pylon1/ca4s8ip/yudelson/pittuohmooc

declare -a datasets=("ALL")
declare -a ABCD=("A")
declare -a ABCD_column=("17") # concepts column
cost="1.0"
costtag="_C"$cost
for dataset in ${datasets[@]}
do
	echo ${dataset}
    fname=${prefixR}/data/${dataset}_allsubmitABCD.txt
	lldata=${prefixR}/data/${dataset}_liblineardata/${dataset}_allsubmit_llTFMtimePSS4.txt
	llmodel=${prefixR}/model/${dataset}_allsubmit_llTFMtimePSS4_model${costtag}.txt
	llpredict=${prefixR}/predict/${dataset}_allsubmit_llTFMtimePSS4_predict${costtag}.txt
	llout=${prefixR}/out/${dataset}_allsubmit_llTFMtimePSS4_out${costtag}.txt
	./bin/train -s 14 -c $cost -g 16,1:1787,1791:3578,3579:5366,5367:7154,7890:9677,9678:11465,11466:13253,13254:15041,15042:16829,16830:18617,18618:20405,20406:22193,22194:23981,23982:25769,25770:27557,27558:29345 "${lldata}" "${llmodel}"
	./bin/predict -b 1 "${lldata}" "${llmodel}" "${llpredict}" | tee "${llout}"
done
