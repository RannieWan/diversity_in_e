setwd("/media/huijieqiao/Speciation_Extin/Sp_Richness_GCM/Script/diversity_in_e")

library(png)
library(grid)
library(ggplot2)
library(gridExtra)
library(OpenImageR)
library(ggpubr)
group<-"Amphibians"
SSPs<-c("SSP119", "SSP245", "SSP585")

SSP_i<-SSPs[1]
year_i<-2100
predict_range<-c(2021:2100)
for (year_i in c(2021:2100)){
  print(year_i)
  images<-list()
  for (threshold in c(1, 5)){
    for (dispersal in c(0:1)){
      
      
      for (SSP_i in SSPs){
        
        img <- readPNG(sprintf("../../Figures/Species_gain_loss_%d/Movies/RawValue/3D/rough/ALL/%s/%d/%d.png", 
                               threshold, SSP_i, dispersal, year_i))
        crop2 = cropImage(img, new_width = 150:780, new_height = 100:1300, type = 'user_defined')
        img_r<-rasterGrob(crop2, interpolate=TRUE)
        title<-paste(SSP_i, "Dispersal:", dispersal, "Exposure year:", threshold)
        g1<-qplot(geom="blank") +
          annotation_custom(img_r, xmin=-Inf, xmax=Inf, ymin=-Inf, ymax=Inf)+
          ggtitle(title)+
          theme_bw()+
          theme(panel.border = element_blank(), panel.grid.major = element_blank(),
                panel.grid.minor = element_blank(), axis.line = element_blank(),
                axis.text.x=element_blank(),
                axis.text.y=element_blank(),axis.ticks=element_blank(),
                axis.title.x=element_blank(),
                axis.title.y=element_blank(),
                legend.position="none")
        images[[title]]<-g1
      }
    }
    
    
  }
  p<-ggarrange(plotlist=images, nrow=4, ncol=3)
  ggsave(p, filename=sprintf("../../Figures/Species_gain_loss_all/%d.png", 
                             year_i),
         width=11, height=8)
  ggsave(p, filename=sprintf("../../Figures/Species_gain_loss_all/%d.pdf", 
                             year_i),
         width=11, height=8)
}
#/media/huijieqiao/Speciation_Extin/Sp_Richness_GCM/Figures/Species_gain_loss_5/Movies/RawValue/3D/rough/ALL
#ffmpeg -r 2 -start_number 2015 -i %04d.png -y ../../../../gain_loss_3D.mp4