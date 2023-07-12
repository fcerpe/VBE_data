### Initialize the necessary

setwd("~/Desktop/GitHub/VisualBraille_data/code/visualization")

library("readxl")
library("tidyverse")
library("reshape2")
library("gridExtra")
library("pracma")



### Load matrices of decoding accuracies, only for experts. Pointless in controls 

# Experts
exp_accuracies <- 
  read.csv("../../outputs/derivatives/CoSMoMVPA/mvpa-decoding_grp-experts_task-wordsDecoding_condition-cross-script_nbvoxels-73.csv")



### Manipulate the matrix to get something readable by ggplot

exp_accuracies <- as.data.frame(exp_accuracies)

# rename area: VWFAfr to VWFA 
exp_accuracies$mask <- ifelse(exp_accuracies$mask == "VWFAfr", "VWFA", exp_accuracies$mask)

# Drop unnecessary columns
# remove tmaps, remove voxNb and image columns
exp_accuracies <- group_split(exp_accuracies, image)[[1]]
exp_accuracies <- subset(exp_accuracies, select = -c(4,5,6,7,8))

# divide cross-modal decoding (cmd) by type of training and test:
cmd_both <- group_split(exp_accuracies, modality)[[1]]
cmd_trBR_teFR <- group_split(exp_accuracies, modality)[[2]]
cmd_trFR_teBR <- group_split(exp_accuracies, modality)[[3]]



### Plot the decodings 

# Train on Braille, test on French
plot_trBR_teFR <- ggplot(cmd_trBR_teFR, aes(x = decodingCondition, y = accuracy), middle = mean(accuracy))
plot_trBR_teFR + geom_boxplot(outlier.shape = NA, colour = "#0000ff") + 
  theme_classic() +
  geom_hline(aes(yintercept = 0.5), size = .25, linetype = "dashed") +
  ylim(0,1) +
  geom_jitter(width = 0.3, alpha = 0.7, colour = "#0000ff") +
  theme(axis.text.x = element_text(angle = 90)) +
  facet_grid(~factor(mask, levels = c("VWFA", "lLO", "rLO")), labeller = label_value) + 
  scale_x_discrete(limits=rev, labels = c("RW - PW", "RW - NW", "RW - FS", "PW - NW", "PW - FS", "NW - FS")) +
  labs(x = "Area", y = "Accuracy", title = "Cross-script decoding: train on BRAILLE, test on FRENCH")

# ggsave("figures/cross-script_mean-accuracy_tr-braille-te-french.png", width = 3000, height = 1800, dpi = 320, units = "px")


# Train on French, test on Braille
plot_trFR_teBR <- ggplot(att_trFR_teBR, aes(x = decodingCondition, y = accuracy), middle = mean(accuracy))
plot_trFR_teBR + geom_boxplot(outlier.shape = NA, colour = "#0000ff") + 
  theme_classic() +
  geom_hline(aes(yintercept = 0.5), size = .25, linetype = "dashed") +
  ylim(0,1) +
  geom_jitter(colour = "#0000ff", width = 0.3, alpha = 0.7) +
  theme(axis.text.x = element_text(angle = 90)) +
  facet_grid(~factor(mask, levels = c("VWFA", "lLO", "rLO")), labeller = label_value) + 
  scale_x_discrete(limits=rev, labels = c("RW - PW", "RW - NW", "RW - FS", "PW - NW", "PW - FS", "NW - FS")) +
  labs(x = "Area", y = "Accuracy", title = "Cross-script decoding: train on FRENCH, test on BRAILLE")

# ggsave("figures/cross-script_mean-accuracy_tr-french-te-braille.png", width = 3000, height = 1800, dpi = 320, units = "px")

# both 
plot_both <- ggplot(att_both, aes(x = decodingCondition, y = accuracy), middle = mean(accuracy))
plot_both + geom_boxplot(outlier.shape = NA, colour = "#0000ff") + 
  theme_classic() +
  geom_hline(aes(yintercept = 0.5), size = .25, linetype = "dashed") +
  ylim(0,1) +
  geom_jitter(colour = "#0000ff", width = 0.3, alpha = 0.7) +
  theme(axis.text.x = element_text(angle = 90)) +
  facet_grid(~factor(mask, levels = c("VWFA", "lLO", "rLO")), labeller = label_value) + 
  scale_x_discrete(limits=rev, labels = c("RW - PW", "RW - NW", "RW - FS", "PW - NW", "PW - FS", "NW - FS")) +
  labs(x = "Area", y = "Accuracy", title = "Cross-script decoding: train on FRENCH, test on BRAILLE")
