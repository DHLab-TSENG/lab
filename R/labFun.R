
#' Common arguments of laboratory processing functions
#' @name commonLabArgs
#' @import data.table
#' @import ggplot2
#' @import zoo
#' @param labData a file or dataframe of laboratory test data with at least 4 columns about patient ID, lab item, test value and test date, respectively.
#' @param idColName the column name that records patient ID in labData.
#' @param labItemColName the column name that records lab item in labData. If lab code is combined by multiple columns, then just simply add \code{+} operator between column names, e.g., \code{A + B}.
#' @param dateColName the column name that records test date in labData. It should be in \code{"YYYYMMDD"/"YYYY-MM-DD"} format.
#' @param indexDate the specific date that used for cutting time window. It can be first record (\code{"first"}), last record (\code{"last"}), or any date of interest with \code{"YYYYMMDD"/"YYYY-MM-DD"} format.
#' @param gapDate desired period (in days) of each window interval. If \code{NULL}, it will be seen as only one single time window.
#' @param completeWindows logical. If \code{TRUE}, time window series will be complete in order. If \code{TRUE}, a window without lab test will be skipped. Default is \code{TRUE}.
NULL

#' Mapping local lab codes with LOINC
#'
#' \code{mapLOINC} is used for merging two tables together. One is lab data with local codes, and the other one is mapping table of local lab codes and LOINC.
#'
#' Since the lab item may be coded in local scheme, users can map it with LOINC by providing LOINC mapping table. This step is optional but recommended. After mapped, user can select desired laboratory tests by using function \code{searchCases}.
#'
#'
#' @name mapLOINC
#' @inherit commonLabArgs
#' @param mappingTable a data table with at least two columns: local lab item code and LOINC code. The local column name should be identical as labItemColName in labData.
#' @return A \code{data.table} merged two tables.
#' @examples
#'mapLOINC(labData = labSample,
#'         labItemColName = ITEMID,
#'         mappingTable = mapSample)
NULL

#' Search cases
#'
#' \code{searchCasesByLOINC}
#'
#'
#' LOINC provides a column to record related names for lab tests. This function can be used to search this kind of description. Only searching LOINC codes are also avaliable, but not recoommended.
#'
#'
#' @name searchCases
#' @inherit commonLabArgs
#' @param loincColName tthe column name that records LOINC in labData.
#' @param condition desired keyword string.
#' @param isSummary summary T or F
#' @return A \code{data.table} merged two tables.
#' @examples

#'
NULL

#' Get abnormal mark
#'
#' \code{getAbnormalMark} generates a new column recorded abnormal values: high \code{H} and \code{L}.
#'
#'
#' This step is optional but recommended. Reference ranges differ in different institutions, so a user-defined reference table is needed. The table should record the reference values for male and female separately. Lower bound can be expressed as \code{<}, \code{(} (greater than) or  \code{<=} , \code{[} (great tham or euqal to), and the expression of upper bound is similar. If there is no upper bound or lower bound, just remain empty. After the new abnormal flag column generated, it can be used to do categorical analysis, or be used in the function: \code{plotTimeSeriesLab}.
#'
#'
#' @name abMark
#' @inherit commonLabArgs
#' @param valueColName the column name that records test value in labData. Only numeric value is acceptable.
#' @param genderColName the column name that records gender of each patient. Gender should be coded as \code{M} or \code{F}.
#' @param referenceTable a data table that records reference values of each lab item. Column names should be: \code{LowerBound_Male}, \code{UpperBound_Male}, \code{LowerBound_Female}, \code{UpperBound_Female}.
#' @return A \code{data.table} merged two tables.
#' @examples
#'mapLOINC(labData = labSample,
#'         labItemColName = ITEMID,
#'         mappingTable = mapSample)
#'
#'
NULL


#' Plot Time-Series Window Proportion
#'
#' \code{getTimeSeriesLab} seperates original data into multiple time windows, and summarize statistical information.
#'
#' This function is used for seperating lab data into multiple time windows, and it provides overall statistical information: total count, maximun value, minimun value, mean, nearest record to index date of each time window. If \code{indexDate} is first, then it will be the earliest test date among all the lab tests.
#'
#' @name plotWindow
#' @inherit commonLabArgs
#' @param valueColName the column name that records test value in labData. Only numeric value is acceptable.
#' @return A \code{data.table} with statistical summary.


NULL



#' Obtaining Time-Series Data
#'
#' \code{getTimeSeriesLab} seperates original data into multiple time windows, and summarize statistical information.
#'
#' This function is used for seperating lab data into multiple time windows, and it provides overall statistical information: total count, maximun value, minimun value, mean, nearest record to index date of each time window. If \code{indexDate} is first, then it will be the earliest test date among all the lab tests.
#'
#' @name getTS
#' @inherit commonLabArgs
#' @param valueColName the column name that records test value in labData. Only numeric value is acceptable.
#' @return A \code{data.table} with statistical summary.
#' @examples
#'getTimeSeriesLab(labData = labSample,
#'                 idColName = SUBJECT_ID,
#'                 labItemColName = ITEMID,
#'                 dateColName = CHARTTIME,
#'                 valueColName = VALUENUM,
#'                 indexDate = last,
#'                 gapDate = 360,
#'                 completeWindows = TRUE)
NULL

#' Imputing Time-Series Data
#'
#' \code{imputeTimeSeriesLab} does imputation for time-series data.
#'
#' Two imputation methods are provided: \code{mean} or \code{interpolation}. If choosing \code{mean} method, the imputation is based the mean of all other non-null values among all the windows of the specific lab item for certain patient. If \code{interpolation}, the imputation uses linear interpolation method, and other out-of-range null values will be imputed by mean of known values. If \code{nocb}, the imputation method is "next observation carried backward".
#'
#'
#' @name impTS
#' @inherit commonLabArgs
#' @param valueColName the column name that records lab test value in labData. If there are more than one value column to be imputed, just simply add \code{&} operator between column names, e.g., \code{A & B}, then imputation of multiple columns can be done simultaneously.
#' @param windowColName the column name that records time window sequence in labData.
#' @param impMethod desird imputation method:\code{mean}, \code{interpolation} or \code{nocb}.
#' @return A \code{data.table} with imputed data.
#' @examples
#'
#' timeSeriesData <- getTimeSeriesLab(labData = labSample,
#'                                    idColName = SUBJECT_ID,
#'                                    labItemColName = ITEMID,
#'                                    dateColName = CHARTTIME,
#'                                    valueColName = VALUENUM,
#'                                    indexDate = first,
#'                                    gapDate = 360,
#'                                    completeWindows = TRUE)
#'imputeTimeSeriesLab(labData = timeSeriesData,
#'                 idColName = ID,
#'                 labItemColName = ITEMID,
#'                 windowColName = Window,
#'                 valueColName = Max & Min & Mean & Nearest,
#'                 impMethod = mean)
NULL


#' Wide Time-Series Data
#'
#' \code{wideTimeSeriesLab} transforms time-series data into wide format.
#'
#' After setting desired time window, data can further transform into wide format, which is more suitable for analysis. If lab item code is composed by multiple columns, it will automaticlly combined as one. And there can only be single value column selected in this step.
#'
#'
#' @name wideTS
#' @inherit commonLabArgs
#' @param windowColName the column name that records time window sequence in labData.
#' @return A new, wide-formatted \code{data.table}.
#' @examples
#'
#' timeSeriesData <- getTimeSeriesLab(labData = labSample,
#'                                    idColName = SUBJECT_ID,
#'                                    labItemColName = ITEMID,
#'                                    dateColName = CHARTTIME,
#'                                    valueColName = VALUENUM,
#'                                    indexDate = first,
#'                                    gapDate = 360,
#'                                    completeWindows = TRUE)
#' imputedData <- imputeTimeSeriesLab(labData = timeSeriesData,
#'                    idColName = ID,
#'                    labItemColName = ITEMID,
#'                    windowColName = Window,
#'                    valueColName = Max & Min,
#'                    impMethod = mean)
#' wideTimeSeriesLab(labData = imputedData,
#'                   idColName = ID,
#'                   labItemColName = ITEMID,
#'                   windowColName = Window,
#'                   valueColName = Max)
NULL

#' Plotting Time-Series Data
#'
#' \code{plotTimeSeriesLab} plots line charts of laboratory data.
#'
#' This function provides an overview and temporal changes of laboratory tests. If \code{abnormalMarkColName} provided, then "H" mark is displayed by "▲" icon. Similarly, "L" mark is displayed by "▽" icon. Time mark can be continuous or discrete, but \code{labData} should be longitudinal.
#'
#'
#' @name plotTS
#' @inherit commonLabArgs
#' @param timeMarkColName the column name that records time in labData. Time can be time window or be real date.
#' @param timeStart any starting time point of interesting. It can be time window or be real date depending on the selection of \code{timeMarkColName}.
#' @param timeEnd any ending time point of interesting. It can be time window or be real date depending on the selection of \code{timeMarkColName}.
#' @param abnormalMarkColName the column name that records abnormal mark in labData. It is optional.
#' @return One or multiple line chart of temoral laboratory results of one or multiple patient(s).
#' @examples
#'
#' timeSeriesData <- getTimeSeriesLab(labData = labSample,
#'                                    idColName = SUBJECT_ID,
#'                                    labItemColName = ITEMID,
#'                                    dateColName = CHARTTIME,
#'                                    valueColName = VALUENUM,
#'                                    indexDate = last,
#'                                    gapDate = 360,
#'                                    completeWindows = TRUE)
#' imputedData <- imputeTimeSeriesLab(labData = timeSeriesData,
#'                    idColName = ID,
#'                    labItemColName = ITEMID,
#'                    windowColName = Window,
#'                    valueColName = Max,
#'                    impMethod = mean)
#' imputedData <- imputedData[(ID == "107" | ID == "109") & (ITEMID == "51274" | ITEMID == "51383"),]
#' plotTimeSeriesLab(labData = imputedData,
#'                   idColName = ID,
#'                   labItemColName = ITEMID,
#'                   timeMarkColName = Window,
#'                   valueColName = Max)
NULL
