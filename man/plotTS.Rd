% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/labFun.R, R/plotTimeSeriesLab.R
\name{plotTS}
\alias{plotTS}
\alias{plotTimeSeriesLab}
\title{Plotting Time-Series Data}
\usage{
plotTimeSeriesLab(
  labData,
  idColName,
  labItemColName,
  timeMarkColName,
  valueColName,
  timeStart = NULL,
  timeEnd = NULL,
  abnormalMarkColName = NULL
)
}
\arguments{
\item{labData}{a file or dataframe of laboratory test data with at least 4 columns about patient ID, lab item, test value and test date, respectively.}

\item{idColName}{the column name that records patient ID in labData.}

\item{labItemColName}{the column name that records lab item in labData. If lab code is combined by multiple columns, then just simply add \code{+} operator between column names, e.g., \code{A + B}.}

\item{timeMarkColName}{the column name that records time in labData. Time can be time window or be real date.}

\item{timeStart}{any starting time point of interesting. It can be time window or be real date depending on the selection of \code{timeMarkColName}.}

\item{timeEnd}{any ending time point of interesting. It can be time window or be real date depending on the selection of \code{timeMarkColName}.}

\item{abnormalMarkColName}{the column name that records abnormal mark in labData. It is optional.}
}
\value{
One or multiple line chart of temoral laboratory results of one or multiple patient(s).
}
\description{
\code{plotTimeSeriesLab} plots line charts of laboratory data.
}
\details{
This function provides an overview and temporal changes of laboratory tests. If \code{abnormalMarkColName} provided, then "H" mark is displayed by "▲" icon. Similarly, "L" mark is displayed by "▽" icon. Time mark can be continuous or discrete, but \code{labData} should be longitudinal.
}
\examples{

timeSeriesData <- getTimeSeriesLab(labData = labSample,
                                   idColName = SUBJECT_ID,
                                   labItemColName = ITEMID,
                                   dateColName = CHARTTIME,
                                   valueColName = VALUENUM,
                                   indexDate = first,
                                   gapDate = 30,
                                   completeWindows = TRUE)
timeSeriesPlot <-plotTimeSeriesLab(labData = timeSeriesData,
                                   idColName = ID,
                                   labItemColName = ITEMID,
                                   timeMarkColName = Window,
                                   valueColName = Nearest,
                                   timeStart = 1,
                                   timeEnd  = 5,
                                   abnormalMarkColName = NULL)
plot(timeSeriesPlot)
# With abnormal mark
loincSample <- mapLOINC(labData = labSample,
                       labItemColName = ITEMID,
                       mappingTable = mapSample)
timeSeriesDataLOINC <- getTimeSeriesLab(labData = loincSample,
                                  idColName = SUBJECT_ID,
                                  labItemColName = LOINC + LABEL,
                                  dateColName = CHARTTIME,
                                  valueColName = VALUENUM,
                                  indexDate = first,
                                  gapDate = 30,
                                  completeWindows = TRUE)
colnames(patientSample)[2]<-"ID"
timeSeriesDataMarked <- getAbnormalMark(labData = timeSeriesDataLOINC,
                                       idColName = ID,
                                       labItemColName = LOINC,
                                       valueColName = Nearest,
                                       genderColName = GENDER,
                                       genderTable = patientSample,
                                       referenceTable = refLOINC)

timeSeriesPlotMarked <- plotTimeSeriesLab(labData = timeSeriesDataMarked,
                                         idColName = ID,
                                         labItemColName = LOINC + LABEL,
                                         timeMarkColName = Window,
                                         valueColName = Value,
                                         timeStart = 1,
                                         timeEnd = 5,
                                         abnormalMarkColName = ABMark)
plot(timeSeriesPlotMarked)

}
