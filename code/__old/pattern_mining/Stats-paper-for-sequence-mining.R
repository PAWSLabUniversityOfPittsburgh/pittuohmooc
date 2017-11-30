
rm(list = ls());

# reading most frequent patterns
input = 'BehavPatternExercise.txt';
file.name <- file.path('/Users/roya/Desktop/ProgMOOC/code/java/source_codes/progMooc/resource', input);
df<-read.csv(file.name,header = F,stringsAsFactors = T,sep=",");
df$seq = NA
df$length = NA
for (i in 1:nrow(df)){
  df$seq[i]=as.character(gsub("_","",df$V12[i]))
  df$length[i]=nchar(df$seq[i], type = "chars")               
}
nrow(subset(df)) #sequences
length(unique(df$V2)) #users
length(unique(df$V3))  #exercise


#stat length sequence
summary(df$length)

#filtering more than one
d = subset(df,length>1)
nrow(d)
nrow(subset(d,length>2))
nrow(subset(d,length>3))
nrow(subset(d,length>4))
