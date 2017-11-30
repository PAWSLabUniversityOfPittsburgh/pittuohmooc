#  1 - student
#  3 - problem
#  6 - time
# 12 - passed tests
# 15 - originalConcepts
# 17 - baselineConcepts
# 19 - secondsSincePreviousSnapshot
# 20 - changedConcepts

BEGIN{OFS="\t";}
{
	# convert string to seconds timestamp
	cmd="date -j -f \"%Y-%m-%d %H:%M:%S\" \""$6"\" +%s`";
	cmd | getline TM; # TM - seconds since epoch
	close(cmd);
	
	TMsince=$19;
	if( UP[$1,$3]==0 ) { # first transaction
		if( $15 != $17) { 
			print $1, $3, $12, $17; # add baseline
			if( TMsince==0 ) print "Missing baseline snapshot and timeSince is 0 (line "FNR" in "FILENAME") " >> "errors.txt"
			TM0since=0;	
			TM0=TM-TMsince
		}
		UP[$1,$3]=1;
	} else {
		print $1, $3, $12, $15;
	}	
	
	if( $15 != $17) print $1, $3, $12, $17, $TM0, $TM0since;
	print $1, $3, $12, $15, TM, TMsince;
	
 		awk -F";" 'BEGIN{OFS="\t"; prevt=0;}{if($20!="" && $18!="null" && $18!="" && $18>=30){print $1,$3,$12,$15,$20,$6;} }' ${fname} > data0.txt
	
}
