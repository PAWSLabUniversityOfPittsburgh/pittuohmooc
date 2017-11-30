#!/bin/bash

#
#
# Behavior markup code
#
# 

# Dependencies
# - preprocess


# ========= start of behaviour labeling and merging that with the data =======

# un-compress _allsubmit_behav files
declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")
for dataset in ${datasets[@]} # for all dataset names in datasets array
do
   tar -xjvf data/${dataset}_all.tar.bz
done

./code/behavLbl_PSS4.sh >> temp.txt 2>&1 # behav & log files: ./data/${dataset}_allsubmit_behav_PSS4.txt  ./data/${dataset}_behavLbl_log_PSS4.txt"
./code/behavLbl_PS4.sh  >> temp.txt 2>&1 # behav & log files: ./data/${dataset}_allsubmit_behav_PS4.txt  ./data/${dataset}_behavLbl_log_PS4.txt
./code/behavLbl_PS12.sh >> temp.txt 2>&1 # behav & log files: ./data/${dataset}_allsubmit_behav_PS12.txt  ./data/${dataset}_behavLbl_log_PS12.txt

# lump _PSS4 _PS4 and _PS12 labels to single _all and _allsubmit file

declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")
rm -rf ./data/ALL_allsubmit.txt
for dataset in ${datasets[@]} # for all dataset names in datasets array
do
	echo "merge behaviors of " ${dataset}
	paste -d';' ./data/${dataset}_all.txt <(cut -f22-29 -d';' ./data/${dataset}_all_PSS4.txt) <(cut -f22-29 -d';' ./data/${dataset}_all_PS4.txt) <(cut -f22-45 -d';' ./data/${dataset}_all_PS12.txt) > ./data/${dataset}_all_new.txt
	rm -rf ./data/${dataset}_all.txt	
	mv ./data/${dataset}_all_new.txt ./data/${dataset}_all.txt
	wc -l ./data/${dataset}_all.txt
	echo "create _allsubmit of " ${dataset}
    grep -v ";GENERIC;" ./data/${dataset}_all.txt > ./data/${dataset}_allsubmit.txt
	wc -l ./data/${dataset}_allsubmit.txt
	echo "write to ALL_allsubmit from " ${dataset}
	grep -v ";GENERIC;" ./data/${dataset}_all.txt >> ./data/ALL_allsubmit.txt
done
wc -l ./data/ALL_allsubmit.txt
# merge behaviors of  s2014-ohpe
# 133370 ./data/s2014-ohpe_all.txt
# create _allsubmit of  s2014-ohpe
# 107143 ./data/s2014-ohpe_allsubmit.txt
# write to ALL_allsubmit from  s2014-ohpe
# merge behaviors of  s2015-ohpe
# 115560 ./data/s2015-ohpe_all.txt
# create _allsubmit of  s2015-ohpe
# 92591 ./data/s2015-ohpe_allsubmit.txt
# write to ALL_allsubmit from  s2015-ohpe
# merge behaviors of  k2015-mooc
# 338685 ./data/k2015-mooc_all.txt
# create _allsubmit of  k2015-mooc
# 274456 ./data/k2015-mooc_allsubmit.txt
# write to ALL_allsubmit from  k2015-mooc
# merge behaviors of  k2014-mooc
# 418890 ./data/k2014-mooc_all.txt
# create _allsubmit of  k2014-mooc
# 340206 ./data/k2014-mooc_allsubmit.txt
# write to ALL_allsubmit from  k2014-mooc
# 814396 ./data/ALL_allsubmit.txt

#
# compress and cleanup
#
declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")
for dataset in ${datasets[@]} # for all dataset names in datasets array
do
	tar -cvjf ./data/${dataset}_all.tar.bz ./data/${dataset}_all.txt
	tar -cvjf ./data/${dataset}_allsubmit.tar.bz ./data/${dataset}_allsubmit.txt
done
tar -cvjf ./data/ALL_allsubmit.tar.bz ./data/ALL_allsubmit.txt
# cleanup
declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")
for dataset in ${datasets[@]} # for all dataset names in datasets array
do
	rm -rf ./data/${dataset}_all_PS*.txt
	rm -rf ./data/${dataset}_all*.txt
	rm -rf ./data/${dataset}_behav*.txt
done
rm -rf ./data/ALL_allsubmit.txt

#