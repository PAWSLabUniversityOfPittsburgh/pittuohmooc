#
# compare models within/across clusters
# 

options(echo=TRUE) # if you want see commands in output file
args <- commandArgs(trailingOnly = TRUE)

folder    <- args[1]
nstudents <- as.integer(args[2])
nproblems <- as.integer(args[3])
nskills   <- as.integer(args[4])
nclusters <- as.integer(args[5])
fout      <- args[6]
M = list()
for(c in 1:nclusters) {
  v = NULL
  for(r in 1:20) {
    fnmodel = paste(folder,"clust",c,"_run",r,"_fit_model.txt",sep="")
    mult = ifelse(length(grep("label 1 -1",readLines(fnmodel)))==1,1,-1)
    d=read.delim(fnmodel,header=FALSE,skip=6+nstudents-1)
#     r = d[ 1:(dim(d)[1]-1)  ,1]
#     r = r + tail(d[,1],1)
    # cat(tail(d[,1],1)*mult,"\n")
    # cat(dim(d)[1],"\n")
    v = c(v, mult*d[,1])
  }
  m = matrix(v,ncol=20,byrow=FALSE)
  M[[c]] = m
}

n = dim(M[[1]])[1]
is_nz15p     = matrix(TRUE,nrow=n,ncol=nclusters) # is non-zero value in >=15 runs
n_nz15p      = matrix(0,nrow=n,ncol=nclusters) # number of non-zero value in >=15 runs
mu           = matrix(0,nrow=n,ncol=nclusters)
se           = matrix(0,nrow=n,ncol=nclusters)

is_nz15p_All = rep(TRUE,n) # is non-zero value in >=15 runs

sdrmna=function(x) { return( sd(x, na.rm=TRUE)) }
for(c in 1:nclusters) {
  m = M[[c]]
  m[m==0]=NA
  is_nz15p[,c]     = rowSums(!is.na(m))>=15
  n_nz15p[,c]      = rowSums(!is.na(m))
  
  mu[,c]           = rowMeans(m, na.rm=TRUE)
  se[,c]           = 1.96*apply(m,1,sdrmna)/sqrt(n_nz15p[,c])
  
  is_nz15p_All = is_nz15p_All & is_nz15p[,c]
}

mu_all = mu[is_nz15p_All,]
se_all = se[is_nz15p_All,]

sink(fout,append = FALSE)
cat("Total parameters: \t",n,"\n")
cat("Total parameters per cluster non-zero in at least 15 runs: \t",colSums(is_nz15p),"\n")
cat("Total parameters in ALL cluster non-zero in at least 15 runs: \t",sum(is_nz15p_All),"\n")
sink()

pwise = NULL
for(c1 in 1:(nclusters-1)) {
  for(c2 in (c1+1):nclusters) {
    is_overlap = ! ( (mu_all[,c1]+se_all[,c1]) < (mu_all[,c2]-se_all[,c2]) | (mu_all[,c1]-se_all[,c1]) > (mu_all[,c2]+se_all[,c2]) )
    sink(fout,append = TRUE)
    cat(c1,"v",c2,"\t",sum(is_overlap),"\t(",mean(is_overlap),")\n",sep="")
    sink()
    pwise = c(pwise, sum(is_nz15p[,c1] & is_nz15p[,c2]))
  }
}

sink(fout,append = TRUE)
cat("Total parameters that are non-zero in at least 15 runs in pairs of clusters: \t",pwise,"\n")
sink()
for(c1 in 1:(nclusters-1)) {
  for(c2 in (c1+1):nclusters) {
    ix = is_nz15p[,c1] & is_nz15p[,c2]
    is_overlap = ! ( (mu[ix,c1]+se[ix,c1]) < (mu[ix,c2]-se[ix,c2]) | (mu[ix,c1]-se[ix,c1]) > (mu[ix,c2]+se[ix,c2]) )
    sink(fout,append = TRUE)
    cat(c1,"v",c2,"\t",sum(is_overlap),"\t(",mean(is_overlap),")\n",sep="")
    sink()
  }
}

sink(fout,append = TRUE)
cat("Total skill intercepts and slopes that are non-zero in at least 15 runs in pairs of clusters\n")
sink()
for(c1 in 1:(nclusters-1)) {
  for(c2 in (c1+1):nclusters) {
    # intercept
    ix = is_nz15p[,c1] & is_nz15p[,c2] & c(rep(TRUE,nproblems*nskills), rep(FALSE,2*nproblems*nskills))
    is_overlap = ! ( (mu[ix,c1]+se[ix,c1]) < (mu[ix,c2]-se[ix,c2]) | (mu[ix,c1]-se[ix,c1]) > (mu[ix,c2]+se[ix,c2]) )
    sink(fout,append = TRUE)
    cat(c1,"v",c2,"\tIntercepts\t",sum(is_overlap),"\t(",mean(is_overlap),")\t",sep="")
    sink()
    
    # learn positive
    ix = is_nz15p[,c1] & is_nz15p[,c2] & c(rep(FALSE,nproblems*nskills), rep(TRUE,nproblems*nskills), rep(FALSE,nproblems*nskills))
    is_overlap = ! ( (mu[ix,c1]+se[ix,c1]) < (mu[ix,c2]-se[ix,c2]) | (mu[ix,c1]-se[ix,c1]) > (mu[ix,c2]+se[ix,c2]) )
    sink(fout,append = TRUE)
    cat("SlopeRight\t",sum(is_overlap),"\t(",mean(is_overlap),")\t",sep="")
    sink()
    
    # learn negative
    ix = is_nz15p[,c1] & is_nz15p[,c2] & c(rep(FALSE,2*nproblems*nskills), rep(TRUE,nproblems*nskills))
    is_overlap = ! ( (mu[ix,c1]+se[ix,c1]) < (mu[ix,c2]-se[ix,c2]) | (mu[ix,c1]-se[ix,c1]) > (mu[ix,c2]+se[ix,c2]) )
    sink(fout,append = TRUE)
    cat("SlopeWrong\t",sum(is_overlap),"\t(",mean(is_overlap),")\n",sep="")
    sink()
  }
}
