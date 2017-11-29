#
# produce skill vocabularies, A: col 16, B: col 28, C: col 29
#

BEGIN{na=0;nb=0;nc=0;}
{
	a = $16;
	b = $28;
	c = $29;

	# skills A
	N = split(a, K, ",")
	for(i=1;i<=N;i++) {
		if(K[i]!="") {
			split( K[i], ar, ":")
			if(A[ ar[1] ]==0) {
				A[ ar[1] ] = ++na;
			}			
		}
	}
	# skills B
	N = split(b, K, ",")
	for(i=1;i<=N;i++) {
		if(K[i]!="") {
			split( K[i], ar, ":")
			if(B[ ar[1] ]==0) {
				B[ ar[1] ] = ++nb;
			}			
		}
	}
	# skills C
	N = split(c, K, ",")
	for(i=1;i<=N;i++) {
		if(K[i]!="") {
			split( K[i], ar, ":")
			if(C[ ar[1] ]==0) {
				C[ ar[1] ] = ++nc;
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
}