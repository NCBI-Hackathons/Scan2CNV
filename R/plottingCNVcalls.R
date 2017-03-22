#!/bin/bash

#cat("\nstart")

#libraries
library(gsrc)
library(ggplot2)

#allow reading of args
args <- commandArgs(TRUE)

#read args
file<-args[1]
#file<-"/Users/nickgiangreco/GitHub/Global_Screening_Arrays/files/output/pennTest2_gsrcCNVcall.bed"
chrom<-args[2]
#chrom<-1
#del<-args[3]
#del<- -1
#dup<-args[4]
#dup<-1

#cat("\ngot args")

#
#get file name
split<-unlist(strsplit(file,"/"))
full<-split[length(split)]
split2<-unlist(strsplit(full,"_"))
filename<-split2[1]

#assign outDir
outDir<-paste0(split[2:length(split)-1],collapse="/")

#cat("\nreading file")
#read file
x<-read.table(file,header=F)

#subset based on arg
bed<-subset(x,V1==chrom)
colnames(bed)<-c("chr","s","e","num","avg.lrr")

#plots
# plot(x=bed[,2],
#      y=lrr,
#      xaxt="n",
#      xlab="Starts",ylab="LRR",main=paste0("Chr ",chrom),
#      pch=16,ylim=c(min(lrr),-min(lrr)),
#      font=2,font.axis=2,font.lab=2,
#      col=ifelse(lrr<del,"blue",ifelse(lrr>dup,"red","darkgray"))
#      )
# for(i in 1:nrow(bed)){
#   segments(bed[i,2],bed[i,5],bed[i,3],bed[i,5],
#            col=ifelse(lrr<del,"blue",ifelse(lrr>dup,"red","darkgray")))
# }
# abline(h=0,lwd=2)
# axis(1,at=bed[,2],labels = regs,srt=90)

#cat("\ndoing plotting...")

p<-ggplot()
p <- p + 
  geom_segment(data=bed,mapping=aes(x = s, y = avg.lrr,
      xend = e, yend = avg.lrr),size=2,
      col = ifelse(bed$avg.lrr < -1,"blue",ifelse(bed$avg.lrr > 1,"red","darkgray")))+
  geom_point(data=bed,
             mapping=aes(x=s,y=avg.lrr),
             size=2,shape=18,fill="black")+
  ggtitle(paste0(filename,"; Chr = ",chrom))+
  ylim(min(bed$avg.lrr),-min(bed$avg.lrr))+
  xlab("Chromosomal Position")+
  ylab("Log Ratio")+
  theme_bw()

#output to pdf
pdf(file=paste0(outDir,"/",filename,"_chr",chrom,"_CNVs.pdf"),height=5,width=5)
p
dev.off()
