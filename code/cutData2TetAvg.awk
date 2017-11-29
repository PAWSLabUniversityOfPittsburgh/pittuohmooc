#
# student average over: acerage test success, multiple concepts for student attempts
#

BEGIN{
	fn=0;nk=0;nt=0;}
{
	if(FNR==1)fn++;            # file count
	if(fn==1) K[$1]=++nk;      # file 1: skills
	else if(fn==2) T[$1]=++nt; # file 2: tests
	else if(fn==3){            # file 3: data
		if(FNR==1) {
			start=1;
			ss="";
			for(t in T) {
				if(start==1) {
					ss=ss""t;
					start=0
				} else
					ss=ss"\t"t;
			}
			for(k in K) ss=ss"\t"k;
			print ss;
			split("",student_tests);
			split("",student_skills);
			split("",student_N);
		}
		student_N[$1]++;
		n=split($2,_tests,",");
		for(i=1;i<=n;i++) student_tests[$1,_tests[i]]++;
		m=split($3,_skills,",");
		for(i=1;i<=m;i++) student_skills[$1,_skills[i]]++;
	}
}
END {
	for(s in student_N) {
		ss="";#student_N[s]"";
		for(t in T)
			ss=sprintf("%s\t%4.3f",ss,student_tests[s,t]/student_N[s]);
		for(k in K)
			ss=sprintf("%s\t%4.3f",ss,student_skills[s,k]/student_N[s]);
		print ss;
	}
}