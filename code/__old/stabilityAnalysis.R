rm(list = ls());

meanse<- function(x,mean_digits=4,se_digits=4){
  if (length(x) == 1){
    return (paste0(format(round(mean(x,na.rm=T),mean_digits),nsmall=mean_digits,scientific=FALSE),"(-)"))
  }else{
    return (paste0("M=",format(round(mean(x,na.rm=T),mean_digits),nsmall=mean_digits,scientific=FALSE),",SE=",format(round(sd(x,na.rm=T)/sqrt(length(na.omit(x))),se_digits),nsmall=se_digits,scientific=FALSE)))
  }
}

################
# Read Data 
################
main.directory ='/Users/roya/Desktop/ProgMOOC/code/java/source_codes/progMooc/resource'
#1. reading background information
input = 'StanbilityAnalysisMostFrequentPattern_RandomJS.txt';
file.name <- file.path(main.directory, input);
r_data<-read.csv(file.name,header = F,stringsAsFactors = F,sep=",");
input = 'StanbilityAnalysisMostFrequentPattern_EarlyLateJS.txt';
file.name <- file.path(main.directory, input);
el_data<-read.csv(file.name,header=F,stringsAsFactors = F,sep=",");

################  RANDOM #######################
################   #######################
res<-data.frame(self=numeric(0),other=numeric(0))
for (i in  1:nrow(r_data))
  res<-rbind(res, data.frame(self=r_data[i,3],other = mean(as.matrix(r_data[i,4:ncol(r_data)]))))

qqnorm(res$self)
qqnorm(res$other)
hist(res$self)
hist(res$other)

###Are self-others normall? p>0.5 shows normality
shapiro.test(res$self)
shapiro.test(res$other)
##Are variances of self-others equal?
var.test(res$self,res$other) #if we obtain, p<0.05, then the two variance are not homogenous.Since
# variances are not homogenous(same), we use t.test with param "var.equal = FALSE"
#t.test(res$self,res$other,paired=TRUE,var.equal = FALSE) 

wilcox.test(res$self , res$other, paired=TRUE) 
# > wilcox.test(res$self , res$other, paired=TRUE)
# 
# Wilcoxon signed rank test with continuity correction
# 
# data:  res$self and res$other
# V = 6, p-value < 2.2e-16
# alternative hypothesis: true location shift is not equal to 0

paste0("random self: ",meanse(res$self,4,4))
#######new: random self: M=0.3485,SE=0.0025
#old:   "random self: M=0.3473,SE=0.0024"

paste0("random others: ",meanse(res$other,4,4))
#######new: "random others: M=0.6586,SE=0.0010"
# "random others: M=0.6584,SE=0.0010"


################  EARLYLATE #######################
res<-data.frame(self=numeric(0),other=numeric(0))
for (i in  1:nrow(el_data))
  res<-rbind(res, data.frame(self=el_data[i,3],other = mean(as.matrix(el_data[i,4:ncol(el_data)]))))

qqnorm(res$self) #almost normal
qqnorm(res$other) #almost normal
hist(res$self)
hist(res$other)

###Are self-others normall? p>0.5 shows normality
shapiro.test(res$self)
shapiro.test(res$other)
##Are variances of self-others equal?
var.test(res$self,res$other) #if we obtain, p<0.05, then the two variance are not homogenous.Since
# variances are not homogenous(same), we use t.test with param "var.equal = FALSE"
#t.test(res$self,res$other,paired=TRUE,var.equal = FALSE) 
wilcox.test(res$self , res$other,paired=TRUE) 
# 
# Wilcoxon signed rank test with continuity correction
# 
# data:  res$self and res$other
# V = 149, p-value < 2.2e-16
# alternative hypothesis: true location shift is not equal to 0

paste0("early late self: ",meanse(res$self,4,4))
# "early late self: M=0.4249,SE=0.0022"
paste0("early late others: ",meanse(res$other,4,4))
# [1] "early late others: M=0.6534,SE=0.0010"

write.csv(x=res,
          file = file.path('/Users/roya/Desktop/ProgMOOC/code/java/source_codes/progMooc/resource', 
          paste("stata-early-late-js.txt",sep="-")),row.names=F)

