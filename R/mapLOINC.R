#' @rdname mapLOINC
#' @export

mapLOINC <- function(labData, labItemColName, mappingTable = NULL){
  labData <- as.data.table(labData)
  mappingTable <- as.data.table(mappingTable)
  labCols <- unlist(strsplit(deparse(substitute(labItemColName))," [+] "))

  mappedData <- merge(labData, mappingTable, by = labCols,
                       all.x = TRUE, allow.cartesian=TRUE)
  mappedData
}
