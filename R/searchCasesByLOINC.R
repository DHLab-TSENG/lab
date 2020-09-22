#' @rdname searchCases
#' @export
#'

searchCasesByLOINC <- function(labData, idColName = NULL, loincColName = NULL, dateColName = NULL, condition, isSummary = FALSE){
  labData <- as.data.table(labData)
  setnames(labData,deparse(substitute(loincColName)), "LOINC")

  labWithLOINC <-  merge(labData, tagLOINC, by = "LOINC",
                           all.x = TRUE, allow.cartesian=TRUE)
  input_list <- unlist(strsplit(condition, "&"))

  if (summary == FALSE){
    Case <- labWithLOINC[rowSums(sapply(input_list, grepl, labWithLOINC$tag, ignore.case = TRUE)) == length(input_list)]

#    Case <- unique(labWithLOINC[grepl(tolower(condition), tolower(labWithLOINC$tag))])#[order(ID, Date)] # EVERY ICD only ONCE at ONE DAY
  }else{
    Case <- labWithLOINC[rowSums(sapply(input_list, grepl, labWithLOINC$tag, ignore.case = TRUE)) == length(input_list)]
#    Case <- unique(labWithLOINC[grepl(tolower(condition), tolower(labWithLOINC$tag))])#[order(ID, Date)] # EVERY ICD only ONCE at ONE DAY
    setnames(Case,deparse(substitute(idColName)), "ID")
    setnames(Case,deparse(substitute(dateColName)), "Date")
    Case <- Case[,.(Count = .N, firstRecord = min(Date), lastRecode = max(Date)), by =   c("ID", "LOINC")]
  }
  Case
}
