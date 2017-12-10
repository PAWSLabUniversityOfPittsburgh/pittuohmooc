#
# Create a vocabulary for column defined in ENVIRON["col"]
# - here, all field is treated as one monolithic value
#

BEGIN{n=0; col=ENVIRON["col"];}
{
	if(V[$(col)]==0) {
		V[$(col)] = ++n;
	}
}
END{
	for(v in V) {
		print v"\t"V[v]
	}
}