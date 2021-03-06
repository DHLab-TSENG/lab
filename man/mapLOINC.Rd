% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/labFun.R, R/mapLOINC.R
\name{mapLOINC}
\alias{mapLOINC}
\title{Mapping local lab codes with LOINC}
\usage{
mapLOINC(labData, labItemColName, mappingTable = NULL)
}
\arguments{
\item{labData}{a file or dataframe of laboratory test data with at least 4 columns about patient ID, lab item, test value and test date, respectively.}

\item{labItemColName}{the column name that records lab item in labData. If lab code is combined by multiple columns, then just simply add \code{+} operator between column names, e.g., \code{A + B}.}

\item{mappingTable}{a data table with at least two columns: local lab item code and LOINC code. The local column name should be identical as labItemColName in labData.}
}
\value{
A \code{data.table} merged two tables.
}
\description{
\code{mapLOINC} is used for merging two tables together. One is lab data with local codes, and the other one is mapping table of local lab codes and LOINC.
}
\details{
Since the lab item may be coded in local schemes, users can map it with LOINC by providing LOINC mapping table. This step is optional but recommended. After mapped, user can select desired laboratory tests by using function \code{searchCases}.
}
\examples{
mapLOINC(labData = labMIMIC,
        labItemColName = ITEMID,
        mappingTable = mapMIMIC)
}
