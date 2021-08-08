LAB
================

## lab

# I. Introduction

The proposed open-source lab package is a software tool that help users
to explore and process laboratory data in electronic health records
(EHRs). With the lab package, researchers can easily map local
laboratory codes to the universal standard, mark abnormal results,
summarize data using descriptive statistics, impute missing values, and
generate analysis ready data.

## Feature

  - **Data Mapping** Standardize and manipulate data with Logical
    Observation Identifiers Names and Codes (LOINC), a common
    terminology for laboratory and clinical observations.
  - **Time Series Analysis** Separate lab test results into multiple
    consecutive non-overlapped time windows
  - **Value Imputation** Impute value to replace missing data
  - **Wide Format Generation** Transform longitudinal data into wide
    format to generate analysis ready data

## Development version

``` r
# install.packages("devtools")
devtools::install_github("DHLab-TSENG/dxpr")
```

## Overview

<img src="https://raw.githubusercontent.com/DHLab-TSENG/lab/master/image/overview.png" style="display:block; margin:auto; width:100%;">

## Usage

``` r
# install.packages("devtools")
devtools::install_github("DHLab-TSENG/lab")
library(lab)
```

### Dataset

The sample data includes 1,744 lab records containing 7 different lab
items tested by 5 patients from MIMIC-III database.

``` r

head(labSample)
#>    SUBJECT_ID ITEMID  CHARTTIME VALUENUM VALUEUOM     FLAG
#> 1:         36  50811 2131-05-18     12.7     g/dL abnormal
#> 2:         36  50912 2131-05-18      1.2    mg/dL         
#> 3:         36  51222 2131-05-18     11.9     g/dL abnormal
#> 4:         36  50912 2131-05-19      1.3    mg/dL abnormal
#> 5:         36  50931 2131-05-19    160.0    mg/dL abnormal
#> 6:         36  51222 2131-05-19      9.6     g/dL abnormal

head(mapSample)
#>    ITEMID                          LABEL FLUID  CATEGORY   LOINC
#> 1:  50811                     Hemoglobin Blood Blood Gas   718-7
#> 2:  50861 Alanine Aminotransferase (ALT) Blood Chemistry  1742-6
#> 3:  50904               Cholesterol, HDL Blood Chemistry  2085-9
#> 4:  50906     Cholesterol, LDL, Measured Blood Chemistry 18262-6
#> 5:  50912                     Creatinine Blood Chemistry  2160-0
#> 6:  50931                        Glucose Blood Chemistry  2345-7
```

### I. Data Mapping

If LOINC is not the default terminology, users are recommended to map
local lab item with LOINC by providing mapping table. Once a user map
lab test codes with LOINC, ranges can be used to mark abnormal results,
and related names can be used to search related lab test codes by other
common names of a lab test.

``` r

loincSample <- mapLOINC(labData = labSample, labItemColName = ITEMID, mappingTable = mapSample)

head(loincSample)
#>    ITEMID SUBJECT_ID  CHARTTIME VALUENUM VALUEUOM     FLAG      LABEL
#> 1:  50811         36 2131-05-18     12.7     g/dL abnormal Hemoglobin
#> 2:  50811         36 2131-05-04     12.3     g/dL abnormal Hemoglobin
#> 3:  50811         36 2131-05-15     10.0     g/dL abnormal Hemoglobin
#> 4:  50811         36 2131-05-17     11.7     g/dL abnormal Hemoglobin
#> 5:  50811        109 2142-02-25      6.9     g/dL abnormal Hemoglobin
#> 6:  50811        109 2141-09-20      7.2     g/dL abnormal Hemoglobin
#>    FLUID  CATEGORY LOINC
#> 1: Blood Blood Gas 718-7
#> 2: Blood Blood Gas 718-7
#> 3: Blood Blood Gas 718-7
#> 4: Blood Blood Gas 718-7
#> 5: Blood Blood Gas 718-7
#> 6: Blood Blood Gas 718-7

loincMarkedSample <- getAbnormalMark(labData = loincSample, 
                                     idColName = SUBJECT_ID,
                                     labItemColName = LOINC, 
                                     valueColName = VALUENUM, 
                                     genderColName = GENDER,
                                     genderTable = patientSample,
                                     referenceTable = refLOINC)
head(loincMarkedSample)
#>    ITEMID  ID  CHARTTIME Value VALUEUOM     FLAG
#> 1:  50861  36 2131-04-30     8     IU/L         
#> 2:  50861  36 2131-05-17    12     IU/L         
#> 3:  50861  36 2134-05-14    12     IU/L         
#> 4:  50861 109 2138-07-03    14     IU/L         
#> 5:  50861 109 2142-03-21    46     IU/L abnormal
#> 6:  50861 109 2142-01-09    10     IU/L         
#>                             LABEL FLUID  CATEGORY  LOINC ABMark
#> 1: Alanine Aminotransferase (ALT) Blood Chemistry 1742-6   <NA>
#> 2: Alanine Aminotransferase (ALT) Blood Chemistry 1742-6   <NA>
#> 3: Alanine Aminotransferase (ALT) Blood Chemistry 1742-6   <NA>
#> 4: Alanine Aminotransferase (ALT) Blood Chemistry 1742-6   <NA>
#> 5: Alanine Aminotransferase (ALT) Blood Chemistry 1742-6      H
#> 6: Alanine Aminotransferase (ALT) Blood Chemistry 1742-6   <NA>
```

# II. Time Series Overview

    windowProportion <- plotWindowProportion(labData = loincSample, 
                         idColName = SUBJECT_ID, 
                         labItemColName = LOINC, 
                         dateColName = CHARTTIME, 
                         indexDate = first, 
                         gapDate = c(30, 90, 180, 360), 
                         topN = 5)
    
    print(windowProportion$graph)
    
    print(windowProportion$missingData)
    
    
    timeSeriesData <- getTimeSeriesLab(labData = loincSample,
                                       idColName = SUBJECT_ID,
                                       labItemColName = LOINC + CATEGORY,
                                       dateColName = CHARTTIME,
                                       valueColName = VALUENUM,
                                       indexDate = first,
                                       gapDate = 30,
                                       completeWindows = TRUE)
    head(timeSeriesData)
    
    fullTimeSeriesData <- imputeTimeSeriesLab(labData = timeSeriesData,
                                       idColName = ID,
                                       labItemColName = LOINC + CATEGORY,
                                       windowColName = Window,
                                       valueColName = Mean & Nearest,
                                       impMethod = NOCB)
    head(fullTimeSeriesData)
    
    timeSeriesPlot <- plotTimeSeriesLab(labData = fullTimeSeriesData, 
                                        idColName = ID, 
                                        labItemColName = LOINC + CATEGORY, 
                                        timeMarkColName = Window, 
                                        valueColName = Nearest, 
                                        timeStart = 1, 
                                        timeEnd  = 5, 
                                        abnormalMarkColName = NULL)
    
    plot(timeSeriesPlot)
    
    wideTimeSeriesData <- wideTimeSeriesLab(labData = fullTimeSeriesData,
                                            idColName = ID,
                                            labItemColName = LOINC + CATEGORY,
                                            windowColName = Window, 
                                            valueColName = Nearest)
    head(wideTimeSeriesData)

<!-- ## Visulization -->

<!-- The plot -->

<!-- ```{r pressure, echo=FALSE} -->

<!-- plot(pressure) -->

<!-- ``` -->
