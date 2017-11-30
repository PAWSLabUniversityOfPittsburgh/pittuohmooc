#
# Visualize "the fullest model" fit in LIBLINEAR with "all possible" parameters
#

source("./code/read_liblinear_model.R")
require(ggplot2)

options(echo=TRUE) # if you want see commands in output file
args <- commandArgs(trailingOnly = TRUE)

nG <- as.integer(args[1]) # no. students
nK <- as.integer(args[2]) # no. skills
nB <- as.integer(args[3]) # no. behaviors (definitely a command-line parameter)
nP <- as.integer(args[4]) # no. problems (definitely a command-line parameter)
fn_model<- as.character(args[5]) # model file name
fn_behav_labels<- as.character(args[6]) # file with behavior names
fn_output_prefix<- as.character(args[7]) # prefix for the output graph file

# hard-coded for the time being
nG = 1788 # no. students
nK =  155 # no. skills
nB =    4 # no. behaviors (definitely a command-line parameter)
nP =  241 # no. problems
fn_model = "model/ALL_allsubmit_llTFMcountPS4_model_C1.0.txt" # model file name
fn_behav_labels = "data/behaviors_PS4.txt"
fn_output_prefix = "result/TFM_PS4/fig_"

#
# Description of the columns for 4 and 12 behaviors
#
# Behaviors=4 
# features 141634
# signature  0-0,outcome;1:1787,student intercept;1788:1790,behavior 4 intercept;1791:3578,behavior 1 intercept across students;3579:5366,behavior 2 intercept across students;5367:7154,behavior 3 intercept across students;7155:7395,behavior 1 intercept across problems;7396:7636,behavior 2 intercept across problems;7637:7877,behavior 3 intercept across problems;7878:7881,behavior slope;7882:7885,behavior user slope;7886:7889,behavior problem slope;7890:9677,behavior 1 slope since submission for users;9678:11465,behavior 2 slope since submission for users;11466:13253,behavior 3 slope since submission for users;13254:15041,behavior 4 slope since submission for users;15042:16829,behavior 1 slope since start of work for users;16830:18617,behavior 2 slope since start of work for users;18618:20405,behavior 3 slope since start of work for users;20406:22193,behavior 4 slope since start of work for users;22194:23981,behavior 1 slope since start of work for problems;23982:25769,behavior 2 slope since start of work for problems;25770:27557,behavior 3 slope since start of work for problems;27558:29345,behavior 4 slope since start of work for problems;29346:29499,skill intercepts;29500:66613,skill-problem intercepts;66614:66768,skill slopes;66769:66923,skill failure slopes;66924:104278,skill-problem slopes;104279:141633,skill-problem failure slopes;141634:141634,bias
# pools 16,1:1787,1791:3578,3579:5366,5367:7154,7890:9677,9678:11465,11466:13253,13254:15041,15042:16829,16830:18617,18618:20405,20406:22193,22194:23981,23982:25769,25770:27557,27558:29345
# Behaviors=12
# features 200810
# signature  0-0,outcome;1:1787,student intercept;1788:1798,behavior 12 intercept;1799:3586,behavior 1 intercept across students;3587:5374,behavior 2 intercept across students;5375:7162,behavior 3 intercept across students;7163:8950,behavior 4 intercept across students;8951:10738,behavior 5 intercept across students;10739:12526,behavior 6 intercept across students;12527:14314,behavior 7 intercept across students;14315:16102,behavior 8 intercept across students;16103:17890,behavior 9 intercept across students;17891:19678,behavior 10 intercept across students;19679:21466,behavior 11 intercept across students;21467:21707,behavior 1 intercept across problems;21708:21948,behavior 2 intercept across problems;21949:22189,behavior 3 intercept across problems;22190:22430,behavior 4 intercept across problems;22431:22671,behavior 5 intercept across problems;22672:22912,behavior 6 intercept across problems;22913:23153,behavior 7 intercept across problems;23154:23394,behavior 8 intercept across problems;23395:23635,behavior 9 intercept across problems;23636:23876,behavior 10 intercept across problems;23877:24117,behavior 11 intercept across problems;24118:24129,behavior slope;24130:24141,behavior user slope;24142:24153,behavior problem slope;24154:25941,behavior 1 slope since submission for users;25942:27729,behavior 2 slope since submission for users;27730:29517,behavior 3 slope since submission for users;29518:31305,behavior 4 slope since submission for users;31306:33093,behavior 5 slope since submission for users;33094:34881,behavior 6 slope since submission for users;34882:36669,behavior 7 slope since submission for users;36670:38457,behavior 8 slope since submission for users;38458:40245,behavior 9 slope since submission for users;40246:42033,behavior 10 slope since submission for users;42034:43821,behavior 11 slope since submission for users;43822:45609,behavior 12 slope since submission for users;45610:47397,behavior 1 slope since start of work for users;47398:49185,behavior 2 slope since start of work for users;49186:50973,behavior 3 slope since start of work for users;50974:52761,behavior 4 slope since start of work for users;52762:54549,behavior 5 slope since start of work for users;54550:56337,behavior 6 slope since start of work for users;56338:58125,behavior 7 slope since start of work for users;58126:59913,behavior 8 slope since start of work for users;59914:61701,behavior 9 slope since start of work for users;61702:63489,behavior 10 slope since start of work for users;63490:65277,behavior 11 slope since start of work for users;65278:67065,behavior 12 slope since start of work for users;67066:68853,behavior 1 slope since start of work for problems;68854:70641,behavior 2 slope since start of work for problems;70642:72429,behavior 3 slope since start of work for problems;72430:74217,behavior 4 slope since start of work for problems;74218:76005,behavior 5 slope since start of work for problems;76006:77793,behavior 6 slope since start of work for problems;77794:79581,behavior 7 slope since start of work for problems;79582:81369,behavior 8 slope since start of work for problems;81370:83157,behavior 9 slope since start of work for problems;83158:84945,behavior 10 slope since start of work for problems;84946:86733,behavior 11 slope since start of work for problems;86734:88521,behavior 12 slope since start of work for problems;88522:88675,skill intercepts;88676:125789,skill-problem intercepts;125790:125944,skill slopes;125945:126099,skill failure slopes;126100:163454,skill-problem slopes;163455:200809,skill-problem failure slopes;200810:200810,bias
# pools 48,1:1787,1799:3586,3587:5374,5375:7162,7163:8950,8951:10738,10739:12526,12527:14314,14315:16102,16103:17890,17891:19678,19679:21466,24154:25941,25942:27729,27730:29517,29518:31305,31306:33093,33094:34881,34882:36669,36670:38457,38458:40245,40246:42033,42034:43821,43822:45609,45610:47397,47398:49185,49186:50973,50974:52761,52762:54549,54550:56337,56338:58125,58126:59913,59914:61701,61702:63489,63490:65277,65278:67065,67066:68853,68854:70641,70642:72429,72430:74217

# read model data
w = read_liblinear_model(fn_model)
b = read.delim(fn_behav_labels,header=FALSE,stringsAsFactors = FALSE)[,1]

source("./code/parse_liblinear_TFM_parameters.R")

# parameters
#  1. int_student
#  2. int_behav 
#  3. int_student_wi_behav
#  4. int_problem_wi_behav
#  5. slope_behav_since_prev_submit
#  6. slope_behav_for_user
#  7. slope_behav_for_problem
#  8. slope_user_wi_behav_since_prev_submit
#  9. slope_user_wi_behav_since_start
# 10. slope_user_wi_behav_since_problem_start
# 11. int_skill
# 12. int_skill_wi_problem
# 13. slope_skill
# 14. slope_skill_fail
# 15. slope_skill_wi_problem
# 16. slope_skill_fail_wi_problem
# 17. bias 

parameter_table = data.frame()

value = int_student
main = "global student intercept distribution"
png(paste(fn_output_prefix,"int_student",".png",sep=""),height=360,width=360)
plot(density(value),main=main,sub=paste("Mean,SD,Median=",round(mean(value),digits=3),",",round(sd(value),digits=3),",",round(median(value),digits=3),sep=""),cex=0.8)
abline(v=mean(value),col="red",lty=1)
abline(v=median(value),col="red",lty=2)
abline(v=mean(value)+sd(value),col="red",lty=3)
abline(v=mean(value)-sd(value),col="red",lty=3)
legend("topright",legend=c("mean","median","+/- sd"),col="red",lty=1:3)
parameter_table = rbind(parameter_table, data.frame(variable=main,mean=mean(value),sd=sd(value)))
dev.off()

value = int_behav
main = "global behavior intercepts"
png(paste(fn_output_prefix,"int_behav",".png",sep=""),height=360,width=360)
barplot(value,main=main,names.arg=b[1:(nB-1)])
dev.off()

value = int_student_wi_behav
main = "student intercept w/in behaviors"
labels = NULL
df = data.frame()
for(i in 1:(nB-1)){
  labels = c(labels,paste(b[i],", M(SD)=",round(mean(value[,i]),digits=3),"(",round(sd(value[,i]),digits=3),")",sep=""))
  parameter_table = rbind(parameter_table, data.frame(variable=paste(main," (",b[i],")",sep=""),mean=mean(value[,i]),sd=sd(value[,i])))
}
for(i in 1:(nB-1)){
  df = rbind(df, data.frame(intercept=value[,i], behavior=rep(labels[i],dim(value)[1])))
}
anova_pval = summary(aov(intercept~behavior,data=df))[[1]][,"Pr(>F)"][1]
png(paste(fn_output_prefix,"int_student_wi_behav",".png",sep=""),height=360,width=480)
ggplot(data=df,aes(x=intercept,colour=behavior)) + geom_density() + labs(title = paste(main," (ANOVA p=",round(anova_pval,digits=3),")",sep=""))
dev.off()
png(paste(fn_output_prefix,"int_student_wi_behav_contrasts",".png",sep=""),height=360,width=1080)
par(mfrow=c(1,3))
for(i in 1:(nB-2)){
  for(j in (i+1):(nB-1)){
    ct = cor.test(value[,j],value[,i])
    plot(value[,i],value[,j], main=paste("Contrasts for",main),xlab=labels[i],ylab=labels[j],sub=paste("R=",round(ct$estimate,digits=3)," (pval=",sprintf("%5.3f",ct$p.value),")",sep=""),cex=1.6,cex.lab=1.6, cex.axis=1.6, cex.main=1.6, cex.sub=1.6)
    abline(lm(value[,j]~value[,i]),col="red")
    # df = rbind(df, data.frame(intercept=value[,i], behavior=rep(labels[i],dim(value)[1])))
  }
}
dev.off()


value = int_problem_wi_behav
main = "prob. intercept w/in behaviors"
labels = NULL
df = data.frame()
for(i in 1:(nB-1)){
  labels = c(labels,paste(b[i],", M(SD)=",round(mean(value[,i]),digits=3),"(",round(sd(value[,i]),digits=3),")",sep=""))
}
for(i in 1:(nB-1)){
  df = rbind(df, data.frame(intercept=value[,i], behavior=rep(labels[i],dim(value)[1])))
}
anova_pval = summary(aov(intercept~behavior,data=df))[[1]][,"Pr(>F)"][1]
png(paste(fn_output_prefix,"int_problem_wi_behav",".png",sep=""),height=360,width=480)
ggplot(data=df,aes(x=intercept,colour=behavior)) + geom_density() + labs(title = paste(main," (ANOVA p=",round(anova_pval,digits=3),")",sep=""))
dev.off()
png(paste(fn_output_prefix,"int_problem_wi_behav_contrasts",".png",sep=""),height=360,width=1080)
par(mfrow=c(1,3))
for(i in 1:(nB-2)){
  for(j in (i+1):(nB-1)){
    ct = cor.test(value[,j],value[,i])
    plot(value[,i],value[,j], main=paste("Contrasts for",main),xlab=labels[i],ylab=labels[j],sub=paste("R=",round(ct$estimate,digits=3)," (pval=",sprintf("%5.3f",ct$p.value),")",sep=""),cex=1.6,cex.lab=1.6, cex.axis=1.6, cex.main=1.6, cex.sub=1.6)
    abline(lm(value[,j]~value[,i]),col="red")
    # df = rbind(df, data.frame(intercept=value[,i], behavior=rep(labels[i],dim(value)[1])))
  }
}
dev.off()

value = slope_behav_since_prev_submit
main = "slope behavior since previous submit"
png(paste(fn_output_prefix,"slope_behav_since_prev_submit",".png",sep=""),height=360,width=360)
barplot(value,main=main,names.arg=b)
dev.off()


value = slope_behav_for_user
main = "slope behavior for user"
png(paste(fn_output_prefix,"slope_behav_for_user",".png",sep=""),height=360,width=360)
barplot(value,main=main,names.arg=b)
dev.off()


value = slope_behav_for_problem
main = "slope behavior for problem"
png(paste(fn_output_prefix,"slope_behav_for_problem",".png",sep=""),height=360,width=360)
barplot(value,main=main,names.arg=b)
dev.off()


value = slope_user_wi_behav_since_prev_submit
main = "user slope w/in behav. since prev submit"
labels = NULL
df = data.frame()
for(i in 1:(nB-1)){
  labels = c(labels,paste(b[i],", M(SD)=",round(mean(value[,i]),digits=3),"(",round(sd(value[,i]),digits=3),")",sep=""))
  parameter_table = rbind(parameter_table, data.frame(variable=paste(main," (",b[i],")",sep=""), mean=mean(value[,i]),sd=sd(value[,i])))
}
for(i in 1:(nB-1)){
  df = rbind(df, data.frame(intercept=value[,i], behavior=rep(labels[i],dim(value)[1])))
}
anova_pval = summary(aov(intercept~behavior,data=df))[[1]][,"Pr(>F)"][1]
png(paste(fn_output_prefix,"slope_user_wi_behav_since_prev_submit",".png",sep=""),height=360,width=480)
ggplot(data=df,aes(x=intercept,colour=behavior)) + geom_density() + labs(title = paste(main," (ANOVA p=",round(anova_pval,digits=3),")",sep=""))
dev.off()
png(paste(fn_output_prefix,"slope_user_wi_behav_since_prev_submit_contrasts",".png",sep=""),height=360,width=1080)
par(mfrow=c(1,3))
for(i in 1:(nB-2)){
  for(j in (i+1):(nB-1)){
    ct = cor.test(value[,j],value[,i])
    plot(value[,i],value[,j], main=paste("Contrasts for",main),xlab=labels[i],ylab=labels[j],sub=paste("R=",round(ct$estimate,digits=3)," (pval=",sprintf("%5.3f",ct$p.value),")",sep=""),cex=1.6,cex.lab=1.6, cex.axis=1.6, cex.main=1.6, cex.sub=1.6)
    abline(lm(value[,j]~value[,i]),col="red")
  }
}
dev.off()


value = slope_user_wi_behav_since_start
main = "user slope w/in behav. since start of work"
labels = NULL
df = data.frame()
for(i in 1:(nB-1)){
  labels = c(labels,paste(b[i],", M(SD)=",round(mean(value[,i]),digits=3),"(",round(sd(value[,i]),digits=3),")",sep=""))
  parameter_table = rbind(parameter_table, data.frame(variable=paste(main," (",b[i],")",sep=""),mean=mean(value[,i]),sd=sd(value[,i])))
}
for(i in 1:(nB-1)){
  df = rbind(df, data.frame(intercept=value[,i], behavior=rep(labels[i],dim(value)[1])))
}
anova_pval = summary(aov(intercept~behavior,data=df))[[1]][,"Pr(>F)"][1]
png(paste(fn_output_prefix,"slope_user_wi_behav_since_start",".png",sep=""),height=360,width=480)
ggplot(data=df,aes(x=intercept,colour=behavior)) + geom_density() + labs(title = paste(main," (ANOVA p=",round(anova_pval,digits=3),")",sep=""))
dev.off()
png(paste(fn_output_prefix,"slope_user_wi_behav_since_start_contrasts",".png",sep=""),height=360,width=1080)
par(mfrow=c(1,3))
for(i in 1:(nB-2)){
  for(j in (i+1):(nB-1)){
    ct = cor.test(value[,j],value[,i])
    plot(value[,i],value[,j], main=paste("Contrasts for",main),xlab=labels[i],ylab=labels[j],sub=paste("R=",round(ct$estimate,digits=3)," (pval=",sprintf("%5.3f",ct$p.value),")",sep=""),cex=1.6,cex.lab=1.6, cex.axis=1.6, cex.main=1.6, cex.sub=1.6)
    abline(lm(value[,j]~value[,i]),col="red")
  }
}
dev.off()


value = slope_user_wi_behav_since_problem_start
main = "user slope w/in behavior since prob. start"
labels = NULL
df = data.frame()
for(i in 1:(nB-1)){
  labels = c(labels,paste(b[i],", M(SD)=",round(mean(value[,i]),digits=3),"(",round(sd(value[,i]),digits=3),")",sep=""))
  parameter_table = rbind(parameter_table, data.frame(variable=paste(main," (",b[i],")",sep=""), mean=mean(value[,i]),sd=sd(value[,i])))
}
for(i in 1:(nB-1)){
  df = rbind(df, data.frame(intercept=value[,i], behavior=rep(labels[i],dim(value)[1])))
}
anova_pval = summary(aov(intercept~behavior,data=df))[[1]][,"Pr(>F)"][1]
png(paste(fn_output_prefix,"slope_user_wi_behav_since_problem_start",".png",sep=""),height=360,width=480)
ggplot(data=df,aes(x=intercept,colour=behavior)) + geom_density() + labs(title = paste(main," (ANOVA p=",round(anova_pval,digits=3),")",sep=""))
dev.off()
png(paste(fn_output_prefix,"slope_user_wi_behav_since_problem_start_contrasts",".png",sep=""),height=360,width=1080)
par(mfrow=c(1,3))
for(i in 1:(nB-2)){
  for(j in (i+1):(nB-1)){
    ct = cor.test(value[,j],value[,i])
    plot(value[,i],value[,j], main=paste("Contrasts for",main),xlab=labels[i],ylab=labels[j],sub=paste("R=",round(ct$estimate,digits=3)," (pval=",sprintf("%5.3f",ct$p.value),")",sep=""),cex=1.6,cex.lab=1.6, cex.axis=1.6, cex.main=1.6, cex.sub=1.6)
    abline(lm(value[,j]~value[,i]),col="red")
  }
}
dev.off()



value = int_skill
main = "skill intercept"
png(paste(fn_output_prefix,"int_skill",".png",sep=""),height=360,width=360)
plot(density(value),main=main,sub=paste("Mean,SD,Median=",round(mean(value),digits=3),",",round(sd(value),digits=3),",",round(median(value),digits=3),sep=""))
abline(v=mean(value),col="red",lty=1)
abline(v=median(value),col="red",lty=2)
abline(v=mean(value)+sd(value),col="red",lty=3)
abline(v=mean(value)-sd(value),col="red",lty=3)
legend("topleft",legend=c("mean","median","+/- sd"),col="red",lty=1:3)
dev.off()


# HOW?
value = int_skill_wi_problem
main = "skill intercept w/in problem"
labels = NULL

value = int_skill_wi_problem
main = "skill intercept w/in problem"
png(paste(fn_output_prefix,"int_skill_wi_problem",".png",sep=""),height=360,width=360)
plot(density(value),main=main,sub=paste("Mean,SD,Median=",round(mean(value),digits=3),",",round(sd(value),digits=3),",",round(median(value),digits=3),sep=""))
abline(v=mean(value),col="red",lty=1)
abline(v=median(value),col="red",lty=2)
abline(v=mean(value)+sd(value),col="red",lty=3)
abline(v=mean(value)-sd(value),col="red",lty=3)
legend("topleft",legend=c("mean","median","+/- sd"),col="red",lty=1:3)
dev.off()
df = data.frame()
sds = NULL
means = NULL
for(i in 1:(nP)){
  labels = c(labels,paste("prob. ",i,", M(SD)=",round(mean(value[,i]),digits=3),"(",round(sd(value[,i]),digits=3),")",sep=""))
  means = c(means,mean(value[,i]))
  sds = c(sds,sd(value[,i]))
}
# for(i in 1:(nP)){
#   df = rbind(df, data.frame(intercept=value[,i], behavior=rep(labels[i],dim(value)[1])))
# }
# anova_pval = summary(aov(intercept~behavior,data=df))[[1]][,"Pr(>F)"][1]
# ggplot(data=df,aes(x=intercept,colour=behavior)) + geom_density(show.legend = FALSE) + labs(title = paste(main," (ANOVA p=",round(anova_pval,digits=3),")",sep="")) + scale_y_log10()
# plot(density(value),log="y",main=main,sub=paste("Mean(SD)=",round(mean(value),digits=3),"(",round(sd(value),digits=3),")",sep=""))

png(paste(fn_output_prefix,"int_skill_wi_problem_means_sds",".png",sep=""),height=360,width=720)
par(mfrow=c(1,2))
plot(density(means),main=main,sub="problem means")
plot(density(sds),main=main,sub="problem SDs")
dev.off()
# OR
ix = sort(means, index.return=TRUE)$ix
png(paste(fn_output_prefix,"int_skill_wi_problem_means_vs_sds",".png",sep=""),height=360,width=720)
plot(1:nP, means[ix], ylim=range(c(means[ix]-sds[ix], means[ix]+sds[ix])), pch=19, xlab="Problem", ylab="w/in prob. M(SD)", main=main)
arrows(1:nP, means[ix]-sds[ix], 1:nP, means[ix]+sds[ix], length=0.05, angle=90, code=3)
dev.off()


value = slope_skill
main = "skill slope"
png(paste(fn_output_prefix,"slope_skill",".png",sep=""),height=360,width=360)
plot(density(value),main=main,sub=paste("Mean,SD,Median=",round(mean(value),digits=3),",",round(sd(value),digits=3),",",round(median(value),digits=3),sep=""))
abline(v=mean(value),col="red",lty=1)
abline(v=median(value),col="red",lty=2)
abline(v=mean(value)+sd(value),col="red",lty=3)
abline(v=mean(value)-sd(value),col="red",lty=3)
legend("topright",legend=c("mean","median","+/- sd"),col="red",lty=1:3)
dev.off()


value = slope_skill_fail
main = "skill slope for failures"
png(paste(fn_output_prefix,"slope_skill_fail",".png",sep=""),height=360,width=360)
plot(density(value),main=main,sub=paste("Mean,SD,Median=",round(mean(value),digits=3),",",round(sd(value),digits=3),",",round(median(value),digits=3),sep=""))
abline(v=mean(value),col="red",lty=1)
abline(v=median(value),col="red",lty=2)
abline(v=mean(value)+sd(value),col="red",lty=3)
abline(v=mean(value)-sd(value),col="red",lty=3)
legend("topright",legend=c("mean","median","+/- sd"),col="red",lty=1:3)
dev.off()


# slope_skill vs. slope_skill_fail
ct = cor.test(slope_skill_fail,slope_skill)
png(paste(fn_output_prefix,"slope_skill__vs__slope_skill_fail",".png",sep=""),height=360,width=360)
plot(slope_skill,slope_skill_fail, sub=paste("R=",round(ct$estimate,digits=3)," (pval=",sprintf("%5.3f",ct$p.value),")",sep=""),xlab="skill slope",ylab="skill slope for failures")
abline(lm(slope_skill_fail~slope_skill),col="red")
dev.off()


value = slope_skill_wi_problem
main = "skill slope w/in problem"
labels = NULL
df = data.frame()
sds = NULL
means = NULL
for(i in 1:(nP)){
  labels = c(labels,paste("prob. ",i,", M(SD)=",round(mean(value[,i]),digits=3),"(",round(sd(value[,i]),digits=3),")",sep=""))
  means = c(means,mean(value[,i]))
  sds = c(sds,sd(value[,i]))
}
# for(i in 1:(nP)){
#   df = rbind(df, data.frame(intercept=value[,i], behavior=rep(labels[i],dim(value)[1])))
# }
# anova_pval = summary(aov(intercept~behavior,data=df))[[1]][,"Pr(>F)"][1]
# ggplot(data=df,aes(x=intercept,colour=behavior)) + geom_density(show.legend = FALSE) + labs(title = paste(main," (ANOVA p=",round(anova_pval,digits=3),")",sep="")) + scale_y_log10()
# plot(density(value),log="y",main=main,sub=paste("Mean(SD)=",round(mean(value),digits=3),"(",round(sd(value),digits=3),")",sep=""))

png(paste(fn_output_prefix,"slope_skill_wi_problem_means_sds",".png",sep=""),height=360,width=720)
par(mfrow=c(1,2))
plot(density(means),main=main,sub="distribution of prob. means")
plot(density(sds),main=main,sub="distribution of prob. SDs")
dev.off()
# OR
ix = sort(means, index.return=TRUE)$ix
png(paste(fn_output_prefix,"slope_skill_wi_problem_means_vs_sds",".png",sep=""),height=360,width=360)
plot(1:nP, means[ix], ylim=range(c(means[ix]-sds[ix], means[ix]+sds[ix])), pch=19, xlab="Problem", ylab="w/in prob. M(SD)", main=main)
arrows(1:nP, means[ix]-sds[ix], 1:nP, means[ix]+sds[ix], length=0.05, angle=90, code=3)
dev.off()


value = slope_skill_fail_wi_problem
main = "skill fail slope w/in problem"
labels = NULL
df = data.frame()
sds = NULL
means = NULL
for(i in 1:(nP)){
  labels = c(labels,paste("prob. ",i,", M(SD)=",round(mean(value[,i]),digits=3),"(",round(sd(value[,i]),digits=3),")",sep=""))
  means = c(means,mean(value[,i]))
  sds = c(sds,sd(value[,i]))
}
# for(i in 1:(nP)){
#   df = rbind(df, data.frame(intercept=value[,i], behavior=rep(labels[i],dim(value)[1])))
# }
# anova_pval = summary(aov(intercept~behavior,data=df))[[1]][,"Pr(>F)"][1]
# ggplot(data=df,aes(x=intercept,colour=behavior)) + geom_density(show.legend = FALSE) + labs(title = paste(main," (ANOVA p=",round(anova_pval,digits=3),")",sep="")) + scale_y_log10()
# plot(density(value),log="y",main=main,sub=paste("Mean(SD)=",round(mean(value),digits=3),"(",round(sd(value),digits=3),")",sep=""))

png(paste(fn_output_prefix,"slope_skill_fail_wi_problem_means_sds",".png",sep=""),height=360,width=720)
par(mfrow=c(1,2))
plot(density(means),main=main,sub="distribution of prob. means")
plot(density(sds),main=main,sub="distribution of prob. SDs")
dev.off()
# OR
ix = sort(means, index.return=TRUE)$ix
png(paste(fn_output_prefix,"slope_skill_wi_problem_means_vs_sds",".png",sep=""),height=360,width=360)
plot(1:nP, means[ix], ylim=range(c(means[ix]-sds[ix], means[ix]+sds[ix])), pch=19, xlab="Problem", ylab="w/in prob. M(SD)", main=main)
arrows(1:nP, means[ix]-sds[ix], 1:nP, means[ix]+sds[ix], length=0.05, angle=90, code=3)
dev.off()

png(paste(fn_output_prefix,"bias",".png",sep=""),height=360,width=360)
barplot(bias)
dev.off()

library(knitr)
parameter_table$mean = round(parameter_table$mean, digits=3)
parameter_table$sd = round(parameter_table$sd, digits=3)
kable(parameter_table, format = "markdown")
