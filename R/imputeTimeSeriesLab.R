#' @rdname impTS
#' @export
#'

imputeTimeSeriesLab <- function(labData, idColName, labItemColName, windowColName, valueColName, impMethod){
  labData <- as.data.table(labData)

  labCols <- unlist(strsplit(deparse(substitute(labItemColName))," [+] "))
  valueCols <- unlist(strsplit(deparse(substitute(valueColName))," [&] "))
  setnames(labData,deparse(substitute(idColName)), "ID")
  setnames(labData,deparse(substitute(windowColName)), "Window")
  labData <- labData[,c("ID", "Window", valueCols, labCols), with = FALSE]
  setorderv(labData, c("ID", labCols, "Window", valueCols))
  setcolorder(labData, c("ID", labCols, "Window", valueCols))
  valueStart <- 2 + length(labCols)
  valueEnd <- valueStart + length(valueCols)

  labData[,c(valueStart:valueEnd) := lapply(.SD, function(x) as.numeric(x)), .SDcols = valueStart:valueEnd]

  seq <- labData[, .(Window = seq(min(Window), length.out = max(Window) - min(Window) +1, by = 1L)), by = ID]
  seq <- seq[!(Window == 0L)]
  lab <- unique(labData[,c("ID", labCols), with = FALSE])
  seq <- merge(seq, lab, by = c("ID"), all.x = TRUE, allow.cartesian = TRUE)
  resultAll <- merge(seq, labData, by = c("ID", labCols,"Window"), all.x = TRUE)

  if(tolower(deparse(substitute(impMethod))) == "interpolation"){
    resultAll[, c(valueStart:valueEnd) := lapply(.SD, function(x) ifelse((rleid(x) == 1 | rleid(x) == max(rleid(x))) & max(rleid(x)) > 1 & is.na(x) == T, mean(x, na.rm = TRUE), x)), by = c("ID", labCols),  .SDcols = valueStart:valueEnd]
    resultAll <-resultAll[, c(valueStart:valueEnd) := lapply(.SD, function(x) as.numeric(na.approx(x))), by = c("ID", labCols), .SDcols = valueStart:valueEnd]
  }else if(tolower(deparse(substitute(impMethod))) == "mean"){
    resultAll[,  c(valueStart:valueEnd) := lapply(.SD, function(x) ifelse(is.na(x), mean(x, na.rm = TRUE), x)), by = c("ID", labCols), .SDcols = valueStart:valueEnd]
  }else if(tolower(deparse(substitute(impMethod))) == "nocb"){
    resultAll[,  c(valueStart:valueEnd) := lapply(.SD, function(x) ifelse(is.na(x), na.locf(x, na.rm = FALSE, fromLast = TRUE), x)), by = c("ID", labCols), .SDcols = valueStart:valueEnd]
  }
}
