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
experts <- read.csv("../../outputs/derivatives/CoSMoMVPA/mvpa-decoding_grp-experts_task-wordsDecoding_condition-cross-script_nbvoxels-43.csv")



### Manipulate the matrix to get something readable by ggplot

experts <- as.data.frame(experts)

# rename area: VWFAfr to VWFA 
experts$mask <- ifelse(experts$mask == "VWFAfr", "VWFA", experts$mask)

# Drop unnecessary columns
# remove tmaps, remove voxNb and image columns
experts <- group_split(experts, image)[[1]]
experts <- subset(experts, select = -c(4,5,6,7,8))


# Add number of decoding pair, to place the horizontal lines 
experts$numDecoding <- t(repmat(c(1,2,3,4,5,6), 1,nrow(experts)/6))
experts$decodingCondition <- ifelse(experts$modality == "tr-braille_te-french", 
                                    paste(experts$decodingCondition,"_BF",sep=""), 
                                    ifelse(experts$modality == "tr-french_te-braille", 
                                           paste(experts$decodingCondition,"_FB",sep=""),
                                           paste(experts$decodingCondition,"_AVG",sep="")))

stats <- experts %>% group_by(mask, decodingCondition, modality, numDecoding) %>% 
  summarize(mean_accuracy = mean(accuracy), sd_accuracy = sd(accuracy), se_accuracy = sd(accuracy)/sqrt(6), .groups = 'keep') 


### Plot the decodings 

# Both training - test conditions
ggplot(subset(stats, mask == "VWFA" & modality == "both"), aes(x = decodingCondition, y = mean_accuracy)) + 
  scale_color_manual(name = "condtions",
                     limits = c("both"),
                     values = c("#8372AC"),
                     labels = c("average")) +
  # Mean and SE bars
  geom_pointrange(aes(x = decodingCondition, 
                      y = mean_accuracy, 
                      ymin = mean_accuracy - se_accuracy, 
                      ymax = mean_accuracy + se_accuracy, 
                      colour = modality),
                  position = position_dodge(1), size = 1, linewidth = 2) +
  # Individual data clouds 
  geom_point(data = subset(experts, modality == "both"),
             aes(x = reorder(decodingCondition, modality),
                 y = accuracy,
                 colour = modality),
             position = position_jitter(w = 0.3, h = 0.01),
             alpha = 0.5,
             legend = F) +
  geom_hline(yintercept = 0.5, size = .25, linetype = "dashed") +            
  theme_classic() +                                                          
  ylim(0.15,1) +                                                                    
  theme(axis.text.x = element_text(size = 15), axis.text.y = element_text(size = 15), 
        axis.ticks = element_blank(), axis.title.y = element_text(size = 20)) +      
  scale_x_discrete(limits=rev,                                                
                   labels = c("RW\nPW","RW\nNW",
                              "RW\nFS","PW\nNW",
                              "PW\nFS","NW\nFS")) +
  labs(x = "Decoding pair", y = "Decoding accuracy", title = "Crossmodal decoding")      

ggsave("figures/trial_cross.png", width = 3000, height = 1800, dpi = 320, units = "px")

