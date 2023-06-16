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

  result <- labData
  return(result)
}

countImpute <- function (labData, ttID, vS, vE, k, trID){
  distance <- as.matrix(dist(labData[c(ttID,trID)]))[-1,1]
  distanceRank <- order(distance)
  #If distance ranking the same, randomly choose the neighbors (in this case, choose the first records)
  neighbors <- trID[distanceRank[c(1:k)]]
  trRw <<- labData[neighbors, lapply(.SD, function(x) mean(x)), .SDcols = c(vS:vE)]
  newRow <- as.list(fcoalesce(as.matrix(labData[ttID])[1,vS:vE], as.matrix(trRw)[1,]))
  labData[ttID, c(vS:vE) := newRow]
  trID <- append(trID, ttID)
  return(trID)
}

imputed <- imputeKNN(completed, ID+Window, 2)
