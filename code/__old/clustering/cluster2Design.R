#
# turn cluster column into design matrix of validation model runs
#

options(echo=TRUE) # if you want see commands in output file
args <- commandArgs(trailingOnly = TRUE)

fname    <- args[1]
n_rounds <- as.integer(args[2])
n_fit    <- as.integer(args[3])
n_test   <- as.integer(args[4])
fnameout <- args[5]

D = read.delim(fname, header=FALSE, sep="\t", stringsAsFactors=FALSE)
M = matrix(0, nrow=dim(D)[1],ncol=n_rounds)
U = unique(D$V2)

# 0 - do not include, 1 - fit, 2 - test
for(i in 1:n_rounds) {
  r = runif(dim(D)[1])
  for(u in U) {
    ix=D[,2]==u
    M[ix,i] = rank(r[ix])
  }
}
# 798 users, 10 runs
# sum(M>0) # 7980
# sum(M>(n_fit+n_test)) # 4980
# sum(M<=(n_fit+n_test)) # 3000
M[M>(n_fit+n_test)] = 0
M[(M<=n_fit & M>0)] = 1
M[M>n_fit] = 2
# sum(M==0) # 4980
# sum(M>0) # 3000
# sum(M==1) # 2400
# sum(M==2) # 600

D = cbind(D,M)
write.table(D,file=fnameout,quote=FALSE,sep="\t",row.names=FALSE,col.names=FALSE)
