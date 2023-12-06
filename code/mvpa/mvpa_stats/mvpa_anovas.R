setwd("~/Desktop/GitHub/VisualBraille_data/code/mvpa/mvpa_stats")

library(readxl)
library(tidyverse)
library(reshape2)
library(gridExtra)
library(pracma)
library(tidyr)
library(dplyr)
library(car)
library(lme4)


### Load matrices of decoding general for both groups 
# Controls
controls <- read.csv("../../../outputs/derivatives/CoSMoMVPA/decoding-pairwise-within-script_grp-controls_rois-expansionIntersection_nbvoxels-43.csv")
# Experts
experts  <- read.csv("../../../outputs/derivatives/CoSMoMVPA/decoding-pairwise-within-script_grp-experts_rois-expansionIntersection_nbvoxels-43.csv")

### Manipulate the matrices
# as data frame
controls <- as.data.frame(controls)
experts <- as.data.frame(experts)

# Assign group, to keep track once merged
controls$group <- rep("control", nrow(controls))
experts$group <- rep("expert", nrow(experts))

# Group matrices into one
# Why were they separated? 
general <- rbind(experts, controls)

# rename area: VWFAfr to VWFA 
general$mask <- ifelse(general$mask == "VWFAfr", "VWFA", general$mask)

# Assign the script, to ease splitting the original accuracy matrix: 1 = French, 2 = Braille
general$script <- t(repmat(c(1,1,1,1,1,1,2,2,2,2,2,2), 1, nrow(general)/12))

# rename scripts 1 and 2 with french and braille
general$script <- ifelse(general$script == 1, "french", "braille")

# remove tmaps, remove voxNb and image columns
general <- group_split(general, image)[[1]]
general <- subset(general, select = -c(4,5,6,7,8))

# Add number of decoding pair, to place the horizontal lines 
general$numDecoding <- t(repmat(c(1,2), 1,nrow(general)/2))

# calculate stats for error bars
general$cluster <- paste(general$script, general$group, sep="_")
# general$decodingCondition <- ifelse(general$group == "expert", 
#                                     paste(general$decodingCondition,"_exp",sep=""), 
#                                     paste(general$decodingCondition,"_ctr",sep=""))

general$decodingCondition <- sub("^[fb]([a-z]+)_v_[fb]([a-z]+)$", "\\1_v_\\2", general$decodingCondition)

stats_gen <- general %>% group_by(mask, decodingCondition, script, numDecoding, cluster) %>% 
  summarize(mean_accuracy = mean(accuracy), sd_accuracy = sd(accuracy), .groups = 'keep') 


### Do stats
# Divide the dataset into subgroups
# VWFA: french, braille, both
vwfa <- group_split(general, mask)[[1]]
vwfa_fr <- group_split(vwfa, script)[[2]]
vwfa_br <- group_split(vwfa, script)[[1]]

stats_vwfa <- vwfa %>% 
              group_by(decodingCondition, group, numDecoding, cluster) %>% 
              summarize(mean_accuracy = mean(accuracy), sd_accuracy = sd(accuracy), .groups = 'keep') 
stats_vwfa_fr <- vwfa_fr %>% 
                 group_by(mask, decodingCondition, group, numDecoding, cluster) %>% 
                 summarize(mean_accuracy = mean(accuracy), sd_accuracy = sd(accuracy), .groups = 'keep') 
stats_vwfa_br <- vwfa_br %>% 
                 group_by(mask, decodingCondition, group, numDecoding, cluster) %>% 
                 summarize(mean_accuracy = mean(accuracy), sd_accuracy = sd(accuracy), .groups = 'keep') 

# lLO: experts, controls, both
llo <- group_split(general, mask)[[2]]
llo_experts <- group_split(llo, group)[[2]]
llo_controls <- group_split(llo, group)[[1]]

# rLO: experts, controls, both
rlo <- group_split(general, mask)[[3]]
rlo_experts <- group_split(rlo, group)[[2]]
rlo_controls <- group_split(rlo, group)[[1]]

# repeated measures ANOVA
# from chatGPT, needs to be vetted

# Perform repeated measures ANOVA
repeated_anova <- aov(accuracy ~ decodingCondition + Error(subID / decodingCondition) + group, data = vwfa_fr)

# Summary of ANOVA results
summary(repeated_anova)

mixed_model <- lmer(accuracy ~ decodingCondition + (1|group) + (1|subID), data = vwfa_fr)

mixed_anova <- anova(mixed_model, type = 3)

summary(mixed_anova)

# Assuming you have your data loaded into a variable named 'my_data'

# Install and load required package
# install.packages("ez")
library(ez)

# Performing repeated measures ANOVA
result_anova <- ezANOVA(data = vwfa,
                        dv = accuracy, 
                        wid = subID, 
                        within = .c(decodingCondition, script), 
                        between = group, 
                        type = 3) 

# Viewing the ANOVA result
print(result_anova)
print(repeated_anova)

## yet another trial

#create dataset
df <- data.frame(program=rep(c(1, 2), each=20),
                 gender=rep(c('M', 'F'), each=10, times=2),
                 division=rep(c(1, 2), each=5, times=4),
                 height=c(7, 7, 8, 8, 7, 6, 6, 5, 6, 5,
                          5, 5, 4, 5, 4, 3, 3, 4, 3, 3,
                          6, 6, 5, 4, 5, 4, 5, 4, 4, 3,
                          2, 2, 1, 4, 4, 2, 1, 1, 2, 1)) 

#view first six rows of dataset
head(df)

#calculate mean jumping height increase grouped by program, gender, and division
df %>%
  group_by(program, gender, division) %>%
  summarize(mean_height = mean(height))

#perform three-way ANOVA
model <- aov(height ~ program * gender * division, data=df)

#view summary of three-way ANOVA
summary(model)



