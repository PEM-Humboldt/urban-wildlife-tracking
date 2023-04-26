In depth analysis of errors in the movement data and deletion of
outliers
================
Marius Bottin
2023-04-26

- [Getting the general data from
  movebank](#getting-the-general-data-from-movebank)

# Getting the general data from movebank

Here we will apply the script to get all the data from movebank. If
needed, more details are presented in the document
[importingCleaningFormatting.Rmd](./importingCleaningFormatting.md)

``` r
source("importingMovebankData.R")
```

    ## Loading required package: move

    ## Loading required package: geosphere

    ## Loading required package: raster

``` r
source("movebankFromDirectApi.R")
```

    ## Loading required package: httr

    ## No encoding supplied: defaulting to UTF-8.

``` r
source("itis_taxo.R")
```

    ## Loading required package: ritis

    ## 
    ## Attaching package: 'ritis'

    ## The following object is masked from 'package:stats':
    ## 
    ##     terms
