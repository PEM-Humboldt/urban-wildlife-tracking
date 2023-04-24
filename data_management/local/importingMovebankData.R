require(move)
passWord <- read.csv("password.csv",h=F)[1,1]
lgin <- movebankLogin(username="Humboldt_AreaMetropolitana",password=passWord)
study_id<- getMovebankID("Rastreo fauna área metropolitana del Valle de Aburrá, Colombia",login=lgin)
refData <- getMovebankReferenceTable(study_id,lgin,allAttributes = T)
animals<-getMovebankAnimals(study_id,lgin)
mvData<-getMovebankData(study_id,animalName = animals$animalName ,login=lgin,includeOutliers=T)
mvData_clean <- getMovebankData(study_id,animalName = animals$animalName ,login=lgin,includeOutliers=F)
all(mvData_clean$tag_id%in%refData$tag_id)

