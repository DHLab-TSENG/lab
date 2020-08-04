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
#
# wide <- labDataLongToWide(stat,
#                   idColName = ID,
#                   labItemColName = ITEMID,
#                   windowColName = Window,
#                   valueColName = Min)
#
# labDataLongToWide(sr,
#                   idColName = ID,
#                   labItemColName = ITEMID,
#                   windowColName = Window,
#                   valueColName = Min)

# timeSeriesData <- getTimeSeriesLab(labData = mimic_lab_sample,
#                                    idColName = SUBJECT_ID,
#                                    labItemColName = ITEMID,
#                                    dateColName = CHARTTIME,
#                                    valueColName = VALUENUM,
#                                    indexDate = first,
#                                    gapDate = 360,
#                                    completeWindows = T)
#
# imputedData <- imputeTimeSeriesLab(labData = timeSeriesData,
#                 idColName = ID,
#                 labItemColName = ITEMID,
#                 windowColName = Window,
#                 valueColName = Max & Min,
#                 impMethod = mean)
#
# imputedData[ITEMID == "50804"]$ITEMSQ <- "B"

