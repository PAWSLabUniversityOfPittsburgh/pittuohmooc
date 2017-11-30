#
# Answer, User, Problem, Skills to irt file
#

# assume presence of counts file with counts of U/P/K in positions $2,$4,$6
# skill delimiter ~

BEGIN{OFS="";nk=0;nu=0;np=0;}
NR==FNR{
	NU=$2; NP=$4; NK=$6; next;
} {
	if( !($2 in U) ) U[$2]=++nu;
	if( !($3 in P) ) P[$3]=++np;
	if (ENVIRON["noafm"]=="" || ENVIRON["noafm"]=="0" || ENVIRON["nopfa"]=="" || ENVIRON["nopfa"]=="0" ) {
		n=0;
		split("",A);
		split("",AT);
		split("",ATsucc);
		split("",ATfail);
		for(i=4;i<=NF && $(i)!="";i++){
			if( !($(i) in K) ) K[$(i)]=++nk;
			k = K[$(i)];		
			A[++n]=K[$(i)]+NU+NP;
			uk=$2"__"$(i);
			t=(uk in T)?T[uk]:0;
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
				ATsucc[n]=tsucc;
				ATfail[n]=tfail;
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
	if(ENVIRON["noirt"]=="" || ENVIRON["noirt"]=="0") print (($1==1)?"+1":"-1")," ",U[$2],":1 ",P[$3]+NU,":1" > "irt.txt";
	if(ENVIRON["noafm"]=="" || ENVIRON["noafm"]=="0") print (($1==1)?"+1":"-1")," ",U[$2],":1 ",P[$3]+NU,":1",ss,sst > "afm.txt";
	if(ENVIRON["nopfa"]=="" || ENVIRON["nopfa"]=="0") print (($1==1)?"+1":"-1")," ",U[$2],":1 ",P[$3]+NU,":1",ss,sstsucc,sstfail > "pfa.txt";
}
