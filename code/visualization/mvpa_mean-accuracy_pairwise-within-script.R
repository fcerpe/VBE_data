
setwd("~/Desktop/GitHub/VisualBraille_data/code/visualization")

library("readxl")
library("tidyverse")
library("reshape2")
library("gridExtra")
library("pracma")

### Load matrices of decoding accuracies for both groups 

# Controls
controls <- read.csv("../../outputs/derivatives/CoSMoMVPA/mvpa-decoding_grp-controls_task-wordsDecoding_condition-pairwise-within-script_nbvoxels-73.csv")

# Experts
experts <- read.csv("../../outputs/derivatives/CoSMoMVPA/mvpa-decoding_grp-experts_task-wordsDecoding_condition-pairwise-within-script_nbvoxels-73.csv")



### Manipulate the matrix to get something readable by ggplot
controls <- as.data.frame(controls)
experts <- as.data.frame(experts)

# Assign the script, to ease splitting the original accuracy matrix: 1 = French, 2 = Braille
extraCol <- repmat(c(1,1,1,1,1,1,2,2,2,2,2,2), 1,36)
extraCol <- t(extraCol)
controls$script <- extraCol
experts$script <- extraCol

# Assign group, to keep track once merged
controls$group <- rep("control", 432)
experts$group <- rep("expert", 432)

# remove tmaps, remove voxNb and image columns
controls <- group_split(controls, image)[[1]]
controls <- subset(controls, select = -c(4,5,6,7,8))

experts <- group_split(experts, image)[[1]]
experts <- subset(experts, select = -c(4,5,6,7,8))

# rename scripts 1 and 2 with french and braille
controls$script <- ifelse(controls$script == 1, "french", "braille")
controls$mask <- ifelse(controls$mask == "VWFAfr", "VWFA", controls$mask)

experts$script <- ifelse(experts$script == 1, "french", "braille")
experts$mask <- ifelse(experts$mask == "VWFAfr", "VWFA", experts$mask)

# Add number of decoding pair, to place the horizontal lines 
nDec <- repmat(c(1,2,3,4,5,6,7,8,9,10,11,12), 1,18)
experts$numDecoding <- t(nDec)
controls$numDecoding <- t(nDec)


# calculate stats for error bars
stats_controls <- controls %>% group_by(mask, decodingCondition, script, numDecoding) %>% 
  summarize(mean_accuracy = mean(accuracy), sd_accuracy = sd(accuracy), se_accuracy = sd(accuracy)/sqrt(6), .groups = 'keep') 

stats_experts <-experts %>% group_by(mask, decodingCondition, script, numDecoding) %>% 
  summarize(mean_accuracy = mean(accuracy), sd_accuracy = sd(accuracy), se_accuracy = sd(accuracy)/sqrt(6), .groups = 'keep') 



### Plots - new way

# Experts 
ggplot(stats_experts, aes(x = decodingCondition, y = mean_accuracy)) + 
  scale_color_manual(name = "script", values = c("french" = "#69B5A2", "braille" = "#FF9E4A")) +
  # Mean dot - to be changed
  geom_dotplot(binaxis = "y", binwidth = 0.015, stackdir = "center", aes(colour = script, fill = script), legend = F) + 
  # SE bars 
  geom_errorbar(data = stats_experts, 
                aes(x = decodingCondition, y = mean_accuracy, ymin = mean_accuracy - se_accuracy, ymax = mean_accuracy + se_accuracy, colour = script),
                width = .15, position = position_dodge(1), size = 1, alpha = .8) +
  # Individual data clouds 
  geom_dotplot(data = experts, aes(x = reorder(decodingCondition, script), y = accuracy, colour = script, fill = script), 
               binaxis = "y", binwidth = 0.015, stackdir = "center", alpha = 0.3, legend = F) +
  geom_hline(yintercept = 0.5, size = .25, linetype = "dashed") +                # .50 line
  theme_classic() +                                                              # white background, simple theme
  ylim(0,1) +                                                                    # proper y axis length
  theme(axis.text.x = element_text(angle = 90)) +                                # vertical text for x axis
  facet_grid(~factor(mask, levels = c("VWFA", "lLO", "rLO")), 
             labeller = label_value) +                                           # split the decodings according to group = area
  scale_x_discrete(limits=rev,                                                   # customize x axis labels
                   labels = c("FRW - FPW", "FRW - FNW", "FRW - FFS", "FPW - FNW", "FPW - FFS", "FNW - FFS",
                              "BRW - BPW", "BRW - BNW", "BRW - BFS", "BPW - BNW", "BPW - BFS", "BNW - BFS")) +
  labs(x = "Area", y = "Accuracy", title = "Pairwise decoding - expert group")      

ggsave("figures/pairwise-decoding_mean-accuracy_experts.png", width = 3000, height = 1800, dpi = 320, units = "px")


# Controls
ggplot(stats_controls, aes(x = decodingCondition, y = mean_accuracy)) + 
  scale_color_manual(name = "script", values = c("braille" = "#da5F49", "french" = "#699ae5")) +
  # Mean dot - to be changed
  geom_dotplot(binaxis = "y", binwidth = .02, stackdir = "center", aes(colour = script, fill = script)) +
  # SE bars 
  geom_errorbar(data = stats_controls, 
                aes(x = decodingCondition, y = mean_accuracy, ymin = mean_accuracy - se_accuracy, ymax = mean_accuracy + se_accuracy, colour = script),
                width = .1, position = position_dodge(1), size = .9, alpha = .8) +
  # Bar instead of dot
  # geom_linerange(data = stats_controls, aes(x = decodingCondition, xmin = numDecoding - .4, xmax = numDecoding + .4, colour = script), size = 1.7) + 
  # Individual data clouds 
  geom_dotplot(data = controls, aes(x = reorder(decodingCondition, script), y = accuracy, colour = script, fill = script), 
               binaxis = "y", binwidth = .015, stackdir = "center", alpha = .3, legend = F) +
  geom_hline(yintercept = .5, size = .25, linetype = "dashed") +                # .50 line
  theme_classic() +                                                              # white background, simple theme
  ylim(0,1) +                                                                    # proper y axis length
  theme(axis.text.x = element_text(angle = 90)) +                                # vertical text for x axis
  facet_grid(~factor(mask, levels = c("VWFA", "lLO", "rLO")), 
             labeller = label_value) +                                           # split the decodings according to group = area
  scale_x_discrete(limits=rev,                                                   # customize x axis labels
                   labels = c("FRW - FPW", "FRW - FNW", "FRW - FFS", "FPW - FNW", "FPW - FFS", "FNW - FFS",
                              "BRW - BPW", "BRW - BNW", "BRW - BFS", "BPW - BNW", "BPW - BFS", "BNW - BFS")) +
  labs(x = "Area", y = "Accuracy", title = "Pairwise decoding - control group")      

ggsave("figures/pairwise-decoding_mean-accuracy_controls.png", width = 3000, height = 1800, dpi = 320, units = "px")



### Plots - old way

# Experts 
accu_exp_plot <- ggplot(experts, aes(x = decodingCondition, y = accuracy), middle = mean(accuracy))
accu_exp_plot + geom_boxplot(outlier.shape = NA, aes(colour = script)) + 
  theme_classic() +
  geom_hline(aes(yintercept = 0.5), size = .25, linetype = "dashed") +
  ylim(0,1) +
  geom_jitter(aes(colour = script), width = 0.3) +
  theme(axis.text.x = element_text(angle = 90)) +
  facet_grid(~factor(mask, levels = c("VWFA", "lLO", "rLO")), labeller = label_value) + 
  scale_x_discrete(limits=rev, labels = c("FRW - FPW", "FRW - FNW", "FRW - FFS", "FPW - FNW",
                              "FPW - FFS", "FNW - FFS", "BRW - BPW", "BRW - BNW",
                              "BRW - BFS", "BPW - BNW", "BPW - BFS", "BNW - BFS")) +
  labs(x = "Area", y = "Accuracy", title = "Mean decoding acccuracy - experts")

ggsave("figures/pairwise-decoding_mean-accuracy_experts.png", width = 3000, height = 1800, dpi = 320, units = "px")


# Controls
accu_ctrl_plot <- ggplot(controls, aes(x = decodingCondition, y = accuracy), middle = mean(accuracy))
accu_ctrl_plot + geom_boxplot(outlier.shape = NA, aes(colour = script)) + 
  theme_classic() +
  geom_hline(aes(yintercept = 0.5), size = .25, linetype = "dashed") +
  ylim(0,1) +
  geom_jitter(aes(colour = script), width = 0.3) +
  theme(axis.text.x = element_text(angle = 90)) +
  facet_grid(~factor(mask, levels = c("VWFA", "lLO", "rLO")), labeller = label_value) + 
  scale_x_discrete(limits=rev, labels = c("FRW - FPW", "FRW - FNW", "FRW - FFS", "FPW - FNW",
                                          "FPW - FFS", "FNW - FFS", "BRW - BPW", "BRW - BNW",
                                          "BRW - BFS", "BPW - BNW", "BPW - BFS", "BNW - BFS")) +
  labs(x = "Area", y = "Accuracy", title = "Mean decoding acccuracy - controls")

ggsave("figures/pairwise-decoding_mean-accuracy_controls.png", width = 3000, height = 1800, dpi = 320, units = "px")
