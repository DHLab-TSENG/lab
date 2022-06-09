
#' @details
#' The only function you're likely to need from roxygen2 is [roxygenize()].
#' Otherwise refer to the vignettes to see how to format the documentation.
#' @keywords internal
"_PACKAGE"

#' Dataset - LOINC
#'
#' These datasets are used for diagnostic code transformation.
#'
#' @name LOINC
#' @format These datatable with ICD diagnostic codes and the specific Standardization categories.
"refLOINC"
#' @rdname LOINC
"tagLOINC"
NULL

#' Dataset - Sample
#' @format Sample from MIMIC

#' @name Sample
"patientSample"
#' @rdname Sample
"mapSample"
#' @rdname Sample
"labSample"
#' @rdname indexSample
"indexTable"
NULL
