#' @rdname abMark
#' @export
#'

getAbnormalMark <- function (labData, labItemColName, valueColName, genderColName, referenceTable){
  labData <- as.data.table(labData)

  labCols <- unlist(strsplit(deparse(substitute(labItemColName))," [+] "))
  setnames(labData,deparse(substitute(valueColName)), "Value")
  setnames(labData,deparse(substitute(genderColName)), "Sex")
  referenceTable <- as.data.table(referenceTable)

  colNameList <- colnames(labData)
  labData$Value <- as.numeric(labData$Value)
  # Write a warning msg to notify that NAs introudced because of non-numeric results
  labData <- merge(labData, referenceTable, by= labCols, all.x=TRUE)
  labData$ABMark <- NA

  labData[, ABMark := ifelse(Sex == "M",
                                 ifelse (grepl("\\(|=",labData$LowerBound_Male),
                                         ifelse(Value < as.numeric(gsub("[^0-9.,]","",labData$LowerBound_Male)), "L", ABMark),
                                         ifelse(Value <= as.numeric(gsub("[^0-9.,]","",labData$LowerBound_Male)) , "L", ABMark)),
                                 ABMark)]
  labData[, ABMark := ifelse(Sex == "M",
                                 ifelse (grepl("\\)|=", labData$UpperBound_Male),
                                         ifelse(Value > as.numeric(gsub("[^0-9.,]","",labData$UpperBound_Male)), "H", ABMark),
                                         ifelse(Value >= as.numeric(gsub("[^0-9.,]","",labData$UpperBound_Male)) , "H", ABMark)),
                                 ABMark)]
  labData[, ABMark := ifelse(Sex == "F",
                                 ifelse (grepl("\\(|=",labData$LowerBound_Female),
                                         ifelse(Value < as.numeric(gsub("[^0-9.,]","",labData$LowerBound_Female)), "L", ABMark),
                                         ifelse(Value <= as.numeric(gsub("[^0-9.,]","",labData$LowerBound_Female)) , "L", ABMark)),
                                 ABMark)]
  labData[, ABMark := ifelse(Sex == "F",
                                 ifelse (grepl("\\)|=", labData$UpperBound_Female),
                                         ifelse(Value > as.numeric(gsub("[^0-9.,]","",labData$UpperBound_Female)), "H", ABMark),
                                         ifelse(Value >= as.numeric(gsub("[^0-9.,]","",labData$UpperBound_Female)) , "H", ABMark)),
                                 ABMark)]


  labData[, c(colNameList,"ABMark"), with = FALSE]
}




# default is without "=" mark
