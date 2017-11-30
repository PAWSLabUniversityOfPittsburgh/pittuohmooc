#
# produce skill vocabularies considering problems, A: col 17, B: col 30, C: col 31, D: col 32
#

BEGIN{na=0;nb=0;nc=0;}
{
	a = $17;
	b = $30;
	c = $31;
	d = $32;
	p = $4;

	# skills A
	N = split(a, K, ",")
	for(i=1;i<=N;i++) {
		if(K[i]!="") {
			split( K[i], ar, ":")
			if(A[ p"__"ar[1] ]==0) {
				A[ p"__"ar[1] ] = ++na;
			}			
		}
	}
	# skills B
	N = split(b, K, ",")
	for(i=1;i<=N;i++) {
		if(K[i]!="") {
			split( K[i], ar, ":")
			if(B[ p"__"ar[1] ]==0) {
				B[ p"__"ar[1] ] = ++nb;
			}			
		}
	}
	# skills C
	N = split(c, K, ",")
	for(i=1;i<=N;i++) {
		if(K[i]!="") {
			split( K[i], ar, ":")
			if(C[ p"__"ar[1] ]==0) {
				C[ p"__"ar[1] ] = ++nc;
			}			
		}
	}
	# skills D
	N = split(d, K, ",")
	for(i=1;i<=N;i++) {
		if(K[i]!="") {
			split( K[i], ar, ":")
			if(D[ p"__"ar[1] ]==0) {
				D[ p"__"ar[1] ] = ++nd;
			}			
		}
	}
}
END{
	for(a in A) {
		print a"\t"A[a] > ENVIRON["vocski"]"A.txt";
	}
	for(b in B) {
		print b"\t"B[b] > ENVIRON["vocski"]"B.txt";
	}
	for(c in C) {
		print c"\t"C[c] > ENVIRON["vocski"]"C.txt";
	}
	for(d in D) {
		print d"\t"D[d] > ENVIRON["vocski"]"D.txt";
	}
}