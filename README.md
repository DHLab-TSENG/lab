LAB
================

## lab

# I. Introduction

The proposed open-source lab package is a software tool that help users
to explore and process laboratory data in electronic health records
(EHRs). With the lab package, researchers can easily map local
laboratory codes to the universal standard, mark abnormal results,
process general statistical information about longitudinal laboratory
data, impute missing values, generate analysis ready data, and visualize
these data.

## Feature

  - **Data Mapping**  
  - **Time Series Overview**
  - **Value Imputation**
  - **Visualization**

## Usage

``` r
# install.packages("devtools")
devtools::install_github("DHLab-TSENG/lab")
```

``` r
library(lab)

# Dataset

head(labSample)
```

    ##    SUBJECT_ID HADM_ID ITEMID           CHARTTIME VALUE VALUENUM VALUEUOM
    ## 1:         36  122659  50811 2131-05-18 12:24:00  12.7     12.7     g/dL
    ## 2:         36  122659  50811 2131-05-18 12:52:00  12.4     12.4     g/dL
    ## 3:         36  122659  50811 2131-05-18 13:17:00  11.9     11.9     g/dL
    ## 4:         36  122659  50912 2131-05-18 14:37:00   1.2      1.2    mg/dL
    ## 5:         36  122659  51222 2131-05-18 14:37:00  11.9     11.9     g/dL
    ## 6:         36  122659  50912 2131-05-19 02:02:00   1.3      1.3    mg/dL
    ##        FLAG
    ## 1: abnormal
    ## 2: abnormal
    ## 3: abnormal
    ## 4:         
    ## 5: abnormal
    ## 6: abnormal

``` r
head(mapSample)
```

    ##    ITEMID                          LABEL FLUID  CATEGORY   LOINC
    ## 1:  50811                     Hemoglobin Blood Blood Gas   718-7
    ## 2:  50861 Alanine Aminotransferase (ALT) Blood Chemistry  1742-6
    ## 3:  50904               Cholesterol, HDL Blood Chemistry  2085-9
    ## 4:  50906     Cholesterol, LDL, Measured Blood Chemistry 18262-6
    ## 5:  50912                     Creatinine Blood Chemistry  2160-0
    ## 6:  50931                        Glucose Blood Chemistry  2345-7

``` r
# I. Data Mapping

loincSample <- mapLOINC(labData = labSample, labItemColName = ITEMID, mappingTable = mapSample)
head(loincSample)
```

    ##    ITEMID SUBJECT_ID HADM_ID           CHARTTIME VALUE VALUENUM VALUEUOM
    ## 1:  50811         36  122659 2131-05-18 12:24:00  12.7     12.7     g/dL
    ## 2:  50811         36  122659 2131-05-18 12:52:00  12.4     12.4     g/dL
    ## 3:  50811         36  122659 2131-05-18 13:17:00  11.9     11.9     g/dL
    ## 4:  50811         36  182104 2131-05-04 06:47:00  12.3     12.3     g/dL
    ## 5:  50811         36  182104 2131-05-04 09:49:00   9.1      9.1     g/dL
    ## 6:  50811         36  182104 2131-05-04 11:00:00   9.6      9.6     g/dL
    ##        FLAG      LABEL FLUID  CATEGORY LOINC
    ## 1: abnormal Hemoglobin Blood Blood Gas 718-7
    ## 2: abnormal Hemoglobin Blood Blood Gas 718-7
    ## 3: abnormal Hemoglobin Blood Blood Gas 718-7
    ## 4: abnormal Hemoglobin Blood Blood Gas 718-7
    ## 5: abnormal Hemoglobin Blood Blood Gas 718-7
    ## 6: abnormal Hemoglobin Blood Blood Gas 718-7

``` r
loincMarkedSample <- getAbnormalMark(labData = loincSample, 
                                     idColName = SUBJECT_ID,
                                     labItemColName = LOINC, 
                                     valueColName = VALUENUM, 
                                     genderColName = GENDER,
                                     genderTable = patientSample,
                                     referenceTable = refLOINC)
head(loincMarkedSample)
```

    ##    ITEMID  ID HADM_ID           CHARTTIME VALUE Value VALUEUOM     FLAG
    ## 1:  50861  36  182104 2131-04-30 09:33:00     8     8     IU/L         
    ## 2:  50861  36  122659 2131-05-17 06:09:00    12    12     IU/L         
    ## 3:  50861  36  165660 2134-05-14 02:20:00    12    12     IU/L         
    ## 4:  50861 109      NA 2138-07-03 14:45:00    14    14     IU/L         
    ## 5:  50861 109  158943 2142-03-21 01:20:00    46    46     IU/L abnormal
    ## 6:  50861 109  135923 2142-01-09 04:09:00    10    10     IU/L         
    ##                             LABEL FLUID  CATEGORY  LOINC ABMark
    ## 1: Alanine Aminotransferase (ALT) Blood Chemistry 1742-6   <NA>
    ## 2: Alanine Aminotransferase (ALT) Blood Chemistry 1742-6   <NA>
    ## 3: Alanine Aminotransferase (ALT) Blood Chemistry 1742-6   <NA>
    ## 4: Alanine Aminotransferase (ALT) Blood Chemistry 1742-6   <NA>
    ## 5: Alanine Aminotransferase (ALT) Blood Chemistry 1742-6      H
    ## 6: Alanine Aminotransferase (ALT) Blood Chemistry 1742-6   <NA>

``` r
# II. Time Series Overview

timeSeriesData <- getTimeSeriesLab(labData = loincSample,
                                   idColName = SUBJECT_ID,
                                   labItemColName = LOINC + CATEGORY,
                                   dateColName = CHARTTIME,
                                   valueColName = VALUENUM,
                                   indexDate = first,
                                   gapDate = 360,
                                   completeWindows = TRUE)
head(timeSeriesData)
```

    ##    ID  LOINC  CATEGORY Window Count Max  Min  Mean Nearest firstRecord
    ## 1: 36 1742-6 Chemistry      1     2  12  8.0 10.00       8  2131-04-30
    ## 2: 36 1742-6 Chemistry      2    NA  NA   NA    NA      NA        <NA>
    ## 3: 36 1742-6 Chemistry      3    NA  NA   NA    NA      NA        <NA>
    ## 4: 36 1742-6 Chemistry      4     1  12 12.0 12.00      12  2134-05-14
    ## 5: 36 2160-0 Chemistry      1    34   2  0.7  1.25       1  2131-04-30
    ## 6: 36 2160-0 Chemistry      2    NA  NA   NA    NA      NA        <NA>
    ##    lastRecode
    ## 1: 2131-05-17
    ## 2:       <NA>
    ## 3:       <NA>
    ## 4: 2134-05-14
    ## 5: 2132-02-08
    ## 6:       <NA>

``` r
fullTimeSeriesData <- imputeTimeSeriesLab(labData = timeSeriesData,
                                   idColName = ID,
                                   labItemColName = LOINC + CATEGORY,
                                   windowColName = Window,
                                   valueColName = Max & Min & Mean & Nearest,
                                   impMethod = NOCB)
head(fullTimeSeriesData)
```

    ##    ID  LOINC  CATEGORY Window  Max  Min       Mean Nearest
    ## 1: 36 1742-6 Chemistry      1 12.0  8.0 10.0000000       8
    ## 2: 36 1742-6 Chemistry      2 12.0 12.0 12.0000000      12
    ## 3: 36 1742-6 Chemistry      3 12.0 12.0 12.0000000      12
    ## 4: 36 1742-6 Chemistry      4 12.0 12.0 12.0000000      12
    ## 5: 36 2160-0 Chemistry      1  2.0  0.7  1.2500000       1
    ## 6: 36 2160-0 Chemistry      2  1.2  0.8  0.9272727       1

<!-- ## Visulization -->

<!-- The plot -->

<!-- ```{r pressure, echo=FALSE} -->

<!-- plot(pressure) -->

<!-- ``` -->
