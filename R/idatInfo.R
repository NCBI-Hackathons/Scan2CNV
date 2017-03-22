#libraries
load(illuminaio)

#list idats
idatDir<-"/Users/nickgiangreco/GitHub/Global_Screening_Arrays/files/"
idatFiles<-list.files(path=idatDir,pattern="*.idat",full.names = T)
idatFileNames<-list.files(path=idatDir,pattern="*.idat",full.names = F)

#read idats
idats<-vector(mode="list",length=length(idatFiles))
for(i in 1:length(idatFiles)){
  idats[[i]]<-readIDAT(idatFiles[i])
}
names(idats)<-idatFileNames
#parse file info
cat("Types of info:")
names(idats$`201274980046_R04C02_Grn.idat`)


#data frame output of idat file and info
df<-data.frame(
          "File"=names(idats),
          "Chip.Type"=sapply(idats,function(x){x$ChipType}),
          row.names=NULL
)