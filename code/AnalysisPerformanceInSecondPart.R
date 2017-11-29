rm(list = ls());


main.directory ='/Users/roya/Desktop/ProgMOOC/data'
#1. reading background information
input = 'backgrounds-encoded.tsv';
file.name <- file.path(main.directory, input);
metadata1<-read.csv(file.name,header = T,stringsAsFactors = T,sep="\t");
input = 'background-data.txt';
file.name <- file.path(main.directory, input);
metadata2<-read.table(file.name,header=T,stringsAsFactors = T,sep=" ",fill=T);
metadata<-merge(metadata1, metadata2, all.x=T,by.x='USER',by.y='student')


main.directory ='/Users/roya/Desktop/ProgMOOC/code/java/source_codes/progMooc/resource'
#1. reading background information
input = 'UserPerformanceSummary.txt';
file.name <- file.path(main.directory, input);
perfall<-read.csv(file.name,header = F,stringsAsFactors = T,sep=",");
colnames(perfall)<-c("dataset","usr","noProbsAttempted","noProbsSolved",
                   "percentageSolvedFromAttempted","averageAttmptOnSolvedProbs","avgTotalTimeOnSolvedProbs")


input = 'UserPerformanceSummarySecondPart.txt';
file.name <- file.path(main.directory, input);
perf2<-read.csv(file.name,header = F,stringsAsFactors = T,sep=",");
colnames(perf2)<-c("dataset","usr","noProbsAttempted","noProbsSolved",
                   "percentageSolvedFromAttempted","averageAttmptOnSolvedProbs","avgTotalTimeOnSolvedProbs")


input = 'user-first-last-grade.txt';
file.name <- file.path('/Users/roya/Desktop/ProgMOOC/code/java/source_codes/progMooc/resource', input);
gradedf<-read.csv(file.name,header = F,stringsAsFactors = F,sep=",");
colnames(gradedf)<-c("user","firstgrade","lastgrade")



#merge with grade
perf2<-merge(perf2, gradedf, all.x=T,by.x='usr',by.y='user')
nrow(subset(perf2,firstgrade==-2))
perf2$lastgrade[perf2$lastgrade==-2]=NA
perf2$firstgrade[perf2$firstgrade==-2]=NA
#
perfall<-merge(perfall, gradedf, all.x=T,by.x='usr',by.y='user')
nrow(subset(perfall,firstgrade==-2))
perfall$lastgrade[perfall$lastgrade==-2]=NA
perfall$firstgrade[perfall$firstgrade==-2]=NA


#effectiveness scores
mean.time=mean(perf2$avgTotalTimeOnSolvedProbs,na.rm=T);
sd.time=sd(perf2$avgTotalTimeOnSolvedProbs,na.rm=T)
mean.noProbsSolved=mean(perf2$noProbsSolved,na.rm=T);
sd.noProbsSolved=sd(perf2$noProbsSolved,na.rm=T)
perf2$effscore=NA
for (i in 1:nrow(perf2)){
  z.hour=(perf2$avgTotalTimeOnSolvedProbs[i]-mean.time)/sd.time
  z.solved=(perf2$noProbsSolved[i]-mean.noProbsSolved)/sd.noProbsSolved
  #the nagation is because if R-P<0 then E>0 & if R-P<0, then E>0
  #ref is (PAASand MERRIENBOER,1993, page 742)
  perf2$effscore[i]=round(-(z.hour-z.solved)/sqrt(2),4)   
  
}
#
mean.time=mean(perfall$avgTotalTimeOnSolvedProbs,na.rm=T);
sd.time=sd(perfall$avgTotalTimeOnSolvedProbs,na.rm=T)
mean.noProbsSolved=mean(perfall$noProbsSolved,na.rm=T);
sd.noProbsSolved=sd(perfall$noProbsSolved,na.rm=T)
perfall$effscore=NA
for (i in 1:nrow(perfall)){
  z.hour=(perfall$avgTotalTimeOnSolvedProbs[i]-mean.time)/sd.time
  z.solved=(perfall$noProbsSolved[i]-mean.noProbsSolved)/sd.noProbsSolved
  #the nagation is because if R-P<0 then E>0 & if R-P<0, then E>0
  #ref is (PAASand MERRIENBOER,1993, page 742)
  perfall$effscore[i]=round(-(z.hour-z.solved)/sqrt(2),4)   
  
}


input = 'StanbilityAnalysisMostFrequentPattern_ALL.txt';
file.name <- file.path(main.directory, input);
all=read.csv(file.name,header = T,stringsAsFactors = T,sep=",");
all=merge(all, perfall, all.x=T,by.x='user',by.y='usr')


input = 'StanbilityAnalysisMostFrequentPattern_EarlyLate.txt';
file.name <- file.path(main.directory, input);
behav1=read.csv(file.name,header = T,stringsAsFactors = T,sep=",");
behav1=subset(behav1,half==1)
behav1=merge(behav1, perf2, all.x=T,by.x='user',by.y='usr')



##########################
##Setting params analysis
##########################
#######1. =========>>
df=behav1  #df=behav1   df=all

dels<-vector()
for (i in 4:(ncol(df)-9))
  if (nchar(gsub("_","",gsub("X","",colnames(df)[i])), type = "chars")==1)
    dels=append(dels,colnames(df)[i])
df=df[,!(colnames(df) %in% dels)]

m = cor(df[,4:(ncol(df)-9)])
m[upper.tri(m)] <- 0
diag(m) = 0
reduced_data= df[,!apply(m,2,function(x) any(abs(x) > 0.1))]
reduced_data=cbind(reduced_data,df[,(ncol(df)-6):ncol(df)])
hist(reduced_data$noProbsSolved)
set.seed(124)
#noProbsSolved names(reduced_data)[35]
fit=NULL

fit=glm(as.formula(paste( "noProbsSolved~",
                              paste(colnames(reduced_data)[1:(ncol(reduced_data)-7)], collapse = "+"),
                              sep = "")),data=reduced_data,family=poisson(link=log))
summary(fit)
#pchisq(fit$deviance, df=fit$df.residual, lower.tail=FALSE)

# fit=step(lm(as.formula(paste( "noProbsSolved~",
#                  paste(colnames(reduced_data)[1:(ncol(reduced_data)-7)], collapse = "+"),
#                  sep = "")),data=reduced_data,
#             direction="backward"))
# summary(fit)
# par(mfrow=c(2,2))  # set 2 rows and 2 column plot layout
# plot(fit)

#effscore names(reduced_data)[41]
hist(reduced_data$effscore)
set.seed(124)
fit=glm(as.formula(paste( "effscore~",
                          paste(colnames(reduced_data)[1:(ncol(reduced_data)-7)], collapse = "+"),
                          sep = "")),data=reduced_data,family=gaussian(link=identity))
summary(fit)
#pchisq(fit$deviance, df=fit$df.residual, lower.tail=FALSE)


# fit=NULL
# fit=step(lm(as.formula(paste( "effscore~",
#                              paste(colnames(reduced_data)[1:(ncol(reduced_data)-7)], collapse = "+"),
#                              sep = "")),data=subset(reduced_data,!is.na(effscore)),
#             direction="backward"))
# summary(fit)
# par(mfrow=c(2,2))  # set 2 rows and 2 column plot layout
# plot(fit)

# ##grade
# #grade names(reduced_data)[39]
# hist(reduced_data$firstgrade)
# fit=NULL
# fit=step(lm(as.formula(paste("firstgrade~",
#                              paste(colnames(reduced_data)[1:(ncol(reduced_data)-7)], collapse = "+"),
#                              sep = "")),data=subset(reduced_data,firstgrade>-2),
#             direction="backward"))
# summary(fit)
# par(mfrow=c(2,2))  # set 2 rows and 2 column plot layout
# plot(fit)
# 
# 
# #averageAttmptOnSolvedProbs names(reduced_data)[37]
# hist(reduced_data$averageAttmptOnSolvedProbs)
# fit=NULL
# fit=step(lm(as.formula(paste("averageAttmptOnSolvedProbs~",
#                              paste(colnames(reduced_data)[1:(ncol(reduced_data)-7)], collapse = "+"),
#                              sep = "")),data=reduced_data),
#             direction="backward")
# summary(fit)
# par(mfrow=c(2,2))  # set 2 rows and 2 column plot layout
# plot(fit)
# 
# #avgTotalTimeOnSolvedProbs names(reduced_data)[38]
# hist(log(reduced_data$avgTotalTimeOnSolvedProbs))
# fit=NULL
# fit=step(lm(as.formula(paste( "log(avgTotalTimeOnSolvedProbs)~",
#                              paste(colnames(reduced_data)[1:(ncol(reduced_data)-7)], collapse = "+"),
#                              sep = "")),data=reduced_data),
#          direction="backward")
# summary(fit)
# par(mfrow=c(2,2))  # set 2 rows and 2 column plot layout
# plot(fit)
# 
# 
# ###logistic regression for prob being effective
# reduced_data$effclass[reduced_data$effscore>0.5]=1
# reduced_data$effclass[reduced_data$effscore<=0.5]=0
# fit=glm(as.formula(paste( "effclass ~",
#                     paste(colnames(reduced_data)[1:(ncol(reduced_data)-7)], collapse = "+"),
#                     sep = "")), family = binomial(link = "logit"), data = reduced_data)
# summary(fit)

# ###############################
# ###############################
# ###############################
# fit=NULL
# fit=lm(effscore ~ GENDER+progexp,
#         data = subset(behav1,!is.na(effscore)))
# summary(fit)
# 
# reduced_data$effclass[reduced_data$effscore>0.5]=1
# reduced_data$effclass[reduced_data$effscore<=0.5]=0
# fit2=glm(as.formula(paste( "effclass ~",
#                           paste(colnames(reduced_data)[1:34], collapse = "+"),
#                           sep = "")), family = binomial(link = "logit"), data = reduced_data)
# summary(fit2)
# 
# AIC(fit,fit2)
# BIC(fit,fit2)
