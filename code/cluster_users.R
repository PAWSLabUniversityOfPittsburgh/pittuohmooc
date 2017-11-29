rm(list = ls());

################
# FUNCTIONS 
################
getColVars<- function(dataset_most_freq_patterns,a,b,c,d){
  vars=vector("character")
  vars = append(vars,colnames(dataset_most_freq_patterns)[c]);
  vars = append(vars,colnames(dataset_most_freq_patterns)[d]);
  for (i in a:b){
    varname = colnames(dataset_most_freq_patterns)[i]
    vars = append(vars,varname);
  }
  return (vars)
}

meanse<- function(x,mean_digits=4,se_digits=4){
  if (length(x) == 1){
    return (paste0(format(round(mean(x,na.rm=T),mean_digits),nsmall=mean_digits,scientific=FALSE),"(-)"))
  }else{
    return (paste0(format(round(mean(x,na.rm=T),mean_digits),nsmall=mean_digits,scientific=FALSE),"(",format(round(sd(x,na.rm=T)/sqrt(length(na.omit(x))),se_digits),nsmall=se_digits,scientific=FALSE),")"))
  }
}

my.mean<- function(x,mean_digits=4){
  return (as.numeric(format(round(mean(x,na.rm=T),mean_digits),nsmall=mean_digits,scientific=FALSE)))
}
my.se<- function(x,se_digits=4){
  return (as.numeric(format(round(sd(x,na.rm=T)/sqrt(length(na.omit(x))),se_digits),nsmall=se_digits,scientific=FALSE)))
}

generateGroupByFunction<-function(most.freq.patterns){
  txt0=""
  for (i in 7:ncol(most.freq.patterns)){
    varname = colnames(most.freq.patterns)[i]
    if (i < ncol(most.freq.patterns))
    {
      txt0 = paste0(txt0,paste0("sum",varname,"= sum(",varname,"),"),"\n")
    }else{
      txt0 = paste0(txt0,paste0("sum",varname,"= sum(",varname,")"),"\n")
    }
  }
  
  txt = cat("most.freq.patterns %>%\n",
    "group_by(user,dataset) %>%\n",
    "dplyr::summarize(\n",
      "sumcorrect=sum(avg.correct),\n",
      "sumattempt=sum(noattempt),\n", 
      "nexercises=length(exercise),\n",
      txt0,"\n",") -> dataset_most_freq_patterns")
  return (cat(gsub("\"", "", txt)))
}

generateSummary<-function(x,myfun){
  txt0=""
  for (i in 1:(ncol(x)-1)){
    varname = colnames(x)[i]
    if (i < (ncol(x)-1))
    {
      txt0 = paste0(txt0,paste0(varname,"=",myfun,"(",varname,"),"),"\n")
    }else{
      txt0 = paste0(txt0,paste0(varname,"=",myfun,"(",varname,")"),"\n")
    }
  }
  
  txt = cat("y %>%\n",
            "group_by(cluster) %>%\n",
            "dplyr::summarize(\n",
            "n=length(cluster),\n",
            txt0,"\n",") -> output")
  return (cat(gsub("\"", "", txt)))
}


######functions not used
######
NonNAlength<- function(x){
  return (length(x[!is.na(x)]))
}

maxbehav = function(v) {
  b = v[1]
  s = v[2]
  m = v[3]
  r = v[4]
  mx = max(c(b,s,m,r))
  res = ""
  if(b==mx) res = paste(res,"B",sep="")
  if(s==mx) res = paste(res,"S",sep="")
  if(r==mx) res = paste(res,"R",sep="")
  if(m==mx) res = paste(res,"M",sep="")
  return( res )
}

ovrmedbehav = function(v) {
  b = v[1]
  s = v[2]
  m = v[3]
  r = v[4]
  med = median(c(b,s,m,r))
  res = ""
  if(b>=med) res = paste(res,"B",sep="")
  if(s>=med) res = paste(res,"S",sep="")
  if(r>=med) res = paste(res,"R",sep="")
  if(m>=med) res = paste(res,"M",sep="")
  return( res )
}

################
# Read Data 
################
main.directory ='/Users/roya/Desktop/ProgMOOC/data'
#1. reading background information
input = 'backgrounds-encoded.tsv';
file.name <- file.path(main.directory, input);
metadata1<-read.csv(file.name,header = T,stringsAsFactors = T,sep="\t");
input = 'background-data.txt';
file.name <- file.path(main.directory, input);
metadata2<-read.table(file.name,header=T,stringsAsFactors = T,sep=" ",fill=T);
metadata<-merge(metadata1, metadata2, all.x=T,by.x='USER',by.y='student')

#check if Gender and gender column is same
t=subset(metadata, !is.na(GENDER))
nrow(subset(t, is.na(gender)))
#686
t=subset(metadata, !is.na(gender))
nrow(subset(t, is.na(GENDER)))
#0
###USING GENDER column gives us all available gender information

# metadata$firstgrade<-NA
# 
# for (i in 1:nrow(metadata))
# {
#   if (!is.na(metadata$credit_grade_csv[i]))
#   {
#     tmp<-strsplit(as.character(metadata$credit_grade_csv[i]), ",")
#     gradevec<-tmp[[1]]
#     metadata$firstgrade[i]<-as.numeric(gradevec[2])
# #     max = -1;
# #     for (j in 1:length(gradevec))
# #     {
# #       if (j%% 2==0)
# #       {
# #       if (as.numeric(gradevec[j])> max)
# #         max = as.numeric(gradevec[j])      
# #       }
# #     }
# #     metadata$firstgrade[i]<-max
#     }
# }

#2.reading behaviour summary for dataset-student-exercise
# input = 'sumBehavCorrectness.txt';
# file.name <- file.path("/Users/roya/Desktop/ProgMOOC/code/java/source_codes/progMooc/resource", input);
# data<-read.csv(file.name,header = T,stringsAsFactors = T);
# data$buildsec<-as.numeric(data$buildsec)
# data$reducesec<-as.numeric(data$reducesec)
# data$massagesec<-as.numeric(data$massagesec)
# data$strugglesec<-as.numeric(data$strugglesec)
# 

####################
# Behaviour Labeling
# Exercise
###################
##1.maxexercisebehav = maxBehav
# data$maxexercisebehav = apply(data[,c("builder","struggler","massager","reducer")],1,maxbehav)
# sort(table(data$maxexercisebehav))
# # RM   SRM   BRM     M    BM    SM  BSRM    BR    SR   BSM     R   BSR     B     S    BS 
# # 1     1     2     2     6    49    51   252   256   491   725  1549 40748 41319 57655 
# length(grep("B",data$maxexercisebehav))
# # 100754
# length(grep("S",data$maxexercisebehav))
# # 101371
# length(grep("R",data$maxexercisebehav))
# # 2837
# length(grep("M",data$maxexercisebehav))
# # 603
# 
##2.maxexercisebehav = ovrmedBehav
# data$ovrmedexercisebehav = apply(data[,c("builder","struggler","massager","reducer")],1,ovrmedbehav)
# sort(table(data$ovrmedexercisebehav))
# # RM    BRM    SRM     BM     SM     SR     BR    BSM    BSR   BSRM     BS 
# # 2     18     33     59    714   1201   1418   3838   5918   6191 123715 
# length(grep("B",data$ovrmedexercisebehav))
# # 141157
# length(grep("S",data$ovrmedexercisebehav))
# # 141610
# length(grep("R",data$ovrmedexercisebehav))
# # 14781
# length(grep("M",data$ovrmedexercisebehav))
# # 10855

################
# Prelim_stats 
################
# data<-merge(data, metadata, all.x=T,by.x='user',by.y='USER')
# 
# cor.test(data$percentage.correctness,data$firstgrade,method="spearman")
#rho = -0.00509011 , p > 0.05

################
# CLUSTERING 
################
######
#0. clustering based on most frequent patterns 
######
# reading most frequent patterns
input = 'ClusteringInputMostFrequentPattern.txt';
file.name <- file.path('/Users/roya/Desktop/ProgMOOC/code/java/source_codes/progMooc/resource', input);
most.freq.patterns<-read.csv(file.name,header = T,stringsAsFactors = T,sep=",");
nrow(subset(most.freq.patterns,  user ==""))

input = 'user-first-last-grade.txt';
file.name <- file.path('/Users/roya/Desktop/ProgMOOC/code/java/source_codes/progMooc/resource', input);
gradedf<-read.csv(file.name,header = F,stringsAsFactors = F,sep=",");
colnames(gradedf)<-c("user","firstgrade","lastgrade")

input = 'UserPerformanceSummary.txt';
file.name <- file.path('/Users/roya/Desktop/ProgMOOC/code/java/source_codes/progMooc/resource', input);
usrperf<-read.csv(file.name,header = F,stringsAsFactors = F,sep=",");
colnames(usrperf)<-c("dataset","usr","noProbsAttempted","noProbsSolved",
                       "percentageSolvedFromAttempted","averageAttmptOnSolvedProbs","avgTotalTimeOnSolvedProbs")

#merge with grade
usrperf<-merge(usrperf, gradedf, all.x=T,by.x='usr',by.y='user')
nrow(subset(usrperf,firstgrade==-2))

#effectiveness scores
mean.time=mean(usrperf$avgTotalTimeOnSolvedProbs);
sd.time=sd(usrperf$avgTotalTimeOnSolvedProbs)
mean.noProbsSolved=mean(usrperf$noProbsSolved);
sd.noProbsSolved=sd(usrperf$noProbsSolved)
usrperf$effscore=NA
for (i in 1:nrow(usrperf)){
  z.hour=(usrperf$avgTotalTimeOnSolvedProbs[i]-mean.time)/sd.time
  z.solved=(usrperf$noProbsSolved[i]-mean.noProbsSolved)/sd.noProbsSolved
  #the nagation is because if R-P<0 then E>0 & if R-P<0, then E>0
  #ref is (PAASand MERRIENBOER,1993, page 742)
  usrperf$effscore[i]=round(-(z.hour-z.solved)/sqrt(2),4)   
  
}
  
length(unique(usrperf$dataset))
length(unique(usrperf$usr))
summary(usrperf$noProbsAttempted)
summary(usrperf$noProbsSolved)
summary(usrperf$percentageSolvedFromAttempted)
summary(usrperf$averageAttmptOnSolvedProbs)
summary(usrperf$avgTotalTimeOnSolvedProbs)
summary(usrperf$effscore)
summary(usrperf$firstgrade)

library(dplyr)
generateGroupByFunction(most.freq.patterns)
######the code for generating summative vectors for the user
#####
most.freq.patterns %>%
  group_by(user,dataset) %>%
  dplyr::summarize(
    sumcorrect=sum(avg.correct),
    sumattempt=sum(noattempt),
    nexercises=length(exercise),
    sumAA= sum(AA),
    sumAD= sum(AD),
    sumX_AA= sum(X_AA),
    sumAa= sum(Aa),
    sumAA_= sum(AA_),
    sumDD= sum(DD),
    sumaA= sum(aA),
    sumAd= sum(Ad),
    sumAf= sum(Af),
    sumJJ= sum(JJ),
    sumAc= sum(Ac),
    sumDA= sum(DA),
    sumX_AD= sum(X_AD),
    sumDd= sum(Dd),
    sumJA= sum(JA),
    sumJc= sum(Jc),
    sumX_Af= sum(X_Af),
    sumdD= sum(dD),
    sumDE= sum(DE),
    sumJj= sum(Jj),
    sumAAA= sum(AAA),
    sumaa= sum(aa),
    sumX_Aa= sum(X_Aa),
    sumaD= sum(aD),
    sumED= sum(ED),
    sumX_JJ= sum(X_JJ),
    sumAa_= sum(Aa_),
    sumDe= sum(De),
    sumjJ= sum(jJ),
    sumdd= sum(dd),
    sumcA= sum(cA),
    sumJl= sum(Jl),
    sumX_AA_= sum(X_AA_),
    sumJK= sum(JK),
    sumdA= sum(dA),
    sumX_JA= sum(X_JA),
    sumfA= sum(fA),
    sumic= sum(ic),
    sumde= sum(de),
    sumJa= sum(Ja),
    sumeD= sum(eD),
    sumAE= sum(AE),
    sumci= sum(ci),
    sumX_Ad= sum(X_Ad),
    sumAe= sum(Ae),
    sumAC= sum(AC),
    sumDc= sum(Dc),
    sumed= sum(ed),
    sumad= sum(ad),
    sumJk= sum(Jk),
    sumX_Jc= sum(X_Jc),
    sumADD= sum(ADD),
    sumdE= sum(dE),
    sumjc= sum(jc),
    sumX_aA= sum(X_aA),
    sumaA_= sum(aA_),
    sumAF= sum(AF),
    sumEd= sum(Ed),
    sumlc= sum(lc),
    sumjA= sum(jA),
    sumJc_= sum(Jc_),
    sumaf= sum(af),
    sumX_Ac= sum(X_Ac),
    sumKJ= sum(KJ),
    sumjj= sum(jj),
    sumDf= sum(Df),
    sumAAD= sum(AAD),
    sumX_AAA= sum(X_AAA),
    sumDa= sum(Da),
    sumfD= sum(fD),
    sumDDD= sum(DDD),
    sumX_Jj= sum(X_Jj),
    sumcD= sum(cD),
    sumcc= sum(cc),
    sumcic= sum(cic),
    sumff= sum(ff),
    sumaa_= sum(aa_),
    sumAc_= sum(Ac_),
    sumJC= sum(JC),
    sumac= sum(ac),
    sumX_Ja= sum(X_Ja),
    sumAfA= sum(AfA),
    sumJL= sum(JL),
    sumX_Jl= sum(X_Jl),
    sumlJ= sum(lJ),
    sumX_Aa_= sum(X_Aa_),
    sumX_AfA= sum(X_AfA),
    sumjk= sum(jk),
    sumAB= sum(AB),
    sumkJ= sum(kJ),
    sumlA= sum(lA),
    sumjK= sum(jK),
    sumCA= sum(CA),
    sumX_aa= sum(X_aa),
    sumADA= sum(ADA),
    sumEA= sum(EA),
    sumDF= sum(DF),
    sumDC= sum(DC),
    sumfc= sum(fc),
    sumdf= sum(df),
    sumja= sum(ja),
    sumjl= sum(jl),
    sumeA= sum(eA),
    sumJA_= sum(JA_),
    sumX_Jc_= sum(X_Jc_),
    sumda= sum(da),
    sumAAa= sum(AAa),
    sumKj= sum(Kj),
    sumIc= sum(Ic),
    sumcf= sum(cf),
    sumJJJ= sum(JJJ),
    sumdc= sum(dc),
    sumFD= sum(FD),
    sumJB= sum(JB),
    sumAf_= sum(Af_),
    sumkj= sum(kj),
    sumAG= sum(AG),
    sumcl= sum(cl),
    sumDDE= sum(DDE),
    sumca= sum(ca),
    sumBA= sum(BA),
    sumfd= sum(fd),
    sumX_jA= sum(X_jA),
    sumDED= sum(DED),
    sumAaA= sum(AaA),
    sumX_AF= sum(X_AF),
    sumAAA_= sum(AAA_),
    sumX_aD= sum(X_aD),
    sumEE= sum(EE),
    sumJa_= sum(Ja_),
    sumX_jJ= sum(X_jJ),
    sumDA_= sum(DA_),
    sumX_af= sum(X_af),
    sumjc_= sum(jc_),
    sumBD= sum(BD),
    sumcI= sum(cI),
    sumee= sum(ee),
    sumDDd= sum(DDd),
    sumGc= sum(Gc),
    sumaAA= sum(aAA),
    sumfa= sum(fa),
    sumX_Ac_= sum(X_Ac_),
    sumEe= sum(Ee),
    sumCD= sum(CD),
    sumX_ADD= sum(X_ADD),
    sumX_AC= sum(X_AC),
    sumDB= sum(DB),
    sumAAd= sum(AAd),
    sumDdD= sum(DdD),
    sumKA= sum(KA),
    sumdDD= sum(dDD),
    sumJJK= sum(JJK),
    sumAC_= sum(AC_),
    sumici= sum(ici),
    sumAAAA= sum(AAAA),
    sumll= sum(ll),
    sumcd= sum(cd),
    sumeE= sum(eE),
    sumae= sum(ae),
    sumFf= sum(Ff),
    sumlj= sum(lj),
    sumAdA= sum(AdA),
    sumcA_= sum(cA_),
    sumADd= sum(ADd),
    sumcG= sum(cG),
    sumJKJ= sum(JKJ),
    sumX_ad= sum(X_ad),
    sumJb= sum(Jb),
    sumFA= sum(FA),
    sumLc= sum(Lc),
    sumaf_= sum(af_),
    sumEDD= sum(EDD),
    sumX_JA_= sum(X_JA_),
    sumaE= sum(aE),
    sumAd_= sum(Ad_),
    sumX_jc= sum(X_jc),
    sumfF= sum(fF),
    sumclc= sum(clc),
    sumX_Af_= sum(X_Af_),
    sumLJ= sum(LJ),
    sumfE= sum(fE),
    sumAdD= sum(AdD),
    sumX_Ja_= sum(X_Ja_),
    sumDDe= sum(DDe),
    sumX_aA_= sum(X_aA_),
    sumjA_= sum(jA_),
    sumX_JC= sum(X_JC),
    sumKa= sum(Ka),
    sumAb= sum(Ab),
    sumJC_= sum(JC_),
    sumfe= sum(fe),
    sumcici= sum(cici),
    sumDeD= sum(DeD),
    sumJJj= sum(JJj),
    sumef= sum(ef),
    sumicic= sum(icic),
    sumCc= sum(Cc),
    sumDdd= sum(Ddd),
    sumAD_= sum(AD_),
    sumEf= sum(Ef),
    sumX_jj= sum(X_jj),
    sumDDA= sum(DDA),
    sumJjJ= sum(JjJ),
    sumAJ= sum(AJ),
    sumac_= sum(ac_),
    sumlc_= sum(lc_),
    sumX_ac= sum(X_ac),
    sumX_ja= sum(X_ja),
    sumla= sum(la),
    sumea= sum(ea),
    sumDAA= sum(DAA),
    sumaC= sum(aC),
    sumdF= sum(dF),
    sumaF= sum(aF),
    sumic_= sum(ic_),
    sumX_JJJ= sum(X_JJJ),
    sumja_= sum(ja_),
    sumcC= sum(cC),
    sumX_JL= sum(X_JL),
    sumX_aa_= sum(X_aa_),
    sumcIc= sum(cIc),
    sumjJJ= sum(jJJ),
    sumcicic= sum(cicic),
    sumDed= sum(Ded),
    sumfA_= sum(fA_),
    sumDEd= sum(DEd),
    sumKK= sum(KK),
    sumADE= sum(ADE),
    sumjL= sum(jL),
    sumddD= sum(ddD),
    sumAdd= sum(Add),
    sumded= sum(ded),
    sumJJk= sum(JJk),
    sumce= sum(ce),
    sumKc= sum(Kc),
    sumX_JK= sum(X_JK),
    sumFd= sum(Fd),
    sumbA= sum(bA),
    sumdDd= sum(dDd),
    sumjC= sum(jC),
    sumFF= sum(FF),
    sumX_AAD= sum(X_AAD),
    sumDc_= sum(Dc_),
    sumDAD= sum(DAD),
    sumDb= sum(Db)
    
  ) -> dataset_most_freq_patterns
#####
dataset_most_freq_patterns<-merge(dataset_most_freq_patterns, metadata, all.x=T,by.x='user',by.y='USER')

####generating  percentage vectors (normalized vectors) dividing each number in the vector by sum of the numbers in the vector
dataset_most_freq_patterns$pcorrect<-NA
dataset_most_freq_patterns$avg.attempt<-NA
dataset_most_freq_patterns[,paste0(sub("sum","",colnames(dataset_most_freq_patterns)[6:250]))]<-NA
for (i in 1:nrow(dataset_most_freq_patterns)){
  dataset_most_freq_patterns$pcorrect[i]=(dataset_most_freq_patterns$sumcorrect[i]/dataset_most_freq_patterns$nexercises[i])
  dataset_most_freq_patterns$avg.attempt[i]=dataset_most_freq_patterns$sumattempt[i]/dataset_most_freq_patterns$nexercises[i]
  dataset_most_freq_patterns[i,paste0(sub("sum","",colnames(dataset_most_freq_patterns)[6:250]))]=(dataset_most_freq_patterns[i,colnames(dataset_most_freq_patterns)[6:250]]/rowSums(dataset_most_freq_patterns[i,6:250]))
  if (rowSums(dataset_most_freq_patterns[i,6:250])==0)#freqs did not occur in current user patterns
    dataset_most_freq_patterns[i,paste0(sub("sum","",colnames(dataset_most_freq_patterns)[6:250]))]=0
}

##distribution of rowSum
t<-rowSums(dataset_most_freq_patterns[,268:ncol(dataset_most_freq_patterns)])
hist(t)
summary(t)
table(t)
#####1.  clustering with kernlab package (FAILED)
#####
# library(kernlab) 
# tmp<-dataset_most_freq_patterns[1:nrow(dataset_most_freq_patterns),267:ncol(dataset_most_freq_patterns)]
# sc <- specc(cldata, centers=2)
# centers(sc)
# size(sc)
# withinss(sc)
# membership <- data.frame(tmp[,1],sc@.Data)
# names(membership) <- c("user","cluster")
# library(plyr)
# membership.users.count <- ddply(membership,"cluster",summarise,numUsers=length(userID))
# membership.users.count
#########

####PCA
########
# vars=getColVars(dataset_most_freq_patterns,267,ncol(dataset_most_freq_patterns),1,2)
# tmp = subset( dataset_most_freq_patterns, (user %in% metadata$USER))
# tmp <- tmp[,names(tmp) %in% vars]
# cldata<-tmp[1:nrow(tmp),6:ncol(tmp)]
# 
# sum(is.na(cldata))
# sum(is.infinite(as.matrix(cldata)))
# fit <- princomp(cldata, cor=TRUE)
# summary(fit)
# loadings(fit) # pc loadings 
# plot(fit,type="lines") # scree plot 
# fit$scores # the principal components
# biplot(fit)
# 
# library(nFactors)
# ev <- eigen(cor(cldata)) # get eigenvalues
# ap <- parallel(subject=nrow(cldata),var=ncol(cldata),rep=100,cent=.05)
# nS <- nScree(x=ev$values, aparallel=ap$eigen$qevpea)
# plotnScree(nS)
#optimal number of factors to extract
#31

# ###FA
# write.csv(x=cldata,
#           file = file.path('/Users/roya/Desktop/ProgMOOC/code/java/source_codes/progMooc/resource', 
#           paste("cldata.txt",sep="-")),row.names=F)
# library(Hmisc)
# fit <- factanal(cldata[,-1],31)
# print(fit) 


##extract
# corMat<-cor(cldata)
# library(psych)
# solution <- psych::principal(cldata, nfactors = 31, rotate = "varimax")
# solution

####TDA
# library(TDA)
# vars=getColVars(dataset_most_freq_patterns,267,ncol(dataset_most_freq_patterns),1,2)
# tmp = subset( dataset_most_freq_patterns, (user %in% metadata$USER))
# tmp <- tmp[,names(tmp) %in% vars]
# cldata<-tmp[1:nrow(tmp),6:ncol(tmp)]
# 
# sum(is.na(cldata))
# # 0
# sum(is.infinite(as.matrix(cldata)))
# # 0
# cl=clusterTree(cldata,k=100,density="knn",Nlambda=10)
# plot(cl)
# cluster_labels <- rep(1,dim(dataset_most_freq_patterns)[1])
# for(i in cl[["id"]]) {
#   cluster_labels[ cl[["DataPoints"]][[i]] ] <- i
# }
# table(cluster_labels)
#######


#####2. clustering with kknn package, 
#####
#leaving number of k to automatic, it picks only one cluster
# FAILED it does not work with 2 clusters
library(kknn)
set.seed(1)
vars=getColVars(dataset_most_freq_patterns,268,ncol(dataset_most_freq_patterns),1,2)
tmp = subset( dataset_most_freq_patterns, (user %in% metadata$USER))
tmp <- tmp[,names(tmp) %in% vars]
cldata<-tmp[1:nrow(tmp),3:ncol(tmp)]

cl <- kknn::specClust(cldata,centers=2) 
curClustVec=cl$cluster 
table(cl$cluster)
# 1   2 
# 295 503 

# 1   2   3 
#389 272 137 
######

######3. clustering with hierarchical clustering, 
#######
vars=getColVars(dataset_most_freq_patterns,268,ncol(dataset_most_freq_patterns),1,2)
tmp = subset( dataset_most_freq_patterns, (user %in% metadata$USER))
tmp = tmp[,names(tmp) %in% vars]

set.seed(1234)
D <- proxy::dist(tmp[,3:ncol(tmp)], method = "cosine")
cl  <- hclust(D, method="ward.D") 
plot(cl)
rect.hclust(cl, 2)
hc2 = cutree(cl, k = 2)
curClustVec = hc2
table(hc2)
# 1   2 
# 416 382 

plot(cl)
rect.hclust(cl, 3)
hc3 = cutree(cl, k = 3)
curClustVec = hc3
table(hc3)
# 1   2   3 
# 258 158 382 

plot(cl)
rect.hclust(cl, 4)
hc4 = cutree(cl, k = 4)
curClustVec = hc4
table(hc4)
# 1   2   3   4 
# 186 115 379 118
######

######save results
 hc = cl$cluster  
 k = 3
 type = "SpecClustPrevSnapAdaptTime3Sup1"
# #####
# hc = hc3
# k = 3
# type = "CosPrevSnapAdaptTime3Sup1"
# 
# hc = hc4
# k = 4
# type = "Hier4Cos"

####
vars=getColVars(dataset_most_freq_patterns,268,ncol(dataset_most_freq_patterns),1,2)
tmp = subset( dataset_most_freq_patterns, (user %in% metadata$USER))
tmp <- tmp[,names(tmp) %in% vars]
tmp=merge(tmp, usrperf, all.x=T,by.x='user',by.y='usr')
tmp=merge(tmp, metadata, all.x=T,by.x='user',by.y='USER')
tmp$progexp <- plyr::mapvalues(tmp$PROGRAMMING_EXPERIENCE, 
                from=c("None","SomeExperience","SomeExperienceTookACourse","WorkedInGroupAsProgrammer","WorkedInGroupAsProgrammerOverMultipleProjects"), 
                to=c("low","low","high","high","high"));
library(xlsx) #load the packagex
y=tmp[,c(3:247,249:256)]
y$cluster<-hc
y$lastgrade[y$lastgrade==-2]=NA
y$firstgrade[y$firstgrade==-2]=NA

generateSummary(y,"my.mean")
output=NULL
############
#####
y %>%
  group_by(cluster) %>%
  dplyr::summarize(
    n=length(cluster),
    AA=my.mean(AA),
    AD=my.mean(AD),
    X_AA=my.mean(X_AA),
    Aa=my.mean(Aa),
    AA_=my.mean(AA_),
    DD=my.mean(DD),
    aA=my.mean(aA),
    Ad=my.mean(Ad),
    Af=my.mean(Af),
    JJ=my.mean(JJ),
    Ac=my.mean(Ac),
    DA=my.mean(DA),
    X_AD=my.mean(X_AD),
    Dd=my.mean(Dd),
    JA=my.mean(JA),
    Jc=my.mean(Jc),
    X_Af=my.mean(X_Af),
    dD=my.mean(dD),
    DE=my.mean(DE),
    Jj=my.mean(Jj),
    AAA=my.mean(AAA),
    aa=my.mean(aa),
    X_Aa=my.mean(X_Aa),
    aD=my.mean(aD),
    ED=my.mean(ED),
    X_JJ=my.mean(X_JJ),
    Aa_=my.mean(Aa_),
    De=my.mean(De),
    jJ=my.mean(jJ),
    dd=my.mean(dd),
    cA=my.mean(cA),
    Jl=my.mean(Jl),
    X_AA_=my.mean(X_AA_),
    JK=my.mean(JK),
    dA=my.mean(dA),
    X_JA=my.mean(X_JA),
    fA=my.mean(fA),
    ic=my.mean(ic),
    de=my.mean(de),
    Ja=my.mean(Ja),
    eD=my.mean(eD),
    AE=my.mean(AE),
    ci=my.mean(ci),
    X_Ad=my.mean(X_Ad),
    Ae=my.mean(Ae),
    AC=my.mean(AC),
    Dc=my.mean(Dc),
    ed=my.mean(ed),
    ad=my.mean(ad),
    Jk=my.mean(Jk),
    X_Jc=my.mean(X_Jc),
    ADD=my.mean(ADD),
    dE=my.mean(dE),
    jc=my.mean(jc),
    X_aA=my.mean(X_aA),
    aA_=my.mean(aA_),
    AF=my.mean(AF),
    Ed=my.mean(Ed),
    lc=my.mean(lc),
    jA=my.mean(jA),
    Jc_=my.mean(Jc_),
    af=my.mean(af),
    X_Ac=my.mean(X_Ac),
    KJ=my.mean(KJ),
    jj=my.mean(jj),
    Df=my.mean(Df),
    AAD=my.mean(AAD),
    X_AAA=my.mean(X_AAA),
    Da=my.mean(Da),
    fD=my.mean(fD),
    DDD=my.mean(DDD),
    X_Jj=my.mean(X_Jj),
    cD=my.mean(cD),
    cc=my.mean(cc),
    cic=my.mean(cic),
    ff=my.mean(ff),
    aa_=my.mean(aa_),
    Ac_=my.mean(Ac_),
    JC=my.mean(JC),
    ac=my.mean(ac),
    X_Ja=my.mean(X_Ja),
    AfA=my.mean(AfA),
    JL=my.mean(JL),
    X_Jl=my.mean(X_Jl),
    lJ=my.mean(lJ),
    X_Aa_=my.mean(X_Aa_),
    X_AfA=my.mean(X_AfA),
    jk=my.mean(jk),
    AB=my.mean(AB),
    kJ=my.mean(kJ),
    lA=my.mean(lA),
    jK=my.mean(jK),
    CA=my.mean(CA),
    X_aa=my.mean(X_aa),
    ADA=my.mean(ADA),
    EA=my.mean(EA),
    DF=my.mean(DF),
    DC=my.mean(DC),
    fc=my.mean(fc),
    df=my.mean(df),
    ja=my.mean(ja),
    jl=my.mean(jl),
    eA=my.mean(eA),
    JA_=my.mean(JA_),
    X_Jc_=my.mean(X_Jc_),
    da=my.mean(da),
    AAa=my.mean(AAa),
    Kj=my.mean(Kj),
    Ic=my.mean(Ic),
    cf=my.mean(cf),
    JJJ=my.mean(JJJ),
    dc=my.mean(dc),
    FD=my.mean(FD),
    JB=my.mean(JB),
    Af_=my.mean(Af_),
    kj=my.mean(kj),
    AG=my.mean(AG),
    cl=my.mean(cl),
    DDE=my.mean(DDE),
    ca=my.mean(ca),
    BA=my.mean(BA),
    fd=my.mean(fd),
    X_jA=my.mean(X_jA),
    DED=my.mean(DED),
    AaA=my.mean(AaA),
    X_AF=my.mean(X_AF),
    AAA_=my.mean(AAA_),
    X_aD=my.mean(X_aD),
    EE=my.mean(EE),
    Ja_=my.mean(Ja_),
    X_jJ=my.mean(X_jJ),
    DA_=my.mean(DA_),
    X_af=my.mean(X_af),
    jc_=my.mean(jc_),
    BD=my.mean(BD),
    cI=my.mean(cI),
    ee=my.mean(ee),
    DDd=my.mean(DDd),
    Gc=my.mean(Gc),
    aAA=my.mean(aAA),
    fa=my.mean(fa),
    X_Ac_=my.mean(X_Ac_),
    Ee=my.mean(Ee),
    CD=my.mean(CD),
    X_ADD=my.mean(X_ADD),
    X_AC=my.mean(X_AC),
    DB=my.mean(DB),
    AAd=my.mean(AAd),
    DdD=my.mean(DdD),
    KA=my.mean(KA),
    dDD=my.mean(dDD),
    JJK=my.mean(JJK),
    AC_=my.mean(AC_),
    ici=my.mean(ici),
    AAAA=my.mean(AAAA),
    ll=my.mean(ll),
    cd=my.mean(cd),
    eE=my.mean(eE),
    ae=my.mean(ae),
    Ff=my.mean(Ff),
    lj=my.mean(lj),
    AdA=my.mean(AdA),
    cA_=my.mean(cA_),
    ADd=my.mean(ADd),
    cG=my.mean(cG),
    JKJ=my.mean(JKJ),
    X_ad=my.mean(X_ad),
    Jb=my.mean(Jb),
    FA=my.mean(FA),
    Lc=my.mean(Lc),
    af_=my.mean(af_),
    EDD=my.mean(EDD),
    X_JA_=my.mean(X_JA_),
    aE=my.mean(aE),
    Ad_=my.mean(Ad_),
    X_jc=my.mean(X_jc),
    fF=my.mean(fF),
    clc=my.mean(clc),
    X_Af_=my.mean(X_Af_),
    LJ=my.mean(LJ),
    fE=my.mean(fE),
    AdD=my.mean(AdD),
    X_Ja_=my.mean(X_Ja_),
    DDe=my.mean(DDe),
    X_aA_=my.mean(X_aA_),
    jA_=my.mean(jA_),
    X_JC=my.mean(X_JC),
    Ka=my.mean(Ka),
    Ab=my.mean(Ab),
    JC_=my.mean(JC_),
    fe=my.mean(fe),
    cici=my.mean(cici),
    DeD=my.mean(DeD),
    JJj=my.mean(JJj),
    ef=my.mean(ef),
    icic=my.mean(icic),
    Cc=my.mean(Cc),
    Ddd=my.mean(Ddd),
    AD_=my.mean(AD_),
    Ef=my.mean(Ef),
    X_jj=my.mean(X_jj),
    DDA=my.mean(DDA),
    JjJ=my.mean(JjJ),
    AJ=my.mean(AJ),
    ac_=my.mean(ac_),
    lc_=my.mean(lc_),
    X_ac=my.mean(X_ac),
    X_ja=my.mean(X_ja),
    la=my.mean(la),
    ea=my.mean(ea),
    DAA=my.mean(DAA),
    aC=my.mean(aC),
    dF=my.mean(dF),
    aF=my.mean(aF),
    ic_=my.mean(ic_),
    X_JJJ=my.mean(X_JJJ),
    ja_=my.mean(ja_),
    cC=my.mean(cC),
    X_JL=my.mean(X_JL),
    X_aa_=my.mean(X_aa_),
    cIc=my.mean(cIc),
    jJJ=my.mean(jJJ),
    cicic=my.mean(cicic),
    Ded=my.mean(Ded),
    fA_=my.mean(fA_),
    DEd=my.mean(DEd),
    KK=my.mean(KK),
    ADE=my.mean(ADE),
    jL=my.mean(jL),
    ddD=my.mean(ddD),
    Add=my.mean(Add),
    ded=my.mean(ded),
    JJk=my.mean(JJk),
    ce=my.mean(ce),
    Kc=my.mean(Kc),
    X_JK=my.mean(X_JK),
    Fd=my.mean(Fd),
    bA=my.mean(bA),
    dDd=my.mean(dDd),
    jC=my.mean(jC),
    FF=my.mean(FF),
    X_AAD=my.mean(X_AAD),
    Dc_=my.mean(Dc_),
    DAD=my.mean(DAD),
    Db=my.mean(Db),
    noProbsAttempted=my.mean(noProbsAttempted),
    noProbsSolved=my.mean(noProbsSolved),
    percentageSolvedFromAttempted=my.mean(percentageSolvedFromAttempted),
    averageAttmptOnSolvedProbs=my.mean(averageAttmptOnSolvedProbs),
    avgTotalTimeOnSolvedProbs=my.mean(avgTotalTimeOnSolvedProbs),
    firstgrade=my.mean(firstgrade),
    lastgrade=my.mean(lastgrade),
    effscore=my.mean(effscore)
    
  ) -> output
###########

res=NULL
res=output
output=NULL
generateSummary(y,"my.se")
############
######
y %>%
  group_by(cluster) %>%
  dplyr::summarize(
    n=length(cluster),
    AA=my.se(AA),
    AD=my.se(AD),
    X_AA=my.se(X_AA),
    Aa=my.se(Aa),
    AA_=my.se(AA_),
    DD=my.se(DD),
    aA=my.se(aA),
    Ad=my.se(Ad),
    Af=my.se(Af),
    JJ=my.se(JJ),
    Ac=my.se(Ac),
    DA=my.se(DA),
    X_AD=my.se(X_AD),
    Dd=my.se(Dd),
    JA=my.se(JA),
    Jc=my.se(Jc),
    X_Af=my.se(X_Af),
    dD=my.se(dD),
    DE=my.se(DE),
    Jj=my.se(Jj),
    AAA=my.se(AAA),
    aa=my.se(aa),
    X_Aa=my.se(X_Aa),
    aD=my.se(aD),
    ED=my.se(ED),
    X_JJ=my.se(X_JJ),
    Aa_=my.se(Aa_),
    De=my.se(De),
    jJ=my.se(jJ),
    dd=my.se(dd),
    cA=my.se(cA),
    Jl=my.se(Jl),
    X_AA_=my.se(X_AA_),
    JK=my.se(JK),
    dA=my.se(dA),
    X_JA=my.se(X_JA),
    fA=my.se(fA),
    ic=my.se(ic),
    de=my.se(de),
    Ja=my.se(Ja),
    eD=my.se(eD),
    AE=my.se(AE),
    ci=my.se(ci),
    X_Ad=my.se(X_Ad),
    Ae=my.se(Ae),
    AC=my.se(AC),
    Dc=my.se(Dc),
    ed=my.se(ed),
    ad=my.se(ad),
    Jk=my.se(Jk),
    X_Jc=my.se(X_Jc),
    ADD=my.se(ADD),
    dE=my.se(dE),
    jc=my.se(jc),
    X_aA=my.se(X_aA),
    aA_=my.se(aA_),
    AF=my.se(AF),
    Ed=my.se(Ed),
    lc=my.se(lc),
    jA=my.se(jA),
    Jc_=my.se(Jc_),
    af=my.se(af),
    X_Ac=my.se(X_Ac),
    KJ=my.se(KJ),
    jj=my.se(jj),
    Df=my.se(Df),
    AAD=my.se(AAD),
    X_AAA=my.se(X_AAA),
    Da=my.se(Da),
    fD=my.se(fD),
    DDD=my.se(DDD),
    X_Jj=my.se(X_Jj),
    cD=my.se(cD),
    cc=my.se(cc),
    cic=my.se(cic),
    ff=my.se(ff),
    aa_=my.se(aa_),
    Ac_=my.se(Ac_),
    JC=my.se(JC),
    ac=my.se(ac),
    X_Ja=my.se(X_Ja),
    AfA=my.se(AfA),
    JL=my.se(JL),
    X_Jl=my.se(X_Jl),
    lJ=my.se(lJ),
    X_Aa_=my.se(X_Aa_),
    X_AfA=my.se(X_AfA),
    jk=my.se(jk),
    AB=my.se(AB),
    kJ=my.se(kJ),
    lA=my.se(lA),
    jK=my.se(jK),
    CA=my.se(CA),
    X_aa=my.se(X_aa),
    ADA=my.se(ADA),
    EA=my.se(EA),
    DF=my.se(DF),
    DC=my.se(DC),
    fc=my.se(fc),
    df=my.se(df),
    ja=my.se(ja),
    jl=my.se(jl),
    eA=my.se(eA),
    JA_=my.se(JA_),
    X_Jc_=my.se(X_Jc_),
    da=my.se(da),
    AAa=my.se(AAa),
    Kj=my.se(Kj),
    Ic=my.se(Ic),
    cf=my.se(cf),
    JJJ=my.se(JJJ),
    dc=my.se(dc),
    FD=my.se(FD),
    JB=my.se(JB),
    Af_=my.se(Af_),
    kj=my.se(kj),
    AG=my.se(AG),
    cl=my.se(cl),
    DDE=my.se(DDE),
    ca=my.se(ca),
    BA=my.se(BA),
    fd=my.se(fd),
    X_jA=my.se(X_jA),
    DED=my.se(DED),
    AaA=my.se(AaA),
    X_AF=my.se(X_AF),
    AAA_=my.se(AAA_),
    X_aD=my.se(X_aD),
    EE=my.se(EE),
    Ja_=my.se(Ja_),
    X_jJ=my.se(X_jJ),
    DA_=my.se(DA_),
    X_af=my.se(X_af),
    jc_=my.se(jc_),
    BD=my.se(BD),
    cI=my.se(cI),
    ee=my.se(ee),
    DDd=my.se(DDd),
    Gc=my.se(Gc),
    aAA=my.se(aAA),
    fa=my.se(fa),
    X_Ac_=my.se(X_Ac_),
    Ee=my.se(Ee),
    CD=my.se(CD),
    X_ADD=my.se(X_ADD),
    X_AC=my.se(X_AC),
    DB=my.se(DB),
    AAd=my.se(AAd),
    DdD=my.se(DdD),
    KA=my.se(KA),
    dDD=my.se(dDD),
    JJK=my.se(JJK),
    AC_=my.se(AC_),
    ici=my.se(ici),
    AAAA=my.se(AAAA),
    ll=my.se(ll),
    cd=my.se(cd),
    eE=my.se(eE),
    ae=my.se(ae),
    Ff=my.se(Ff),
    lj=my.se(lj),
    AdA=my.se(AdA),
    cA_=my.se(cA_),
    ADd=my.se(ADd),
    cG=my.se(cG),
    JKJ=my.se(JKJ),
    X_ad=my.se(X_ad),
    Jb=my.se(Jb),
    FA=my.se(FA),
    Lc=my.se(Lc),
    af_=my.se(af_),
    EDD=my.se(EDD),
    X_JA_=my.se(X_JA_),
    aE=my.se(aE),
    Ad_=my.se(Ad_),
    X_jc=my.se(X_jc),
    fF=my.se(fF),
    clc=my.se(clc),
    X_Af_=my.se(X_Af_),
    LJ=my.se(LJ),
    fE=my.se(fE),
    AdD=my.se(AdD),
    X_Ja_=my.se(X_Ja_),
    DDe=my.se(DDe),
    X_aA_=my.se(X_aA_),
    jA_=my.se(jA_),
    X_JC=my.se(X_JC),
    Ka=my.se(Ka),
    Ab=my.se(Ab),
    JC_=my.se(JC_),
    fe=my.se(fe),
    cici=my.se(cici),
    DeD=my.se(DeD),
    JJj=my.se(JJj),
    ef=my.se(ef),
    icic=my.se(icic),
    Cc=my.se(Cc),
    Ddd=my.se(Ddd),
    AD_=my.se(AD_),
    Ef=my.se(Ef),
    X_jj=my.se(X_jj),
    DDA=my.se(DDA),
    JjJ=my.se(JjJ),
    AJ=my.se(AJ),
    ac_=my.se(ac_),
    lc_=my.se(lc_),
    X_ac=my.se(X_ac),
    X_ja=my.se(X_ja),
    la=my.se(la),
    ea=my.se(ea),
    DAA=my.se(DAA),
    aC=my.se(aC),
    dF=my.se(dF),
    aF=my.se(aF),
    ic_=my.se(ic_),
    X_JJJ=my.se(X_JJJ),
    ja_=my.se(ja_),
    cC=my.se(cC),
    X_JL=my.se(X_JL),
    X_aa_=my.se(X_aa_),
    cIc=my.se(cIc),
    jJJ=my.se(jJJ),
    cicic=my.se(cicic),
    Ded=my.se(Ded),
    fA_=my.se(fA_),
    DEd=my.se(DEd),
    KK=my.se(KK),
    ADE=my.se(ADE),
    jL=my.se(jL),
    ddD=my.se(ddD),
    Add=my.se(Add),
    ded=my.se(ded),
    JJk=my.se(JJk),
    ce=my.se(ce),
    Kc=my.se(Kc),
    X_JK=my.se(X_JK),
    Fd=my.se(Fd),
    bA=my.se(bA),
    dDd=my.se(dDd),
    jC=my.se(jC),
    FF=my.se(FF),
    X_AAD=my.se(X_AAD),
    Dc_=my.se(Dc_),
    DAD=my.se(DAD),
    Db=my.se(Db),
    noProbsAttempted=my.se(noProbsAttempted),
    noProbsSolved=my.se(noProbsSolved),
    percentageSolvedFromAttempted=my.se(percentageSolvedFromAttempted),
    averageAttmptOnSolvedProbs=my.se(averageAttmptOnSolvedProbs),
    avgTotalTimeOnSolvedProbs=my.se(avgTotalTimeOnSolvedProbs),
    firstgrade=my.se(firstgrade),
    lastgrade=my.se(lastgrade),
    effscore=my.se(effscore)
    
  ) -> output
############
res=rbind(res,output)
write.xlsx(x=res,file = file.path('/Users/roya/Desktop/ProgMOOC/code/java/source_codes/progMooc/resource', 
                                paste(type,'stat.xlsx',sep="-")),sheetName = "Sheet1")          
#prepare clustering labels for Michael
tmp$cluster<-NA
tmp$cluster<-hc
write.table(x=subset(tmp, user %in% metadata$USER, select=c("user","cluster")),
                       file = file.path('/Users/roya/Desktop/ProgMOOC/code/java/source_codes/progMooc/resource', paste(type,".txt",sep="")),row.names=F,quote=F,sep="\t",col.names=F)

######################Clusters Performance Comparisons
######Post-processing on clusters
qqnorm(tmp$noProbsAttempted)
qqnorm(tmp$noProbsSolved)
qqnorm(tmp$percentageSolvedFromAttempted)
qqnorm(tmp$averageAttmptOnSolvedProbs)
qqnorm(tmp$avgTotalTimeOnSolvedProbs)
qqnorm(tmp$effscore)

###for N=2 clusters
######
wilcox.test(noProbsAttempted ~ cluster, data = tmp) 
wilcox.test(noProbsSolved ~ cluster, data = tmp) 
wilcox.test(percentageSolvedFromAttempted ~ cluster, data = tmp) 
wilcox.test(averageAttmptOnSolvedProbs ~ cluster, data = tmp) 
wilcox.test(avgTotalTimeOnSolvedProbs ~ cluster, data = tmp) 
wilcox.test(effscore ~ cluster, data = tmp) 

gradetmp=subset(tmp, firstgrade!=-2 & !is.na(firstgrade))
wilcox.test(firstgrade ~ cluster, data=gradetmp ) 
aggregate(firstgrade~ cluster,data=gradetmp,FUN=meanse)

gradetmp=subset(tmp, lastgrade!=-2 & !is.na(lastgrade))
wilcox.test(lastgrade ~ cluster, data=gradetmp ) 
aggregate(lastgrade~ cluster,data=gradetmp,FUN=meanse)
#######

###for N=3 or N=4 cluster
########
library(DescTools)
kruskal.test(percentageSolvedFromAttempted ~ cluster, data = tmp) 
DunnTest(tmp$percentageSolvedFromAttempted, tmp$cluster)
kruskal.test(averageAttmptOnSolvedProbs ~ cluster, data = tmp) 
DunnTest(tmp$averageAttmptOnSolvedProbs, tmp$cluster)
kruskal.test(avgTotalTimeOnSolvedProbs ~ cluster, data = tmp) 
DunnTest(tmp$avgTotalTimeOnSolvedProbs, tmp$cluster)
kruskal.test(effscore ~ cluster, data = tmp) 
DunnTest(tmp$effscore, tmp$cluster)
gradetmp=subset(tmp, firstgrade!=-2 & !is.na(firstgrade))
kruskal.test(firstgrade ~ cluster, data=gradetmp ) 
aggregate(firstgrade~ cluster,data=gradetmp,FUN=meanse)
DunnTest(tmp$firstgrade, tmp$cluster)

gradetmp=subset(tmp, lastgrade!=-2 & !is.na(lastgrade))
kruskal.test(lastgrade ~ cluster, data=gradetmp ) 
aggregate(lastgrade~ cluster,data=gradetmp,FUN=meanse)

#summary(aov(percentageSolvedFromAttempted ~ cluster, data = tmp))
#summary(aov(averageAttmptOnSolvedProbs ~ cluster, data = tmp))
#summary(aov(avgTotalTimeOnSolvedProbs ~ cluster, data = tmp))
#summary(aov(effscore ~ cluster, data = tmp))
#######

### stats for all 798
meanse(tmp$noProbsAttempted)
meanse(tmp$noProbsSolved)
meanse(tmp$percentageSolvedFromAttempted)
meanse(tmp$averageAttmptOnSolvedProbs)
meanse(tmp$avgTotalTimeOnSolvedProbs)
meanse(tmp$effscore)
tmp2=subset(tmp, firstgrade!=-2 & !is.na(firstgrade))
meanse(tmp2$firstgrade)
######################prepare clustering labels by priorExp
######################
vars=getColVars(dataset_most_freq_patterns,268,ncol(dataset_most_freq_patterns),1,2)
tmp = subset( dataset_most_freq_patterns, (user %in% metadata$USER))
tmp <- tmp[,names(tmp) %in% vars]
###subseting plot patterns
main.directory ='/Users/roya/Desktop/ProgMOOC/code/java/source_codes/progMooc/resource'
input = paste0(type,'-plot-patterns.csv');
file.name <- file.path(main.directory, input);
top.patterns<-read.csv(file.name,header = F,stringsAsFactors = T,sep=",");
clmns=c("user","dataset")
clmns=append(clmns,as.vector(top.patterns$V1))
tmp=subset(tmp,select=clmns)
tmp=merge(tmp, usrperf, all.x=T,by.x='user',by.y='usr')
tmp=merge(tmp, metadata, all.x=T,by.x='user',by.y='USER')
tmp$progexp <- plyr::mapvalues(tmp$PROGRAMMING_EXPERIENCE, 
                               from=c("None","SomeExperience","SomeExperienceTookACourse","WorkedInGroupAsProgrammer","WorkedInGroupAsProgrammerOverMultipleProjects"), 
                               to=c("low","low","high","high","high"));


hc=paste(curClustVec,tmp$progexp) #for spectral clust (hc=cl$cluster), for hc, (hc=hc2 or hc=hc3 or etc)
nn = paste0(type,"-cluster-by-progexp")
tmp$cluster<-NA
tmp$cluster<-hc
x=as.data.frame(cbind(n=as.vector(table(hc)), 
                      aggregate(.~ hc,data=tmp[,c(3:54)],FUN=my.mean)))
x= rbind(x,as.data.frame(cbind(n=as.vector(table(hc)),
                               aggregate(.~ hc,data=tmp[,c(3:54)],FUN=my.se))));
write.xlsx(x=x,file = file.path('/Users/roya/Desktop/ProgMOOC/code/java/source_codes/progMooc/resource', 
                                paste(nn,'stat.xlsx',sep="-")),sheetName = "Sheet1")          

mean(tmp$effscore)
median(tmp$effscore)
tmp$effclass[tmp$effscore<median(tmp$effscore)]="low"
tmp$effclass[tmp$effscore>=median(tmp$effscore)]="high"
table(tmp$effclass)

hc=paste(curClustVec,tmp$effclass) #for spectral clust (hc=cl$cluster), for hc, (hc=hc2 or hc=hc3 or etc)
nn = paste0(type,"-cluster-by-effclass")
tmp$cluster<-NA
tmp$cluster<-hc
x=as.data.frame(cbind(n=as.vector(table(hc)), 
                      aggregate(.~ hc,data=tmp[,c(3:54)],FUN=my.mean)))
x= rbind(x,as.data.frame(cbind(n=as.vector(table(hc)),
                               aggregate(.~ hc,data=tmp[,c(3:54)],FUN=my.se))));
write.xlsx(x=x,file = file.path('/Users/roya/Desktop/ProgMOOC/code/java/source_codes/progMooc/resource', 
                                paste(nn,'stat.xlsx',sep="-")),sheetName = "Sheet1")          


#########
#########
#########
#########
#########
#########
#########
#########
#########
#########
#########
#########
#########
#########
#########
#########
#########
#########
#########
#########
#########
#########
#########
#########
#########
#########
#########
#########
#########
#########
#########
#########
#########
#########
#########
#########
#########
#########
#########
#########
#########
#########
#########
#########
#########
#########
#########
#########
#########
#########
#########
#########
#########
#########
#########
#########
#########
#########
#########
#########
# dataset_most_freq_patterns$progexp <- mapvalues(dataset_most_freq_patterns$PROGRAMMING_EXPERIENCE, 
#    from=c("None","SomeExperience","SomeExperienceTookACourse","WorkedInGroupAsProgrammer","WorkedInGroupAsProgrammerOverMultipleProjects"), 
#    to=c("None","Some","SomeCourse","HighProject","HighProject"));
# 
# dataset_most_freq_patterns$educ <- mapvalues(dataset_most_freq_patterns$EDUCATION, 
#     from=c("PrimaryEducation","SecondaryEducation",
#            "HigherEducationUnderGraduateStudies","HigherEducationUnderCollege",
#            "HigherEducationLicenciateOrPhD","HigherEducationGraduateStudies"), 
#     to=c("PrimSecond","PrimSecond","UnderGraduate","UnderGraduate",
#          "LicencPhD","LicencPhD"));
# 
# dataset_most_freq_patterns$cluster<-hc2
# dataset_most_freq_patterns$cluster<-factor(dataset_most_freq_patterns$cluster)
# 
# table(dataset_most_freq_patterns[ , c("GENDER","cluster")])
# table(dataset_most_freq_patterns[ , c("progexp","cluster")])
# table(dataset_most_freq_patterns[ , c("educ","cluster")])
# 
# #####checking assumptions of normality
# dataset_most_freq_patterns$firstgrade<-as.numeric(dataset_most_freq_patterns$firstgrade)
# qqnorm(dataset_most_freq_patterns$firstgrade)
# qqline(dataset_most_freq_patterns$firstgrade)
# hist(dataset_most_freq_patterns$firstgrade)
# qqnorm(dataset_most_freq_patterns$avg.attempt)
# qqline(dataset_most_freq_patterns$avg.attemp)
# 
# qqnorm(dataset_most_freq_patterns$pcorrect)
# qqline(dataset_most_freq_patterns$pcorrect)
# 
# kruskal.test(firstgrade ~ cluster, data = dataset_most_freq_patterns) 
# kruskal.test(pcorrect ~ cluster, data = dataset_most_freq_patterns) 
# kruskal.test(avg.attempt ~ cluster, data = dataset_most_freq_patterns) 
# 
# 
# kruskal.test(firstgrade ~ educ, data = dataset_most_freq_patterns) 
# kruskal.test(pcorrect ~ educ, data = dataset_most_freq_patterns) 
# kruskal.test(avg.attempt ~ educ, data = dataset_most_freq_patterns) 
# 
# 
# kruskal.test(firstgrade ~ progexp, data = dataset_most_freq_patterns) 
# kruskal.test(pcorrect ~ progexp, data = dataset_most_freq_patterns) 
# kruskal.test(avg.attempt ~ progexp, data = dataset_most_freq_patterns) 
# 
# ==========TODO =================
#   1. see how you can do with max grade
# 
# 
# 
# #######cluster, (predict pcorrect, attempt)
# fit<-NULL
# fit <- aov(pcorrect ~ cluster , data=dataset_most_freq_patterns)
# summary(fit)
# TukeyHSD(fit, which = 'cluster')
# dataset_most_freq_patterns$cluster<-factor(dataset_most_freq_patterns$cluster)
# fit<-NULL
# fit <- aov(firstgrade ~ cluster , data=dataset_most_freq_patterns)
# summary(fit)
# TukeyHSD(fit, which = 'cluster')
# dataset_most_freq_patterns$cluster<-factor(dataset_most_freq_patterns$cluster)
# fit<-NULL
# fit <- aov(avg.attempt ~ cluster , data=dataset_most_freq_patterns)
# summary(fit)
# TukeyHSD(fit, which = 'cluster')
# 
# ###education (only determine pcorrect) 
# dataset_most_freq_patterns$educ<-factor(dataset_most_freq_patterns$educ)
# fit<-NULL
# fit <- aov(pcorrect ~ educ , data=dataset_most_freq_patterns)
# summary(fit)
# TukeyHSD(fit, which = 'educ')
# 
# dataset_most_freq_patterns$educ<-factor(dataset_most_freq_patterns$educ)
# fit<-NULL
# fit <- aov(firstgrade ~ educ , data=dataset_most_freq_patterns)
# summary(fit)
# 
# dataset_most_freq_patterns$educ<-factor(dataset_most_freq_patterns$educ)
# fit<-NULL
# fit <- aov(avg.attempt ~ educ , data=dataset_most_freq_patterns)
# summary(fit)
# 
# #####progexp (predict pcorrect,firstattempt)
# dataset_most_freq_patterns$progexp<-factor(dataset_most_freq_patterns$progex)
# fit<-NULL
# fit <- aov(pcorrect ~ progexp , data=dataset_most_freq_patterns)
# summary(fit)
# TukeyHSD(fit, which = 'progexp')
# 
# dataset_most_freq_patterns$progexp<-factor(dataset_most_freq_patterns$progexp)
# fit<-NULL
# fit <- aov(firstgrade ~ progexp , data=dataset_most_freq_patterns)
# summary(fit)
# 
# dataset_most_freq_patterns$progexp<-factor(dataset_most_freq_patterns$progexp)
# fit<-NULL
# fit <- aov(avg.attempt ~ progexp , data=dataset_most_freq_patterns)
# summary(fit)
# TukeyHSD(fit, which = 'progexp')
# 
# 
# ######
# #1. clustering based on percent percent raw behaviours (B,S,M,R), log1pcount (B,S,M,R), percent time(B,S,M,R), log1pTime (B,S,M,R)
# ######
# library(dplyr)
# data %>%
#   group_by(user,dataset) %>%
#   summarize(
#     pcorrect=mean(percentage.correctness),
#     nexercises=length(exercise),
#     countB = sum(builder),
#     countS = sum(struggler),
#     countM = sum(massager),
#     countR = sum(reducer),
#     log1pB = log1p(sum(builder)),
#     log1pS = log1p(sum(struggler)),
#     log1pM = log1p(sum(massager)),
#     log1pR = log1p(sum(reducer)),
#     timeB = sum(buildsec),
#     timeS = sum(strugglesec),
#     timeM = sum(massagesec),
#     timeR = sum(reducesec), 
#     log1pTimeB = log1p(sum(buildsec)),
#     log1pTimeS = log1p(sum(strugglesec)),
#     log1pTimeM = log1p(sum(massagesec)),
#     log1pTimeR = log1p(sum(reducesec))
#   ) -> data_by_dataset_rawbehav
# data_by_dataset_rawbehav<-merge(data_by_dataset_rawbehav, metadata, all.x=T,by.x='user',by.y='USER')
# 
# varsBRMS = c("B","S","M","R")
# varsBRMScount = c("countB","countS","countM","countR")
# varsBRMSTime = c("timeB","timeS","timeM","timeR")
# data_by_dataset_rawbehav$countALL = rowSums(data_by_dataset_rawbehav[,varsBRMScount]);
# data_by_dataset_rawbehav$totalTIME = rowSums(data_by_dataset_rawbehav[,varsBRMSTime]);
# for(i in 1:length(varsBRMS)) {
#   data_by_dataset_rawbehav[,paste("percent",varsBRMS[i],sep="")]=data_by_dataset_rawbehav[,paste("count",varsBRMS[i],sep="")]/data_by_dataset_rawbehav$countALL
#   data_by_dataset_rawbehav[,paste("percentTime",varsBRMS[i],sep="")]=data_by_dataset_rawbehav[,paste("time",varsBRMS[i],sep="")]/data_by_dataset_rawbehav$totalTIME
# }
# varsBRMSpercent = c("percentB","percentS","percentM","percentR")
# varsBRMSpercentTime = c("percentTimeB","percentTimeS","percentTimeM","percentTimeR")
# varsBRMSlog1pCount = c("log1pB","log1pS","log1pM","log1pR")
# varsBRMSlog1pTime = c("log1pTimeB","log1pTimeS","log1pTimeM","log1pTimeR")
# m = cor(data_by_dataset_rawbehav[,varsBRMSpercent])
# m = cor(data_by_dataset_rawbehav[,varsBRMSpercentTime])
# m = cor(data_by_dataset_rawbehav[,varsBRMSlog1pCount])
# m = cor(data_by_dataset_rawbehav[,varsBRMSlog1pTime])
# m = cor(data_by_dataset_rawbehav[,c(varsBRMSpercent,varsBRMSpercentTime)])
# 
# # varsBRMSpercent_noS
# varsBRMSpercent_noS = c("percentB","percentM","percentR","percentTimeB","percentTimeM","percentTimeR")
# m = cor(data_by_dataset_rawbehav[,varsBRMSpercent_noS])
# 
# D_BRMS_noS <- proxy::dist(data_by_dataset_rawbehav[,varsBRMSpercent_noS], method = "Euclidean")
# cl_BRMS_noS  <- hclust(D_BRMS_noS, method="ward.D") 
# plot(cl_BRMS_noS)
# rect.hclust(cl_BRMS_noS, 4)
# hc4 = cutree(cl_BRMS_noS, k = 4)
# table(hc4)
# # 1   2   3   4 
# # 574 402 453 436 
# 
# data_by_dataset_rawbehav<-cbind(cluster=hc4,data_by_dataset_rawbehav)
# cbind( n=as.vector(table(subset(data_by_dataset_rawbehav,is.na(pcorrect)==F)$cluster)),
#        aggregate(cbind(percentB,percentS,percentM,percentR,percentTimeB,percentTimeS,percentTimeM,percentTimeR,pcorrect)~cluster,
#        data=data_by_dataset_rawbehav,FUN=meanse))
# # n cluster     percentB     percentS     percentM     percentR percentTimeB percentTimeS percentTimeM percentTimeR     pcorrect
# # 1 574       1 0.4706(0.00) 0.4604(0.00) 0.0279(0.00) 0.0411(0.00) 0.7096(0.00) 0.2813(0.00) 0.0012(0.00) 0.0079(0.00) 0.6938(0.00)
# # 2 402       2 0.4243(0.00) 0.5062(0.00) 0.0289(0.00) 0.0407(0.00) 0.2720(0.00) 0.6949(0.00) 0.0120(0.00) 0.0211(0.00) 0.6671(0.00)
# # 3 453       3 0.3777(0.00) 0.5693(0.00) 0.0278(0.00) 0.0251(0.00) 0.0368(0.00) 0.9531(0.00) 0.0069(0.00) 0.0033(0.00) 0.6660(0.00)
# # 4 436       4 0.4406(0.00) 0.4860(0.00) 0.0279(0.00) 0.0454(0.00) 0.5040(0.00) 0.4878(0.00) 0.0035(0.00) 0.0048(0.00) 0.6596(0.00)
# cbind(n=as.vector(table(subset(data_by_dataset_rawbehav,is.na(firstgrade)==F)$cluster)),
#        aggregate(cbind(percentB,percentS,percentM,percentR,percentTimeB,percentTimeS,percentTimeM,percentTimeR,firstgrade)~cluster,
#                  data=data_by_dataset_rawbehav,FUN=meanse))
# # n cluster     percentB     percentS     percentM     percentR percentTimeB percentTimeS percentTimeM percentTimeR   firstgrade
# # 1 97       1 0.4765(0.00) 0.4519(0.00) 0.0272(0.00) 0.0445(0.00) 0.6898(0.00) 0.2921(0.00) 0.0007(0.00) 0.0173(0.00) 3.3918(0.02)
# # 2 70       2 0.4440(0.00) 0.4868(0.00) 0.0259(0.00) 0.0433(0.00) 0.2821(0.00) 0.6817(0.00) 0.0008(0.00) 0.0354(0.00) 2.9571(0.03)
# # 3 27       3 0.4044(0.00) 0.5390(0.00) 0.0289(0.00) 0.0278(0.00) 0.0556(0.00) 0.9348(0.00) 0.0052(0.00) 0.0044(0.00) 1.9630(0.08)
# # 4 93       4 0.4490(0.00) 0.4702(0.00) 0.0290(0.00) 0.0518(0.00) 0.5086(0.00) 0.4770(0.00) 0.0052(0.00) 0.0092(0.00) 3.3871(0.02)
# 
# 
# ################stats
# table(data_by_dataset_rawbehav[ , c("GENDER","cluster")])
# table(data_by_dataset_rawbehav[ , c("PROGRAMMING_EXPERIENCE","cluster")])
# table(data_by_dataset_rawbehav[ , c("EDUCATION","cluster")])
# 
# data_by_dataset_rawbehav$EDUCATION<-factor(data_by_dataset_rawbehav$EDUCATION)
# fit<-NULL
# fit <- aov(pcorrect ~ EDUCATION , data=data_by_dataset_rawbehav)
# summary(fit)
# TukeyHSD(fit, which = 'EDUCATION')
# 
# data_by_dataset_rawbehav$EDUCATION<-factor(data_by_dataset_rawbehav$EDUCATION)
# fit<-NULL
# fit <- aov(firstgrade ~ EDUCATION , data=data_by_dataset_rawbehav)
# summary(fit)
# 
# data_by_dataset_rawbehav$EDUCATION<-factor(data_by_dataset_rawbehav$EDUCATION)
# fit<-NULL
# fit <- aov(pcorrect ~ EDUCATION , data=data_by_dataset_rawbehav)
# summary(fit)
# TukeyHSD(fit, which = 'EDUCATION')
# 
# data_by_dataset_rawbehav$PROGRAMMING_EXPERIENCE<-factor(data_by_dataset_rawbehav$PROGRAMMING_EXPERIENCE)
# fit<-NULL
# fit <- aov(firstgrade ~ PROGRAMMING_EXPERIENCE , data=data_by_dataset_rawbehav)
# summary(fit)
# 
# data_by_dataset_rawbehav$PROGRAMMING_EXPERIENCE<-factor(data_by_dataset_rawbehav$PROGRAMMING_EXPERIENCE)
# fit<-NULL
# fit <- aov(pcorrect ~ PROGRAMMING_EXPERIENCE , data=data_by_dataset_rawbehav)
# summary(fit)
# TukeyHSD(fit, which = 'PROGRAMMING_EXPERIENCE')
# 
# data_by_dataset_rawbehav$cluster<-factor(data_by_dataset_rawbehav$cluster)
# fit<-NULL
# fit <- aov(pcorrect ~ cluster , data=data_by_dataset_rawbehav)
# summary(fit)
# TukeyHSD(fit, which = 'cluster')
# 
# data_by_dataset_rawbehav$cluster<-factor(data_by_dataset_rawbehav$cluster)
# fit<-NULL
# fit <- aov(firstgrade ~ cluster , data=data_by_dataset_rawbehav)
# summary(fit)
# TukeyHSD(fit, which = 'cluster')
# 
# ##########
# #2. clustering based on percent max behaviours, logp1count (max behaviour)
# ##########
# library(dplyr)
# data %>%
#   group_by(user,dataset) %>%
#   summarize(
#     pcorrect=mean(percentage.correctness),
#     nexercises=length(exercise),
#     countBS = sum(maxexercisebehav=="BS"),
#     countS = sum(maxexercisebehav=="S"),
#     countB = sum(maxexercisebehav=="B"),
#     countBSR = sum(maxexercisebehav=="BSR"),
#     countR = sum(maxexercisebehav=="R"),
#     countBSM = sum(maxexercisebehav=="BSM"),
#     countSR = sum(maxexercisebehav=="SR"),
#     countBR = sum(maxexercisebehav=="BR"),
#     countBSRM = sum(maxexercisebehav=="BSRM"),
#     countSM = sum(maxexercisebehav=="SM"),
#     countBM = sum(maxexercisebehav=="BM"),
#     countM = sum(maxexercisebehav=="M"),
#     countBRM = sum(maxexercisebehav=="BRM"),
#     countSRM = sum(maxexercisebehav=="SRM"),
#     countRM = sum(maxexercisebehav=="RM"),
#     timeBS = sum(buildsec,strugglesec),
#     timeS = sum(strugglesec),
#     timeB = sum(buildsec),
#     timeBSR = sum(buildsec,strugglesec,reducesec),
#     timeR = sum(reducesec),
#     timeBSM = sum(buildsec,strugglesec,massagesec),
#     timeSR = sum(strugglesec,reducesec),
#     timeBR = sum(buildsec,reducesec),
#     timeBSRM = sum(buildsec,strugglesec,reducesec,massagesec),
#     timeSM = sum(strugglesec,massagesec),
#     timeBM = sum(buildsec,massagesec),
#     timeM = sum(massagesec),
#     timeBRM = sum(buildsec,reducesec,massagesec),
#     timeSRM = sum(strugglesec,reducesec,massagesec),
#     timeRM = sum(reducesec,massagesec),
#     log1pBS = log1p(sum(maxexercisebehav=="BS")),
#     log1pS = log1p(sum(maxexercisebehav=="S")),
#     log1pB = log1p(sum(maxexercisebehav=="B")),
#     log1pBSR = log1p(sum(maxexercisebehav=="BSR")),
#     log1pR = log1p(sum(maxexercisebehav=="R")),
#     log1pBSM = log1p(sum(maxexercisebehav=="BSM")),
#     log1pSR = log1p(sum(maxexercisebehav=="SR")),
#     log1pBR = log1p(sum(maxexercisebehav=="BR")),
#     log1pBSRM = log1p(sum(maxexercisebehav=="BSRM")),
#     log1pSM = log1p(sum(maxexercisebehav=="SM")),
#     log1pBM = log1p(sum(maxexercisebehav=="BM")),
#     log1pM = log1p(sum(maxexercisebehav=="M")),
#     log1pBRM = log1p(sum(maxexercisebehav=="BRM")),
#     log1pSRM = log1p(sum(maxexercisebehav=="SRM")),
#     log1pRM = log1p(sum(maxexercisebehav=="RM")),
#     log1pTimeBS = log1p(sum(buildsec,strugglesec)),
#     log1pTimeS = log1p(sum(strugglesec)),
#     log1pTimeB = log1p(sum(buildsec)),
#     log1pTimeBSR = log1p(sum(buildsec,strugglesec,reducesec)),
#     log1pTimeR = log1p(sum(reducesec)),
#     log1pTimeBSM = log1p(sum(buildsec,strugglesec,massagesec)),
#     log1pTimeSR = log1p(sum(strugglesec,reducesec)),
#     log1pTimeBR = log1p(sum(buildsec,reducesec)),
#     log1pTimeBSRM = log1p(sum(buildsec,strugglesec,reducesec,massagesec)),
#     log1pTimeSM = log1p(sum(strugglesec,massagesec)),
#     log1pTimeBM = log1p(sum(buildsec,massagesec)),
#     log1pTimeM = log1p(sum(massagesec)),
#     log1pTimeBRM = log1p(sum(buildsec,reducesec,massagesec)),
#     log1pTimeSRM = log1p(sum(strugglesec,reducesec,massagesec)),
#     log1pTimeRM = log1p(sum(reducesec,massagesec))
#   ) -> data_by_dataset_maxbehav
# data_by_dataset_maxbehav<-merge(data_by_dataset_maxbehav, metadata, all.x=T,by.x='user',by.y='USER')
# 
# 
# varsBRMS = c("BS","S","B","BSR","R","BSM","SR","BR","BSRM","SM","BM","M","BRM","SRM","RM")
# varsBRMScount = c("countBS","countS","countB","countBSR","countR","countBSM","countSR","countBR",
#                   "countBSRM","countSM","countBM","countM","countBRM","countSRM","countRM")
# varsBRMSTime = c("timeBS","timeS","timeB","timeBSR","timeR","timeBSM","timeSR","timeBR",
#                  "timeBSRM","timeSM","timeBM","timeM","timeBRM","timeSRM","timeRM")
# data_by_dataset_maxbehav$countALL = rowSums(data_by_dataset_maxbehav[,varsBRMScount]);
# data_by_dataset_maxbehav$totalTIME = rowSums(data_by_dataset_maxbehav[,varsBRMSTime]);
# for(i in 1:length(varsBRMS)) {
#   data_by_dataset_maxbehav[,paste("percent",varsBRMS[i],sep="")]=data_by_dataset_maxbehav[,paste("count",varsBRMS[i],sep="")]/data_by_dataset_maxbehav$countALL
#   data_by_dataset_maxbehav[,paste("percentTime",varsBRMS[i],sep="")]=data_by_dataset_maxbehav[,paste("time",varsBRMS[i],sep="")]/data_by_dataset_maxbehav$totalTIME
# }
# varsBRMSpercent = c("percentBS","percentS","percentB","percentBSR","percentR","percentBSM","percentSR","percentBR",
#                     "percentBSRM","percentSM","percentBM","percentM","percentBRM","percentSRM","percentRM")
# varsBRMSpercentTime = c("percentTimeBS","percentTimeS","percentTimeB","percentTimeBSR","percentTimeR","percentTimeBSM","percentTimeSR","percentTimeBR",
#                         "percentTimeBSRM","percentTimeSM","percentTimeBM","percentTimeM","percentTimeBRM","percentTimeSRM","percentTimeRM")
# varsBRMSlog1pCount = c("log1pBS","log1pS","log1pB","log1pBSR","log1pR","log1pBSM","log1pSR","log1pBR","log1pBSRM","log1pSM","log1pBM",
#                        "log1pM","log1pBRM","log1pSRM","log1pRM")
# varsBRMSlog1pTime = c("log1pTimeBS","log1pTimeS","log1pTimeB","log1pTimeBSR","log1pTimeR","log1pTimeBSM","log1pTimeSR","log1pTimeBR","log1pTimeBSRM","log1pTimeSM","log1pTimeBM",
#                       "log1pTimeM","log1pTimeBRM","log1pTimeSRM","log1pTimeRM")
# m = cor(data_by_dataset_maxbehav[,varsBRMSpercent]) #drop BS, S, and BSRM
# m = cor(data_by_dataset_maxbehav[,varsBRMSpercentTime]) #drop BS, S, SR, BR, SM, BM, BRM, SRM, BSR,BSM, RM, BSRM
# m = cor(data_by_dataset_maxbehav[,varsBRMSlog1pCount]) #BS, S, BSM, BSRM
# m = cor(data_by_dataset_maxbehav[,varsBRMSlog1pTime]) #highly correlated (keep log1pTimeB)
# 
# d1=setdiff(varsBRMSpercent,c("percentBS","percentS","percentBSRM"))
# d2=setdiff(varsBRMSpercentTime,c("percentTimeBS","percentTimeS","percentTimeSR","percentTimeBR","percentTimeSM",
#                               "percentTimeBM","percentTimeBRM","percentTimeSRM","percentTimeBSM",
#                               "percentTimeBSR","percentTimeRM","percentTimeBSRM"))
# d3=setdiff(varsBRMSlog1pCount,c("log1pBS","log1pS","log1pBSM","log1pBSRM"))
# m = cor(data_by_dataset_maxbehav[,c(d1,d2)])
# ################cluster
# 
# D<- proxy::dist(data_by_dataset_maxbehav[,c(d1,d2)], method = "Euclidean")
# cl  <- hclust(D, method="ward.D") 
# plot(cl)
# rect.hclust(cl, 4)
# hc4 = cutree(cl, k = 4)
# table(hc4)
# # 1   2   3   4 
# # 813 427 336 289 
# plot(cl)
# rect.hclust(cl, 5)
# hc5 = cutree(cl, k = 5)
# table(hc5)
# # 1   2   3   4   5 
# # 501 427 312 336 289 
# plot(cl)
# rect.hclust(cl, 6)
# hc6 = cutree(cl, k = 6)
# table(hc6)
# 
# data_by_dataset_maxbehav<-cbind(cluster=hc6,data_by_dataset_maxbehav)
# cbind( n=as.vector(table(subset(data_by_dataset_maxbehav,is.na(pcorrect)==F)$cluster)),
#        aggregate(cbind(percentB,percentBSR,percentR,percentBSM,percentSR,percentBR,percentSM, percentBM,percentM, percentBRM, percentSRM,
#                        percentRM,pcorrect)~cluster, data=data_by_dataset_maxbehav,FUN=meanse))
# cbind( n=as.vector(table(subset(data_by_dataset_maxbehav,is.na(firstgrade)==F)$cluster)),
#        aggregate(cbind(percentB,percentBSR,percentR,percentBSM,percentSR,percentBR,percentSM, percentBM,percentM, percentBRM, percentSRM,
#                        percentRM,firstgrade)~cluster, data=data_by_dataset_maxbehav,FUN=meanse))
# 
# ################stats
# table(data_by_dataset_maxbehav[ , c("GENDER","cluster")])
# table(data_by_dataset_maxbehav[ , c("PROGRAMMING_EXPERIENCE","cluster")])
# table(data_by_dataset_maxbehav[ , c("EDUCATION","cluster")])
# 
# data_by_dataset_maxbehav$EDUCATION<-factor(data_by_dataset_maxbehav$EDUCATION)
# fit<-NULL
# fit <- aov(pcorrect ~ EDUCATION , data=data_by_dataset_maxbehav)
# summary(fit)
# TukeyHSD(fit, which = 'EDUCATION')
# 
# data_by_dataset_maxbehav$EDUCATION<-factor(data_by_dataset_maxbehav$EDUCATION)
# fit<-NULL
# fit <- aov(firstgrade ~ EDUCATION , data=data_by_dataset_maxbehav)
# summary(fit)
# 
# data_by_dataset_maxbehav$EDUCATION<-factor(data_by_dataset_maxbehav$EDUCATION)
# fit<-NULL
# fit <- aov(pcorrect ~ EDUCATION , data=data_by_dataset_maxbehav)
# summary(fit)
# TukeyHSD(fit, which = 'EDUCATION')
# 
# data_by_dataset_maxbehav$PROGRAMMING_EXPERIENCE<-factor(data_by_dataset_maxbehav$PROGRAMMING_EXPERIENCE)
# fit<-NULL
# fit <- aov(firstgrade ~ PROGRAMMING_EXPERIENCE , data=data_by_dataset_maxbehav)
# summary(fit)
# 
# data_by_dataset_maxbehav$PROGRAMMING_EXPERIENCE<-factor(data_by_dataset_maxbehav$PROGRAMMING_EXPERIENCE)
# fit<-NULL
# fit <- aov(pcorrect ~ PROGRAMMING_EXPERIENCE , data=data_by_dataset_maxbehav)
# summary(fit)
# TukeyHSD(fit, which = 'PROGRAMMING_EXPERIENCE')
# 
# data_by_dataset_maxbehav$cluster<-factor(data_by_dataset_maxbehav$cluster)
# fit<-NULL
# fit <- aov(pcorrect ~ cluster , data=data_by_dataset_maxbehav)
# summary(fit)
# TukeyHSD(fit, which = 'cluster')
# 
# data_by_dataset_maxbehav$cluster<-factor(data_by_dataset_maxbehav$cluster)
# fit<-NULL
# fit <- aov(firstgrade ~ cluster , data=data_by_dataset_maxbehav)
# summary(fit)
# TukeyHSD(fit, which = 'cluster')
# 
# ##########
# #3. clustering based on percent median behaviours, logp1count (median behaviour)
# ##########
# library(dplyr)
# data %>%
#   group_by(user,dataset) %>%
#   summarize(
#     pcorrect=mean(percentage.correctness),
#     nexercises=length(exercise),
#     countBS = sum(ovrmedexercisebehav=="BS"),
#     countBSRM = sum(ovrmedexercisebehav=="BSRM"),
#     countBSR = sum(ovrmedexercisebehav=="BSR"),
#     countBSM = sum(ovrmedexercisebehav=="BSM"),
#     countBR = sum(ovrmedexercisebehav=="BR"),
#     countSR = sum(ovrmedexercisebehav=="SR"),
#     countSM = sum(ovrmedexercisebehav=="SM"),
#     countBM = sum(ovrmedexercisebehav=="BM"),
#     countSRM = sum(ovrmedexercisebehav=="SRM"),
#     countBRM = sum(ovrmedexercisebehav=="BRM"),
#     countRM = sum(ovrmedexercisebehav=="RM")
#     ) -> data_by_dataset_ovrmedexercisebehav
# varsBRMS = c("RM","BRM","SRM","BM","SM","SR","BR","BSM","BSR","BSRM","BS")
# varsBRMScount = c("countRM","countBRM","countSRM","countBM","countSM","countSR","countBR","countBSM","countBSR","countBSRM","countBS")
# varsBRMSpercent = c("percentRM","percentBRM","percentSRM","percentBM","percentSM","percentSR","percentBR","percentBSM","percentBSR","percentBSRM","percentBS")
# data_by_dataset_ovrmedexercisebehav$countALL = rowSums(data_by_dataset_ovrmedexercisebehav[,varsBRMScount]);
# for(i in 1:length(varsBRMS)) {
#   data_by_dataset_ovrmedexercisebehav[,paste("percent",varsBRMS[i],sep="")] =  data_by_dataset_ovrmedexercisebehav[,paste("count",varsBRMS[i],sep="")] / data_by_dataset_ovrmedexercisebehav$countALL
# }
# m = cor(data_by_dataset_ovrmedexercisebehav[,varsBRMSpercent])
# 
# # varsBRMSpercent_noBS
# varsBRMSpercent_noBS = c("percentRM","percentBRM","percentSRM","percentBM","percentSM","percentSR","percentBR","percentBSM","percentBSR","percentBSRM")
# D_BRMS_noBS <- proxy::dist(data_by_dataset_ovrmedexercisebehav[,varsBRMSpercent_noBS], method = "Euclidean")
# cl_BRMS_noBS  <- hclust(D_BRMS_noBS, method="ward.D") 
# plot(cl_BRMS_noBS)
# rect.hclust(cl_BRMS_noBS, 4)
# hc4 = cutree(cl_BRMS_noBS, k = 4)
# table(hc4)
# #    1    2    3    4 
# # 1162  105  562   36 
# plot(cl_BRMS_noBS)
# rect.hclust(cl_BRMS_noBS, 5)
# hc5 = cutree(cl_BRMS_noBS, k = 5)
# table(hc5)
# #   1   2   3   4   5 
# # 451 105 711 562  36 
# hc2 = cutree(cl_BRMS_noBS, k = 2)
# table(hc2)
# #    1    2 
# # 1724  141 
# 
# aggregate(cbind(percentRM,percentBRM,percentSRM,percentBM,percentSM,percentSR,percentBR,percentBSM,percentBSR,percentBSRM,pcorrect)~hc5,data=data_by_dataset_ovrmedexercisebehav,FUN=meanse)
# #   hc5    percentRM   percentBRM   percentSRM    percentBM    percentSM    percentSR    percentBR   percentBSM   percentBSR  percentBSRM     pcorrect
# # 1   1 0.0000(0.00) 0.0001(0.00) 0.0002(0.00) 0.0003(0.00) 0.0030(0.00) 0.0041(0.00) 0.0022(0.00) 0.0156(0.00) 0.0177(0.00) 0.0177(0.00) 0.7377(0.00)
# # 2   2 0.0000(0.00) 0.0006(0.00) 0.0006(0.00) 0.0011(0.00) 0.0098(0.00) 0.0119(0.00) 0.0146(0.00) 0.0340(0.00) 0.0412(0.00) 0.1889(0.00) 0.5703(0.00)
# # 3   3 0.0000(0.00) 0.0001(0.00) 0.0004(0.00) 0.0004(0.00) 0.0072(0.00) 0.0116(0.00) 0.0094(0.00) 0.0346(0.00) 0.0327(0.00) 0.0445(0.00) 0.6403(0.00)
# # 4   4 0.0000(0.00) 0.0001(0.00) 0.0002(0.00) 0.0004(0.00) 0.0040(0.00) 0.0077(0.00) 0.0114(0.00) 0.0132(0.00) 0.0664(0.00) 0.0339(0.00) 0.6767(0.00)
# # 5   5 0.0000(0.00) 0.0000(0.00) 0.0000(0.00) 0.0003(0.00) 0.0184(0.00) 0.0055(0.00) 0.0069(0.00) 0.2845(0.00) 0.0182(0.00) 0.0533(0.00) 0.7649(0.00)
# aggregate(cbind(percentRM,percentBRM,percentSRM,percentBM,percentSM,percentSR,percentBR,percentBSM,percentBSR,percentBSRM,pcorrect)~hc2,data=data_by_dataset_ovrmedexercisebehav,FUN=meanse)
# #   hc2    percentRM   percentBRM   percentSRM    percentBM    percentSM    percentSR    percentBR   percentBSM   percentBSR  percentBSRM     pcorrect
# # 1   1 0.0000(0.00) 0.0001(0.00) 0.0003(0.00) 0.0004(0.00) 0.0051(0.00) 0.0084(0.00) 0.0082(0.00) 0.0227(0.00) 0.0398(0.00) 0.0340(0.00) 0.6776(0.00)
# # 2   2 0.0000(0.00) 0.0004(0.00) 0.0005(0.00) 0.0009(0.00) 0.0120(0.00) 0.0103(0.00) 0.0127(0.00) 0.0979(0.00) 0.0353(0.00) 0.1543(0.00) 0.6200(0.00)
# 
# 
# ##there are instance with pmassager=0,preducer=0, so drop builder for the clustering
# ##
# ##
# plot(density(sum_by_dataset$preducer))
# plot(density(sum_by_dataset$pmassager))
# plot(density(sum_by_dataset$pbuilder))
# plot(density(sum_by_dataset$pstruggler))
# 
# plot(density(sum_by_dataset$logp1builder))
# plot(density(sum_by_dataset$logp1reducer))
# plot(density(sum_by_dataset$logp1massager))
# plot(density(sum_by_dataset$logp1struggler))
# 
# 
# sum_by_dataset$scaledlogp1builder = scale(sum_by_dataset$logp1builder)
# sum_by_dataset$scaledlogp1reducer = scale(sum_by_dataset$logp1reducer)
# sum_by_dataset$scaledlogp1massager = scale(sum_by_dataset$logp1massager)
# sum_by_dataset$scaledlogp1struggler = scale(sum_by_dataset$logp1struggler)
# 
# 
# library(proxy)
# vars0 = c("preducer","pmassager","pstruggler")
# D0 <- proxy::dist(sum_by_dataset[,vars], method = "Euclidean")
# vars = c("preducer","pmassager","pstruggler","logp1builder","logp1reducer","logp1massager","logp1struggler")
# D <- proxy::dist(sum_by_dataset[,vars], method = "Euclidean")
# varsscaled = c("preducer","pmassager","pstruggler","scaledlogp1builder","scaledlogp1reducer","scaledlogp1massager","scaledlogp1struggler")
# Dscaled <- proxy::dist(sum_by_dataset[,varsscaled], method = "Euclidean")
# 
# m = round(cor(sum_by_dataset[,union(vars,varsscaled)]), digits=3)
# 
# cl0 <- hclust(D0, method="ward.D") 
# plot(cl0)
# rect.hclust(cl0, 4)
# hc4 = cutree(cl0, k = 4)
# table(hc4)
# plot(cl0)
# rect.hclust(cl0, 5)
# hc5 = cutree(cl0, k = 5)
# table(hc5)
# rect.hclust(cl0, 3)
# hc3 = cutree(cl0, k = 3)
# table(hc3)
# aggregate(cbind(pbuilder,pmassager,pstruggler,preducer,avg.percentage.correctness)~hc3,data=sum_by_dataset,FUN=meanse)
# 
# 
# cl <- hclust(D, method="ward.D") 
# plot(cl)
# rect.hclust(cl, 4)
# hc4 = cutree(cl, k = 4)
# 
# clscaled <- hclust(Dscaled, method="average") 
# plot(clscaled)
# rect.hclust(clscaled, 4)
# hc4 = cutree(clscaled, k = 4)
# 
# sum_by_dataset$cluster<-NULL
# sum_by_dataset<-cbind(hc4,sum_by_dataset)
# names(sum_by_dataset)[1]<-"cluster"
# 
# #stats
# table(sum_by_dataset$cluster)
# aggregate(cbind(pbuilder,pmassager,pstruggler,preducer,avg.percentage.correctness)~cluster,data=sum_by_dataset,FUN=meanse)
# 
# 
