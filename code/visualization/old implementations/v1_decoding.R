
setwd("~/Desktop/GitHub/VisualBraille_data/code/visualization")

library("readxl")
library("tidyverse")
library("reshape2")
library("gridExtra")
library("pracma")
library("dplyr")

### Load matrices of decoding accuracies for both groups 

# Controls
controls <- read.csv("../../outputs/derivatives/CoSMoMVPA/decoding-pairwise-within-script_grp-controls_rois-earlyVisual_nbvoxels-81.csv")

# Experts
experts <- read.csv("../../outputs/derivatives/CoSMoMVPA/decoding-pairwise-within-script_grp-experts_rois-earlyVisual_nbvoxels-81.csv")



### Manipulate the matrix to get something readable by ggplot
controls <- as.data.frame(controls)
experts <- as.data.frame(experts)

# Assign the script, to ease splitting the original accuracy matrix: 1 = French, 2 = Braille
experts$script <- t(repmat(c(1,1,1,1,1,1,2,2,2,2,2,2), 1, nrow(experts)/12))
controls$script <- t(repmat(c(1,1,1,1,1,1,2,2,2,2,2,2), 1, nrow(controls)/12))

# Assign group, to keep track once merged
controls$group <- rep("control", nrow(controls))
experts$group <- rep("expert", nrow(experts))

# remove tmaps, remove voxNb and image columns
controls <- group_split(controls, image)[[1]]
controls <- subset(controls, select = -c(4,5,6,7,8))

experts <- group_split(experts, image)[[1]]
experts <- subset(experts, select = -c(4,5,6,7,8))

# rename scripts 1 and 2 with french and braille
controls$script <- ifelse(controls$script == 1, "french", "braille")
experts$script <- ifelse(experts$script == 1, "french", "braille")

# Add number of decoding pair, to place the horizontal lines 
experts$numDecoding <- t(repmat(c(1,2,3,4,5,6,7,8,9,10,11,12), 1,nrow(experts)/12))
controls$numDecoding <- t(repmat(c(1,2,3,4,5,6,7,8,9,10,11,12), 1,nrow(controls)/12))


# calculate stats for error bars
stats_controls <- controls %>% group_by(mask, decodingCondition, script, numDecoding) %>% 
  summarize(mean_accuracy = mean(accuracy), sd_accuracy = sd(accuracy), se_accuracy = sd(accuracy)/sqrt(6), .groups = 'keep') 

stats_experts <-experts %>% group_by(mask, decodingCondition, script, numDecoding) %>% 
  summarize(mean_accuracy = mean(accuracy), sd_accuracy = sd(accuracy), se_accuracy = sd(accuracy)/sqrt(6), .groups = 'keep') 

# combine in general matrix and calculate stats for error bars
general <- rbind(experts, controls)
general$cluster <- paste(general$script, general$group, sep="_")
general$decodingCondition <- ifelse(general$group == "expert", 
                                    paste(general$decodingCondition,"_exp",sep=""), 
                                    paste(general$decodingCondition,"_ctr",sep=""))

stats_gen <- general %>% group_by(mask, decodingCondition, script, numDecoding, cluster) %>% 
  summarize(mean_accuracy = mean(accuracy), sd_accuracy = sd(accuracy), se_accuracy = sd(accuracy)/sqrt(6), .groups = 'keep') 



### Plots - new way

# V1
ggplot(stats_gen, aes(x = decodingCondition, y = mean_accuracy)) + 
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
                  position = position_dodge(1), size = .75, linewidth = 1.7) +
  # Individual data clouds 
  geom_point(data = general, 
             aes(x = reorder(decodingCondition, cluster), 
                 y = accuracy, 
                 colour = cluster),
             position = position_jitter(w = 0.3, h = 0.01),
             alpha = 0.3,
             legend = F) +
  geom_hline(yintercept = 0.5, size = .25, linetype = "dashed") +                
  theme_classic() +                                                              
  ylim(0,1) +                                                                    
  theme(axis.text.x = element_text(angle = 45,  vjust=1, hjust=1, size = 10), 
        axis.ticks = element_blank(),
        axis.title.x = element_text(size = 15), 
        axis.title.y = element_text(size = 15)) +
  scale_x_discrete(limits=rev,                                                   
                   labels = c("\nFRW - FPW"," ", "\nFRW - FNW"," ", "\nFRW - FFS"," ", "\nFPW - FNW"," ", "\nFPW - FFS"," ", "\nFNW - FFS"," ",
                              "\nBRW - BPW"," ", "\nBRW - BNW"," ", "\nBRW - BFS"," ", "\nBPW - BNW"," ", "\nBPW - BFS"," ", "\nBNW - BFS"," ")) +
  labs(x = "Decoding pair", y = "Accuracy")      

ggsave("figures/area-V1_pairwise-decoding_mean-accuracy.png", width = 3000, height = 1800, dpi = 320, units = "px")

