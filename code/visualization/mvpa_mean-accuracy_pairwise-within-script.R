
setwd("~/Desktop/GitHub/VisualBraille_data/code/visualization")

library("readxl")
library("tidyverse")
library("reshape2")
library("gridExtra")
library("pracma")
library("dplyr")

### Load matrices of decoding accuracies for both groups 

# Controls
controls <- read.csv("../../outputs/derivatives/CoSMoMVPA/mvpa-decoding_grp-controls_task-wordsDecoding_condition-pairwise-within-script_nbvoxels-73.csv")

# Experts
experts <- read.csv("../../outputs/derivatives/CoSMoMVPA/mvpa-decoding_grp-experts_task-wordsDecoding_condition-pairwise-within-script_nbvoxels-73.csv")



### Manipulate the matrix to get something readable by ggplot
controls <- as.data.frame(controls)
experts <- as.data.frame(experts)

# rename area: VWFAfr to VWFA 
experts$mask <- ifelse(experts$mask == "VWFAfr", "VWFA", experts$mask)
controls$mask <- ifelse(controls$mask == "VWFAfr", "VWFA", controls$mask)

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

# VWFA
ggplot(subset(stats_gen, mask == "VWFA"), aes(x = decodingCondition, y = mean_accuracy)) + 
  scale_color_manual(name = "script x group",
                     limits = c("french_expert",   "braille_expert",    "french_control",  "braille_control"),
                     values = c("#69B5A2",         "#FF9E4A",           "#699ae5",         "#da5F49"),
                     labels = c("french - expert", "braille - expert", "french - control", "braille - control")) +
  # Mean and SE bars
  geom_pointrange(aes(x = decodingCondition, 
                      y = mean_accuracy, 
                      ymin = mean_accuracy - se_accuracy, 
                      ymax = mean_accuracy + se_accuracy, 
                      colour = cluster),
                  position = position_dodge(1), size = .5, linewidth = 1) +
  # Individual data clouds 
  geom_point(data = subset(general, mask == "VWFA"), 
             aes(x = reorder(decodingCondition, cluster), 
                 y = accuracy, 
                 colour = cluster),
             position = position_jitter(w = 0.3, h = 0.01),
             alpha = 0.2,
             legend = F) +
  geom_hline(yintercept = 0.5, size = .25, linetype = "dashed") +                # .50 line
  theme_classic() +                                                              # white background, simple theme
  ylim(0,1) +                                                                    # proper y axis length
  theme(axis.text.x = element_text(angle = 90), axis.ticks = element_blank()) +       # oblique text for x axis
  scale_x_discrete(limits=rev,                                                   # customize x axis labels
                   labels = c("\nFRW - FPW"," ", "\nFRW - FNW"," ", "\nFRW - FFS"," ", "\nFPW - FNW"," ", "\nFPW - FFS"," ", "FNW - FFS"," ",
                              "\nBRW - BPW"," ", "\nBRW - BNW"," ", "\nBRW - BFS"," ", "\nBPW - BNW"," ", "\nBPW - BFS"," ", "BNW - BFS"," ")) +
  labs(x = "Decoding pair", y = "Accuracy", title = "Pairwise decoding - VWFA")      

ggsave("figures/area-VWFA_pairwise-decoding_mean-accuracy.png", width = 3000, height = 1800, dpi = 320, units = "px")


# lLO 
ggplot(subset(stats_gen, mask == "lLO"), aes(x = decodingCondition, y = mean_accuracy)) + 
  scale_color_manual(name = "script x group",
                     limits = c("french_expert",   "braille_expert",    "french_control",  "braille_control"),
                     values = c("#69B5A2",         "#FF9E4A",           "#699ae5",         "#da5F49"),
                     labels = c("french - expert", "braille - expert", "french - control", "braille - control")) +
  # Mean and SE bars
  geom_pointrange(aes(x = decodingCondition, 
                      y = mean_accuracy, 
                      ymin = mean_accuracy - se_accuracy, 
                      ymax = mean_accuracy + se_accuracy, 
                      colour = cluster),
                  position = position_dodge(1), size = .5, linewidth = 1) +
  # Individual data clouds 
  geom_point(data = subset(general, mask == "lLO"), 
             aes(x = reorder(decodingCondition, cluster), 
                 y = accuracy, 
                 colour = cluster),
             position = position_jitter(w = 0.3, h = 0.01),
             alpha = 0.2,
             legend = F) +
  geom_hline(yintercept = 0.5, size = .25, linetype = "dashed") +                # .50 line
  theme_classic() +                                                              # white background, simple theme
  ylim(0,1) +                                                                    # proper y axis length
  theme(axis.text.x = element_text(angle = 90), axis.ticks = element_blank()) +       # oblique text for x axis
  scale_x_discrete(limits=rev,                                                   # customize x axis labels
                   labels = c("\nFRW - FPW"," ", "\nFRW - FNW"," ", "\nFRW - FFS"," ", "\nFPW - FNW"," ", "\nFPW - FFS"," ", "FNW - FFS"," ",
                              "\nBRW - BPW"," ", "\nBRW - BNW"," ", "\nBRW - BFS"," ", "\nBPW - BNW"," ", "\nBPW - BFS"," ", "BNW - BFS"," ")) +
  labs(x = "Decoding pair", y = "Accuracy", title = "Pairwise decoding - lLO")      

ggsave("figures/area-lLO_pairwise-decoding_mean-accuracy.png", width = 3000, height = 1800, dpi = 320, units = "px")


# rLO 
ggplot(subset(stats_gen, mask == "rLO"), aes(x = decodingCondition, y = mean_accuracy)) + 
  scale_color_manual(name = "script x group",
                     limits = c("french_expert",   "braille_expert",    "french_control",  "braille_control"),
                     values = c("#69B5A2",         "#FF9E4A",           "#699ae5",         "#da5F49"),
                     labels = c("french - expert", "braille - expert", "french - control", "braille - control")) +
  # Mean and SE bars
  geom_pointrange(aes(x = decodingCondition, 
                      y = mean_accuracy, 
                      ymin = mean_accuracy - se_accuracy, 
                      ymax = mean_accuracy + se_accuracy, 
                      colour = cluster),
                  position = position_dodge(1), size = .5, linewidth = 1) +
  # Individual data clouds 
  geom_point(data = subset(general, mask == "rLO"), 
             aes(x = reorder(decodingCondition, cluster), 
                 y = accuracy, 
                 colour = cluster),
             position = position_jitter(w = 0.3, h = 0.01),
             alpha = 0.2,
             legend = F) +
  geom_hline(yintercept = 0.5, size = .25, linetype = "dashed") +                # .50 line
  theme_classic() +                                                              # white background, simple theme
  ylim(0,1) +                                                                    # proper y axis length
  theme(axis.text.x = element_text(angle = 90), axis.ticks = element_blank()) +       # oblique text for x axis
  scale_x_discrete(limits=rev,                                                   # customize x axis labels
                   labels = c("\nFRW - FPW"," ", "\nFRW - FNW"," ", "\nFRW - FFS"," ", "\nFPW - FNW"," ", "\nFPW - FFS"," ", "FNW - FFS"," ",
                              "\nBRW - BPW"," ", "\nBRW - BNW"," ", "\nBRW - BFS"," ", "\nBPW - BNW"," ", "\nBPW - BFS"," ", "BNW - BFS"," ")) +
  labs(x = "Decoding pair", y = "Accuracy", title = "Pairwise decoding - rLO")      

ggsave("figures/area-rLO_pairwise-decoding_mean-accuracy.png", width = 3000, height = 1800, dpi = 320, units = "px")
