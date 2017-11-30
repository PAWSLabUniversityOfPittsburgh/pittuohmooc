#
# Explore problem completion
#

d = read.delim("data/ALLBG_student_avgProbCorrect.txt",header=FALSE,sep="\t",quote="",stringsAsFactors = FALSE)
names(d)=c("student","avgcorr")
str(d)
# 'data.frame':	797 obs. of  2 variables:
# $ student: chr  "f973ef8f580c4474d8d96c16ed161963" "ec99c51f0ad8b593b92b70210f81c186" "cf3871acaf903e7b932f184eb4597b80" "88ac6da209de1262ae0eedff27d6c3b3" ...
# $ avgcorr: num  0.632 0.619 0.635 0.707 0.422 ...

q=quantile(d$avgcorr,probs=c(1/3,2/3))
d$cluster = 2
d$cluster[d$avgcorr<=q[1]] = 1
d$cluster[d$avgcorr> q[2]] = 3

plot(density(d$avgcorr))
abline(v=q[1])
abline(v=q[2])

table(d$cluster)
#   1   2   3 
# 266 265 266 


# write this cluster to file
write.table(cbind(d$student,d$cluster),file="data/ALLBG_allsubmitABCD_clusterPCorr.txt", quote=FALSE, sep="\t", row.names=FALSE, col.names = FALSE)
