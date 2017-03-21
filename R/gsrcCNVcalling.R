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

#call segments
seg<-segm(dat)

#gsrc cnv calling
del<- -0.1
dup<-0.1
cnv.call<-cnv(seg,del=del,dup=dup) 

#Output to bedgraph
outDir<-"/files"
#outDir<-args[2]
bed<-cnv.call$cna[,c("chrom","loc.start","loc.end","num.mark","seg.mean")]
write.table(bed,file=paste0(path,outDir,"/",sample.name,"_gsrcCNVcall.bed"),
            quote=F,row.names=F,col.names=F)
