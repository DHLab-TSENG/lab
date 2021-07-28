#' @rdname plotAb
#' @export
#'

plotAbnormalRate <- function(labData, idColName, labItemColName, abnormalMarkColName, topN = 10){
  labData <- as.data.table(labData)

  setnames(labData,deparse(substitute(idColName)), "ID")
  labCols <- unlist(strsplit(deparse(substitute(labItemColName))," [+] "))
  setnames(labData,deparse(substitute(dateColName)), "Date")
  setnames(labData,deparse(substitute(abnormalMarkColName)), "abnormalMark")

  labData <- labData[,c("ID", "Date", labCols, "abnormalMark"), with = FALSE]
  labData[, "Date"] <- base::as.Date(format(labData[, Date]))

  dataWindow <- unique(labData[, -"Date"])
  pplCount <- length(unique(dataWindow[,ID]))

  ###
  #SELECT DATA WITH MOST ABNORMAL DATA
  ###

  dataWindow[, "abnormalMark" := ifelse(is.na(abnormalMark), "Normal", abnormalMark)]
  sumData <- dataWindow[, .(ABRate = 1 - (.N/pplCount)) , by = c("LAB", "abnormalMark")]
  sumData <- sumData[order(`Abnormal Rate`,decreasing = TRUE)][1:topN,]
  sumData[,"LAB"] <- as.factor(sumData[,LAB])
  missingGraph <- ggplot(sumData, aes(x = LAB, y = `Missing Rate`))+
  geom_bar(position="dodge",stat = "identity")
    return(list(missingRate = sumData, graph = missingGraph))


  dataGap <- unique(melt(dataWindow, id.vars = c("ID", "LAB"), variable.name = "Gap"))
  dataGap <- dataGap[, .(missing = length(setdiff(min(value):max(value), unique(value))), sum = length(min(value):max(value))),by = c("ID", "LAB", "Gap")]
  allCom <- dataGap[, do.call(CJ, c(.SD, unique = TRUE)), .SDcols = c("ID", "LAB", "Gap")]
  dataGapSeq <- merge(allCom, dataGap, by = c("ID", "LAB", "Gap"), all.x = TRUE, allow.cartesian = TRUE)

  sumGap <- dataGapSeq[, .(`Missing ID` = (sum(is.na(missing)) + sum(missing!=0, na.rm = TRUE))/.N , `Missing Record` = sum(missing, na.rm = TRUE)/sum(sum, na.rm = TRUE)) ,by = c("LAB", "Gap")]
  sumLong <- melt(sumGap, variable.name = "Method", id.vars = 1:2)
  sumLong <- sumLong

  missingGraph <- ggplot(sumLong, aes(x = Gap, y = value, fill = Method)) +
  geom_bar(position="dodge",stat = "identity")+ facet_wrap( ~ LAB, scales = "free")

  return(list(missingData = sumLong, graph = missingGraph))
}
