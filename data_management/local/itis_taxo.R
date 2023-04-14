# taxonomic information from Itis:
require(ritis)
taxa<-unique(animals$taxon_canonical_name)
taxa<-taxa[taxa!=""]
tsn<-mapply(function(tab,tax)tab[which(tab$combinedName==tax),"tsn"],lapply(taxa,search_scientific),taxa)
taxSup<-lapply(tsn,hierarchy_full)
taxo<-data.frame(scientific_name=taxa,
           kingdom=unlist(sapply(taxSup,function(x)x[x$rankname=="Kingdom","taxonname"])),
           phylum=unlist(sapply(taxSup,function(x)x[x$rankname=="Phylum","taxonname"])),
           class=unlist(sapply(taxSup,function(x)x[x$rankname=="Class","taxonname"])),
           order=unlist(sapply(taxSup,function(x)x[x$rankname=="Order","taxonname"])),
           family=unlist(sapply(taxSup,function(x)x[x$rankname=="Family","taxonname"])),
           genus=unlist(sapply(taxSup,function(x)x[x$rankname=="Genus","taxonname"])),
           specific_epithet=sapply(strsplit(taxa," "),function(x)x[2]),
           tsn=unlist(tsn)
)
taxo<-rbind(taxo,data.frame(scientific_name="Ortalis columbiana",kingdom="Animalia",phylum="Chordata",class="Aves",order="Galliformes",family="Cracidae",genus="Ortalis",specific_epithet="columbiana",tsn=NA))
