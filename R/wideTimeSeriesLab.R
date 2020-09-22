#' @rdname wideTS
#' @export

wideTimeSeriesLab <- function(labData, idColName, labItemColName, windowColName, valueColName){

  labData <- as.data.table(labData)

  setnames(labData,deparse(substitute(idColName)), "ID")
  setnames(labData,deparse(substitute(windowColName)), "Window")
  setnames(labData, deparse(substitute(valueColName)), "Value")

  resultAll <- dcast(labData, as.formula(paste("ID + Window ~ ", deparse(substitute(labItemColName)))), value.var = "Value")
  resultAll
}
