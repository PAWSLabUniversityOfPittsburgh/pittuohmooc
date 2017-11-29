#
# produce item (col 4 now) and student (col 2 now) vocabularies, 
#

BEGIN{fn=0;ng=0;ni=0;}
{
	if(G[$2]==0) {
		G[$2] = ++ng;
	}
	if(I[$4]==0) {
		I[$4] = ++ni;
	}
}
END{
	for(g in G) {
		print g"\t"G[g] > ENVIRON["vocstu"];
	}
	for(i in I) {
		print i"\t"I[i] > ENVIRON["vocite"];
	}
}