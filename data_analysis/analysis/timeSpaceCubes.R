require(rgl)
require(move)
load("../../data_management/local/filteredList.RData")
load("../../data_management/local/list_dateTime.RData")


ptTimes<-list_dateTime$Pigua2$time_s
ptTimeStamps<- list_dateTime$Pigua2$timestamp
timeLags<-timeLag(filteredList$Pigua2$moveData,"secs")

timesThresh<-c(0,4.5*3600,7*3600,12*3600,17*3600,19.5*3600,24*3600)
periods<-factor(c("Late night","Dawn","Morning","Afternoon","Dusk","Early night"),levels=c("Late night","Dawn","Morning","Afternoon","Dusk","Early night"),ordered=T)
stopifnot(length(timesThresh)==(length(periods)+1))
periodTab<-data.frame(begin=timesThresh[1:(length(timesThresh)-1)],
                      end=timesThresh[2:length(timesThresh)])
rownames(periodTab)<-periods
periodPt<-periods[findInterval(ptTimes,timesThresh)]
liTime<-data.frame(begin=ptTimes[1:(length(ptTimes)-1)],
                   end=ptTimes[2:length(ptTimes)],
                   more1day=timeLags>24*3600)
liTime$passMidnight<-liTime$more1day|(liTime$end<liTime$begin)
perLi<-factor(rep(NA,nrow(liTime)),levels=levels(periods))
for(i in 1:nrow(liTime))
{
  if(liTime$more1day[i]){
    majPerLi<-NA
  }else{
    b<-as.numeric(c(periodPt[i]))
    e<-as.numeric(c(periodPt[i+1]))
    if(liTime$passMidnight[i])
    {concerned<-periods[c(b:nlevels(periods),1:e)]}else{concerned<-periods[b:e]}
    if(length(concerned)==1){majPerLi<-concerned}
    if(length(concerned)==2)
    {
      majPerLi<-concerned[which.max(
        c(periodTab$end[concerned[1]]-liTime$begin[i],
          liTime$end[i] - periodTab$begin[concerned[2]])
        )]
    }
    if(length(concerned)==3){majPerLi<-concerned[2]}
    if(length(concerned)>3){majPerLi<-NA}
  }
  perLi[i]<-majPerLi
}
        
data.frame(ts_beg=ptTimeStamps[1:(length(ptTimeStamps)-1)],
           ts_end=ptTimeStamps[2:length(ptTimeStamps)],
           ptTime_beg=ptTimes[1:(length(ptTimes)-1)],
           ptTime_end=ptTimes[2:length(ptTimes)],
           perLi
           )



# 
ColLi<-c("black","orange","lightgreen","seagreen","orangered","gray22")[perLi]
ColLi[is.na(ColLi)]<-"grey"
ColPt<-c("black","orange","lightgreen","seagreen","orangered","gray22")[periodPt]
spPtsList<-lapply(filteredList,function(x)move2ade(x$moveData))
spLinList<-lapply(spPtsList,as,"SpatialLines")
plot3d(x=filteredList$Pigua2$moveData$location_long,
       y=filteredList$Pigua2$moveData$location_lat,
       z=filteredList$Pigua2$moveData$timestamp,
      type="p",col=ColPt,decorate = F
)
ColRep<-rep(NA,length(filteredList$Pigua2$moveData$location_long)*2)
ColRep<-c(NA,rep(ColLi,each=2),NA)
plot3d(x=rep(filteredList$Pigua2$moveData$location_long,each=2),
           y=rep(filteredList$Pigua2$moveData$location_lat,each=2),
           z=rep(filteredList$Pigua2$moveData$timestamp,each=2),
           col =ColRep,type="l",add=T)
axis3d("x--")
axis3d("y--")
zval<-as.numeric(filteredList$Pigua2$moveData$timestamp)
AT=seq(min(zval),max(zval),length.out=5)
LABELS<-as.Date(as.POSIXct(AT,origin="1970-01-01",tz="GMT"))
axis3d("z--",at=AT,labels=LABELS)

rglwidget()
