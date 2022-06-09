#' @rdname plotTS
#' @export

plotTimeSeriesLab <- function(labData, idColName, labItemColName, timeMarkColName,
                              valueColName, timeStart = NULL, timeEnd  = NULL, abnormalMarkColName = NULL){

  labData <- as.data.table(labData)
  setnames(labData,deparse(substitute(idColName)), "ID")
  labCols <- unlist(strsplit(deparse(substitute(labItemColName))," [+] "))

  setnames(labData,deparse(substitute(timeMarkColName)), "TimeMark")
  setnames(labData,deparse(substitute(valueColName)), "Value")
  if(deparse(substitute(abnormalMarkColName)) != "NULL"){
    setnames(labData,deparse(substitute(abnormalMarkColName)), "abnormalMark")
    labData <- labData[,c("ID", labCols, "TimeMark", "Value", "abnormalMark"), with = FALSE]
    labData[, abnormalMark := ifelse(is.na(abnormalMark), "Normal", abnormalMark)]
  }else{
    labData <- labData[,c("ID", labCols, "TimeMark", "Value"), with = FALSE]
  }
  if(!is.null(timeStart)){
    labData <- labData[TimeMark >= timeStart]
  }
  if(!is.null(timeEnd)){
    labData <- labData[TimeMark <= timeEnd]
  }

  labData$ID <- as.factor(labData$ID)
  labData$Value <- as.numeric(labData$Value)

  if(deparse(substitute(abnormalMarkColName)) != "NULL"){
    plot <- ggplot(labData, aes(x = TimeMark , y = Value, group = ID , col = ID)) +
      geom_line(size = 1) + geom_point(aes(shape = abnormalMark), size = 3) +
      scale_shape_manual(values=c(17, 25, 16)) + scale_y_continuous() +
      labs(x="Window",y="Laboratory Result")+
      facet_wrap( ~  deparse(substitute(labItemColName)), scales = "free") #+ geom_line(group =2)
  }else{
    plot <- ggplot(labData, aes(x = TimeMark , y = Value, group = ID , col = ID)) +
      geom_line(size = 1) + geom_point() + scale_y_continuous() +
      labs(x="Window",y="Results")+
      facet_wrap(as.formula(paste("~", deparse(substitute(labItemColName)))), scales = "free") #+ geom_line(group =2)
  }
  return(plot)
}
