#!/bin/bash

#
# AFM prep data
declare -a datasets=("s2014-ohpe" "s2015-ohpe" "k2015-mooc" "k2014-mooc")
declare -a datasets=("ALL")
declare -a ABCD=("A" "B" "C" "D" "Alm" "Arfe")
declare -a ABCD_column=("17" "62" "63" "64" "65" "66") # concepts column
for dataset in ${datasets[@]}
do
    fname=./data/${dataset}_allsubmitABCDAlmArfe.txt
    vocstu=./data/${dataset}_voc/${dataset}_allsubmit_voc_student.txt
    vocitm=./data/${dataset}_voc/${dataset}_allsubmit_voc_item.txt
    if [ ! -d "./data/${dataset}_liblineardata" ]; then
		mkdir ./data/${dataset}_liblineardata
	fi
    for abcd in {0..5}
    do
        vocskl=./data/${dataset}_voc/${dataset}_allsubmit_voc_skill${ABCD[$abcd]}.txt
        lldata=./data/${dataset}_liblineardata/${dataset}_allsubmit_llafm${ABCD[$abcd]}wp.txt
        export skl_col=${ABCD_column[$abcd]}
        awk -F"\t|;" 'BEGIN{fn=0;skl_col=ENVIRON["skl_col"]}{
            if(FNR==1) { fn++;}
            if(fn==1) {
                G[$1] = $2;
                ng++;
            }
            if(fn==2){
                S[$1] = $2;
                nk++;
            }
            if(fn==3){
                P[$1] = $2;
                np++;
            }
            if(fn==4){
                N = split($(skl_col), K, ","); # get skills parsed
                n=0;
				g = $2;
				p = $4;
                c = $3;
                split("",A);
                split("",AT);
                for(i=1;i<=N;i++) {
                    if(K[i]!="") {
                        split( K[i], ar, ":")
                        k = ar[1];
                        A[++n]=S[k];
                        gk=g"__"c"__"p"__"k;
                        t=(gk in T)?T[gk]:0;
                        AT[n]=t;
                        T[gk]++;
                    } # if not empty
                } # all skill:count pairs
                n=asort(A);
                
                ss="";
                sst="";
                for(i=1;i<=n;i++){
                    if(i==1 || (i>1 && A[i]!=A[i-1])) {
                        if(A[i]<nk && P[p]<np) ss=ss" "( (P[p]-1)*nk+A[i]+ng-1)":1";
                        sst=sst" "( (P[p]-1)*nk+A[i]+ng-1+nk*np-1 )":"AT[i];
                    } # if not repetition in one transaction
                } # for all skills
                print (($12=="1.0")?"+1":"-1")""((G[$2]<ng)?" "G[$2]":1":"")""ss""sst" "(ng-1+nk*np-1+nk*np+1)":1";
            }
        }' "${vocstu}" "${vocskl}" "${vocitm}" "${fname}" > "${lldata}"
    done
done
