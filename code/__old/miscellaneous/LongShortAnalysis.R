rm(list = ls());
getType <-function(x){
  label = grepl("^[[:upper:]]+$", x)
  if (label == FALSE){  
    return ("S")
  }else{
    return ("L")
  }
}
################
main.directory ='/Users/roya/Desktop/ProgMOOC/code/java/source_codes/progMooc/resource'
input = 'BehavPatternExercise_user-based.txt';
file.name <- file.path(main.directory, input);
userbased<-read.csv(file.name,header = F,stringsAsFactors = T,sep=",");

input = 'BehavPatternExercise_problem-based.txt';
file.name <- file.path(main.directory, input);
problembased<-read.csv(file.name,header = F,stringsAsFactors = T,sep=",");

sink(file.path(main.directory,"long-short-grouping.txt"), append = FALSE)
for (i in 1:nrow (userbased) ){
  u = as.character(userbased[i,12])
  p = as.character(problembased[i,12])
  u_split=strsplit(u, "")[[1]]
  p_split=strsplit(p, "")[[1]]
  for (j in 2:(length(u_split)-1)){
    cat((paste(getType(u_split[j]),getType(p_split[j]),sep=" ")),"\n")
  }
}
sink()
closeAllConnections()

main.directory ='/Users/roya/Desktop/ProgMOOC/code/java/source_codes/progMooc/resource'
input = 'long-short-grouping.txt';
file.name <- file.path(main.directory, input);
data<-read.csv(file.name,header = F,stringsAsFactors = T,sep=" ");
colnames(data)[1]="user"
colnames(data)[2]="problem"
table(data$user,data$problem)
#      L      S
# L 426155  58354
# S  60088 425382
#(426155+425382)/( 426155 + 58354+ 60088+ 425382)≈0.88