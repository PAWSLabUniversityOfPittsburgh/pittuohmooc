#
# time series data multiple tests, multiple concepts for student attempts
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
		}
		split("",tests);
		split("",skills);
		n=split($1,_tests,",");
		for(i=1;i<=n;i++) tests[_tests[i]]++;
		m=split($2,_skills,",");
		for(i=1;i<=m;i++) skills[_skills[i]]++;
		ss="";
		for(t in T)
			if(t in tests) ss=ss"\t1";
			else ss=ss"\t0";
		for(k in K)
			if(k in skills) ss=ss"\t1";
			else ss=ss"\t0";
		print ss;
	}
}