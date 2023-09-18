### Initialize the necessary

setwd("~/Desktop/GitHub/VisualBraille_data/code/visualization")

library("readxl")
library("tidyverse")
library("reshape2")
library("gridExtra")
library("pracma")
library("dplyr")



### Load matrices of decoding accuracies, only for experts. Pointless in controls 

# Experts
experts <- 
  read.csv("../../outputs/derivatives/CoSMoMVPA/mvpa-decoding_grp-experts_task-wordsDecoding_condition-cross-script_nbvoxels-73.csv")



### Manipulate the matrix to get something readable by ggplot

experts <- as.data.frame(experts)

# rename area: VWFAfr to VWFA 
experts$mask <- ifelse(experts$mask == "VWFAfr", "VWFA", experts$mask)

# Drop unnecessary columns
# remove tmaps, remove voxNb and image columns
experts <- group_split(experts, image)[[1]]
experts <- subset(experts, modality != "both")
experts <- subset(experts, select = -c(4,5,6,7,8))


# Add number of decoding pair, to place the horizontal lines 
experts$numDecoding <- t(repmat(c(1,2,3,4,5,6), 1,nrow(experts)/6))
experts$decodingCondition <- ifelse(experts$modality == "tr-braille_te-french", 
                                    paste(experts$decodingCondition,"_BF",sep=""), 
                                    paste(experts$decodingCondition,"_FB",sep=""))

stats <- experts %>% group_by(mask, decodingCondition, modality, numDecoding) %>% 
  summarize(mean_accuracy = mean(accuracy), sd_accuracy = sd(accuracy), se_accuracy = sd(accuracy)/sqrt(6), .groups = 'keep') 


### Plot the decodings 

# Both training - test conditions
ggplot(stats, aes(x = decodingCondition, y = mean_accuracy)) + 
  scale_color_manual(name = "script x group",
                     limits = c("tr-french_te-braille", "tr-braille_te-french"),
                     values = c("#69B5A2",              "#FF9E4A"),
                     labels = c("training FR, test BR", "training BR, test FR")) +
  # Mean and SE bars
  geom_pointrange(aes(x = decodingCondition, 
                      y = mean_accuracy, 
                      ymin = mean_accuracy - se_accuracy, 
                      ymax = mean_accuracy + se_accuracy, 
                      colour = modality),
                  position = position_dodge(1), size = .5, linewidth = 1) +
  # Individual data clouds 
  geom_point(data = experts,
             aes(x = reorder(decodingCondition, modality),
                 y = accuracy,
                 colour = modality),
             position = position_jitter(w = 0.3, h = 0.01),
             alpha = 0.2,
             legend = F) +
  geom_hline(yintercept = 0.5, size = .25, linetype = "dashed") +                # .50 line
  theme_classic() +                                                              # white background, simple theme
  ylim(0,1) +                                                                    # proper y axis length
  theme(axis.text.x = element_text(angle = 90), axis.ticks = element_blank()) +       # oblique text for x axis
  facet_grid(~factor(mask, levels = c("VWFA", "lLO", "rLO")), 
             labeller = label_value) + 
  scale_x_discrete(limits=rev,                                                   # customize x axis labels
                   labels = c("\nRW - PW"," ", "\nRW - NW"," ", "\nRW - FS"," ", 
                              "\nPW - NW"," ", "\nPW - FS"," ", "\nNW - FS"," ")) +
  labs(x = "Decoding pair", y = "Accuracy", title = "Crossmodal decoding")      

ggsave("figures/crossmodal-decoding_mean-accuracy.png", width = 3000, height = 1800, dpi = 320, units = "px")


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

ggsave("figures/cross-script_mean-accuracy_tr-braille-te-french.png", width = 3000, height = 1800, dpi = 320, units = "px")


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

ggsave("figures/cross-script_mean-accuracy_tr-french-te-braille.png", width = 3000, height = 1800, dpi = 320, units = "px")

