# In this file, we will define the functions which are useful to manage the Periods Of Days (Day, Night, Dusk, Down etc)

# Intervals ----
# A first thing to do is to define the functions to compare non overlapping intervals:
# Surprisingly there is no functions in base R package to manage efficiently such intervals
# On the long term the real solution consist in creating a S4 class for non-overlapping auto-following integer intervals, but right now we will simply


begInt<-function(vecThresh){
  return(vecThresh[1:(length(vecThresh)-1)])
}
endInt<-function(vecThresh,exclEnd=F){
  return(vecThresh[2:length(vecThresh)]-ifelse(exclEnd,1,0))
}

# The %ins% operator gives a table as whether the x intervals are contained in the y intervals
'%cont%' <- function(x,y){
  as.table(matrix(
    rep(begInt(x),length(begInt(y)))>=rep(begInt(y),each=length(begInt(x)))&
    rep(endInt(x),length(endInt(y)))<=rep(endInt(y),each=length(endInt(x))),
    nrow=length(x)-1,
    ncol=length(y)-1,
    byrow = F,
    dimnames=list(
       paste0("[",begInt(x),",",endInt(x),"]"),
       paste0("[",begInt(y),",",endInt(y),"]"))
    ))
}

# The %o% operator gives a table of whether the x intervals overlap the y intervals 
'%o%' <- function(x,y){
  as.table(matrix(
    rep(begInt(x),length(begInt(y)))<=rep(endInt(y),each=length(begInt(x)))&
      rep(endInt(x),length(endInt(y)))>=rep(begInt(y),each=length(endInt(x))),
    nrow=length(x)-1,
    ncol=length(y)-1,
    byrow = F,
    dimnames=list(
       paste0("[",begInt(x),",",endInt(x),"]"),
       paste0("[",begInt(y),",",endInt(y),"]"))
    ))
}

overlaps_ln <- function(x,y)
{
  tabO<-x %o% y
  w<-which(tabO,arr.ind=T)
  bX<-begInt(x)
  bY<-begInt(y)
  eX<-endInt(x)
  eY<-endInt(y)
  res<-matrix(0,nrow=length(x)-1,ncol=length(y)-1,dimnames = dimnames(tabO))
  res[w]<-apply(cbind(eX[w[,"row"]],eY[w[,"col"]]),1,min)-apply(cbind(bX[w[,"row"]],bY[w[,"col"]]),1,max)
  return(res)
}

# definitions Periods of Day ----
require(lubridate)

# Extract period of day for punctual measures
extract_ptPOD <- function(ts, times = c("00:00:00", "04:30:00", "07:00:00","12:00:00", "17:00:00", "19:30:00", "23:59:59"), POD = c("Late night", "Dawn", "Morning", "Afternoon", "Dusk", "Early night"))
{
  stopifnot(length(POD) == (length(times)-1))
  ts_time_s<-as.numeric(ts)-as.numeric(as.POSIXct(paste(as.Date(ts,tz = tz(ts)),"00:00:00"),tz=tz(ts)))
  times_s <- as.numeric(as.POSIXct(paste("1970-01-01",times),tz="GMT"))
  return(factor(POD[findInterval(ts_time_s,times_s)],levels=unique(POD)))
}

# Extract period of day for timestamp intervals (entered as just the timestamps, the results concern the intervals between timestamps)
extract_liPOD <- function(ts, times = c("00:00:00", "04:30:00", "07:00:00","12:00:00", "17:00:00", "19:30:00", "23:59:59"), POD = c("Late night", "Dawn", "Morning", "Afternoon", "Dusk", "Early night"), maxIntOverl = 3)
{
  stopifnot(length(POD) == (length(times)-1))
  dates <- as.Date(ts)
  r_dates <- range(dates)
  thresh <- as.numeric(as.POSIXct(
    paste(rep(as.Date(r_dates[1]:r_dates[2],origin="1970-01-01") ,each=length(times)-1),
          rep(times[-length(times)],(r_dates[2]-r_dates[1])+1))))
  POD_lev<-rep(POD,(r_dates[2]-r_dates[1])+1)
  ts_s <- as.numeric(ts)
  res<-POD_lev[apply(overlaps_ln(ts_s,thresh),1,which.max)]
  res[rowSums(ts_s %o% thresh) > maxIntOverl]<-NA
  return(factor(res,levels = unique(POD)))
}