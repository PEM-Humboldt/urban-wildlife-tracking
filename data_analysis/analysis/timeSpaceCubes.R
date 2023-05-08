require(rgl)
require(move)
load("../../data_management/local/filteredList.RData")
source("functions_PeriodOfDay.R")

# Repeat point colors for lines----
# The plots from rgl allow to set colors of the points, not the colors of the lines between points...
# As a fix, it is possible to repeat each points twice, and to define for each point and the following the colors of the lines
pointRep<-function(x){return(rep(x,each=2))}

colRep<-function(colLines){return(c(NA,rep(colLines,each=2),NA))}

# Function for POD 3D rgl plot of a `move` object ----

POD_plot3d <- function(mvData, 
                       times = c("00:00:00", "04:30:00", "07:00:00","12:00:00", "17:00:00", "19:30:00", "23:59:59"),
                       POD = c("Late night", "Dawn", "Morning", "Afternoon", "Dusk", "Early night"),
                       COL = c("black","orange","lightgreen","seagreen","orangered","gray22"),
                       COL_NA = "grey",
                       makePlot=F)
{
  ptPOD <- extract_ptPOD(timestamps(mvData), times=times, POD = POD)
  liPOD <- extract_liPOD(timestamps(mvData), times=times, POD = POD)
  colPt <- COL[ptPOD]
  colLi <- COL[liPOD]
  colPt[is.na(colPt)] <- COL_NA
  colLi[is.na(colLi)] <- COL_NA
  plot3d(x=mvData$location_long, y = mvData$location_lat, z = timestamps(mvData), decorate=F, col=colPt)
  plot3d(x=pointRep(mvData$location_long), y = pointRep(mvData$location_lat), z = pointRep(timestamps(mvData)),
           col = colRep(colLi),type="l",add=T)
  axis3d("x--")
  axis3d("y--")
  zval<-as.numeric(timestamps(mvData))
  AT=seq(min(zval),max(zval),length.out=5)
  LABELS<-as.Date(as.POSIXct(AT,origin="1970-01-01",tz="GMT"))
  axis3d("z--",at=AT,labels=LABELS)
  return(scene3d())
}

# Apply to all animals and save the "scenes"----
scene3d_POD <- lapply(filteredList,function(x) POD_plot3d(x$moveData))
save(scene3d_POD,file="scene3d_POD.RData")

#Save the html widgets in html widgets ----
require(htmlwidgets)
for(i in 1:length(scene3d_POD))
{
  saveWidget(rglwidget(scene3d_POD[[i]]),file=paste0("html_widgets/POD/",names(scene3d_POD)[[i]],".html"),selfcontained = T, title=names(scene3d_POD)[[i]])
}

# save snapshots in png files ----
for(i in 1:length(scene3d_POD))
{
  snapshot3d(filename=paste0("Fig/POD3d_",names(scene3d_POD)[i],".png"), scene = scene3d_POD[[i]],webshot=F)
}
