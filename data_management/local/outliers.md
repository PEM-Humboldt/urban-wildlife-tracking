In depth analysis of errors in the movement data and deletion of
outliers
================
Marius Bottin
2023-05-02

- [Getting the general data from
  movebank](#getting-the-general-data-from-movebank)
- [Importing data, by individual](#importing-data-by-individual)
- [Very basic filter](#very-basic-filter)
- [Analyses of spatial errors](#analyses-of-spatial-errors)
  - [Before starting filtering](#before-starting-filtering)
  - [Loading the User Equivalent Range Error
    (UERE)](#loading-the-user-equivalent-range-error-uere)
  - [Checking Error criteria](#checking-error-criteria)
  - [Calculating Error criteria](#calculating-error-criteria)
  - [Applying the filters](#applying-the-filters)
  - [Saving the files for later use](#saving-the-files-for-later-use)

# Getting the general data from movebank

If needed, more details are presented in the document
[importingCleaningFormatting.Rmd](./importingCleaningFormatting.md)

``` r
passWord <- read.csv("password.csv", h = F)[1, 1]
lgin <- movebankLogin(username = "Humboldt_AreaMetropolitana", password = passWord)
study_id <- getMovebankID("Rastreo fauna área metropolitana del Valle de Aburrá, Colombia",
    login = lgin)
```

# Importing data, by individual

Before doing that, make sure that you ran the code contained in file
[SpatialErrorCalibration.Rmd](SpatialErrorCalibration.md). Various
processes needed to be done, in particular the relationship between
names of the animals in the movebank data and the calibration local
datasets.

------------------------------------------------------------------------

**Note: timestamps and timezones**

The data from movevank is usually given with Universal Time Zone (UTZ)
timestamp. For it to make more ecological sense, we need to put the
timestamp in the local timezone (“America/Bogota”). There might be some
options to download it directly in local timezone (TODO) but here we
will transform the timestamp with the package `lubridate`

------------------------------------------------------------------------

``` r
load("./tabNames.RData")
rawList <- list()
for (i in 1:nrow(tabNames)) {
    rawList[[tabNames$aniNames[i]]] <- list()
    rawList[[i]]$moveData = getMovebankData(study = study_id, login = lgin,
        animalName = tabNames$aniNames[i])
    timestamps(rawList[[i]]$moveData) <- with_tz(timestamps(rawList[[i]]$moveData),
        tz = "America/Bogota")
    rawList[[i]]$ctmmData = as.telemetry(rawList[[i]]$moveData)
    rawList[[i]]$ctmmData$class <- NULL
}
```

# Very basic filter

Let’s first remove all the relocation which are not in the Antioquia
department! For that, you will need the local database with geographic
extra information as explained in
[localExtraSpatialDataDB.Rmd](./localExtraSpatialDataDB.md) (only the
municipality data is mandatory)

We need to be sure that `move`-formatted data and `ctmm`-formatted data
are exactly the same, and that

``` r
stopifnot(sapply(rawList, function(x) {
    m1 <- match(x$moveData$timestamp, x$ctmmData$timestamp)
    all(m1 == (1:length(m1)))
}))
```

``` r
Colombia <- pgGetGeom(extraSp, query = "SELECT ST_Union(the_geom) geom FROM mpio ")
```

    ## Returning MultiPolygon types in SpatialPolygons*-class.

``` r
inColombia <- lapply(rawList, function(rl, poly) !is.na(over(rl$moveData,
    poly)), poly = Colombia)
```

The number of points out of Colombia is:

``` r
sapply(sapply(inColombia, `!`), sum)
```

    ##          Zorro02          Zorro03          Zorro04          Zorro05 
    ##                0              125              129              109 
    ##          Zorro06          Zorro07     Guacharaca01     Guacharaca03 
    ##               80               95                2                0 
    ##       Phimosus01       Phimosus02           Pigua1       Zarigueya1 
    ##                0               47                0               90 
    ##       Zarigueya2       Zarigueya3       Zarigueya4       Phimosus04 
    ##               41               35                5                0 
    ##           Pigua2           Garza1        GarzaAve4       Zarigueya5 
    ##              127                1                3                0 
    ##           Pigua5     Guacharaca06         Ardilla1        GarzaAve2 
    ##              346              620                0                0 
    ##        GarzaAve3       Zarigueya6       Phimosus05       Phimosus07 
    ##                0                0               62               36 
    ##       Phimosus06       Zarigueya7     Guacharaca02      PavaGarza-4 
    ##                1               30                6                0 
    ##            Asio2       BuhoPigua6         Ardilla2  PavaGuacharaca5 
    ##                4                0              591              453 
    ##     Guacharaca04   PerezosoZorro1            Titi4       Phimosus03 
    ##                2                5                1                1 
    ## GuacharacaAsio-4       GarzaTiti3 
    ##                1                0

``` r
for (i in names(inColombia)) {
    rawList[[i]]$moveData <- rawList[[i]]$moveData[inColombia[[i]]]
    rawList[[i]]$ctmmData <- subset(rawList[[i]]$ctmmData, inColombia[[i]])
}
```

# Analyses of spatial errors

In the document
[importingCleaningFormatting.Rmd](./importingCleaningFormatting.md), you
may see how to use the function from `ctmm` and `move` for managing
movement data. However, there are some decisions to take, animal by
animal, in order to delete erroneous data from the individual datasets.

The criteria for pointing outliers may be extracted from:

- HDOP data associated with each relocation
- distance from the previous and the following point
- average speed calculated on every trajectory between 2 relocation
  points
- it is important to take into account the fact that some of the
  relocation might be missing and therefore the comparison of distances
  and speeds may be irrelevant
- `ctmm` uses calibration datasets to fit UERE models (see
  [SpatialErrorCalibration.Rmd](SpatialErrorCalibration.md))
- `ctmm` also allows to create semi-variogram that apparently may be of
  use for searching for outliers

With all these criteria, it is possible to point out which are the
points which may be erroneous. However, it seems that there are no real
procedure to automatically suppress outliers based on them. Each outlier
should be evaluated visually, because it might be a real change in the
movement behavior of the animals.

**Note that the goal here is to suppress the data that seems erroneous,
in a case where we want to fit a movement model (for example in a case
of homerange estimation) we might want to suppress the points that are
adding noise in the autocorrelation structure of the dataset… THAT IS
NOT THE CASE HERE**

## Before starting filtering

``` r
stopifnot(sapply(rawList, function(x) {
    m1 <- match(x$moveData$timestamp, x$ctmmData$timestamp)
    all(m1 == (1:length(m1)))
}))
```

## Loading the User Equivalent Range Error (UERE)

The UERE have been fitted in
[SpatialErrorCalibration.Rmd](./SpatialErrorCalibration.md).

``` r
load("uere.RData")
```

The values applied to the UERE, in meters, are the following:

``` r
(uere_val <- sapply(UERE_list, function(x) x$UERE[1]))
```

    ##       Garza1    GarzaAve4 Guacharaca01 Guacharaca03   Phimosus02   Phimosus04 
    ##     31.30580     30.37799     38.31116     38.29654     37.42671     24.31075 
    ##       Pigua2   Zarigueya1   Zarigueya2   Zarigueya3   Zarigueya4      Zorro02 
    ##     31.30580     18.05908     79.45091     56.27909     16.70156     21.98817 
    ##      Zorro03      Zorro04      Zorro05      Zorro06      Zorro07 
    ##     18.29613     26.21434     23.29503     19.50820     24.60193

``` r
mean(uere_val)
```

    ## [1] 31.51348

Note that these values are much higher than the usual values applied
without calibration to the devices (10m.)

Let’s apply the values to the

``` r
for (i in 1:length(rawList)) {
    if (names(rawList)[i] %in% names(UERE_list)) {
        uere(rawList[[i]]$ctmmData) <- NULL
        uere(rawList[[i]]$ctmmData) <- UERE_list[[names(rawList)[i]]]
    }
}
```

## Checking Error criteria

Let’s first create a list with only the calibrated data:

``` r
namesCalib <- sort(names(UERE_list))
rawListCalib <- rawList[namesCalib]
```

In order to have an idea about the criteria to apply for filtering
erroneous data, let’s first have a look at the highest quantiles of the
HDOP measurements:

``` r
tot_hdop <- unlist(lapply(rawList, function(x) x$ctmmData$HDOP))
quantile(tot_hdop, c(0.9, 0.95, 0.975, 0.99, 0.999))
```

    ##     90%     95%   97.5%     99%   99.9% 
    ## 1.52000 1.85000 2.27000 2.86880 4.37888

We can reasonably suppress all values superior to 2.5, which also mean,
knowing the average UERE value for the devices, that we suppress
approximately all the points where the estimated error is around 75m.

``` r
tot_varxy <- unlist(lapply(rawListCalib, function(x) x$ctmmData$VAR.xy))
quantile(tot_varxy, c(0.9, 0.95, 0.975, 0.99, 0.999))
```

    ##       90%       95%     97.5%       99%     99.9% 
    ##  1162.147  1629.271  2675.198  5252.272 18331.664

We can reasonably suppress all values superior to 5000 m2

## Calculating Error criteria

Other criteria:

``` r
err_crit_calc <- function(rLid) {
    spPt <- spTransform(SpatialPointsDataFrame.telemetry(rLid$ctmmData),
        "+proj=tmerc +lat_0=4.596200416666666 +lon_0=-74.07750791666666 +k=1 +x_0=1000000 +y_0=1000000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs")
    distances <- numeric(length(spPt) - 1)
    for (i in 2:length(spPt)) {
        distances[i - 1] <- gDistance(spPt[i, ], spPt[i - 1, ])
    }
    tl <- as.numeric(diff(rLid$ctmmData$timestamp))
    res <- data.frame(timestamp = rLid$ctmmData$timestamp, dist_from = c(NA,
        distances), dist_to = c(distances, NA), tl_from = c(NA, tl), tl_to = c(tl,
        NA), speed_from_m_s = c(NA, distances/tl), speed_to_m_s = c(distances/tl,
        NA), hdop = rLid$ctmmData$HDOP, VAR.xy = ifelse("VAR.xy" %in% colnames(rLid$ctmmData),
        rLid$ctmmData$VAR.xy, NA), VAR.v = ifelse("VAR.v" %in% colnames(rLid$ctmmData),
        rLid$ctmmData$VAR.v, NA))
    res$sum_dist_from_to <- res$dist_from + res$dist_to
    res$sum_tl_from_to <- res$tl_from + res$tl_to
    res$aver_speed_from_to <- res$sum_dist_from_to/res$sum_tl_from_to
    return(res)
}
errCrit <- lapply(rawList, err_crit_calc)
```

What we obtain for each individual is a table such as this (example
Garza1, first 20 rows):

``` r
errCrit$Garza1 %>%
    head(n = 20) %>%
    kable()
```

<table>
<thead>
<tr>
<th style="text-align:left;">
timestamp
</th>
<th style="text-align:right;">
dist_from
</th>
<th style="text-align:right;">
dist_to
</th>
<th style="text-align:right;">
tl_from
</th>
<th style="text-align:right;">
tl_to
</th>
<th style="text-align:right;">
speed_from_m_s
</th>
<th style="text-align:right;">
speed_to_m_s
</th>
<th style="text-align:right;">
hdop
</th>
<th style="text-align:right;">
VAR.xy
</th>
<th style="text-align:right;">
VAR.v
</th>
<th style="text-align:right;">
sum_dist_from_to
</th>
<th style="text-align:right;">
sum_tl_from_to
</th>
<th style="text-align:right;">
aver_speed_from_to
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
2022-12-19 18:12:30
</td>
<td style="text-align:right;">
—
</td>
<td style="text-align:right;">
352.603340
</td>
<td style="text-align:right;">
—
</td>
<td style="text-align:right;">
7272
</td>
<td style="text-align:right;">
—
</td>
<td style="text-align:right;">
0.0484878
</td>
<td style="text-align:right;">
0.78
</td>
<td style="text-align:right;">
298.1321
</td>
<td style="text-align:right;">
0.3042
</td>
<td style="text-align:right;">
—
</td>
<td style="text-align:right;">
—
</td>
<td style="text-align:right;">
—
</td>
</tr>
<tr>
<td style="text-align:left;">
2022-12-19 20:13:42
</td>
<td style="text-align:right;">
352.603340
</td>
<td style="text-align:right;">
488.788972
</td>
<td style="text-align:right;">
7272
</td>
<td style="text-align:right;">
1791
</td>
<td style="text-align:right;">
0.0484878
</td>
<td style="text-align:right;">
0.2729140
</td>
<td style="text-align:right;">
1.10
</td>
<td style="text-align:right;">
298.1321
</td>
<td style="text-align:right;">
0.3042
</td>
<td style="text-align:right;">
841.39231
</td>
<td style="text-align:right;">
9063
</td>
<td style="text-align:right;">
0.0928382
</td>
</tr>
<tr>
<td style="text-align:left;">
2022-12-19 20:43:33
</td>
<td style="text-align:right;">
488.788972
</td>
<td style="text-align:right;">
25.979132
</td>
<td style="text-align:right;">
1791
</td>
<td style="text-align:right;">
1819
</td>
<td style="text-align:right;">
0.2729140
</td>
<td style="text-align:right;">
0.0142821
</td>
<td style="text-align:right;">
0.99
</td>
<td style="text-align:right;">
298.1321
</td>
<td style="text-align:right;">
0.3042
</td>
<td style="text-align:right;">
514.76810
</td>
<td style="text-align:right;">
3610
</td>
<td style="text-align:right;">
0.1425950
</td>
</tr>
<tr>
<td style="text-align:left;">
2022-12-19 21:13:52
</td>
<td style="text-align:right;">
25.979132
</td>
<td style="text-align:right;">
47.145459
</td>
<td style="text-align:right;">
1819
</td>
<td style="text-align:right;">
1823
</td>
<td style="text-align:right;">
0.0142821
</td>
<td style="text-align:right;">
0.0258615
</td>
<td style="text-align:right;">
0.94
</td>
<td style="text-align:right;">
298.1321
</td>
<td style="text-align:right;">
0.3042
</td>
<td style="text-align:right;">
73.12459
</td>
<td style="text-align:right;">
3642
</td>
<td style="text-align:right;">
0.0200781
</td>
</tr>
<tr>
<td style="text-align:left;">
2022-12-19 21:44:15
</td>
<td style="text-align:right;">
47.145459
</td>
<td style="text-align:right;">
52.053787
</td>
<td style="text-align:right;">
1823
</td>
<td style="text-align:right;">
1822
</td>
<td style="text-align:right;">
0.0258615
</td>
<td style="text-align:right;">
0.0285696
</td>
<td style="text-align:right;">
1.07
</td>
<td style="text-align:right;">
298.1321
</td>
<td style="text-align:right;">
0.3042
</td>
<td style="text-align:right;">
99.19925
</td>
<td style="text-align:right;">
3645
</td>
<td style="text-align:right;">
0.0272152
</td>
</tr>
<tr>
<td style="text-align:left;">
2022-12-19 22:14:37
</td>
<td style="text-align:right;">
52.053787
</td>
<td style="text-align:right;">
70.671433
</td>
<td style="text-align:right;">
1822
</td>
<td style="text-align:right;">
1832
</td>
<td style="text-align:right;">
0.0285696
</td>
<td style="text-align:right;">
0.0385761
</td>
<td style="text-align:right;">
1.01
</td>
<td style="text-align:right;">
298.1321
</td>
<td style="text-align:right;">
0.3042
</td>
<td style="text-align:right;">
122.72522
</td>
<td style="text-align:right;">
3654
</td>
<td style="text-align:right;">
0.0335865
</td>
</tr>
<tr>
<td style="text-align:left;">
2022-12-19 22:45:09
</td>
<td style="text-align:right;">
70.671433
</td>
<td style="text-align:right;">
14.187779
</td>
<td style="text-align:right;">
1832
</td>
<td style="text-align:right;">
1792
</td>
<td style="text-align:right;">
0.0385761
</td>
<td style="text-align:right;">
0.0079173
</td>
<td style="text-align:right;">
0.90
</td>
<td style="text-align:right;">
298.1321
</td>
<td style="text-align:right;">
0.3042
</td>
<td style="text-align:right;">
84.85921
</td>
<td style="text-align:right;">
3624
</td>
<td style="text-align:right;">
0.0234159
</td>
</tr>
<tr>
<td style="text-align:left;">
2022-12-19 23:15:01
</td>
<td style="text-align:right;">
14.187779
</td>
<td style="text-align:right;">
21.754899
</td>
<td style="text-align:right;">
1792
</td>
<td style="text-align:right;">
1825
</td>
<td style="text-align:right;">
0.0079173
</td>
<td style="text-align:right;">
0.0119205
</td>
<td style="text-align:right;">
1.02
</td>
<td style="text-align:right;">
298.1321
</td>
<td style="text-align:right;">
0.3042
</td>
<td style="text-align:right;">
35.94268
</td>
<td style="text-align:right;">
3617
</td>
<td style="text-align:right;">
0.0099372
</td>
</tr>
<tr>
<td style="text-align:left;">
2022-12-19 23:45:26
</td>
<td style="text-align:right;">
21.754899
</td>
<td style="text-align:right;">
6.767783
</td>
<td style="text-align:right;">
1825
</td>
<td style="text-align:right;">
1828
</td>
<td style="text-align:right;">
0.0119205
</td>
<td style="text-align:right;">
0.0037023
</td>
<td style="text-align:right;">
0.93
</td>
<td style="text-align:right;">
298.1321
</td>
<td style="text-align:right;">
0.3042
</td>
<td style="text-align:right;">
28.52268
</td>
<td style="text-align:right;">
3653
</td>
<td style="text-align:right;">
0.0078080
</td>
</tr>
<tr>
<td style="text-align:left;">
2022-12-20 00:15:54
</td>
<td style="text-align:right;">
6.767783
</td>
<td style="text-align:right;">
50.326738
</td>
<td style="text-align:right;">
1828
</td>
<td style="text-align:right;">
1829
</td>
<td style="text-align:right;">
0.0037023
</td>
<td style="text-align:right;">
0.0275160
</td>
<td style="text-align:right;">
0.88
</td>
<td style="text-align:right;">
298.1321
</td>
<td style="text-align:right;">
0.3042
</td>
<td style="text-align:right;">
57.09452
</td>
<td style="text-align:right;">
3657
</td>
<td style="text-align:right;">
0.0156124
</td>
</tr>
<tr>
<td style="text-align:left;">
2022-12-20 00:46:23
</td>
<td style="text-align:right;">
50.326738
</td>
<td style="text-align:right;">
32.054889
</td>
<td style="text-align:right;">
1829
</td>
<td style="text-align:right;">
1821
</td>
<td style="text-align:right;">
0.0275160
</td>
<td style="text-align:right;">
0.0176029
</td>
<td style="text-align:right;">
0.83
</td>
<td style="text-align:right;">
298.1321
</td>
<td style="text-align:right;">
0.3042
</td>
<td style="text-align:right;">
82.38163
</td>
<td style="text-align:right;">
3650
</td>
<td style="text-align:right;">
0.0225703
</td>
</tr>
<tr>
<td style="text-align:left;">
2022-12-20 01:16:44
</td>
<td style="text-align:right;">
32.054889
</td>
<td style="text-align:right;">
1.176476
</td>
<td style="text-align:right;">
1821
</td>
<td style="text-align:right;">
1820
</td>
<td style="text-align:right;">
0.0176029
</td>
<td style="text-align:right;">
0.0006464
</td>
<td style="text-align:right;">
0.89
</td>
<td style="text-align:right;">
298.1321
</td>
<td style="text-align:right;">
0.3042
</td>
<td style="text-align:right;">
33.23136
</td>
<td style="text-align:right;">
3641
</td>
<td style="text-align:right;">
0.0091270
</td>
</tr>
<tr>
<td style="text-align:left;">
2022-12-20 01:47:04
</td>
<td style="text-align:right;">
1.176476
</td>
<td style="text-align:right;">
13.082054
</td>
<td style="text-align:right;">
1820
</td>
<td style="text-align:right;">
1824
</td>
<td style="text-align:right;">
0.0006464
</td>
<td style="text-align:right;">
0.0071722
</td>
<td style="text-align:right;">
0.78
</td>
<td style="text-align:right;">
298.1321
</td>
<td style="text-align:right;">
0.3042
</td>
<td style="text-align:right;">
14.25853
</td>
<td style="text-align:right;">
3644
</td>
<td style="text-align:right;">
0.0039129
</td>
</tr>
<tr>
<td style="text-align:left;">
2022-12-20 02:17:28
</td>
<td style="text-align:right;">
13.082054
</td>
<td style="text-align:right;">
34.113205
</td>
<td style="text-align:right;">
1824
</td>
<td style="text-align:right;">
1817
</td>
<td style="text-align:right;">
0.0071722
</td>
<td style="text-align:right;">
0.0187745
</td>
<td style="text-align:right;">
0.90
</td>
<td style="text-align:right;">
298.1321
</td>
<td style="text-align:right;">
0.3042
</td>
<td style="text-align:right;">
47.19526
</td>
<td style="text-align:right;">
3641
</td>
<td style="text-align:right;">
0.0129622
</td>
</tr>
<tr>
<td style="text-align:left;">
2022-12-20 02:47:45
</td>
<td style="text-align:right;">
34.113205
</td>
<td style="text-align:right;">
63.930251
</td>
<td style="text-align:right;">
1817
</td>
<td style="text-align:right;">
1820
</td>
<td style="text-align:right;">
0.0187745
</td>
<td style="text-align:right;">
0.0351265
</td>
<td style="text-align:right;">
1.02
</td>
<td style="text-align:right;">
298.1321
</td>
<td style="text-align:right;">
0.3042
</td>
<td style="text-align:right;">
98.04346
</td>
<td style="text-align:right;">
3637
</td>
<td style="text-align:right;">
0.0269572
</td>
</tr>
<tr>
<td style="text-align:left;">
2022-12-20 03:18:05
</td>
<td style="text-align:right;">
63.930251
</td>
<td style="text-align:right;">
17.112553
</td>
<td style="text-align:right;">
1820
</td>
<td style="text-align:right;">
1821
</td>
<td style="text-align:right;">
0.0351265
</td>
<td style="text-align:right;">
0.0093973
</td>
<td style="text-align:right;">
0.69
</td>
<td style="text-align:right;">
298.1321
</td>
<td style="text-align:right;">
0.3042
</td>
<td style="text-align:right;">
81.04280
</td>
<td style="text-align:right;">
3641
</td>
<td style="text-align:right;">
0.0222584
</td>
</tr>
<tr>
<td style="text-align:left;">
2022-12-20 03:48:26
</td>
<td style="text-align:right;">
17.112553
</td>
<td style="text-align:right;">
4.379435
</td>
<td style="text-align:right;">
1821
</td>
<td style="text-align:right;">
1825
</td>
<td style="text-align:right;">
0.0093973
</td>
<td style="text-align:right;">
0.0023997
</td>
<td style="text-align:right;">
0.82
</td>
<td style="text-align:right;">
298.1321
</td>
<td style="text-align:right;">
0.3042
</td>
<td style="text-align:right;">
21.49199
</td>
<td style="text-align:right;">
3646
</td>
<td style="text-align:right;">
0.0058947
</td>
</tr>
<tr>
<td style="text-align:left;">
2022-12-20 04:18:51
</td>
<td style="text-align:right;">
4.379435
</td>
<td style="text-align:right;">
21.261708
</td>
<td style="text-align:right;">
1825
</td>
<td style="text-align:right;">
1820
</td>
<td style="text-align:right;">
0.0023997
</td>
<td style="text-align:right;">
0.0116823
</td>
<td style="text-align:right;">
0.87
</td>
<td style="text-align:right;">
298.1321
</td>
<td style="text-align:right;">
0.3042
</td>
<td style="text-align:right;">
25.64114
</td>
<td style="text-align:right;">
3645
</td>
<td style="text-align:right;">
0.0070346
</td>
</tr>
<tr>
<td style="text-align:left;">
2022-12-20 04:49:11
</td>
<td style="text-align:right;">
21.261708
</td>
<td style="text-align:right;">
132.141634
</td>
<td style="text-align:right;">
1820
</td>
<td style="text-align:right;">
1822
</td>
<td style="text-align:right;">
0.0116823
</td>
<td style="text-align:right;">
0.0725256
</td>
<td style="text-align:right;">
0.99
</td>
<td style="text-align:right;">
298.1321
</td>
<td style="text-align:right;">
0.3042
</td>
<td style="text-align:right;">
153.40334
</td>
<td style="text-align:right;">
3642
</td>
<td style="text-align:right;">
0.0421206
</td>
</tr>
<tr>
<td style="text-align:left;">
2022-12-20 05:19:33
</td>
<td style="text-align:right;">
132.141634
</td>
<td style="text-align:right;">
2.665111
</td>
<td style="text-align:right;">
1822
</td>
<td style="text-align:right;">
1608
</td>
<td style="text-align:right;">
0.0725256
</td>
<td style="text-align:right;">
0.0016574
</td>
<td style="text-align:right;">
0.78
</td>
<td style="text-align:right;">
298.1321
</td>
<td style="text-align:right;">
0.3042
</td>
<td style="text-align:right;">
134.80674
</td>
<td style="text-align:right;">
3430
</td>
<td style="text-align:right;">
0.0393023
</td>
</tr>
</tbody>
</table>

## Applying the filters

Applying the HDOP threshold (uncalibrated data) or the VAR.xy threshold
(calibrated data):

``` r
critVARxy <- 5000
critHdop <- 2.5
toSupp <- list()
for (i in 1:length(rawList)) {
    calibrated <- names(rawList)[i] %in% namesCalib
    if (calibrated) {
        toSupp[[names(rawList)[i]]] <- data.frame(timestamp = errCrit[[names(rawList)[i]]]$timestamp,
            supp = errCrit[[names(rawList)[i]]]$VAR.xy > critVARxy)
    } else {
        toSupp[[names(rawList)[i]]] <- data.frame(timestamp = errCrit[[names(rawList)[i]]]$timestamp,
            supp = errCrit[[names(rawList)[i]]]$hdop > critHdop)

    }
}
```

``` r
stopifnot(mapply(function(x, y) {
    m <- match(x$moveData$timestamp, y$timestamp)
    all(m == 1:length(m))
}, rawList, toSupp))
```

Number of relocation to delete with these criteria

``` r
sapply(toSupp, function(x) sum(x$supp))
```

    ##          Zorro02          Zorro03          Zorro04          Zorro05 
    ##                0                0                0                0 
    ##          Zorro06          Zorro07     Guacharaca01     Guacharaca03 
    ##                0                0                0                0 
    ##       Phimosus01       Phimosus02           Pigua1       Zarigueya1 
    ##              310                0                8                0 
    ##       Zarigueya2       Zarigueya3       Zarigueya4       Phimosus04 
    ##              447                0                0                0 
    ##           Pigua2           Garza1        GarzaAve4       Zarigueya5 
    ##                0                0                0                3 
    ##           Pigua5     Guacharaca06         Ardilla1        GarzaAve2 
    ##                2               11                8               15 
    ##        GarzaAve3       Zarigueya6       Phimosus05       Phimosus07 
    ##               94                1                3                5 
    ##       Phimosus06       Zarigueya7     Guacharaca02      PavaGarza-4 
    ##                2                0                0                0 
    ##            Asio2       BuhoPigua6         Ardilla2  PavaGuacharaca5 
    ##                1                1                1                7 
    ##     Guacharaca04   PerezosoZorro1            Titi4       Phimosus03 
    ##                0                4                1                1 
    ## GuacharacaAsio-4       GarzaTiti3 
    ##                3                0

Percentage of data to delete with these criteria:

``` r
sapply(toSupp, function(x) sum(x$supp)/nrow(x)) * 100
```

    ##          Zorro02          Zorro03          Zorro04          Zorro05 
    ##        0.0000000        0.0000000        0.0000000        0.0000000 
    ##          Zorro06          Zorro07     Guacharaca01     Guacharaca03 
    ##        0.0000000        0.0000000        0.0000000        0.0000000 
    ##       Phimosus01       Phimosus02           Pigua1       Zarigueya1 
    ##       11.1751983        0.0000000        1.3490725        0.0000000 
    ##       Zarigueya2       Zarigueya3       Zarigueya4       Phimosus04 
    ##      100.0000000        0.0000000        0.0000000        0.0000000 
    ##           Pigua2           Garza1        GarzaAve4       Zarigueya5 
    ##        0.0000000        0.0000000        0.0000000        1.7647059 
    ##           Pigua5     Guacharaca06         Ardilla1        GarzaAve2 
    ##        0.1763668        1.8707483        7.6923077        0.6567426 
    ##        GarzaAve3       Zarigueya6       Phimosus05       Phimosus07 
    ##        6.7335244        0.9523810        0.2647838        0.4374453 
    ##       Phimosus06       Zarigueya7     Guacharaca02      PavaGarza-4 
    ##        0.1853568        0.0000000        0.0000000        0.0000000 
    ##            Asio2       BuhoPigua6         Ardilla2  PavaGuacharaca5 
    ##        0.3311258        0.9433962        0.4566210        1.9444444 
    ##     Guacharaca04   PerezosoZorro1            Titi4       Phimosus03 
    ##        0.0000000        8.8888889        0.3623188        0.6134969 
    ## GuacharacaAsio-4       GarzaTiti3 
    ##        2.4390244        0.0000000

The percentage is usually very low, but result in deleting all the data
in Zarigueya2, and a significant percentage of Phimosus01 and
PerezosoZorro1.

Additional to the criteria about global HDOP and VAR.xy values.

We will suppress the points when all these conditions are met:

- The speed is among the 5% highest
- The speed is superior to 15 m/s (54 km/h) for birds and 5 m/s (15-20
  km/h) for others
- The HDOP is among the 5% highest

``` r
propSpeed <- 0.95
propHdop <- 0.95
speedBird <- 15
speedOthers <- 5
for (i in 1:length(errCrit)) {
    A1 <- (rank(errCrit[[i]]$aver_speed_from_to) - 1)/nrow(errCrit[[i]]) >
        propSpeed
    if (grepl("Guacharaca", names(errCrit)[i]) | grepl("Phimosus", names(errCrit)[i]) |
        grepl("Pigua", names(errCrit)[i]) | grepl("Garza", names(errCrit)[i]) |
        grepl("Asio", names(errCrit)[i])) {
        B <- errCrit[[i]]$aver_speed_from_to > speedBird
    } else {
        B <- errCrit[[i]]$aver_speed_from_to > speedOthers
    }
    A2 <- (rank(errCrit[[i]]$hdop) - 1)/nrow(errCrit[[i]]) > propHdop
    toSupp[[i]]$supp <- toSupp[[i]]$supp | (!is.na(errCrit[[i]]$aver_speed_from_to) &
        A1 & B & A2)
}
```

Number of relocation to delete with these criteria

``` r
sapply(toSupp, function(x) sum(x$supp))
```

    ##          Zorro02          Zorro03          Zorro04          Zorro05 
    ##                0                1                0                1 
    ##          Zorro06          Zorro07     Guacharaca01     Guacharaca03 
    ##                0                2                0                0 
    ##       Phimosus01       Phimosus02           Pigua1       Zarigueya1 
    ##              310                0               10                0 
    ##       Zarigueya2       Zarigueya3       Zarigueya4       Phimosus04 
    ##              447                1                0                0 
    ##           Pigua2           Garza1        GarzaAve4       Zarigueya5 
    ##                0                0                0                3 
    ##           Pigua5     Guacharaca06         Ardilla1        GarzaAve2 
    ##                2               12                8               15 
    ##        GarzaAve3       Zarigueya6       Phimosus05       Phimosus07 
    ##               94                1                3                5 
    ##       Phimosus06       Zarigueya7     Guacharaca02      PavaGarza-4 
    ##                2                0                0                0 
    ##            Asio2       BuhoPigua6         Ardilla2  PavaGuacharaca5 
    ##                1                1                2                7 
    ##     Guacharaca04   PerezosoZorro1            Titi4       Phimosus03 
    ##                0                4                1                2 
    ## GuacharacaAsio-4       GarzaTiti3 
    ##                3                0

Percentage of data to delete with these criteria:

``` r
sapply(toSupp, function(x) sum(x$supp)/nrow(x)) * 100
```

    ##          Zorro02          Zorro03          Zorro04          Zorro05 
    ##        0.0000000        0.2024291        0.0000000        0.2272727 
    ##          Zorro06          Zorro07     Guacharaca01     Guacharaca03 
    ##        0.0000000        0.3952569        0.0000000        0.0000000 
    ##       Phimosus01       Phimosus02           Pigua1       Zarigueya1 
    ##       11.1751983        0.0000000        1.6863406        0.0000000 
    ##       Zarigueya2       Zarigueya3       Zarigueya4       Phimosus04 
    ##      100.0000000        0.2976190        0.0000000        0.0000000 
    ##           Pigua2           Garza1        GarzaAve4       Zarigueya5 
    ##        0.0000000        0.0000000        0.0000000        1.7647059 
    ##           Pigua5     Guacharaca06         Ardilla1        GarzaAve2 
    ##        0.1763668        2.0408163        7.6923077        0.6567426 
    ##        GarzaAve3       Zarigueya6       Phimosus05       Phimosus07 
    ##        6.7335244        0.9523810        0.2647838        0.4374453 
    ##       Phimosus06       Zarigueya7     Guacharaca02      PavaGarza-4 
    ##        0.1853568        0.0000000        0.0000000        0.0000000 
    ##            Asio2       BuhoPigua6         Ardilla2  PavaGuacharaca5 
    ##        0.3311258        0.9433962        0.9132420        1.9444444 
    ##     Guacharaca04   PerezosoZorro1            Titi4       Phimosus03 
    ##        0.0000000        8.8888889        0.3623188        1.2269939 
    ## GuacharacaAsio-4       GarzaTiti3 
    ##        2.4390244        0.0000000

Now we apply the filters on the raw data from movebank to create a
filtered dataset:

``` r
stopifnot(mapply(function(x, y) {
    m <- match(x$moveData$timestamp, y$timestamp)
    all(m == 1:length(m))
}, rawList, toSupp))
```

``` r
filteredList <- list()
for (i in names(toSupp)) {
    filteredList[[i]]$moveData <- rawList[[i]]$moveData[!toSupp[[i]]$supp]
    filteredList[[i]]$ctmmData <- subset(rawList[[i]]$ctmmData, !toSupp[[i]]$supp)
}
filteredList <- filteredList[sapply(filteredList, function(x) nrow(x$ctmmData) >
    0)]
```

## Saving the files for later use

``` r
save(filteredList, file = "filteredList.RData")
save(errCrit, file = "spatErrCrit.RData")
```
