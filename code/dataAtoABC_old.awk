#
# All two columns of concepts for B - just changes from previous submit
# and C - changes taking into account removals.
# Concepts are in column 
#

# GP - student, concepts array for a problem, keeps the last copy of concepts

BEGIN{}
{
	g = $2;
	k = $16;
	p = $4;
	B = ""; # concepts
	C = ""; # concepts
	if( G[g,p]=="" ) { # use all, it's a first submission
		B = k;
		C = k;
	} else {
		# split without counts
		prevN = split(G[g,p], PrevK1, ",")
		    N = split(k,          K1, ",")
		# separate out counts and names
		split("",PrevK2_k);
		split("",PrevK2_c);
		split("",PrevK2_rev_k);
		split("",K2_k);
		split("",K2_c);
		split("",K2_rev_k);
		for(i=1;i<=prevN;i++) {
			if(PrevK1[i]!="") {
				split( PrevK1[i], ar, ":")
				PrevK2_k[i] = ar[1];
				PrevK2_rev_k[ ar[1] ] = i; # reverse lookup, the key is concept
				PrevK2_c[i] = ar[2];
			} else {
				prevN--; # last element could be null
			}
		}
		for(i=1;i<=N;i++) {
			if(K1[i]!="") {
				split( K1[i], ar, ":")
				K2_k[i] = ar[1];
				K2_rev_k[ ar[1] ] = i; # reverse lookup, the key is concept
				K2_c[i] = ar[2];
			} else {
				N--; # last element could be null
			}
		}
		# compose B and C
		for(i=1;i<=N;i++) {
			if( !(K2_k[i] in PrevK2_rev_k) ) { # new
				B = B""K2_k[i]":"K2_c[i]",";
				C = C""K2_k[i]":"K2_c[i]",";
			}
		}
		for(i=1;i<=prevN;i++) {
			if( !(PrevK2_k[i] in K2_rev_k) ) { # new
				C = C""PrevK2_k[i]"__NEG:"PrevK2_c[i]",";
			}
		}
	}
	G[g,p] = k;
	print $0";"B";"C;
}
