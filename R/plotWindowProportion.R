plotWindowProportion <- function(labData, idColName, labItemColName, dateColName, indexDate = last, gapDate = c(30, 90, 180, 360)){
  labData <- as.data.table(labData)

#  "LAB" <- unlist(strsplit(deparse(substitute(labItemColName))," [+] "))
  setnames(labData,deparse(substitute(idColName)), "ID")
  setnames(labData,deparse(substitute(labItemColName)), "LAB")
  setnames(labData,deparse(substitute(dateColName)), "Date")

  labData <- labData[,c("ID", "Date", "LAB"), with = FALSE]
  labData[, "Date"] <- base::as.Date(format(labData[, Date]))

  if(deparse(substitute(indexDate)) == "all"){
    dataWindow <- unique(labData[, -"Date"][, missing := 0L])
    dataGapSeq <- merge(CJ(ID = dataWindow[,ID], LAB = dataWindow[,LAB], unique = TRUE), dataWindow, by = c("ID", "LAB"), all.x = TRUE, allow.cartesian = TRUE)
    sumGap <- dataGapSeq[, .(`Missing Rate` = sum((is.na(missing)))/.N) , by = c("LAB")]
    sumGap <- sumGap[order(`Missing Rate`,decreasing = TRUE)]
    sumGap[,"LAB"] <- as.factor(sumGap[,LAB])
    missingGraph <- ggplot(sumGap, aes(x = LAB, y = `Missing Rate`))+
      geom_bar(position="dodge",stat = "identity")

    return(list(missingData = sumGap, graph = missingGraph))
  }else{
    if(deparse(substitute(indexDate)) == "first"){
      setorderv(labData, c("ID", "Date"))
      dataWindow <- labData[, gap := Date - head(Date, 1), by = c("ID")][, paste0("gap_", gapDate) := lapply(gapDate , function(x) as.numeric(floor(gap/x) + 1))][, -c("gap", "Date")]
    }else  if (deparse(substitute(indexDate)) == "last"){
      setorderv(labData, c("ID", "Date"))
      dataWindow <- labData[, gap := Date - tail(Date, 1), by = c("ID")][, paste0("gap_", gapDate) := lapply(gapDate, function(x) as.numeric(ceiling(gap/x) - 1))][, -c("gap", "Date")]
    }else{
      setorderv(labData, c("ID", "Date"))
      dataWindow <- labData[, gap := Date - base::as.Date(indexDate), by = c("ID")][, paste0("gap_", gapDate) := lapply(gapDate, function(x) ifelse(gap >= 0, floor(gap/x)+1, floor(gap/x)))][, -c("gap", "Date")]
    }
    dataGap <- unique(melt(dataWindow, id.vars = c("ID", "LAB"), variable.name = "Gap"))
    dataGap <- dataGap[, .(missing = length(setdiff(min(value):max(value), unique(value))), sum = length(min(value):max(value))),by = c("ID", "LAB", "Gap")]
    allCom <- dataGap[, do.call(CJ, c(.SD, unique = TRUE)), .SDcols = c("ID", "LAB", "Gap")]
    dataGapSeq <- merge(allCom, dataGap, by = c("ID", "LAB", "Gap"), all.x = TRUE, allow.cartesian = TRUE)

    sumGap <- dataGapSeq[, .(`Missing ID` = (sum(is.na(missing)) + sum(missing!=0, na.rm = TRUE))/.N , `Missing Record` = sum(missing, na.rm = TRUE)/sum(sum, na.rm = TRUE)) ,by = c("LAB", "Gap")]
    sumLong <- melt(sumGap, variable.name = "Method", id.vars = 1:2)

    missingGraph <- ggplot(sumLong, aes(x = Gap, y = value, fill = Method))+
    geom_bar(position="dodge",stat = "identity")+ facet_wrap( ~ LAB, scales = "free")

    return(list(missingData = sumLong, graph = missingGraph))
  }
}
#
# part <- plotWindowProportion(labData = labMIMIC,
#                              idColName = SUBJECT_ID,
#                              labItemColName = ITEMID,
#                              dateColName = CHARTTIME,
#                              indexDate = all,
#                              gapDate = c(30, 90, 180, 360))
