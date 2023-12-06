
setwd("~/Desktop/GitHub/VisualBraille_data/code/visualization")

library("readxl")
library("tidyverse")
library("reshape2")
library("gridExtra")
library("pracma")
library("dplyr")

### Load matrices of decoding accuracies for both groups 

# Controls
controls <- read.csv("../../outputs/derivatives/CoSMoMVPA/multiple-decoding-multiple-within_grp-controls_rois-expansionIntersection_nbvoxels-43.csv")

# Experts
experts <- read.csv("../../outputs/derivatives/CoSMoMVPA/multiple-decoding-multiple-within_grp-experts_rois-expansionIntersection_nbVoxels-43.csv")



### Manipulate the matrix to get something readable by ggplot
controls <- as.data.frame(controls)
experts <- as.data.frame(experts)

# rename area: VWFAfr to VWFA 
experts$mask <- ifelse(experts$mask == "VWFAfr", "VWFA", experts$mask)
controls$mask <- ifelse(controls$mask == "VWFAfr", "VWFA", controls$mask)

# Assign the script, to ease splitting the original accuracy matrix: 1 = French, 2 = Braille
experts$script <- t(repmat(c(1,2), 1, nrow(experts)/2))
controls$script <- t(repmat(c(1,2), 1, nrow(controls)/2))

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
experts$numDecoding <- t(repmat(c(1,2), 1,nrow(experts)/2))
controls$numDecoding <- t(repmat(c(1,2), 1,nrow(controls)/2))


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

# VWFA
ggplot(subset(stats_gen), aes(x = decodingCondition, y = mean_accuracy)) + 
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
  geom_point(data = subset(general), 
             aes(x = reorder(decodingCondition, cluster), 
                 y = accuracy, 
                 colour = cluster),
             position = position_jitter(w = 0.3, h = 0.01),
             alpha = 0.3,
             legend = F) +
  geom_hline(yintercept = 0.25, size = .25, linetype = "dashed") +                
  theme_classic() +                                                              
  ylim(0,1) +                                                                    
  theme(axis.text.x = element_blank(), 
        axis.ticks = element_blank(),
        axis.title.x = element_text(size = 15), 
        axis.title.y = element_text(size = 15)) +
  facet_grid(~factor(mask, levels = c("VWFA", "lLO", "rLO")), 
             labeller = label_value) + 
  scale_x_discrete(limits=rev) +
  labs(y = "Accuracy", title = "multi-class decoding")      

ggsave("figures/area-VWFA+LO_multiple-decoding_mean-accuracy.png", width = 3000, height = 1800, dpi = 320, units = "px")
