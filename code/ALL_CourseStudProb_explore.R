#
# Predicting path to successful solution of problems.
#

d = read.delim("data/ALL_CourseStudProb_submits.txt",header = TRUE, sep="\t")
dim(d)
# 143365      5

str(d)
# 'data.frame':	143365 obs. of  5 variables:
# $ solved : int  1 1 1 1 1 1 1 1 1 0 ...
# $ course : Factor w/ 4 levels "hy-s2015-ohpe",..: 2 2 1 4 3 3 2 2 2 3 ...
# $ student: Factor w/ 1865 levels "hy-s2015-ohpe__122dad1c05282dcd26fe1b89eaea6481",..: 774 626 32 1765 1477 1457 308 984 746 1518 ...
# $ problem: Factor w/ 241 levels "viikko01-Viikko01_001.Nimi",..: 191 125 14 225 48 75 199 16
# $ submits: int  10 7 2 1 1 1 26 1 2 1 ...

plot(density((d$submits)))
boxplot(d$submits)
plot(density(log(d$submits)))
boxplot(log(d$submits))

a1 = aggregate(submits~problem,data=d,FUN=mean)
plot(density(a1$submits))
plot(density(log(a1$submits)))
plot(density(scale(log(a1$submits))))
# bi-modal, 0 between modes
a2 = aggregate(solved~problem,data=d,FUN=mean)
plot(density(a2$solved))
plot(scale(log(a1$submits)),a2$solved)
cor.test(scale(log(a1$submits)),a2$solved)
# 95 percent confidence interval:
#   -0.4933747 -0.2788364
# sample estimates:
#   cor 
# -0.3914112 

d$solvedm = d$solved
d$solvedm[d$solvedm==0] = -1
table(d$solvedm)
#    -1      1 
# 20532 122833 

d$zl_submits = d$submits
d$l_submits = log(d$submits)
for(p in levels(d$problem)) {
  ix = d$problem==p
  d$zl_submits[ix] = scale(log(d$zl_submits[ix]))
}
d$zl_submits[is.na(d$zl_submits)] = 0 # 1 submit only, hense SD=NaN
plot(density(d$zl_submits))
abline(v=c(-2,0,2),col="red")
# 2 spikes, 0 in the middle
# positive tail too long
plot(density(d$l_submits))

d$l_submitsm = d$solvedm * d$l_submits
plot(density(d$l_submitsm))


rmse = function(a, e) {
  return( sqrt(mean((a-e)^2)) )
}

acc = function(a, e) {
  p = 1*(e>=0.5)
  return( mean(a==p) )
}

library(lme4)
library(lattice)
f0 = glm(solved~1,data=d)
summary(f0)
# Estimate Std. Error t value Pr(>|t|)    
# (Intercept) 0.8567851  0.0009251   926.1   <2e-16 ***
# AIC: 106080
acc(d$solved,fitted(f0))
# 0.8567851
rmse(d$solved,fitted(f0))
# 0.3502918


f1 = lmer(solved~1+course+(1|student),data=d,family=binomial)
summary(f1)
# Random effects:
# Groups  Name        Variance Std.Dev.
# student (Intercept) 0.144    0.3795  
#                   Estimate Std. Error z value Pr(>|z|)    
# (Intercept)              1.70266    0.03602   47.27  < 2e-16 ***
#   coursek2014-mooc         0.21233    0.04030    5.27 1.37e-07 ***
#   coursek2015-ohjelmointi  0.36450    0.04212    8.65  < 2e-16 ***
#   courses2014-ohpe        -0.14759    0.04834   -3.05  0.00227 ** 
acc(d$solved,fitted(f1))
# 0.8573501
rmse(d$solved,fitted(f1))
# 0.3459071
dotplot(ranef(f1,condVar = TRUE))
# some studens week, most middle

f2 = lmer(solved~1+course+(1|student)+(1|problem),data=d,family=binomial)
summary(f2)
Random effects:
#   Groups  Name        Variance Std.Dev.
# student (Intercept)  1.05    1.025   
# problem (Intercept) 23.11    4.807   
#   Estimate Std. Error z value Pr(>|z|)    
# (Intercept)               2.4319     0.4467   5.444 5.21e-08 ***
#   coursek2014-mooc         -0.6195     0.6129  -1.011  0.31212    
# coursek2015-ohjelmointi   0.3201     0.1022   3.132  0.00174 ** 
#   courses2014-ohpe         -1.0058     0.6161  -1.633  0.10255    
acc(d$solved,fitted(f2))
# 0.9626757
rmse(d$solved,fitted(f2))
# 0.1722617
dotplot(ranef(f2,condVar = TRUE))
# some studens week, most middle
# some problems very weak, never solved?
anova(f1,f2,test="Chisq")
#    Df    AIC    BIC logLik deviance Chisq Chi Df Pr(>Chisq)    
# f1  5 116786 116836 -58388   116776                            
# f2  6  35619  35678 -17804    35607 81169      1  < 2.2e-16 ***

f4 = lmer(solved~1+course+(1|student)+(1|problem)+l_submits,data=d,family=binomial)
summary(f4)
# Groups  Name        Variance Std.Dev.
# student (Intercept)  0.7715  0.8784  
# problem (Intercept) 20.7791  4.5584  
# Number of obs: 143365, groups:  student, 1865; problem, 241
# 
# Fixed effects:
#   Estimate Std. Error z value Pr(>|z|)    
# (Intercept)              3.24295    0.43804    7.40 1.33e-13 ***
# coursek2014-mooc        -0.45175    0.60379   -0.75    0.454    
# coursek2015-ohjelmointi  0.38814    0.09221    4.21 2.56e-05 ***
# courses2014-ohpe        -0.88522    0.60653   -1.46    0.144    
# l_submits               -0.74437    0.01841  -40.43  < 2e-16 ***
acc(d$solved,fitted(f4))
# 0.9638894
rmse(d$solved,fitted(f4))
# 0.1686848
dotplot(ranef(f4,condVar = TRUE))
# some studens week, most middle  
# some problems very weak, never solved
anova(f2,f4,test="Chisq")
#    Df   AIC   BIC logLik deviance Chisq Chi Df Pr(>Chisq)    
# f2  6 35619 35678 -17804    35607                            
# f4  7 34033 34102 -17010    34019  1588      1  < 2.2e-16 ***
  
# predict number of attempts to success/failure

g0 = glm(l_submitsm~1,data=d)
summary(g0)
# Estimate Std. Error t value Pr(>|t|)    
# (Intercept) 0.440492   0.003475   126.7   <2e-16 ***
plot(d$l_submitsm,fitted(g0))
cor.test(d$l_submitsm,fitted(g0))
# NA
mean(abs(d$l_submitsm-fitted(g0)))
# 0.9610278

g1 = lmer(l_submitsm~1+course+(1|student),data=d)
summary(g1)
#   Groups   Name        Variance Std.Dev.
# student  (Intercept) 0.02408  0.1552  
# Residual             1.70823  1.3070  
#   Estimate Std. Error t value
# (Intercept)              0.42062    0.01560  26.965
# coursek2014-mooc         0.05298    0.01738   3.048
# coursek2015-ohjelmointi  0.02857    0.01796   1.591
# courses2014-ohpe        -0.01221    0.02115  -0.577
plot(d$l_submitsm,fitted(g1))
# two clouds, no corr
cor(d$l_submitsm,fitted(g1))^2
# 0.02564653
cor.test(d$l_submitsm,fitted(g1))
# 0.1550975 0.1651848
#   cor 
# 0.1601454 
mean(abs(d$l_submitsm-fitted(g1)))
# 0.9401311
dotplot(ranef(g1,condVar = TRUE))
# few studens week, few strong


g2 = lmer(l_submitsm~1+course+(1|student)+(1|problem),data=d)
summary(g2)
# Groups   Name        Variance Std.Dev.
# student  (Intercept) 0.02997  0.1731  
# problem  (Intercept) 1.18687  1.0894  
# Residual             0.90877  0.9533  
#   Estimate Std. Error t value
# (Intercept)              0.37757    0.10230   3.691
# coursek2014-mooc        -0.05528    0.14165  -0.390
# coursek2015-ohjelmointi  0.02273    0.01731   1.313
# courses2014-ohpe        -0.09009    0.14209  -0.634
plot(d$l_submitsm,fitted(g2))
ix_right   = d$l_submitsm>=0
ix_up_left = d$l_submitsm<0 & fitted(g2) >=0
ix_dn_left = d$l_submitsm<0 & fitted(g2) < 0
ylm = c(min(fitted(g2)),max(fitted(g2)))
xlm = c(min(d$l_submitsm),max(d$l_submitsm))
  plot(d$l_submitsm[ix_right],  fitted(g2)[ix_right],  xlim=xlm, ylim=ylm, col="green",xlab="log(submissions), negative - never solved",ylab="model prediction")
points(d$l_submitsm[ix_up_left],fitted(g2)[ix_up_left],xlim=xlm, ylim=ylm, col="red")
points(d$l_submitsm[ix_dn_left],fitted(g2)[ix_dn_left],xlim=xlm, ylim=ylm, col="blue")
# three clouds, two not correl, two can be corr
cor(d$l_submitsm,fitted(g2))^2
# 0.4831448
cor.test(d$l_submitsm,fitted(g2))
# 95 percent confidence interval:
#   0.6907382 0.6961129
# sample estimates:
#   cor 
# 0.6934352 
mean(abs(d$l_submitsm-fitted(g2)))
# 0.6317505
dotplot(ranef(g2,condVar = TRUE))
# few studens week, few strong
# problem, hogged al the variance

save.image(file="code/ALL_CourseStudProb_explore.RData")
