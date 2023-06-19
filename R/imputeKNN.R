#' @rdname impKNN
#' @export
#'

imputeKNN <- function(labData, idColName, k){

  labData <- as.data.table(labData)

  idCols <- unlist(strsplit(deparse(substitute(idColName))," [+] "))

  setcolorder(labData, idCols)

  valueStart <-  1 + length(idCols)
  valueEnd <- length(labData)

  trainID <- which(complete.cases(labData))
  if(k > length(trainID)){
    stop("Total completed records are less than value k.")
  }
  testID <- which(!complete.cases(labData) & rowSums(is.na(labData))!=ncol(labData))

  #remain NA to the end, then impute zero
  zeroID <- which(rowSums(is.na(labData))==ncol(labData))

  for(i in testID){
    trainID <- countImpute(labData, i, valueStart, valueEnd, k, trainID)
  }

  #imputed all zero records

  labData[!is.na(labData)] <- 0

  result <- labData
  return(result)
}
