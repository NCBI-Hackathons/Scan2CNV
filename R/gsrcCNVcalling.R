#!/usr/bin/Rscript

#####INPUT#####
#1. pennCNV input file name with full path
#2. output txt
#3 output bed
########## 

args <- commandArgs(TRUE)
library(illuminaio)
library(gsrc)

filewpath <- args[1]
out_txt <- args[2]
out_bed <- args[3]

sample.name<-unlist(strsplit(filewpath,"\\."))[1]


#reading file
file.df<-read.delim(filewpath,sep="\t",header=T)

#making custom list to comply to
#"gsrc" cnv calling
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
del <- -0.1
dup <- 0.1
cnv.call<-cnv(seg,del=del,dup=dup) 

#Output to bedgraph
#outDir<-"/Users/nickgiangre/GitHub/Gobal_Screening_Arrays/files/output"
outDir<-args[2]

#Making data frames
cna.bed<-data.frame("chr"=cnv.call$cna$chrom,"s"=cnv.call$cna$loc.start,"e"=cnv.call$cna$loc.end,
               "num.probes"=cnv.call$cna$num.mark,"avg.probe.val"=cnv.call$cna$seg.mean)
cna.bed$state<-"NULL"
del <- -0.1
dup <- 0.1
for(i in 1:nrow(cna.bed)){
  valtmp<-cna.bed[i,"avg.probe.val"]
  val<-ifelse(valtmp<del,-1,ifelse(valtmp>dup,1,0))
  cna.bed[i,"state"]<-val
}

#Output
write.table(cna.bed, file = out_txt, quote=F, row.names=F, col.names=T)
write.table(cbind(cna.bed[,1:3], cna.bed[,6]),file = out_bed, quote=F, row.names=F,col.names=F)

