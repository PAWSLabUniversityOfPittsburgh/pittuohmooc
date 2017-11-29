#
# implementing the by-student split design and generating the run make file
#

BEGIN{fn=0;}{
	if(FNR==1) fn++;
	if(fn==1) {
		C[$1] = $2;
		LC[$2]++;
		if(LC[$2]==1) NC++;
		for(i=1;i<=runs;i++) M[$1][i] = $(i+2);
		NG++;
	}
	if(fn==2) {
		for(i=1;i<=runs;i++) {
			if(M[$1][i]==1) print $2 >> "./data/"fname"/data/clust"C[$1]"_run"i"_fit.txt"
			if(M[$1][i]==2) print $2 >> "./data/"fname"/data/clust"C[$1]"_run"i"_test.txt"
		}
	}
}END{
	print "echo "fname" - fit "NC" models "runs" runs" >> "./data/"fname"/make.sh"
	for(lc in LC) {
		for(i=1;i<=runs;i++) {
			fdata="./data/"fname"/data/clust"lc"_run"i"_fit.txt"
			fmodel="./data/"fname"/model/clust"lc"_run"i"_fit_model.txt"
			print "./bin/train -q -s 14 -g 1:1-"(NG-1)" "fdata" "fmodel  >> "./data/"fname"/make.sh"
		}
	}
	print "echo "fname" - test "NC" models "runs" runs, across "NC" predictions" >> "./data/"fname"/make.sh"
	for(what in LC) { # predict what
		print "echo Predicting cluster "what >> "./data/"fname"/make.sh"
		for(who in LC) { # predict who
			print "echo    predictor cluster "who >> "./data/"fname"/make.sh"
			for(i=1;i<=runs;i++) {
				fdata="./data/"fname"/data/clust"what"_run"i"_test.txt"
				fmodel="./data/"fname"/model/clust"who"_run"i"_fit_model.txt"
				fpredict="./data/"fname"/predict/clust"what"_run"i"_test_by"who".txt"
				fout="./data/"fname"/result/tmp.txt"
				print "./bin/predict -b 1 "fdata" "fmodel" "fpredict" | tee -a "fout >> "./data/"fname"/make.sh"
			}
		}
	}
}