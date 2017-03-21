#!/bin/bash

##Install/load libraries
#source("https://bioconductor.org/biocLite.R")
#biocLite("illuminaio")
library(illuminaio)
#install.packages("gsrc")
library(gsrc)

##load PennCNV input file
file<-"/Users/nickgiangreco/GitHub/Global_Screening_Arrays/files/pennTest2.txt"

file.df<-read.table(file,sep="\t",header=T,stringsAsFactors=F)

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
dat$samples<-"Sample.1"
dat$geno<-file.df$Gtype

#call segments
seg<-segm(dat)

#gsrc cnv calling
del<- -0.1
dup<-0.1
cnv.call<-cnv(seg,del=del,dup=dup) 

#Output to bedgraph
