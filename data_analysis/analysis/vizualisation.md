Visual analysis of relocation and trajectory data
================
Marius Bottin
2023-05-02

- [1 Loading filtered data](#1-loading-filtered-data)
- [2 Basic maps of relocations](#2-basic-maps-of-relocations)
  - [2.1 With leaflet](#21-with-leaflet)
    - [2.1.1 Ardilla1](#211-ardilla1)
    - [2.1.2 Ardilla2](#212-ardilla2)
    - [2.1.3 Asio2](#213-asio2)
    - [2.1.4 BuhoPigua6](#214-buhopigua6)
    - [2.1.5 Garza1](#215-garza1)
    - [2.1.6 GarzaAve2](#216-garzaave2)
    - [2.1.7 GarzaAve3](#217-garzaave3)
    - [2.1.8 GarzaAve4](#218-garzaave4)
    - [2.1.9 GarzaTiti3](#219-garzatiti3)
    - [2.1.10 Guacharaca01](#2110-guacharaca01)
    - [2.1.11 Guacharaca02](#2111-guacharaca02)
    - [2.1.12 Guacharaca03](#2112-guacharaca03)
    - [2.1.13 Guacharaca04](#2113-guacharaca04)
    - [2.1.14 Guacharaca06](#2114-guacharaca06)
    - [2.1.15 GuacharacaAsio-4](#2115-guacharacaasio-4)
    - [2.1.16 PavaGarza-4](#2116-pavagarza-4)
    - [2.1.17 PavaGuacharaca5](#2117-pavaguacharaca5)
    - [2.1.18 PerezosoZorro1](#2118-perezosozorro1)
    - [2.1.19 Phimosus01](#2119-phimosus01)
    - [2.1.20 Phimosus02](#2120-phimosus02)
    - [2.1.21 Phimosus03](#2121-phimosus03)
    - [2.1.22 Phimosus04](#2122-phimosus04)
    - [2.1.23 Phimosus05](#2123-phimosus05)
    - [2.1.24 Phimosus06](#2124-phimosus06)
    - [2.1.25 Phimosus07](#2125-phimosus07)
    - [2.1.26 Pigua1](#2126-pigua1)
    - [2.1.27 Pigua2](#2127-pigua2)
    - [2.1.28 Pigua5](#2128-pigua5)
    - [2.1.29 Titi4](#2129-titi4)
    - [2.1.30 Zarigueya1](#2130-zarigueya1)
    - [2.1.31 Zarigueya3](#2131-zarigueya3)
    - [2.1.32 Zarigueya4](#2132-zarigueya4)
    - [2.1.33 Zarigueya5](#2133-zarigueya5)
    - [2.1.34 Zarigueya6](#2134-zarigueya6)
    - [2.1.35 Zarigueya7](#2135-zarigueya7)
    - [2.1.36 Zorro02](#2136-zorro02)
    - [2.1.37 Zorro03](#2137-zorro03)
    - [2.1.38 Zorro04](#2138-zorro04)
    - [2.1.39 Zorro05](#2139-zorro05)
    - [2.1.40 Zorro06](#2140-zorro06)
    - [2.1.41 Zorro07](#2141-zorro07)
    - [2.1.42 Conclusion `leaflet`](#2142-conclusion-leaflet)

# 1 Loading filtered data

We first load the filtered object containing the data in the `ctmm` and
`move` formats, which was created in
[outliers.Rmd](../../data_management/local/outliers.md)

``` r
load("../../data_management/local/filteredList.RData")
```

# 2 Basic maps of relocations

## 2.1 With leaflet

The map of points and lines with `leaflet` is created that way:

``` r
llMaps <- lapply(filteredList, function(x) {
    A <- move2ade(x$moveData)
    res <- leaflet(A) %>%
        addProviderTiles("Esri.WorldImagery") %>%
        addPolylines(data = as(A, "SpatialLines")) %>%
        addCircleMarkers(radius = 1, color = "red", fill = "red")
    return(res)
})
```

### 2.1.1 Ardilla1

``` r
llMaps$Ardilla1
```

![](Fig/visu_unnamed-chunk-3-1.jpeg)<!-- -->

### 2.1.2 Ardilla2

``` r
llMaps$Ardilla2
```

![](Fig/visu_unnamed-chunk-4-1.jpeg)<!-- -->

### 2.1.3 Asio2

``` r
llMaps$Asio2
```

![](Fig/visu_unnamed-chunk-5-1.jpeg)<!-- -->

### 2.1.4 BuhoPigua6

``` r
llMaps$BuhoPigua6
```

![](Fig/visu_unnamed-chunk-6-1.jpeg)<!-- -->

### 2.1.5 Garza1

``` r
llMaps$Garza1
```

![](Fig/visu_unnamed-chunk-7-1.jpeg)<!-- -->

### 2.1.6 GarzaAve2

``` r
llMaps$GarzaAve2
```

![](Fig/visu_unnamed-chunk-8-1.jpeg)<!-- -->

### 2.1.7 GarzaAve3

``` r
llMaps$GarzaAve3
```

![](Fig/visu_unnamed-chunk-9-1.jpeg)<!-- -->

### 2.1.8 GarzaAve4

``` r
llMaps$GarzaAve4
```

![](Fig/visu_unnamed-chunk-10-1.jpeg)<!-- -->

### 2.1.9 GarzaTiti3

``` r
llMaps$GarzaTiti3
```

![](Fig/visu_unnamed-chunk-11-1.jpeg)<!-- -->

### 2.1.10 Guacharaca01

``` r
llMaps$Guacharaca01
```

![](Fig/visu_unnamed-chunk-12-1.jpeg)<!-- -->

### 2.1.11 Guacharaca02

``` r
llMaps$Guacharaca02
```

![](Fig/visu_unnamed-chunk-13-1.jpeg)<!-- -->

### 2.1.12 Guacharaca03

``` r
llMaps$Guacharaca03
```

![](Fig/visu_unnamed-chunk-14-1.jpeg)<!-- -->

### 2.1.13 Guacharaca04

``` r
llMaps$Guacharaca04
```

![](Fig/visu_unnamed-chunk-15-1.jpeg)<!-- -->

### 2.1.14 Guacharaca06

``` r
llMaps$Guacharaca06
```

![](Fig/visu_unnamed-chunk-16-1.jpeg)<!-- -->

### 2.1.15 GuacharacaAsio-4

``` r
llMaps$`GuacharacaAsio-4`
```

![](Fig/visu_unnamed-chunk-17-1.jpeg)<!-- -->

### 2.1.16 PavaGarza-4

``` r
llMaps$`PavaGarza-4`
```

![](Fig/visu_unnamed-chunk-18-1.jpeg)<!-- -->

### 2.1.17 PavaGuacharaca5

``` r
llMaps$PavaGuacharaca5
```

![](Fig/visu_unnamed-chunk-19-1.jpeg)<!-- -->

### 2.1.18 PerezosoZorro1

``` r
llMaps$PerezosoZorro1
```

![](Fig/visu_unnamed-chunk-20-1.jpeg)<!-- -->

### 2.1.19 Phimosus01

``` r
llMaps$Phimosus01
```

![](Fig/visu_unnamed-chunk-21-1.jpeg)<!-- -->

### 2.1.20 Phimosus02

``` r
llMaps$Phimosus02
```

![](Fig/visu_unnamed-chunk-22-1.jpeg)<!-- -->

### 2.1.21 Phimosus03

``` r
llMaps$Phimosus03
```

![](Fig/visu_unnamed-chunk-23-1.jpeg)<!-- -->

### 2.1.22 Phimosus04

``` r
llMaps$Phimosus04
```

![](Fig/visu_unnamed-chunk-24-1.jpeg)<!-- -->

### 2.1.23 Phimosus05

``` r
llMaps$Phimosus05
```

![](Fig/visu_unnamed-chunk-25-1.jpeg)<!-- -->

### 2.1.24 Phimosus06

``` r
llMaps$Phimosus06
```

![](Fig/visu_unnamed-chunk-26-1.jpeg)<!-- -->

### 2.1.25 Phimosus07

``` r
llMaps$Phimosus07
```

![](Fig/visu_unnamed-chunk-27-1.jpeg)<!-- -->

### 2.1.26 Pigua1

``` r
llMaps$Pigua1
```

![](Fig/visu_unnamed-chunk-28-1.jpeg)<!-- -->

### 2.1.27 Pigua2

``` r
llMaps$Pigua2
```

![](Fig/visu_unnamed-chunk-29-1.jpeg)<!-- -->

### 2.1.28 Pigua5

``` r
llMaps$Pigua5
```

![](Fig/visu_unnamed-chunk-30-1.jpeg)<!-- -->

### 2.1.29 Titi4

``` r
llMaps$Titi4
```

![](Fig/visu_unnamed-chunk-31-1.jpeg)<!-- -->

### 2.1.30 Zarigueya1

``` r
llMaps$Zarigueya1
```

![](Fig/visu_unnamed-chunk-32-1.jpeg)<!-- -->

### 2.1.31 Zarigueya3

``` r
llMaps$Zarigueya3
```

![](Fig/visu_unnamed-chunk-33-1.jpeg)<!-- -->

### 2.1.32 Zarigueya4

``` r
llMaps$Zarigueya4
```

![](Fig/visu_unnamed-chunk-34-1.jpeg)<!-- -->

### 2.1.33 Zarigueya5

``` r
llMaps$Zarigueya5
```

![](Fig/visu_unnamed-chunk-35-1.jpeg)<!-- -->

### 2.1.34 Zarigueya6

``` r
llMaps$Zarigueya6
```

![](Fig/visu_unnamed-chunk-36-1.jpeg)<!-- -->

### 2.1.35 Zarigueya7

``` r
llMaps$Zarigueya7
```

![](Fig/visu_unnamed-chunk-37-1.jpeg)<!-- -->

### 2.1.36 Zorro02

``` r
llMaps$Zorro02
```

![](Fig/visu_unnamed-chunk-38-1.jpeg)<!-- -->

### 2.1.37 Zorro03

``` r
llMaps$Zorro03
```

![](Fig/visu_unnamed-chunk-39-1.jpeg)<!-- -->

### 2.1.38 Zorro04

``` r
llMaps$Zorro04
```

![](Fig/visu_unnamed-chunk-40-1.jpeg)<!-- -->

### 2.1.39 Zorro05

``` r
llMaps$Zorro05
```

![](Fig/visu_unnamed-chunk-41-1.jpeg)<!-- -->

### 2.1.40 Zorro06

``` r
llMaps$Zorro06
```

![](Fig/visu_unnamed-chunk-42-1.jpeg)<!-- -->

### 2.1.41 Zorro07

``` r
llMaps$Zorro07
```

![](Fig/visu_unnamed-chunk-43-1.jpeg)<!-- -->

### 2.1.42 Conclusion `leaflet`

`leaflet` gives us the possibility to observe the relocations and
trajectory on a satellite basemap. Moreover, when applied on a local
machine, it is possible to zoom into the map to see details. However,
when a lot of points and lines are overlapping, it is quite difficult to
distinguish the movement and to extrapolate some patterns out of the
maps
