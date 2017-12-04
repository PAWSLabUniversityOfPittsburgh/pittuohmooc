#
# produce skill vocabularies, A: col 17, B: col 30, C: col 31, D: col 32
#

BEGIN{na=0;nb=0;nc=0;nd=0;nalm=0;nafre=0;}
{
	a = $17;
	b = $62;
	c = $63;
	d = $64;
	alm = $65;
	arfe = $66;

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
	# skills D
	N = split(d, K, ",")
	for(i=1;i<=N;i++) {
		if(K[i]!="") {
			split( K[i], ar, ":")
			if(D[ ar[1] ]==0) {
				D[ ar[1] ] = ++nd;
			}			
		}
	}
	# skills A_lm
	N = split(alm, K, ",")
	for(i=1;i<=N;i++) {
		if(K[i]!="") {
			split( K[i], ar, ":")
			if(ALM[ ar[1] ]==0) {
				ALM[ ar[1] ] = ++nalm;
			}			
		}
	}
	# skills A_rfe
	N = split(arfe, K, ",")
	for(i=1;i<=N;i++) {
		if(K[i]!="") {
			split( K[i], ar, ":")
			if(ARFE[ ar[1] ]==0) {
				ARFE[ ar[1] ] = ++narfe;
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
	for(alm in ALM) {
		print alm"\t"ALM[alm] > ENVIRON["vocski"]"Alm.txt";
	}
	for(arfe in ARFE) {
		print arfe"\t"ARFE[arfe] > ENVIRON["vocski"]"Arfe.txt";
	}
}