#' @rdname getTS
#' @export
#'


getTimeSeriesLab <- function(labData, idColName, labItemColName, dateColName, valueColName,
                             indexDate = last, gapDate = NULL, completeWindows = TRUE){
  labData <- as.data.table(labData)

  labCols <- unlist(strsplit(deparse(substitute(labItemColName))," [+] "))
  setnames(labData,deparse(substitute(idColName)), "ID")
  setnames(labData,deparse(substitute(dateColName)), "Date")
  setnames(labData,deparse(substitute(valueColName)), "Value")

  labData <- labData[,c("ID", "Date", labCols, "Value"), with = FALSE]
  labData[, "Date"] <- base::as.Date(format(labData[, Date]))
  labData[, "Value"] <- as.numeric(labData[, Value])
  #write a warning here!!!!!!! make sure values are numeric

  #for first/last visit
  if(deparse(substitute(gapDate)) == "NULL"){
    gapDate <- as.numeric((max(labData$Date) - min(labData$Date)))
  }
  if (deparse(substitute(indexDate)) == "first"){
    setorderv(labData, c("ID", "Date"))
    dataWindow <- labData[, gap := Date- head(Date, 1), by = c("ID")][,Window := as.numeric(floor(gap/gapDate) + 1)][,-"gap"]
  }else  if (deparse(substitute(indexDate)) == "last"){
    setorderv(labData, c("ID", "Date"))
    dataWindow <- labData[, gap := Date - tail(Date, 1), by = c("ID")][,Window := as.numeric(ceiling(gap/gapDate) - 1)][,-"gap"]
  }else if (length(indexDate)==1L){
    setorderv(labData, c("ID", "Date"))
    dataWindow <- labData[, gap := Date - base::as.Date(indexDate), by = c("ID")][,Window := ifelse(gap >= 0, floor(gap/gapDate)+1, floor(gap/gapDate))]#[,-"gap"]
  }else{
    setorderv(labData, c("ID", "Date"))
    dataWindow <- merge(labData, indexDate,
                         all.x = TRUE)[,gap := Date - base::as.Date(indexDate)][,Window := ifelse(gap >= 0, floor(gap/gapDate)+1, floor(gap/gapDate))][,-"indexDate"]
  }

  statReview <- dataWindow[,.(Count = .N, Max = max(Value),  Min = min(Value), Mean = mean(Value), Nearest = ifelse(Window < 0 , tail(Value, 1), head(Value,1)), firstRecord = min(Date), lastRecode = max(Date)), by =   c("ID", labCols, "Window")]

  setorderv(statReview, c("ID", labCols))

  if(completeWindows){
    seq <- statReview[, .(Window = seq(min(Window), length.out = max(Window) - min(Window) +1, by = 1L)), by = ID]
    seq <- seq[!(Window==0L),]
    lab <- unique(statReview[,c("ID", labCols), with = FALSE])
    seq <- merge(seq, lab, by = "ID", all.x = TRUE, allow.cartesian = TRUE)
    statReview <- merge(seq, statReview, by = c("ID", labCols,"Window"), all.x = TRUE)
  }
  statReview
}

