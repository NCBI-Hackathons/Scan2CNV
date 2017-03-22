#!/opt/R-3.3.1/bin/R

#####INPUT#####
#1. pennCNV input file name with full path
#2. output directory
########## 

args <- commandArgs(TRUE)
#args<-c("/Users/nickgiangreco/GitHub/Global_Screening_Arrays/files","/Users/nickgiangreco/GitHub/Global_Screening_Arrays/files")

##Install/load libraries
#source("https://bioconductor.org/biocLite.R")
#biocLite("illuminaio")
library(illuminaio)
#install.packages("gsrc")
library(gsrc)

##load PennCNV input file
#filewpath<-"/Users/nickgiangreco/GitHub/Global_Screening_Arrays/files/pennTest2.txt"
files<-list.files(path=args[1],pattern="*PennCNV*",full.names=T)
filenames<-list.files(path=args[1],pattern="*PennCNV*",full.names=F)
for(f in 1:length(files)){

#assigning file with full path
filewpath<-files[f]

#setting sample name from file name
tmp<-filenames[f]
sample.name<-unlist(strsplit(tmp,"\\."))[1]

#reading file
file.df<-read.delim(filewpath,sep="\t",header=T)

#making custom list to comply to
#"gsrc" cnv calling
#colnames(file.df)<-tolower(colnames(file.df))
#colnames(file.df)[5]<-"rratio"
dat<-list("snps" = c(),"chr" = c(), "pos" = c(), "baf" = c(), "rratio" = c(), "samples" = c(), "geno" = c())
dat$snps<-file.df$Name
dat$chr<-file.df$Chr
dat$pos<-file.df$Position
dat$baf<-matrix(file.df$B.Allele.Freq)
dat$rratio<-matrix(file.df$Log.R.Ratio)
dat$samples<-sample.name
dat$geno<-file.df$Gtype

#call segments-makes cna
seg<-segm(dat)

#gsrc cnv calling-makes cnv
del<- -0.1
dup<-0.1
cnv.call<-cnv(seg,del=del,dup=dup) 

#Output to bedgraph
#outDir<-"/Users/nickgiangre/GitHub/Gobal_Screening_Arrays/files/output"
outDir<-args[2]

#Making data frames
cna.bed<-data.frame("chr"=cnv.call$cna$chrom,"s"=cnv.call$cna$loc.start,"e"=cnv.call$cna$loc.end,
               "num.probes"=cnv.call$cna$num.mark,"avg.probe.val"=cnv.call$cna$seg.mean)
#all.snp.bed<-data.frame("chr"=cnv.call$chr,"s"=cnv.call$pos,"geno"=cnv.call$geno,"state"=cnv.call$cnv)

#assigning cnv state from individual probes to regions
# chrs<-names(table(cna.bed$chr))
# cna.bed$state<-"NULL"
# for(i in chrs){
#   #cat("\n",i)
#   #get regions and probes in chromosome
#   sub.cna.bed<-subset(cna.bed,chr==i)
#   st<-sub.cna.bed$s
#   en<-sub.cna.bed$e
#   #cat("\n\t",length(st))
#   #then looping for each cna start
#   for(j in 1:length(st)){
#     rn<-rownames(subset(sub.cna.bed, chr==i & s==s[j]))
#     states<-subset(all.snp.bed, chr==i & s >= st[j] & s <= en[j])$state
#     if(mean(states)%%1==0 | length(states)==0){
#       cna.bed[rn,"state"]<-0}else{
#         cna.bed[rn,"state"]<-states[1]}
#   }
# }
#OR
cna.bed$state<-"NULL"
del<- -0.1
dup<-0.1
for(i in 1:nrow(cna.bed)){
  valtmp<-cna.bed[i,"avg.probe.val"]
  val<-ifelse(valtmp<del,-1,ifelse(valtmp>dup,1,0))
  cna.bed[i,"state"]<-val
}

#Output
write.table(cna.bed,file=paste0(outDir,"/",sample.name,"_gsrcCNVcall.bed"),
            quote=F,row.names=F,col.names=F)
}
