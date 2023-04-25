Creating a local database of extra spatial data to be associated with
movement data
================
Marius Bottin
2023-04-24

- [Creating the database](#creating-the-database)
- [Administrative boundaries](#administrative-boundaries)
- [](#section)
- [Turning off the light and
  leaving](#turning-off-the-light-and-leaving)

In order to do analyses of movement data, it may be useful to have a
database running a spatial data-management system. Here I will use a
postgres database with the postgis extension (I run already various
databases with this setup on my computer). However, in most of the case,
you will find the spatialite extension of SQLite more adequate at the
scale of one study, particularly when all the analyses are made in a
single computer.

The main advantages of having a local database with spatial data are:

1.  all the data can be accessed from a same source, and in the same way
2.  you can control and check efficiently the projections used and the
    structure of the spatial data

------------------------------------------------------------------------

**Note**:

A large part of the extra data that we will use here are not yet public,
so I won’t be able to share them. When the files are public, the code
will include the downloading with wget, or sometimes directly in R. My
personal setup for this data consists in a folder called “uwt_data_repo”
which shares the same root as this repository. Local files are copied to
this folder.

------------------------------------------------------------------------

# Creating the database

In bash, if you have postgreSQL installed, one of the easiest solution
to create a database is:

``` bash
createdb move_extra_sp
```

Then, I recommend the use of
[pgpass](https://www.postgresql.org/docs/current/libpq-pgpass.html). I
mainly use it because I can connect to the database without sharing the
connection passwords here, but the fact that it avoids the need to enter
hosts and password without decreasing significantly the security of the
connection may be appealing to anyone.

Then we create the connection for accessing it from R:

``` r
extraSp <- dbConnect(drv = PostgreSQL(), dbname = "move_extra_sp")
# For avoiding setting the connection name in the SQL chunks:
knitr::opts_chunk$set(connection = extraSp)
```

We will check on the installation of the postgis extension and if
needed, install it

``` r
pgPostGIS(extraSp)
```

    ## PostGIS extension version 3.1.8 installed.

    ## [1] TRUE

Now for the postgis_raster extension:

``` r
ext <- dbGetQuery(conn = extraSp, "SELECT * FROM pg_available_extensions;")
if (is.na(ext[ext$name == "postgis_raster", "installed_version"])) {
    dbSendQuery(extraSp, "CREATE EXTENSION postgis_raster")
}
```

Finally, we will create a schema to put all the raw data:

``` r
if (!"rawdata" %in% dbGetQuery(extraSp, "SELECT schema_name FROM information_schema.schemata")$schema_name) {
    dbSendQuery(extraSp, "CREATE SCHEMA rawdata;")
}
```

# Administrative boundaries

It is always useful to have access to administrative boundaries from the
country you are working in. [GADM](https://gadm.org/) is an opensource
initiative which allows to download this kind of data. In R, it is
directly available through the
[geodata](https://github.com/rspatial/geodata/) package.

Let’s download the data in a temporary folder and insert it in its raw
form in the database:

``` r
tmp <- tempdir()
municipios <- as(gadm("Colombia", level = 2, path = tmp), "Spatial")
pgInsert(extraSp, c("rawdata", "municipios"), municipios, geom = "the_geom",
    overwrite = T)
```

    ## [1] TRUE

``` sql
CREATE TABLE mpio
(
    mpio_id smallserial PRIMARY KEY,
    country varchar(3) NOT NULL,
    dept text NOT NULL,
    mpio text NOT NULL,
    mpio_syno TEXT[]
);
SELECT AddGeometryColumn ('public','mpio','the_geom',4326,'MULTIPOLYGON',2);
CREATE INDEX idx_mpio_the_geom ON mpio USING GIST(the_geom);
INSERT INTO mpio(country,dept,mpio,mpio_syno,the_geom)
SELECT "GID_0","NAME_1", "NAME_2",STRING_TO_ARRAY("VARNAME_2",'|'),the_geom
FROM rawdata.municipios
ORDER BY "NAME_1","NAME_2"
RETURNING mpio.dept, mpio.mpio, mpio.mpio_syno;
```

# 

# Turning off the light and leaving

``` r
dbDisconnect(extraSp)
```

    ## [1] TRUE
