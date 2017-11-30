#
# goodness of model estimator
#

# arg1 data file
# arg2 model file
# arg3 tet_graphs file
# arg4 goodness file
# arg5 reduced goodness file

# NU - previously exported as export NU=`wc -l < ./data/all_voc_users.txt`
# NP - previously exported as export NP=`wc -l < ./data/all_voc_tests.txt`
# NK - previously exported as export NK=`wc -l < ./data/all_voc_skills.txt` or export  NK=`wc -l < ./data/all_voc_skillsC.txt`


echo -e "from\tto\tadded\tremoved\tadded_s\tremoved_s" > $4
gawk -F" |:|\t" 'BEGIN{OFS="\t";nw=0; flip=0; fno=0;} {
	if(FNR==1) fno++;
	if(fno==1) {
		if($1=="label" && $2==-1) flip=1;
		if(nw>0) W[nw++]=$1*(1-flip) - $1*flip;
		if($1=="w") nw++;
	} else if(fno==2) {
		PK[$1]=$2;
	} else if(fno==3) {
		up = $2"__"$4;
		skills="_";
		skill_filter=PK[$4-'$((NU+0))'];
		for(i=6;i<=NF;i++) {
			# print "start '$(($NU+$NP+1))' finish '$(($NU+$NP+$NK))'"
			if( i%2==0 && $(i)>='$(($NU+$NP+$NK+1))' && $(i)<='$(($NU+$NP+$NK+$NK))' ) {
				k = ($(i) - '$(($NU+$NP+$NK))')",";
# 				print "check if "k" in "skill_filter" for "$4;
				if( index(skill_filter,k)>0 )
					skills=skills""$(i)"_";
			}
		}
		if( UPresult[up]=="" ) { # fill in initial skills
			UPresult[up]=$1;
			UPskills[up]=skills;
		} else {
			added=0;
			removed=0;
			added_s="";
			removed_s="";
			Nwas=split(UPskills[up],skills_was,"_");
			Nare=split(skills,skills_are,"_");
			## added
			for(i=1;i<=Nare;i++) {
				if(skills_are[i]!="") {
					if(!(skills_are[i] in skills_was)) {
						added+=W[skills_are[i]];
						added_s=added_s""((length(added_s)>0)?",":"")W[skills_are[i]];
						if( W[skills_are[i]]=="" ) print "ERROR in line "FNR". Weight for skill #"skills_are[i]"is null";
					}
				}
			}
			# removed
			for(i=1;i<=Nwas;i++) {
				if(skills_was[i]!="") {
					if(!(skills_was[i] in skills_are)) {
						removed+=W[skills_was[i]]
						removed_s=removed_s""((length(removed_s)>0)?",":"")W[skills_was[i]];
						if( W[skills_was[i]]=="" ) print "ERROR in line "FNR". Weight for previous skill #"skills_was[i]"is null";
					}
				}
			}
		
	# 		print "from",UPresult[up],"to",$1,"added",added,"removed",removed,"added_s",added_s,"removed_s",removed_s >> "'$3'";
			print UPresult[up],$1,added,removed,added_s,removed_s >> "'$4'";
			ss = ((UPresult[up]=="-1")?"N":"Y")""(($1=="-1")?"N":"Y")""((added>0)?"P":((added<0)?"N":"0"))""((removed>0)?"P":((removed<0)?"N":"0"));
			print ss > "'$5'";
		
			yy+=(substr(ss,1,2)=="YY");
			yn+=(substr(ss,1,2)=="YN");
			nn+=(substr(ss,1,2)=="NN");
			ny+=(substr(ss,1,2)=="NY");
	
			yyn00nnn+= (ss=="YYN0" || ss=="YY0N" || ss=="YYNN");
			ynn00nnn+= (ss=="YNN0" || ss=="YN0N" || ss=="YNNN");
			nnp00ppp+= (ss=="NNP0" || ss=="NN0P" || ss=="NNPP");
			nyp00ppp+= (ss=="NYP0" || ss=="NY0P" || ss=="NYPP");
		
			UPresult[up]=$1;
			UPskills[up]=skills;
		}
	}
}END{
	print (1-(yyn00nnn/yy)),"\t",(ynn00nnn/yn),"\t",(1-(nnp00ppp/nn)),"\t",(nyp00ppp/ny);
# 	for(pk in PK) print pk,PK[pk];
}' $2 $3 $1


# echo -e "from\tto\tadded\tremoved\tadded_s\tremoved_s" > $4
# gawk -F" |:|\t" 'BEGIN{OFS="\t";nw=0; flip=0; fno=0;} {
# 	if(FNR=1) fno++;
# 	if(fno==1){
# 		if($1=="label" && $2==-1) flip=1;
# 		if(nw>0) W[nw++]=$1*(1-flip) - $1*flip;
# 		if($1=="w") nw++;
# 	} else if(fno==2) {
# 		PK[$1]=$2;
# 	} else if(fno==3) {
# 		up = $2"__"$4;
# 		skills="_";
# 		skill_filter=PK[$4];
# 		for(i=6;i<=NF;i++) {
# 			# print "start '$(($NU+$NP+1))' finish '$(($NU+$NP+$NK))'"
# 			if( i%2==0 && $(i)>='$(($NU+$NP+1))' && $(i)<='$(($NU+$NP+$NK))' ) {
# # 				k = ($(i) - '$(($NU+$NP))')",";
# # 				print "check if "k" in "skill_filter" for "$4;
# # 				if( index(skill_filter,k)>0 )
# 					skills=skills""$(i)"_";
# 			}
# 		}
# 		if( UPresult[up]=="" ) { # fill in initial skills
# 			UPresult[up]=$1;
# 			UPskills[up]=skills;
# 		} else {
# 			added=0;
# 			removed=0;
# 			added_s="";
# 			removed_s="";
# 			Nwas=split(UPskills[up],skills_was,"_");
# 			Nare=split(skills,skills_are,"_");
# 			## added
# 			for(i=1;i<=Nare;i++) {
# 				if(skills_are[i]!="") {
# 					if(!(skills_are[i] in skills_was)) {
# 						added+=W[skills_are[i]];
# 						added_s=added_s""((length(added_s)>0)?",":"")W[skills_are[i]];
# 						if( W[skills_are[i]]=="" ) print "ERROR in line "FNR". Weight for skill #"skills_are[i]"is null";
# 					}
# 				}
# 			}
# 			# removed
# 			for(i=1;i<=Nwas;i++) {
# 				if(skills_was[i]!="") {
# 					if(!(skills_was[i] in skills_are)) {
# 						removed+=W[skills_was[i]]
# 						removed_s=removed_s""((length(removed_s)>0)?",":"")W[skills_was[i]];
# 						if( W[skills_was[i]]=="" ) print "ERROR in line "FNR". Weight for previous skill #"skills_was[i]"is null";
# 					}
# 				}
# 			}
# 		
# # 			print "from",UPresult[up],"to",$1,"added",added,"removed",removed,"added_s",added_s,"removed_s",removed_s >> "'$4'";
# 			print UPresult[up],$1,added,removed,added_s,removed_s >> "'$4'";
# 			ss = ((UPresult[up]=="-1")?"N":"Y")""(($1=="-1")?"N":"Y")""((added>0)?"P":((added<0)?"N":"0"))""((removed>0)?"P":((removed<0)?"N":"0"));
# 			print ss > "'$5'";
# 		
# 			yy+=(substr(ss,1,2)=="YY");
# 			yn+=(substr(ss,1,2)=="YN");
# 			nn+=(substr(ss,1,2)=="NN");
# 			ny+=(substr(ss,1,2)=="NY");
# 	
# 			yyn00nnn+= (ss=="YYN0" || ss=="YY0N" || ss=="YYNN");
# 			ynn00nnn+= (ss=="YNN0" || ss=="YN0N" || ss=="YNNN");
# 			nnp00ppp+= (ss=="NNP0" || ss=="NN0P" || ss=="NNPP");
# 			nyp00ppp+= (ss=="NYP0" || ss=="NY0P" || ss=="NYPP");
# 		
# 			UPresult[up]=$1;
# 			UPskills[up]=skills;
# 		}
# 	}
# }END{
# 	#print (1-(yyn00nnn/yy)),"\t",(ynn00nnn/yn),"\t",(1-(nnp00ppp/nn)),"\t",(nyp00ppp/ny);
# 	for(pk in PK) print pk,PK[pk];
# }' $2 $3 $1 
# 		
