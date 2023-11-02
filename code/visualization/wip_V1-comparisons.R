setwd("~/Desktop/GitHub/VisualBraille_data/code/visualization")

library("readxl")
library("tidyverse")
library("reshape2")
library("gridExtra")
library("pracma")
library("dplyr")

### Load files

# MVPA Result
exp_jubrain_total <- read.csv("../../outputs/derivatives/CoSMoMVPA/decoding-pairwise-within-script_grp-experts_rois-earlyVisual_nbvoxels-1215.csv")
ctr_jubrain_total <- read.csv("../../outputs/derivatives/CoSMoMVPA/decoding-pairwise-within-script_grp-controls_rois-earlyVisual_nbvoxels-1215.csv")
exp_jubrain_ratio <- read.csv("../../outputs/derivatives/CoSMoMVPA/decoding-pairwise-within-script_grp-experts_rois-earlyVisual-JUBrain_nbvoxels-250.csv")
ctr_jubrain_ratio <- read.csv("../../outputs/derivatives/CoSMoMVPA/decoding-pairwise-within-script_grp-controls_rois-earlyVisual-JUBrain_nbvoxels-250.csv")
exp_visf_total <- read.csv("../../outputs/derivatives/CoSMoMVPA/decoding-pairwise-within-script_grp-experts_rois-earlyVisual_nbvoxels-520.csv")
ctr_visf_total <- read.csv("../../outputs/derivatives/CoSMoMVPA/decoding-pairwise-within-script_grp-controls_rois-earlyVisual_nbvoxels-520.csv")
exp_visf_ratio <- read.csv("../../outputs/derivatives/CoSMoMVPA/decoding-pairwise-within-script_grp-experts_rois-earlyVisual_nbvoxels-250.csv")
ctr_visf_ratio <- read.csv("../../outputs/derivatives/CoSMoMVPA/decoding-pairwise-within-script_grp-controls_rois-earlyVisual_nbvoxels-250.csv")

exp <- exp_visf_total
ctr <- ctr_visf_total


### Manipulate the matrix to get something readable by ggplot
ctr <- as.data.frame(ctr)
exp <- as.data.frame(exp)

# rename area: VWFAfr to VWFA 
exp$mask <- ifelse(exp$mask == "VWFAfr", "VWFA", exp$mask)
ctr$mask <- ifelse(ctr$mask == "VWFAfr", "VWFA", ctr$mask)

# Assign the script, to ease splitting the original accuracy matrix: 1 = French, 2 = Braille
exp$script <- t(repmat(c(1,1,1,1,1,1,2,2,2,2,2,2), 1, nrow(exp)/12))
ctr$script <- t(repmat(c(1,1,1,1,1,1,2,2,2,2,2,2), 1, nrow(ctr)/12))

# Assign group, to keep track once merged
ctr$group <- rep("control", nrow(ctr))
exp$group <- rep("expert", nrow(exp))

# remove tmaps, remove voxNb and image columns
ctr <- group_split(ctr, image)[[1]]
ctr <- subset(ctr, select = -c(4,5,6,7,8))

exp <- group_split(exp, image)[[1]]
exp <- subset(exp, select = -c(4,5,6,7,8))

# rename scripts 1 and 2 with french and braille
ctr$script <- ifelse(ctr$script == 1, "french", "braille")
exp$script <- ifelse(exp$script == 1, "french", "braille")

# Add number of decoding pair, to place the horizontal lines 
exp$numDecoding <- t(repmat(c(1,2,3,4,5,6,7,8,9,10,11,12), 1,nrow(exp)/12))
ctr$numDecoding <- t(repmat(c(1,2,3,4,5,6,7,8,9,10,11,12), 1,nrow(ctr)/12))


# calculate stats for error bars
stats_controls <- ctr %>% group_by(mask, decodingCondition, script, numDecoding) %>% 
  summarize(mean_accuracy = mean(accuracy), sd_accuracy = sd(accuracy), se_accuracy = sd(accuracy)/sqrt(6), .groups = 'keep') 

stats_experts <- exp %>% group_by(mask, decodingCondition, script, numDecoding) %>% 
  summarize(mean_accuracy = mean(accuracy), sd_accuracy = sd(accuracy), se_accuracy = sd(accuracy)/sqrt(6), .groups = 'keep') 

# combine in general matrix and calculate stats for error bars
general <- rbind(exp, ctr)
general$cluster <- paste(general$script, general$group, sep="_")
general$decodingCondition <- ifelse(general$group == "expert", 
                                    paste(general$decodingCondition,"_exp",sep=""), 
                                    paste(general$decodingCondition,"_ctr",sep=""))

stats_pos <- general %>% group_by(mask, decodingCondition, script, numDecoding, cluster) %>% 
  summarize(mean_accuracy = mean(accuracy), sd_accuracy = sd(accuracy), se_accuracy = sd(accuracy)/sqrt(6), .groups = 'keep') 



### Plots - new way

# VWFA
ggplot(stats_pos, aes(x = decodingCondition, y = mean_accuracy)) + 
  scale_color_manual(name = "    ",
                     limits = c("french_expert",   "french_control",  "braille_expert",    "braille_control"),
                     values = c("#69B5A2",         "#699ae5",         "#FF9E4A",          "#da5F49"),
                     labels = c("expert - french", "control - french", "expert - braille", "control - braille")) +
  # Mean and SE bars
  geom_pointrange(aes(x = decodingCondition, 
                      y = mean_accuracy, 
                      ymin = mean_accuracy - se_accuracy, 
                      ymax = mean_accuracy + se_accuracy, 
                      colour = cluster),
                  position = position_dodge(1), size = 1, linewidth = 2) +
  # Individual data clouds 
  geom_point(data = general, 
             aes(x = reorder(decodingCondition, cluster), 
                 y = accuracy, 
                 colour = cluster),
             position = position_jitter(w = 0.3, h = 0.01),
             alpha = 0.5) +
  geom_hline(yintercept = 0.5, size = .25, linetype = "dashed") +                
  theme_classic() +                                                              
  ylim(0.15,1) +                                                                    
  theme(axis.text.x = element_text(angle = 0, size = 15), 
        axis.text.y = element_text(size = 15), 
        axis.ticks = element_blank(),
        axis.title.y = element_text(size = 20)) +
  scale_x_discrete(limits=rev,                                                   
                   labels = c("     FRW\n     FPW","","     FRW\n     FNW","",
                              "     FRW\n     FFS","","     FPW\n     FNW","",
                              "     FPW\n     FFS","","     FNW\n     FFS","",
                              "     BRW\n     BPW","","     BRW\n     BNW","",
                              "     BRW\n     BFS","","     BPW\n     BNW","",
                              "     BPW\n     BFS","","     BNW\n     BFS","")) +
  labs(y = "Decoding accuracy")      

ggsave("figures/cond-V1-visfatlas_pairwise-decoding_mean-accuracy.png", width = 3500, height = 1800, dpi = 320, units = "px")

