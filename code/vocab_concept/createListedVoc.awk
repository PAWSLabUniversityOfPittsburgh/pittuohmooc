#
# produce skill vocabularies, A: col 17 - in the original preprocess file, B: col 30, C: col 31, D: col 32
#

#
# Create a vocabulary for column defined in ENVIRON["col"]
# - here, each field is treated as comma-separated list
#

BEGIN{n=0; col=ENVIRON["col"];}
{
	N = split($(col), K, ",")
	for(i=1;i<=N;i++) {
		if(K[i]!="") {
			split( K[i], ar, ":")
			if(A[ ar[1] ]==0) {
				A[ ar[1] ] = ++n;
			}			
		}
	}
}
END{
	for(a in A) {
		print a"\t"A[a];
	}
}