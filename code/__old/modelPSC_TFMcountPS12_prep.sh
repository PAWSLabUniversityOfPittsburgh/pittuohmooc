#!/bin/bash

#
# The Fullest Model 1 prep data
# 4 behaviors, counts
#

declare -a datasets=("ALL")
declare -a ABCD=("A")
declare -a ABCD_column=("17") # concepts column
for dataset in ${datasets[@]}
do
    fname=./data/${dataset}_allsubmit.txt
    vocstu=./data/${dataset}_voc/${dataset}_allsubmit_voc_student.txt
    vocitm=./data/${dataset}_voc/${dataset}_allsubmit_voc_item.txt
    if [ ! -d "./data/${dataset}_liblineardata" ]; then
		mkdir ./data/${dataset}_liblineardata
	fi
	vocskl=./data/${dataset}_voc/${dataset}_allsubmit_voc_skill${ABCD[$abcd]}.txt
	lldata=./data/${dataset}_liblineardata/${dataset}_allsubmit_llTFMcountPS12.txt
	export skl_col=${ABCD_column[$abcd]}
	awk -F"\t|;" 'BEGIN{fn=0;skl_col=ENVIRON["skl_col"]; nb=12;}{
		if(FNR==1) { fn++;}
		if(fn==1) {
			G[$1] = $2;
			ng++;
		}
		if(fn==2){
			S[$1] = $2;
			nk++;
		}
		if(fn==3){
			P[$1] = $2;
			np++;
		}
		if(fn==4){
			N = split($(skl_col), K, ","); # get skills parsed
			n=0;
			g = $2;
			p = $4;
			c = $3; # course
			gc = g"__"c; # user (course)
			gcp = g"__"c"__"p; # user (course) - problem
			B[1] = $38; 
			B[2] = $39;
			B[3] = $40;
			B[4] = $41;
			B[5] = $42; 
			B[6] = $43;
			B[7] = $44;
			B[8] = $45;
			B[9] = $46; 
			B[10] = $47;
			B[11] = $48;
			B[12] = $49;
			# skill preparations
			split("",A);
			split("",AT);
			for(i=1;i<=N;i++) {
				if(K[i]!="") {
					split( K[i], ar, ":")
					k = ar[1];
					A[++n]=S[k]; # A - skill ids
					gpk=g"__"c"__"p"__"k; # user-problem-skill (with course)
					gk=g"__"c"__"k;       # user-skill (with course)
					
					tall=(gk in Tall)?Tall[gk]:0;
					tfail=(gk in Tfail)?Tfail[gk]:0;
					
					tpall=(gpk in Tall)?Tall[gpk]:0;
					tpfail=(gpk in Tfail)?Tfail[gpk]:0;
					
					ATall[n]=((tall==0)?tall:log(tall+1));    # ATall  - slopes of skill
					ATfail[n]=((tfail==0)?tfail:log(tfail+1));# ATfail - error slopes of skill
					Tall[gk]+=ar[2];
					if($12!="1.0")Tfail[gk]+=ar[2];
					
					ATPall[n]=((tpall==0)?tpall:log(tpall+1));    # ATPall  - slopes of skill within problem
					ATPfail[n]=((tpfail==0)?tpfail:log(tpfail+1));# ATPfail - error slopes of skill within problem
					TPall[gpk]+=ar[2];
					if($12!="1.0")TPfail[gpk]+=ar[2];
				} # if not empty
			} # all skill:count pairs
			n=asort(A);

			# collect output
			if(FNR==1) npools = 0; # number of pooled variables
			if(FNR==1) pools = ""; # specifications of the pools of the variables ",x-y,w-z,..."
			if(FNR==1) signature = ""; # signature of all fields
			output = (($12=="1.0")?"+1":"-1"); # outcome
			offset = 0; # feature index offset
			if(FNR==1) signature=signature" 0-0,outcome";
			
			#  1 Student ability (intercept)
			output = output""((G[g]<ng)?" "(offset + G[g])":1":"");
			if(FNR==1) npools++;
			if(FNR==1) pools=pools","(offset+1)":"(offset+ng-1);
			if(FNR==1) signature=signature";"(offset+1)":"(offset+ng-1)",student intercept";
			offset += ng - 1;
			
			#  2 Using behavior since previous submission (intercept)
			for(i=1;i<nb;i++) output = output""((B[i]>0)?" "(offset+i)":1":"");
			if(FNR==1) signature=signature";"(offset+1)":"(offset+nb-1)",behavior "i" intercept";
			offset += (nb-1);
			
			#  3 Using behavior since previous submission for particular student (intercept)
			#    Index variable, blocked by behavior
			for(i=1;i<nb;i++) {
				if(FNR==1) npools++;
				if(FNR==1) pools=pools","(offset+1)":"(offset+ng);
				output = output""((B[i]>0)?" "(offset+G[g])":1":"");
				if(FNR==1) signature=signature";"(offset+1)":"(offset+ng)",behavior "i" intercept across students";
				offset += ng;
			}
			
			#  4 Using behavior since previous submission for particular problem (intercept)
			#    Index variable, blocked by behavior
			for(i=1;i<nb;i++) {
				output = output""((B[i]>0)?" "(offset+P[p])":1":"");
				if(FNR==1) signature=signature";"(offset+1)":"(offset+np)",behavior "i" intercept across problems";
				offset += np;
			}
			
			#  5 Frequency of behavior since previous submission (slope)
			for(i=1;i<=nb;i++) output = output""((B[i]>0)?" "(offset+i)":"log(1+B[i]):"");
			if(FNR==1) signature=signature";"(offset+1)":"(offset+nb)",behavior slope";
			offset += nb;
			
			#  6 Frequency of behavior since start of user work (slope)
			for(i=1;i<=nb;i++) output = output" "(offset+i)":"log(1+BG[gc,i]);
			if(FNR==1) signature=signature";"(offset+1)":"(offset+nb)",behavior user slope";
			offset += nb;
			
			#  7 Frequency of behavior since start of problem (slope)
			for(i=1;i<=nb;i++) output = output" "(offset+i)":"log(1+BGP[gcp,i]);
			if(FNR==1) signature=signature";"(offset+1)":"(offset+nb)",behavior problem slope";
			offset += nb;
			
			#  8 Frequency of user behavior since previous submission (slope)
			for(i=1;i<=nb;i++) {
				if(FNR==1) npools++;
				output = output" "(offset+ G[g])":"log(1+B[i]);
				if(FNR==1) pools=pools","(offset+1)":"(offset+ng);
				if(FNR==1) signature=signature";"(offset+1)":"(offset+ng)",behavior "i" slope since submission for users";
				offset += ng;
			}
			
			#  9 Frequency of user behavior since start of user work (slope)
			for(i=1;i<=nb;i++) {
				if(FNR==1) npools++;
				output = output" "(offset+ G[g])":"log(1+BG[gc,i]);
				if(FNR==1) pools=pools","(offset+1)":"(offset+ng);
				if(FNR==1) signature=signature";"(offset+1)":"(offset+ng)",behavior "i" slope since start of work for users";
				offset += ng;
			}
			
			# 10 Frequency of user behavior since start of problem (slope)
			for(i=1;i<=nb;i++) {
				if(FNR==1) npools++;
				output = output" "(offset+G[g])":"log(1+BGP[gcp,i]);
				if(FNR==1) pools=pools","(offset+1)":"(offset+ng);
				if(FNR==1) signature=signature";"(offset+1)":"(offset+ng)",behavior "i" slope since start of work for problems";
				offset += ng;
			}
			
			# 11 Skill difficulty (intercept)
			for(i=1;i<=n;i++){
				if( ( i==1 || (i>1 && A[i]!=A[i-1]) ) && (A[i]<nk) ){
					output = output" "(offset + A[i])":1";
				}
			}
			if(FNR==1) signature=signature";"(offset+1)":"(offset+nk-1)",skill intercepts";
			offset += nk - 1;
			
			# 12 Skill difficulty within problem (intercept)
			for(i=1;i<=n;i++){
				if( ( i==1 || (i>1 && A[i]!=A[i-1]) ) && (A[i]<nk) ){
					output = output" "(offset + (nk-1)*(P[p]-1) + A[i])":1";
				}
			}	
			if(FNR==1) signature=signature";"(offset+1)":"(offset+(nk-1) * np)",skill-problem intercepts";
			offset += (nk-1) * np;
			
			# 13 Skill learning rate (slope)
			for(i=1;i<=n;i++){
				if( i==1 || (i>1 && A[i]!=A[i-1]) ){
					output = output" "(offset + A[i])":"log(ATall[i]+1);
				}
			}	
			if(FNR==1) signature=signature";"(offset+1)":"(offset+nk)",skill slopes";
			offset += nk;
			
			# 14 Skill learning rate from failures (slope)
			for(i=1;i<=n;i++){
				if( i==1 || (i>1 && A[i]!=A[i-1]) ){
					output = output" "(offset + A[i])":"log(ATfail[i]+1);
				}
			}	
			if(FNR==1) signature=signature";"(offset+1)":"(offset+nk)",skill failure slopes";
			offset += nk;
			
			# 15 Skill learning rate within problem (slope)
			for(i=1;i<=n;i++){
				if( i==1 || (i>1 && A[i]!=A[i-1]) ){
					output = output" "(offset + nk*(P[p]-1) + A[i])":"log(APTall[i]+1);
				}
			}	
			if(FNR==1) signature=signature";"(offset+1)":"(offset+nk*np)",skill-problem slopes";
			offset += nk*np;
			# 16 Skill learning rate from failures within problems (slope)
			for(i=1;i<=n;i++){
				if( i==1 || (i>1 && A[i]!=A[i-1]) ){
					output = output" "(offset + nk*(P[p]-1) + A[i])":"log(APTfail[i]+1);
				}
			}
			if(FNR==1) signature=signature";"(offset+1)":"(offset+nk*np)",skill-problem failure slopes";
			offset += nk*np;
			# 17 Bias
			output = output" "(offset+1)":1";
			if(FNR==1) signature=signature";"(offset+1)":"(offset+1)",bias";
			offset++;
			if(FNR==1) print "features "offset"\nsignature "signature"\npools "npools""pools >> "temp.txt";
			
			#
			print output;
			
			#
			# update variables
			#
			# handle behavior slopes
			BG[gc,1] += $38;  # for this user
			BG[gc,2] += $39;
			BG[gc,3] += $40;
			BG[gc,4] += $41;
			BG[gc,5] += $42;
			BG[gc,6] += $43;
			BG[gc,7] += $44;
			BG[gc,8] += $45;
			BG[gc,9] += $46;
			BG[gc,10] += $47;
			BG[gc,11] += $48;
			BG[gc,12] += $49;
			BGP[gcp,1] += $38;  # since start of this problem for this user
			BGP[gcp,2] += $39;
			BGP[gcp,3] += $40;
			BGP[gcp,4] += $41;
			BGP[gcp,5] += $42;
			BGP[gcp,6] += $43;
			BGP[gcp,7] += $44;
			BGP[gcp,8] += $45;
			BGP[gcp,9] += $46;
			BGP[gcp,10] += $47;
			BGP[gcp,11] += $48;
			BGP[gcp,12] += $49;
		}
	}' "${vocstu}" "${vocskl}" "${vocitm}" "${fname}" > "${lldata}"
done
