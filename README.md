# urban-wildlife-tracking

## Object and objectives

With this repository, we aim to describe the processes of data management and analysis from the project "Rastreo de la fauna urbana en la Área Metropolitana del Valle de Aburrá, Antioquia, Colombia" (Urban fauna tracking in the Metropolitan Area of Valle de Aburrá, Antioquia, Colombia).
This work was conducted by the Instituto Alexander von Humboldt (public Colombian research institute) in an agreement with "Área Metropolitana del Valle de Aburrá" (AMVA).

## Contents

The repository includes :

1. folder ["data_management"](./data_management): documents y codes for the data management steps of the project:
    + subfolder ["general"](./data_management/general): data stream description
    + subfolder ["movebank"](./data_management/movebank): setup and use of the movebank platform
    + subfolder ["oracle_amva"](./data_management/oracle_amva): storing the data in the AMVA Oracle database
    + subfolder ["local"](data_management/local): local filters and data treatment of the data from movebank
2. folder ["data_analysis"](./data_analysis): documents and codes for data analysis
    + subfolder ["documentation"](./data_analysis/documentation): analysis flow and bibliography description. An analysis of the literature was conducted in order to assess the potential movement ecology methodology that may be useful in our project
    + subfolder ["analysis"](./data_analysis/analysis): codes and description of the analysis in R

## Requirement

In order to use the code presented in the repository, you will need:

* R, with the following packages installed:
  + ctmm
  + httr
  + leaflet
  + lubridate
  + move
  + move2
  + parallel
  + rgeos
  + sp
  + knitr
  + rmarkdown

If you want to create a database Oracle such as the one we use in the subfolder ["oracle_amva"](./data_management/oracle_amva) you will need Oracle as well and the package `ROracle` (see https://github.com/marbotte/ROracle for a patched windows version of the package, but refer to the ROracle package from CRAN). *Note that we do not recommend Oracle for such applications, please look for the Postgres + postgis solution and adapt accordingly the SQL and R codes*. 


# Rmarkdown documents

Most of the codes of this repository are presented in rmarkdown document (Rmd extension).

You may render them as github documents with the following command in R:

```
rmarkdown::render("filename.Rmd")
```

However, since github document are not easy to read on a local machine, you may want to use:

```
rmarkdown::render("filename.Rmd", output_format="html_document")
```

If you have a functional latex distribution on your computer (see tinytex R package to install one otherwise), you may even create pdf report out of the rmarkdown files using:

```
rmarkdown::render("filename.Rmd", output_format="pdf_document")
```


