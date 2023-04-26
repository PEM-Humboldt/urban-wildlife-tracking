# Local data treatment

While most of the data from the project is hosted in the movebank platform, there are some operations which need to be conducted on a local machine.

Mostly 2 groups of operations:

* Managing errors and deleting erroneous data
* Managing extra data which may be useful to analyse the central movement data from movebank


In order to do that, this folder contains the following elements:

1. R functions and general routines to clean or import data (files with the .R extension)
1. A rmarkdown document called [importingCleaningFormatting.Rmd](./importingCleaningFormatting.md) presenting the tools from `move` and `ctmm` to clean and manage the data from movebank with only a few individuals as examples
1. A rmarkdown document called [localExtraSpatialDataDB.Rmd](./localExtraSpatialDB.md) which shows how to create a local database with data which may reveal useful later for analysing movement data
1. A rmarkdown document called [outliers.Rmd](./outliers.md) which shows a more in depth analysis of the spatial errors of the movement data and delete erroneous data from the datasets of every individuals.
