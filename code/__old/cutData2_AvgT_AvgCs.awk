#
# student average over: acerage test success, multiple concepts for student attempts
#

BEGIN{
	fn=0;nk=0;nt=0;}
{
	if(FNR==1)fn++;            # file count
	if(fn==1) K[$1]=++nk;      # file 1: skills
	else if(fn==2){            # file 3: data
		if(FNR==1) {
			start=1;
			ss="1.0";
			for(k in K) ss=ss"\t"k;
			print ss;
            split("",student_tests);
			split("",student_skills);
			split("",student_N);
		}

        if ( $12 >= 0.0){
			student_N[$2]++;
			student_tests[$2] = student_tests[$2] + $12;
			if (param==0)
				m=split($17,_skills,",");
			else if (param==1)
				m=split($62,_skills,",");
			else if (param==2)
				m=split($63,_skills,",");
			else if (param==3)
				m=split($64,_skills,",");
			for(i=1;i<=m;i++) student_skills[$2,_skills[i]]++;
        }
	}
}
END {
	for(s in student_N) {
		ss="";#student_N[s]"";
        ss=sprintf("%s\t%4.3f",ss,student_tests[s]/student_N[s]);
		for(k in K)
			ss=sprintf("%s\t%4.3f",ss,student_skills[s,k]/student_N[s]);
		print ss;
	}
}