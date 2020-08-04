README
================

## GitHub Documents

This is an R Markdown format used for publishing markdown documents to
GitHub. When you click the **Knit** button all R code chunks are run and
a markdown file (.md) suitable for publishing to GitHub is generated.

## Including Code

You can include R code in the document as follows:

``` r
library(lab)

timeSeriesData <- getTimeSeriesLab(labData = labMIMIC,
                                   idColName = SUBJECT_ID,
                                   labItemColName = ITEMID,
                                   dateColName = CHARTTIME,
                                   valueColName = VALUENUM,
                                   indexDate = first,
                                   gapDate = 360,
                                   completeWindows = TRUE)
head(timeSeriesData)
```

    ##    ID ITEMID Window Count Max Min Mean Nearest firstRecord lastRecode
    ## 1:  2  50883      1     1 0.3 0.3  0.3     0.3  2138-07-20 2138-07-20
    ## 2:  2  50884      1     1 9.0 9.0  9.0     9.0  2138-07-20 2138-07-20
    ## 3:  2  50885      1     1 9.3 9.3  9.3     9.3  2138-07-20 2138-07-20
    ## 4:  2  51137      1     1  NA  NA   NA      NA  2138-07-17 2138-07-17
    ## 5:  2  51143      1     2 0.0 0.0  0.0     0.0  2138-07-17 2138-07-17
    ## 6:  2  51144      1     2 1.0 0.0  0.5     0.0  2138-07-17 2138-07-17

## Including Plots

You can also embed plots, for example:

![](README_files/figure-gfm/pressure-1.png)<!-- -->

Note that the `echo = FALSE` parameter was added to the code chunk to
prevent printing of the R code that generated the plot.
