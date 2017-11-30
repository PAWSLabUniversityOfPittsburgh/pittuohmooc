rm(list = ls());
library(ggplot2)

theme_set(theme_bw(base_size = 12, base_family = "Helvetica")); #set the background of all plots to white

################
# Read Data 
################
main.directory ='/Users/roya/Desktop/ProgMOOC/code/java/source_codes/progMooc/resource'
input = 'ProblemComplexity.txt';
file.name <- file.path(main.directory, input);
complexity<-read.csv(file.name,header = F,stringsAsFactors = T,sep=",");
colnames(complexity)[1]="dataset"
colnames(complexity)[2]="exe"
colnames(complexity)[3]="avg.concept"
colnames(complexity)[4]="pcorrect"

summary(complexity$pcorrect)
hist(complexity$pcorrect)
nrow(subset(complexity,pcorrect<=0.3))
nrow(subset(complexity,pcorrect>0.3 & pcorrect <0.7))
nrow(subset(complexity,pcorrect>=0.7))

complexity$level2<-NA
complexity$level2[complexity$pcorrect<=0.3]="hard"
complexity$level2[complexity$pcorrect>0.3 & complexity$pcorrect<0.7 ]="moderate"
complexity$level2[complexity$pcorrect>=0.7]="easy"
table(complexity$level2)

p=ggplot(complexity, aes(x=pcorrect)) + geom_density(alpha=.3)
p

hist(complexity$pcorrect)
p=ggplot(complexity, aes(x=avg.concept, y=pcorrect)) + geom_point()
p

p=ggplot(complexity, aes(x=log(avg.concept), y=pcorrect)) + geom_point()
p
nrow(subset(complexity, pcorrect ==0))
nrow(subset(complexity, pcorrect ==1))

complexity$log.avg.concept<-sapply(complexity$avg.concept,log)
complexity$level<-NA
complexity$level[complexity$log.avg.concept<4]="easy"
complexity$level[complexity$log.avg.concept>=4 & complexity$log.avg.concept<=5 ]="moderate"
complexity$level[complexity$log.avg.concept>5]="hard"
table(complexity$level)

main.directory ='/Users/roya/Desktop/ProgMOOC/code/java/source_codes/progMooc/resource'
input = 'SplitPrevAfterFirstSubmissionTime.txt';
file.name <- file.path(main.directory, input);
data<-read.csv(file.name,header = F,stringsAsFactors = T,sep=",");
colnames(data)[1]="exe"
colnames(data)[2]="behav"
colnames(data)[3]="part"
colnames(data)[4]="millisec"
data=merge(data, complexity, all.x=T,by.x='exe',by.y='exe')

data$millisec<-as.numeric(data$millisec)
nrow(subset(data,millisec==0))
data<-subset(data, millisec>=1000 & millisec< 1200000)

#data<-subset(data, millisec>5000 & millisec< 1200000)
data$logTime=as.numeric(lapply(data$millisec,log))
summary(data$logTime)
hist(data$logTime)
summary(data$millisec)
data<-subset(data,!is.na(level2))
data$std.logTime<-NA
M=mean(data$logTime)
SD=sd(data$logTime)
data$std.logTime=as.numeric(lapply(data$logTime, function(x) {(x-M)/SD}))

summary(data$std.logTime)
hist(data$std.logTime)

library(ggplot2)
#p=ggplot(data, aes(x=std.logTime,y=pcorrect,color=level2)) + geom_line()
#p 

p=ggplot(data, aes(x=std.logTime,fill=level2)) + geom_density(alpha=.6)
p 


plot(data$logTime,data$pcorrect)
p=ggplot(data, aes(x=logTime, fill=as.factor(level2))) + geom_density(alpha=.3)
p
p=ggplot(data, aes(x=logTime, fill=as.factor(behav))) + geom_density(alpha=.3)

p

p=ggplot(data, aes(x=logTime, fill=as.factor(behav))) + geom_density(alpha=.3)
p=p+facet_grid( level~.)
p

p=ggplot(data, aes(x=logTime, fill=as.factor(part))) + geom_density(alpha=.3)
p=p+facet_grid(level~.)
p

p=ggplot(data, aes(x=logTime, fill=as.factor(part))) + geom_density(alpha=.3)
p=p+facet_grid(level~bahav)
p


p=ggplot(data, aes(x=logTime, fill=as.factor(part))) + geom_density(alpha=.3)
p=p+facet_grid( behav ~level)
p

ggplot(data, aes(x=logTime, fill=behav)) + geom_density(alpha=.3)

