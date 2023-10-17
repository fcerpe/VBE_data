
setwd("~/Desktop/GitHub/VisualBraille_data/code/visualization")

library("readxl")
library("tidyverse")
library("reshape2")
library("gridExtra")
library("pracma")
library("dplyr")

### Load old decodings 
controls <- read.csv("../../outputs/derivatives/CoSMoMVPA/decoding-pairwise-within-script_grp-controls_rois-vwfaSplit_nbvoxels-23.csv")
experts <- read.csv("../../outputs/derivatives/CoSMoMVPA/decoding-pairwise-within-script_grp-experts_rois-vwfaSplit_nbvoxels-23.csv")

### Manipulate the matrix to get something readable by ggplot
controls <- as.data.frame(controls)
experts <- as.data.frame(experts)
controls$script <- t(repmat(c(1,1,1,1,1,1,2,2,2,2,2,2), 1, nrow(controls)/12))
experts$script <- t(repmat(c(1,1,1,1,1,1,2,2,2,2,2,2), 1, nrow(experts)/12))
controls$group <- rep("control", nrow(controls))
experts$group <- rep("expert", nrow(experts))
controls <- group_split(controls, image)[[1]]
controls <- subset(controls, select = -c(4,5,6,7,8))
experts <- group_split(experts, image)[[1]]
experts <- subset(experts, select = -c(4,5,6,7,8))
controls$script <- ifelse(controls$script == 1, "french", "braille")
experts$script <- ifelse(experts$script == 1, "french", "braille")
experts$numDecoding <- t(repmat(c(1,2,3,4,5,6,7,8,9,10,11,12), 1,nrow(experts)/12))
controls$numDecoding <- t(repmat(c(1,2,3,4,5,6,7,8,9,10,11,12), 1,nrow(controls)/12))
general <- rbind(experts, controls)
general$cluster <- paste(general$script, general$group, sep="_")
general$decodingCondition <- ifelse(general$group == "expert", 
                                    paste(general$decodingCondition,"_exp",sep=""), 
                                    paste(general$decodingCondition,"_ctr",sep=""))
stats_gen <- general %>% group_by(mask, decodingCondition, script, numDecoding, cluster) %>% 
  summarize(mean_accuracy = mean(accuracy), sd_accuracy = sd(accuracy), se_accuracy = sd(accuracy)/sqrt(6), .groups = 'keep') 



### Plot - freely modify colors in scale and save the hex codes in the name of the file
ggplot(stats_gen, aes(x = decodingCondition, y = mean_accuracy)) + 
  scale_color_manual(name = "script x group",
                     limits = c("french_expert",   "braille_expert",    "french_control",  "braille_control"),
                     values = c("#69B5A2",         "#FF9E4A",           "#699ae5",         "#da5F49"),
                     labels = c("french - expert", "braille - expert", "french - control", "braille - control")) +
  # Mean and SE bars
  # SE bars 
  geom_pointrange(aes(x = decodingCondition, 
                      y = mean_accuracy, 
                      ymin = mean_accuracy - se_accuracy, 
                      ymax = mean_accuracy + se_accuracy, 
                      colour = cluster),
                  position = position_dodge(1), size = .5, linewidth = 1) +
  # Individual data clouds 
  geom_point(data = general, 
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
  facet_grid(~factor(mask, levels = c("antVWFA", "posVWFA")), 
             labeller = label_value) +                                           # split the decodings according to group = area
  scale_x_discrete(limits=rev,                                                   # customize x axis labels
                   labels = c("FRW - FPW"," ", "FRW - FNW"," ", "FRW - FFS"," ", "FPW - FNW"," ", "FPW - FFS"," ", "FNW - FFS"," ",
                              "BRW - BPW"," ", "BRW - BNW"," ", "BRW - BFS"," ", "BPW - BNW"," ", "BPW - BFS"," ", "BNW - BFS"," ")) +
  labs(x = "Decoding pair", y = "Accuracy", title = "Pairwise decoding in splitted VWFA")      

ggsave("figures/color-play_69b5a2_ff9e4a_699ae5_da5f49.png", width = 3000, height = 1800, dpi = 320, units = "px")


