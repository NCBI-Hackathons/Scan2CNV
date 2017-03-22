#libraries
library(gsrc)

#plots
#Visualizations
plot_gsr(dat, samp=1,baf=T)
plot_gsr(norm_dat,samp=1,baf=T)
plot_gsr(norm_dat, sb = synteny_blocks, samp = 1, baf = TRUE, tl =TRUE)
plot_global(norm_dat, sb = synteny_blocks)
