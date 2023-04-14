# Using direcly the API (without dedicated R package) in order to extract unformatted and complete tag ids
require("httr")
myauth<-authenticate(user="Humboldt_AreaMetropolitana",password = passWord)
url<-paste0("https://www.movebank.org/movebank/service/direct-read?entity_type=tag&study_id=",as.character(study_id))
outFile<-tempfile()
A<-GET(url,config=myauth)
B<-content(A,as="text")
writeLines(B,con=outFile)
tag_from_api<-read.csv(file=outFile,colClasses="character",h=T,sep=",")
tracker<-tag_from_api[,c("id","local_identifier","serial_no")]
colnames(tracker)<-c("movebank_tag","supplier_id","serial")
tracker$movebank_tag<-as.numeric(tracker$movebank_tag)
tracker$model<-ifelse((grepl("^89012",tracker$supplier_id)|grepl("^89460",tracker$supplier_id))&nchar(tracker$supplier_id)>18,"ES-400","TGW-4570-4")
