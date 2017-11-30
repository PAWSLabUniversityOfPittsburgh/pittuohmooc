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
	lldata=${prefixR}/data/${dataset}_liblineardata/${dataset}_allsubmit_llTFMcountPS12.txt
	llmodel=${prefixR}/model/${dataset}_allsubmit_llTFMcountPS12_model${costtag}.txt
	llpredict=${prefixR}/predict/${dataset}_allsubmit_llTFMcountPS12_predict${costtag}.txt
	llout=${prefixR}/out/${dataset}_allsubmit_llTFMcountPS12_out${costtag}.txt
	./bin/train -s 14 -c $cost -g 48,1:1787,1799:3586,3587:5374,5375:7162,7163:8950,8951:10738,10739:12526,12527:14314,14315:16102,16103:17890,17891:19678,19679:21466,24154:25941,25942:27729,27730:29517,29518:31305,31306:33093,33094:34881,34882:36669,36670:38457,38458:40245,40246:42033,42034:43821,43822:45609,45610:47397,47398:49185,49186:50973,50974:52761,52762:54549,54550:56337,56338:58125,58126:59913,59914:61701,61702:63489,63490:65277,65278:67065,67066:68853,68854:70641,70642:72429,72430:74217 "${lldata}" "${llmodel}"
	./bin/predict -b 1 "${lldata}" "${llmodel}" "${llpredict}" | tee "${llout}"
done
