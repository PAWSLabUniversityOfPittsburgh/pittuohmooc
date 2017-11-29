#
# Explore problem completion
#

d = read.delim("data/ALLBG_student_problem_completion_upd.txt",header=TRUE,sep="\t",quote="",stringsAsFactors = FALSE)
str(d)
# 'data.frame':	798 obs. of  8 variables:
# $ Student           : Factor w/ 798 levels "100ef9743502405102c03312c6d111ce",..: 516 784 742 657 426 249 553 630 166 181 ...
# $ Course            : Factor w/ 4 levels "hy-s2015-ohpe",..: 1 3 4 1 3 4 1 4 3 3 ...
# $ AttemptedNotSolved: int  3 2 4 7 3 5 3 3 5 2 ...
# $ PartSolved        : int  14 13 14 18 5 15 13 13 9 17 ...
# $ Solved            : int  95 98 82 84 73 65 96 65 80 92 ...
# $ Attempted         : int  112 113 100 109 81 85 112 81 94 111 ...
# $ All               : int  171 115 103 171 115 103 171 103 115 115 ...
# $ NotAttempted      : int  59 2 3 62 34 18 59 22 21 4 ...

# counts
D <- dist(d[,c("AttemptedNotSolved","PartSolved","Solved","NotAttempted")], method = "euclidean")
f1 <- hclust(D, method="ward.D") 
plot(f1) # display dendogram
c1 <- cutree(f1, k=3) # cut tree into 5 clusters
rect.hclust(f1, k=3, border="red")
table(c1)
#   1   2   3 
# 300 263 235

# log1p counts
D <- dist(log1p(d[,c("AttemptedNotSolved","PartSolved","Solved","NotAttempted")]), method = "euclidean")
f2 <- hclust(D, method="ward.D") 
plot(f2) # display dendogram
c2 <- cutree(f2, k=3) # cut tree into 5 clusters
rect.hclust(f2, k=3, border="red")
table(c2)
#   1   2   3 
# 316 264 218 

# log1p counts
d$SolvedPartSolved = d$Solved + d$PartSolved
D <- dist(log1p(d[,c("AttemptedNotSolved","SolvedPartSolved","NotAttempted")]), method = "euclidean")
f22 <- hclust(D, method="ward.D") 
plot(f22) # display dendogram
c22 <- cutree(f22, k=2) # cut tree into 5 clusters
rect.hclust(f22, k=2, border="red")
table(c22)
# c22
#   1   2 
# 535 263 


table(c1,c2)
#    c2
# c1    1   2   3
#  1 252   3  45
#  2   2 261   0
#  3  62   0 173

# log1p counts and n-1 percentages
D1 = log1p(d[,c("AttemptedNotSolved","PartSolved","Solved","NotAttempted")])
D2 = d[,c("AttemptedNotSolved","PartSolved","NotAttempted")]/d$All
D <- dist(cbind(D1,D2), method = "euclidean")
f3 <- hclust(D, method="ward.D") 
plot(f3) # display dendogram
c3 <- cutree(f3, k=3) # cut tree into 5 clusters
rect.hclust(f3, k=3, border="red")
table(c3)
#   1   2   3 
# 379 202 217
table(c2,c3)
#    c3
# c2    1   2   3
#   1 316   0   0
#   2  62 202   0
#   3   1   0 217

# Just take clustering c2 - it was more separated in dendrogram and similar to c3
d$muAttemptedNotSolved = d$AttemptedNotSolved/d$All
d$muPartSolved         = d$PartSolved/d$All
d$muSolved             = d$Solved/d$All
d$muNotAttempted       = d$NotAttempted/d$All
a=aggregate(cbind(muAttemptedNotSolved, muPartSolved, muSolved, muNotAttempted)~c2,data=d,FUN=mean)
a
#   c2 muAttemptedNotSolved muPartSolved  muSolved muNotAttempted
# 1  1           0.02467051   0.07190835 0.5241186     0.37930254
# 2  2           0.02925573   0.13688905 0.8000086     0.03384659
# 3  3           0.01230043   0.01056751 0.3089188     0.66821325
# swap 1 and 2, so that 1 is solvers
c2[c2==2]=5
c2[c2==1]=2
c2[c2==5]=1
table(c2) # swapped
#   1   2   3 
# 264 316 218 
a=aggregate(cbind(muAttemptedNotSolved, muPartSolved, muSolved, muNotAttempted)~c2,data=d,FUN=mean)
a
#   c2 muAttemptedNotSolved muPartSolved  muSolved muNotAttempted
# 1  1           0.02925573   0.13688905 0.8000086     0.03384659
# 2  2           0.02467051   0.07190835 0.5241186     0.37930254
# 3  3           0.01230043   0.01056751 0.3089188     0.66821325

a=aggregate(cbind(muAttemptedNotSolved, muPartSolved, muSolved, muNotAttempted)~c21,data=d,FUN=mean)
a
#   c21 muAttemptedNotSolved muPartSolved  muSolved muNotAttempted
# 1   1           0.01812319   0.02400925 0.3407404      0.6171272
# 2   2           0.02674083   0.09535955 0.6042954      0.2736042
# 3   3           0.02357760   0.11135355 0.7286200      0.1364488

a=aggregate(cbind(muAttemptedNotSolved, muPartSolved, muSolved, muNotAttempted)~c22,data=d,FUN=mean)
a
#   c22 muAttemptedNotSolved muPartSolved  muSolved muNotAttempted
# 1   1           0.01951129   0.04699028 0.4370123      0.4964861
# 2   2           0.02951463   0.13697971 0.7998726      0.0336331



library(nFactors)
mydata = d[,c("AttemptedNotSolved","Solved","NotAttempted")]
ev <- eigen(cor(mydata)) # get eigenvalues
ap <- parallel(subject=nrow(mydata),var=ncol(mydata),rep=100,cent=.05)
nS <- nScree(x=ev$values, aparallel=ap$eigen$qevpea)
plotnScree(nS)

q=quantile(d$Solved,probs=c(1/3,2/3))
c21 = rep(2, dim(d)[1])
c21[d$Solved<=q[1]] = 1
c21[d$Solved> q[2]] = 3
table(c21)
# c21
#   1   2   3 
# 268 268 262 
table(c2,c21)
#    c21
# c2    1   2   3
#   1   0  93 171
#   2  64 162  90
#   3 204  13   1
# 

library(FactoMineR)
result <- PCA(mydata) # graphs generated automatically

# write this cluster to file
write.table(cbind(d$Student,c2),file="data/ALLBG_allsubmitABCD_clusterPSolve.txt", quote=FALSE, sep="\t", row.names=FALSE, col.names = FALSE)
