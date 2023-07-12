
library('tidyverse')
library('data.table')

# Load csv file 
accu <- read.csv("../../outputs/derivatives/CoSMoMVPA/mvpa-decoding_grp-experts_task-wordsDecoding_condition-cross-script_nbvoxels-73.csv")



### Manipulate the matrix to get something readable by ggplot
accu <- as.data.frame(accu)

# rename area: VWFAfr to VWFA 
accu$mask <- ifelse(accu$mask == "VWFAfr", "VWFA", accu$mask)

# check that the headers are ok
head(accu)

# Drop unnecessary columns
# remove tmaps, remove voxNb and image columns
accu <- group_split(accu, image)[[1]]
accu <- subset(accu, select = -c(4,5,6,7,8))

# divide cross-modal decoding (cmd) by type of training and test:
cmd_both <- group_split(accu, modality)[[1]]
cmd_trBR_teFR <- group_split(accu, modality)[[2]]
cmd_trFR_teBR <- group_split(accu, modality)[[3]]
cmd_combined <- rbind(cmd_trBR_teFR, cmd_trFR_teBR)

# get stats to create error bars 
stats_both <- cmd_both %>% group_by(mask, decodingCondition, modality) %>% 
  summarize(mean_accuracy = mean(accuracy), sd_accuracy = sd(accuracy), se_accuracy = sd(accuracy)/sqrt(6), .groups = 'keep') 

stats_trBR_teFR <-cmd_trBR_teFR %>% group_by(mask, decodingCondition, modality) %>% 
  summarize(mean_accuracy = mean(accuracy), sd_accuracy = sd(accuracy), se_accuracy = sd(accuracy)/sqrt(6), .groups = 'keep') 

stats_trFR_teBR <-cmd_trFR_teBR %>% group_by(mask, decodingCondition, modality) %>% 
  summarize(mean_accuracy = mean(accuracy), sd_accuracy = sd(accuracy), se_accuracy = sd(accuracy)/sqrt(6), .groups = 'keep') 

stats_accu <- accu %>% group_by(mask, decodingCondition, modality) %>% 
  summarize(mean_accuracy = mean(accuracy), sd_accuracy = sd(accuracy), se_accuracy = sd(accuracy)/sqrt(6), .groups = 'keep') 

stats_combined <- cmd_combined %>% group_by(mask, decodingCondition, modality) %>% 
  summarize(mean_accuracy = mean(accuracy), sd_accuracy = sd(accuracy), se_accuracy = sd(accuracy)/sqrt(6), .groups = 'keep') 



### Plots 
# First one is commented, following ones are compacted to avoid extra-long scripts

# train on Braille, test on French 
ggplot(stats_trBR_teFR, aes(x = decodingCondition, y = mean_accuracy)) + 
  # Mean dot - to be changed
  geom_dotplot(binaxis = "y", binwidth = 0.015, stackdir = "center", colour = "blue") + 
  # SE bars 
  geom_errorbar(data = stats_trBR_teFR, 
                aes(x = decodingCondition, y = mean_accuracy, ymin = mean_accuracy - se_accuracy, ymax = mean_accuracy + se_accuracy),
                width = .15, position = position_dodge(1), size = 1, alpha = .8, colour = "blue") +
  # Individual data clouds 
  geom_dotplot(data = cmd_trBR_teFR, aes(x = reorder(decodingCondition, modality), y = accuracy), 
                binaxis = "y", binwidth = 0.015, stackdir = "center", alpha = 0.3, colour = "blue") +
  geom_hline(yintercept = 0.5, size = .25, linetype = "dashed") +                # .50 line
  theme_classic() +                                                              # white background, simple theme
  ylim(0,1) +                                                                    # proper y axis length
  theme(axis.text.x = element_text(angle = 90)) +                                # vertical text for x axis
  facet_grid(~factor(mask, levels = c("VWFA", "lLO", "rLO")), 
             labeller = label_value) +                                           # split the decodings according to group = area
  scale_x_discrete(limits=rev,                                                   # customize x axis labels
                   labels = c("RW - PW", "RW - NW", "RW - FS", "PW - NW", "PW - FS", "NW - FS")) +
  labs(x = "Area", y = "Accuracy", title = "Cross-script decoding: train on BRAILLE, test on FRENCH")      

ggsave("figures/cross-script_mean-accuracy_tr-braille-te-french.png", width = 3000, height = 1800, dpi = 320, units = "px")


# train on French, test on Braille 
ggplot(stats_trFR_teBR, aes(x = decodingCondition, y = mean_accuracy)) + 
  geom_dotplot(binaxis = "y", binwidth = 0.015, stackdir = "center", colour = "blue") + 
  geom_errorbar(data = stats_trFR_teBR, 
                aes(x = decodingCondition, y = mean_accuracy, ymin = mean_accuracy - se_accuracy, ymax = mean_accuracy + se_accuracy),
                width = .15, position = position_dodge(1), size = 1, alpha = .8, colour = "blue") +
  geom_dotplot(data = cmd_trFR_teBR, aes(x = reorder(decodingCondition, modality), y = accuracy), 
               binaxis = "y", binwidth = 0.015, stackdir = "center", alpha = 0.3, colour = "blue") +
  geom_hline(yintercept = 0.5, size = .25, linetype = "dashed") +                
  theme_classic() + ylim(0,1) + theme(axis.text.x = element_text(angle = 90)) +                               
  facet_grid(~factor(mask, levels = c("VWFA", "lLO", "rLO")), labeller = label_value) +                                           
  scale_x_discrete(limits=rev, labels = c("RW - PW", "RW - NW", "RW - FS", "PW - NW", "PW - FS", "NW - FS")) +
  labs(x = "Area", y = "Accuracy", title = "Cross-script decoding: train on FRENCH, test on BRAILLE") 

ggsave("figures/cross-script_mean-accuracy_tr-french-te-braille.png", width = 3000, height = 1800, dpi = 320, units = "px")


