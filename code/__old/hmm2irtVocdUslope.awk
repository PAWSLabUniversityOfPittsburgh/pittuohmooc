#
# Answer, User, Problem, Skills to irt/afm/pfa file
#

BEGIN{OFS="";NK=0;NU=0;NP=0;fno=0;} {
	if(FNR==1) fno++;
	if(fno==1) { U[$2] = $1; NU++ }
	if(fno==2) { P[$2] = $1; NP++ }
	if(fno==3) { K[$2] = $1; NK ++ }
	if(fno==4) {
		if (ENVIRON["noafm"]=="" || ENVIRON["noafm"]=="0" || ENVIRON["nopfa"]=="" || ENVIRON["nopfa"]=="0" ) {
			if(Uslope[$2])
			n=0;
			split("",A);
			split("",AT);
			split("",ATsucc);
			split("",ATfail);
			for(i=4;i<=NF && $(i)!="";i++){
				k = K[$(i)];		
				A[++n]=K[$(i)]+2*NU+NP;
				uk=$2"__"$(i);
				if(!(uk in T)) T[uk]=0;
				t=T[uk];
				if(ENVIRON["logarithm"]==1)
					t = log(t+1);
				AT[n]=t;
				T[uk]++;
				# pfa stuff
				if(ENVIRON["nopfa"]=="" || ENVIRON["nopfa"]=="0") {
					tsucc=(uk in Tsucc)?Tsucc[uk]:0;
					tfail=(uk in Tfail)?Tfail[uk]:0;
					if(ENVIRON["logarithm"]==1) {
						tsucc = log(tsucc+1);
						tfail = log(tfail+1);
					}
					ATsucc[n]=tsucc+0;
					ATfail[n]=tfail+0;
					if($1==1)Tsucc[uk]++;
					else     Tfail[uk]++;
				} # pfa
			} # for all skills
			n=asort(A);
			ss="";
			sst="";
			sstsucc="";
			sstfail="";
			for(i=1;i<=n;i++){
				if(i==1 || (i>1 && A[i]!=A[i-1])) {
					ss=ss" "A[i]":1";
					sst=sst" "(A[i]+NK)":"AT[i];
					if(ENVIRON["nopfa"]=="" || ENVIRON["nopfa"]=="0") {
						sstsucc=sstsucc" "(A[i]+1*NK)":"ATsucc[i];
						sstfail=sstfail" "(A[i]+2*NK)":"ATfail[i];
					} # pfa
				} # if not repetition in one transaction
			} # for all skills
		} # if we have afm or pfa
		uslope = Uslope[$2]+0;
		if(ENVIRON["logarithm"]==1) {
			uslope = log( Uslope[$2]+1 );
		}
		if(ENVIRON["noirt"]=="" || ENVIRON["noirt"]=="0") print (($1==1)?"+1":"-1")," ",U[$2],":1 "                        ,P[$3]+2*NU,":1" > "irt"ENVIRON["random"]".txt";
		if(ENVIRON["noafm"]=="" || ENVIRON["noafm"]=="0") print (($1==1)?"+1":"-1")," ",U[$2],":1 ",U[$2]+NU,":",uslope," ",P[$3]+2*NU,":1",ss,sst > "afm"ENVIRON["random"]".txt";
		if(ENVIRON["nopfa"]=="" || ENVIRON["nopfa"]=="0") print (($1==1)?"+1":"-1")," ",U[$2],":1 ",U[$2]+NU,":",uslope," ",P[$3]+2*NU,":1",ss,sstsucc,sstfail > "pfa"ENVIRON["random"]".txt";
		Uslope[$2]++;
	} # main file
}
