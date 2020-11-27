library(dplyr)
library(raster)
library(gglpot2)
library(Rmisc)
library(ggpubr)
setwd("/media/huijieqiao/Speciation_Extin/Sp_Richness_GCM/Script/diversity_in_e")
source("commonFuns/functions.r")
source("commonFuns/colors.r")
threshold<-1
if (F){
  g<-"Mammals"
  for (g in c("Amphibians", "Birds", "Mammals", "Reptiles")){
    df<-readRDS(sprintf("../../Objects/when_where_extinction_%d/%s.rda", threshold, g))
    when_extinct<-df%>%dplyr::distinct(group, sp, GCM, SSP, extinct_year)
    
    when_extinct<-when_extinct%>%dplyr::group_by(group, GCM, SSP, extinct_year)%>%
      dplyr::summarise(n_sp=n())
    coms<-when_extinct%>%dplyr::distinct(group, GCM, SSP)
    i=1
    when_extinct_df<-NULL
    for (i in c(1:nrow(coms))){
      print(paste(i, nrow(coms)))
      com<-coms[i,]
      item<-when_extinct%>%dplyr::filter((group==com$group)&(GCM==com$GCM)&(SSP==com$SSP))
      y=2015
      for (y in c(2021:2100)){
        print(paste(g, i, nrow(coms), y))
        item2<-item%>%dplyr::filter(extinct_year<=y)
        if (nrow(item2)==0){
          com$n_sp<-0
        }else{
          com$n_sp<-sum(item2$n_sp)
        }
        com$extinct_year<-y
        when_extinct_df<-bind_dplyr(when_extinct_df, com)
      }
    }
    saveRDS(when_extinct_df, sprintf("../../Objects/when_where_extinction_%d/when_extinct_%s.rda", threshold, g))
  }
}
if (F){
  when_extinct<-NULL
  for (g in c("Amphibians", "Birds", "Reptiles", "Mammals")){
    when_extinct_df<-readRDS(sprintf("../../Objects/when_where_extinction_%d/when_extinct_%s.rda", threshold, g))
    when_extinct_df_se<-when_extinct_df%>%dplyr::group_by(group, SSP, extinct_year)%>%
      dplyr::summarise(mean_n_sp=mean(n_sp),
                       sd_n_sp=sd(n_sp),
                       CI_n_sp=CI(n_sp)[2]-CI(n_sp)[3])
    if (g=="Amphibians"){
      when_extinct_df_se$all_sp<-6803
    }
    if (g=="Birds"){
      when_extinct_df_se$all_sp<-11145
    }
    if (g=="Mammals"){
      when_extinct_df_se$all_sp<-5537
    }
    if (g=="Reptiles"){
      when_extinct_df_se$all_sp<-7171
    }
    when_extinct_df_se$extinct_ratio<-when_extinct_df_se$mean_n_sp/when_extinct_df_se$all_sp
    when_extinct<-bind(when_extinct, when_extinct_df_se)
  }
  saveRDS(when_extinct, sprintf("../../Objects/when_where_extinction_%d/when_extinct_final.rda", threshold))
}

when_extinct<-readRDS(sprintf("../../Objects/when_where_extinction_%d/when_extinct_final.rda", threshold))
names(when_extinct)[1]<-"Group"
p1<-ggplot(when_extinct, aes(x=extinct_year, y=mean_n_sp, color=Group))+
  #geom_errorbar(aes(ymin=mean_n_sp-CI_n_sp, ymax=mean_n_sp+CI_n_sp, color=Group), alpha=0.7, width=0.25)+
  geom_line(aes(linetype=SSP))+
  scale_color_manual(values=color_groups)+
  scale_linetype_manual(values=linetype_ssp)+
  xlab("Year")+
  ylab("Average number of extinctions")+
  theme_bw()
p1

p2<-ggplot(when_extinct, aes(x=extinct_year, y=extinct_ratio, color=Group))+
  geom_line(aes(linetype=SSP))+
  scale_color_manual(values=color_groups)+
  scale_linetype_manual(values=linetype_ssp)+
  xlab("Year")+
  ylab("Extinction proportion")+
  theme_bw()
p2
legend_g<-get_legend(p1)
p<-ggarrange(p1, p2, ncol=1, common.legend = T, legend="right", legend.grob=legend_g)
p
ggsave(p, filename=sprintf("../../Figures/when_where_extinction_%d/when.pdf", threshold), width=8, height=6)
ggsave(p, filename=sprintf("../../Figures/when_where_extinction_%d/when.png", threshold), width=8, height=6)

ggsave(p1, filename=sprintf("../../Figures/when_where_extinction_%d/when_number.pdf", threshold), width=8, height=4)
ggsave(p1, filename=sprintf("../../Figures/when_where_extinction_%d/when_number.png", threshold), width=8, height=4)

ggsave(p2, filename=sprintf("../../Figures/when_where_extinction_%d/when_proportion.pdf", threshold), width=8, height=4)
ggsave(p2, filename=sprintf("../../Figures/when_where_extinction_%d/when_proportion.png", threshold), width=8, height=4)
