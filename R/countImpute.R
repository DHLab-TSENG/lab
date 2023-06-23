countImpute <- function (labData, ttID, vS, vE, k, trID){
  distance <- as.matrix(dist(labData[c(ttID,trID)]))[-1,1]
  distanceRank <- order(distance)
  #If distance ranking the same, randomly choose the neighbors (in this case, choose the first records)
  neighbors <- trID[distanceRank[c(1:k)]]
  trRw <- labData[neighbors, lapply(.SD, function(x) mean(x)), .SDcols = c(vS:vE)]
  newRow <- as.list(fcoalesce(as.matrix(labData[ttID])[1,vS:vE], as.matrix(trRw)[1,]))
  labData[ttID, c(vS:vE) := newRow]
  trID <- append(trID, ttID)
  return(trID)
}
