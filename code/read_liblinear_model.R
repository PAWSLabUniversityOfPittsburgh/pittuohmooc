read_liblinear_model <- function(filename) {
  raw <- readLines(filename)
  #
  # read header
  #
  n_outcomes = as.integer( strsplit(raw[2]," ")[[1]][[2]] )
  flip_signs = as.integer( strsplit(raw[3]," ")[[1]][[2]] )==-1 # if "label -1 1" flip signs of the prameters, LIBLINEAR "feature" :)
  n_features = as.integer( strsplit(raw[4]," ")[[1]][[2]] )
  has_bias = as.integer( strsplit(raw[5]," ")[[1]][[2]] )==1
  w = as.numeric( raw[7:length(raw)] )
  
  if(length(w)!=(n_features+has_bias)) {
    print(paste("Warning, actual number of features is ",length(w),", while declared is ",n_features,".",sep=""))
  }
  if(flip_signs) {
    w = -w
  }
  return ( w )
}
