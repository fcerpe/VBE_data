
setwd("~/Desktop/GitHub/VisualBraille_data/code/visualization")

library("readxl")
library("tidyverse")
library("reshape2")
library("gridExtra")
library("pracma")

### Load matrices of decoding accuracies for both groups 

# Controls
ctrl_accuracies <- 
  read.csv("../../outputs/derivatives/CoSMoMVPA/mvpa-decoding_grp-controls_task-wordsDecoding_condition-pairwise-within-script_nbvoxels-73.csv")

# Experts
exp_accuracies <- 
  read.csv("../../outputs/derivatives/CoSMoMVPA/0706_mvpa-decoding_grp-experts_task-wordsDecoding_condition-pairwise-within-script_nbvoxels-73.csv")



### Manipulate the matrix to get something readable by ggplot

ctrl_accuracies <- as.data.frame(ctrl_accuracies)
exp_accuracies <- as.data.frame(exp_accuracies)

# Assign the script, to ease splitting the original accuracy matrix: 1 = French, 2 = Braille
extraCol <- repmat(c(1,1,1,1,1,1,2,2,2,2,2,2), 1,36)
extraCol <- t(extraCol)
ctrl_accuracies$script <- extraCol
exp_accuracies$script <- extraCol

# Assign group, to keep track once merged
ctrl_accuracies$group <- rep("control", 432)
exp_accuracies$group <- rep("expert", 432)

# Join matrices and specify who's control and who's expert
# accuracies <- rbind(exp_accuracies, ctrl_accuracies)

# Drop unnecessary columns
# accuracies <- subset(accuracies, select = -c(4,7,8))
ctrl_accuracies <- subset(ctrl_accuracies, select = -c(4,7,8))
exp_accuracies <- subset(exp_accuracies, select = -c(4,7,8))

# remove tmaps, remove voxNb and image columns
# accu_div <- group_split(accuracies, image)[[1]]
ctrl_accuracies <- group_split(ctrl_accuracies, image)[[1]]
exp_accuracies <- group_split(exp_accuracies, image)[[1]]
# accuracies <- subset(accuracies, select = -c(4,5))
ctrl_accuracies <- subset(ctrl_accuracies, select = -c(4,5))
exp_accuracies <- subset(exp_accuracies, select = -c(4,5))

# rename 1 and 2 with french and braille
ctrl_accuracies$script <- ifelse(ctrl_accuracies$script == 1, "french", "braille")
ctrl_accuracies$mask <- ifelse(ctrl_accuracies$mask == "VWFAfr", "VWFA", ctrl_accuracies$mask)
exp_accuracies$script <- ifelse(exp_accuracies$script == 1, "french", "braille")
exp_accuracies$mask <- ifelse(exp_accuracies$mask == "VWFAfr", "VWFA", exp_accuracies$mask)



### Plots

# Experts 
accu_exp_plot <- ggplot(exp_accuracies, aes(x = decodingCondition, y = accuracy), middle = mean(accuracy))
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
accu_ctrl_plot <- ggplot(ctrl_accuracies, aes(x = decodingCondition, y = accuracy), middle = mean(accuracy))
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
