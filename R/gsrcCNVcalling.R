#!/bin/bash

##Install/load libraries
#source("https://bioconductor.org/biocLite.R")
#biocLite("illuminaio")
library(illuminaio)
#install.packages("gsrc")
library(gsrc)

##load PennCNV input file
filewpath<-"/Users/nickgiangreco/GitHub/Global_Screening_Arrays/files/pennTest2.txt"
#filewpath<-args[1]

file.df<-read.table(filewpath,sep="\t",header=T)

#making custom list to comply to
#"gsrc" cnv calling
#colnames(file.df)<-tolower(colnames(file.df))
#colnames(file.df)[5]<-"rratio"
dat<-list("snps" = c(),"chr" = c(), "pos" = c(), "baf" = c(), "rratio" = c(), "samples" = c(), "geno" = c())
dat$snps<-file.df$Name
dat$chr<-file.df$Chr
dat$pos<-file.df$Pos
dat$baf<-file.df$BAF
dat$rratio<-file.df$LRR
sample.name<-"Sample.1"
dat$samples<-sample.name
dat$geno<-file.df$Gtype

#call segments-makes cna
seg<-segm(dat)

#gsrc cnv calling-makes cnv
del<- -0.1
dup<-0.1
cnv.call<-cnv(seg,del=del,dup=dup) 

#Output to bedgraph
outDir<-"/files"
#outDir<-args[2]

#Parsing output
cna.bed<-data.frame("chr"=cnv.call$cna$chrom,"s"=cnv.call$cna$loc.start,"e"=cnv.call$cna$loc.end,
               "num.probes"=cnv.call$cna$num.mark,"avg.probe.val"=cnv.call$cna$seg.mean)
all.snp.bed<-data.frame("chr"=cnv.call$chr,"s"=cnv.call$pos,"geno"=cnv.call$geno,"state"=cnv.call$cnv)

chrs<-names(table(cna.bed$chr))
cna.bed$state<-"NULL"

for(i in chrs){
  all.snp.s<-sort(subset(all.snp.bed,chr==i)$s,decreasing=F)
  cna.bed.s<-sort(subset(cna.bed,chr==i)$s,decreasing=F)
  for(j in cna.bed.s){
    if(length(which(j < all.snp.s))>0)next
    inds.s<-which(j >= all.snp.s)
    for(k in 1:length(inds.s)){
      rn<-rownames(subset(cna.bed,chr==i)[inds.s,])
      cna.bed[rn,]<-all.snp.bed[rn,]$state
    }
  }
}

write.table(cna.bed,file=paste0(path,outDir,"/",sample.name,"_gsrcCNVcall.bed"),
            quote=F,row.names=F,col.names=F)
