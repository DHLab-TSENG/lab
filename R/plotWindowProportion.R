#' @rdname plotWindow
#' @export
#'

plotWindowProportion <- function(labData, idColName, labItemColName,
                                  dateColName, indexDate = last, gapDate = c(30, 90, 180, 360), topN = 10,
                                  studyPeriodStartDays,studyPeriodEndDays){
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
      dataWindow <- labData[, gap := Date - head(Date, 1), by = c("ID")][, paste0("", gapDate) := lapply(gapDate , function(x) as.numeric(floor(gap/x) + 1))][, -c( "Date")]
    }else  if (deparse(substitute(indexDate)) == "last"){
      setorderv(labData, c("ID", "Date"))
      dataWindow <- labData[, gap := Date - tail(Date, 1), by = c("ID")][, paste0("", gapDate) := lapply(gapDate, function(x) as.numeric(ceiling(gap/x) - 1))][, -c( "Date")]
    }else if (length(indexDate)==1L){
      setorderv(labData, c("ID", "Date"))
      dataWindow <- labData[, gap := Date - base::as.Date(indexDate), by = c("ID")][, paste0("", gapDate) := lapply(gapDate, function(x) ifelse(gap >= 0, floor(gap/x)+1, floor(gap/x)))][, -c( "Date")]
    }else{
      setorderv(labData, c("ID", "Date"))
      dataWindow <- merge(labData, indexDate,
                          all.x = TRUE)[,gap := Date - base::as.Date(indexDate), by = c("ID")][, paste0("", gapDate) := lapply(gapDate, function(x) ifelse(gap >= 0, floor(gap/x)+1, floor(gap/x)))][, -c("Date")]
    }

    dataWindow<-dataWindow[gap>=studyPeriodStartDays&gap<=studyPeriodEndDays]
    totalWindow<-(studyPeriodEndDays-studyPeriodStartDays)/gapDate
    totalWindowDT<-data.table(NWindow=totalWindow,Gap=gapDate)

    dataGap <- unique(melt(dataWindow[,-c("gap")], id.vars = c("ID", "LAB"), variable.name = "Gap"))
    totalWindowDT$Gap<-factor(totalWindowDT$Gap,levels = levels(dataGap$Gap))

    dataGap <- dataGap[, .(withValue= sum(!is.na(value))),
                       by = c("ID", "LAB", "Gap")]
    dataGap<-dataGap[totalWindowDT,on="Gap",]

    totalIndividuals<-length(unique(dataGap$ID))
    sumGap <- dataGap[,.(`By Individual` =(totalIndividuals-.N)/totalIndividuals,
                         `By Window` =(sum(NWindow)-sum(withValue))/sum(NWindow),
                         nIndividuals=.N,
                         total=NWindow*totalIndividuals,
                         withValuen=sum(withValue)),
                      by = c("LAB", "Gap")]

    sumLong <- melt(sumGap[,-c("nIndividuals","total","withValuen")],
                    variable.name = "Method", value.name = "Proportion", id.vars = 1:2)

    missingGraph <- ggplot(sumLong, aes(x = Gap, y = Proportion, fill = Method))+
      xlab('Gap')  + ylab('Missing Rate') +
      geom_bar(position="dodge",stat = "identity")+
      facet_wrap( ~ LAB, scales = "free")

    return(list(missingData = sumLong, graph = missingGraph))
  }
}
