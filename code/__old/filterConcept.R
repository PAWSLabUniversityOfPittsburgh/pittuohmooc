rm(list = ls());

suppressWarnings(suppressMessages(library(MASS)))
suppressWarnings(suppressMessages(library(caret)))
suppressWarnings(suppressMessages(library(randomForest)))
suppressWarnings(suppressMessages(library(foreach)))
suppressWarnings(suppressMessages(library(iterators)))
suppressWarnings(suppressMessages(library(doParallel)))
suppressWarnings(suppressMessages(library(mixlm)))
suppressWarnings(suppressMessages(library(parallel)))
suppressWarnings(suppressMessages(library(plyr))) #for rbind.fill

library(MASS)
library(caret)
library(mixlm)
library(doParallel)
library(randomForest)
library(foreach)
library(plyr)

runCF<-function(i){
     #find reliable concepts for each test separately, then append them to the concept vector
    output = vector('character') #define an empty vector for the important concepts
    output<-append(output,sub("X","",colnames(X)[i]))

    #bypass test with no variation in outcome
    if (length(unique(X[,i])) > 1)
    {
        if (method == 'lm')
        {
            fit <- NULL
            step<- NULL
            lmdf<-subset(X,select=c(i,(last.test.index+1):ncol(X))) #X[,i]: i-th test as response variable, X[,last.test.index+1:ncol(X)]: concepts as perdictors
            names(lmdf)[1]<-paste("y")
            fit = lm(y ~ ., data = lmdf)
            options( warn = -1 )
            tryCatch(
            {
               #n <- names(X)
               #vars = paste(n[(last.test.index+1):ncol(X)], collapse = " + ")
               #fit = lm(formula=as.formula(paste(colnames(X)[i],vars,sep="~")),data=X) #X[,i]: i-th test as     response variable, X[,last.test.index+1:ncol(X)]: concepts as perdictors
               sink("/dev/null")
               step<- backward(fit, alpha = 0.05, full = FALSE)
               sink()
               output <- append(output,names(step$model[-1]))
            },error = function(e){
               #print(file.path(dirname(dir),error_file_name)," 1 \n") #MVY
               #sink(file=file.path(dirname(dir),error_file_name),append=T)
               #cat(paste(dataset,method,file,as.character(e),sep="   "))
               sink()
            }, finally ={ #when number of features are more than observations, usually, there are NA's in coefficients and backward regression fails, in those cases we just add the coefficients that are not NA into the output as influential concepts.
                if (length(output)==1)
                {
                    coeffs<-names(coef(fit)[-1])
                    nacoeffs<-is.na(coef(fit))
                    validcoeffs<-vector()
                    for (k in 1:length(coeffs))
                    {
                        if (nacoeffs[k]==F)
                        validcoeffs<-append(validcoeffs,coeffs[k])  
                    }
                    output <- append(output,validcoeffs) 
                }
            }
            )#end tryCatch
            options( warn = 0 )
        }
        if (method == 'rfe'){
            # define the control using a random forest selection function
            set.seed(1)
            control <- rfeControl(functions=rfFuncs, method="cv", number=5)
            results <- NULL
            # run the RFE algorithm
            options( warn = -1 )
            
            tryCatch(
            {
                results <- rfe(x=as.data.frame(X[,(last.test.index+1):ncol(X)]), y=X[,i],
                sizes=c(1:(ncol(X)-last.test.index)), rfeControl=control);
            },error = function(e){
                #print(file.path(dirname(dir),error_file_name)," 2 \n") #MVY
                #sink(file=file.path(dirname(dir),error_file_name),append=T)
                #cat(paste(dataset,method,file,as.character(e),sep="   "))
                #sink()
            })#end tryCatch
            options( warn = 0 )
            # list the chosen features
            output<-append(output,predictors(results))
        }
        output <- unique(output) #remove duplicate concepts
        #if length of reduced concepts is greater than rank of matrix (r), then sample r elements from those concepts
        if ((length(output)-1)>rank) #-1 is to ignore the first value that is the test name
        {
            #print(file.path(dirname(dir),error_file_name)," 3 \n") #MVY
            #sink(file=file.path(dirname(dir),logfname),append=T)
            #cat(paste(filepath,"test",sub("X","",colnames(X)[i]),"exceed rank",sep='  '))
            #sink()
            test.name<-output[1]
            sampled<-sample(output[2:length(output)], rank, replace=F)
            output = vector('character') #define an empty vector for the important concepts
            output<- append(output,test.name)
            output<-append(output,sampled)
        }
        if ((length(output)-1) < 1) #-1 is to ignore the first value that is the test name
        {
        	#print(file.path(dirname(dir),logfname)," 4 \n") #MVY
            #sink(file=file.path(dirname(dir),logfname),append=T)
            #cat(paste(filepath,"test",sub("X","",colnames(X)[i]),"zero length",sep='  '))
            sink()
        }
    }
    else{
      	#cat(file.path(dirname(dir),logfname)," 5 \n") #MVY
        #sink(file=file.path(dirname(dir),logfname),append=T)
        #cat(paste(filepath,"test",sub("X","",colnames(X)[i]),"always ",X[1,i],sep='  '))
        sink()
    }
    return (output)
}

#!/usr/bin/env Rscript

## parse the arguments
# --args1: dir, the directory of the input file
# --args2: file, the name of the input
# --args3: method, the method for reducing the number of features (rfe,lm)
# --args4: the column number of the last test in the input file

#parsing the argument
args <- commandArgs(trailingOnly = T)
dir = args[1]
file = args[2]
method = args[3]
dataset = args[4]
logfname = args[5]
error_file_name = args[6]

#dir = "/Users/roya/Desktop/ProgMOOC.test/data/fc/s2014-ohpe_problems"
#file = "viikko1-Viikko1_001.Nimi_A_AvgT_AvgCs_FCT_input.txt"
#method = "lm"
#logfname="log.txt"
#i=1
#dataset="s2014-ohpe"
#print("************arguments******************")
#print(dir)
#print(file)
#print(method)
#print("******************************")


filepath <- file.path(dir, file);
#read the input data file (has tetrad format)
X<- read.table(header=T,filepath)

#counting number of tests
last.test.index = length(grep("[0-9]\\.[0-9]+", colnames(X)))

#rank of matrix
library(Matrix)
o<-rankMatrix(as.matrix(X),method =  "qr.R", warn.t = F)
rank = o[1]
#print(paste(nrow(X),rank,sep=' '))

myfile <- file.path(dir, paste0(paste(sub('_input.txt','',file),method,sep='_'),'.txt'))

#parallel processing
cl <- makeCluster(detectCores(), type='PSOCK')
registerDoParallel(cl)

#we need to use rbind.fill from package plyr as output has different length for different test items. NA is used for filling the columns that do not have values
final.output<-NULL
#final.output = foreach::foreach(i=1:last.test.index, .errorhandling = 'stop',.combine="rbind.fill",.packages=c('plyr','mixlm','randomForest','MASS','caret')) %dopar% {
#    data.frame(t(data.frame(runCF(i))))
#}

final.output = foreach::foreach(i=1:last.test.index, .errorhandling = 'stop',.combine="rbind.fill",.packages=c('plyr','mixlm','randomForest','MASS','caret')) %dopar%
    data.frame(t(data.frame(runCF(i))))
#for ( i in 1: last.test.index){
# final.output = plyr::rbind.fill(final.output,t(data.frame(runCF(i))))
#}

stopCluster(cl)

#write the influential concepts into the file
write.table(x = final.output, file = myfile, row.names = F,sep='\t',col.names=F,quote=F);

