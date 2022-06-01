#' @rdname plotWindow
#' @export
#'

plotWindowProportion <- function(labData, idColName, labItemColName, dateColName, indexDate = last, gapDate = c(30, 90, 180, 360), topN = 10){
  labData <- as.data.table(labData)

#  "LAB" <- unlist(strsplit(deparse(substitute(labItemColName))," [+] "))
  setnames(labData,deparse(substitute(idColName)), "ID")
  setnames(labData,deparse(substitute(labItemColName)), "LAB")
  setnames(labData,deparse(substitute(dateColName)), "Date")

  labData <- labData[,c("ID", "Date", "LAB"), with = FALSE]
  labData[, "Date"] <- base::as.Date(format(labData[, Date]))

  if(deparse(substitute(indexDate)) == "all"){
    dataWindow <- unique(labData[, -"Date"])
    pplCount <- length(unique(dataWindow[,ID]))
    sumData <- dataWindow[, .(`Missing Rate` = 1 - (.N/pplCount)) , by = c("LAB")]
    sumData <- sumData[order(`Missing Rate`,decreasing = TRUE)][1:topN,]
    sumData[,"LAB"] <- as.factor(sumData[,LAB])
    missingGraph <- ggplot(sumData, aes(x = LAB, y = `Missing Rate`))+
      geom_bar(position="dodge",stat = "identity")

    return(list(missingRate = sumData, graph = missingGraph))
  }else{
    if(deparse(substitute(indexDate)) == "first"){
      setorderv(labData, c("ID", "Date"))
      dataWindow <- labData[, gap := Date - head(Date, 1), by = c("ID")][, paste0("", gapDate) := lapply(gapDate , function(x) as.numeric(floor(gap/x) + 1))][, -c("gap", "Date")]
    }else  if (deparse(substitute(indexDate)) == "last"){
      setorderv(labData, c("ID", "Date"))
      dataWindow <- labData[, gap := Date - tail(Date, 1), by = c("ID")][, paste0("", gapDate) := lapply(gapDate, function(x) as.numeric(ceiling(gap/x) - 1))][, -c("gap", "Date")]
    }else{
      setorderv(labData, c("ID", "Date"))
      dataWindow <- labData[, gap := Date - base::as.Date(indexDate), by = c("ID")][, paste0("", gapDate) := lapply(gapDate, function(x) ifelse(gap >= 0, floor(gap/x)+1, floor(gap/x)))][, -c("gap", "Date")]
    }
    dataGap <- unique(melt(dataWindow, id.vars = c("ID", "LAB"), variable.name = "Gap"))
    dataGap <- dataGap[, .(missing = length(setdiff(min(value):max(value), unique(value))), sum = length(min(value):max(value))),by = c("ID", "LAB", "Gap")]
    allCom <- dataGap[, do.call(CJ, c(.SD, unique = TRUE)), .SDcols = c("ID", "LAB", "Gap")]
    dataGapSeq <- merge(allCom, dataGap, by = c("ID", "LAB", "Gap"), all.x = TRUE, allow.cartesian = TRUE)

    sumGap <- dataGapSeq[, .(`By ID` = (sum(is.na(missing)) + sum(missing!=0, na.rm = TRUE))/.N , `By Record` = sum(missing, na.rm = TRUE)/sum(sum, na.rm = TRUE)) ,by = c("LAB", "Gap")]
    sumLong <- melt(sumGap, variable.name = "Method", value.name = "Proportion", id.vars = 1:2)
    sumLong <- sumLong

    missingGraph <- ggplot(sumLong, aes(x = Gap, y = Proportion, fill = Method))+ xlab('gap')  + ggtitle("Data Missing Rate") +
    geom_bar(position="dodge",stat = "identity")+ facet_wrap( ~ LAB, scales = "free")

    return(list(missingData = sumLong, graph = missingGraph))
  }
}
