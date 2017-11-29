BEGIN{OFS="\t";n=0;}NR==FNR{
	cp=$1"__"$2; 
	if( CPcnt[cp]==0 ) { # course problem count / start
		CPstart[cp]=n+1;
	}
	CPcnt[cp]++;
	CP[++n]=$3;
	next;
} {
	cp=$2;
	U[$1]++;
	# print "# from",CPstart[cp],"to",CPcnt[cp]+CPstart[cp]-1; 
	for(i=CPstart[cp]; i<=(CPstart[cp]+CPcnt[cp]-1); i++) {
		out=0;
		# print "* ",CP[i],$3,match($3,CP[i]); 
		if( match($3,CP[i])>0 ) { out=1; }
		T[$2"__"CP[i]]++;
		print out,$1,$2"__"CP[i],$4;
	}
	n=split($4,skills,",");
	for(i=1;i<=n;i++) K[skills[i]]++;
}
END{
	if(ENVIRON["dumpvoc"]==1) {
		nt = 0;
		nu = 0;
		nk = 0;
		for(t in T) { print t > "./data/all_voc_tests.txt"; nt++; }
		for(k in K) { print k > "./data/all_voc_skills.txt"; nk++; }
		for(u in U) { print u > "./data/all_voc_users.txt"; nu++; }
		for(cp in CPstart) print cp,CPstart[cp],CPcnt[cp] > "./data/all_voc_cps.txt";
	}
}
