#
# Extract concepts for course-problem's that are used in successful submissions only
#

# first argument is the data file

BEGIN{OFS="\t"; fn=1}{
	if($12=="1.0")
	# c = $3; # same problem name means the same problem across courses
	p = $4;
	N = split($17, K, ","); # get skills parsed
	for(i=1;i<=N;i++) {
		if(K[i]!="") {
			split( K[i], ar, ":")
			k = ar[1];
			if(posPK[p][k]==0 && $12=="1.0") {
				posPnK[p]++;
			}
			if($12=="1.0") {
				posPn[p]++;
			}
			if(allPK[p][k]==0) {
				allPnK[p]++;
			}
			allPn[p]++;
			if($12=="1.0") {
				posPK[p][k] += ar[2];
				posPsum[p]+=N;
			}
			allPK[p][k] += ar[2];
			allPsum[p]+=N;
		} # if not empty
	} # all skill:count pairs
}END{
	print "problem","concept","sumAllCounts";
	print "problem","posNConcepts","posAvgOccur","allNConceptsAll","allAvgOccur" > "./data/ALL_conceptsForSuccesses_courseProblemSummaries.txt";
	for(p in posPK) {
		for(k in posPK[p]) {
			if(posPK[p][k]>0) print p,k,posPK[p][k];
		}
		# summaries: number of concepts in problem, ratio the concept is part of submission (not the count within problem)
		print p,posPnK[p],posPsum[p]/posPn[p],allPnK[p],allPsum[p]/allPn[p] > "./data/ALL_conceptsForSuccesses_courseProblemSummaries.txt";
	}
}
