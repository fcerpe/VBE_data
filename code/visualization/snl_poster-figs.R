setwd("~/Desktop/GitHub/VisualBraille_data/code/visualization")

library("readxl")
library("tidyverse")
library("reshape2")
library("gridExtra")
library("pracma")
library("dplyr")

### Load matrices of decoding general for both groups 

# Controls
pair_controls <- read.csv("../../outputs/derivatives/CoSMoMVPA/decoding-pairwise-within-script_grp-controls_rois-expansionIntersection_nbvoxels-43.csv")

# Experts
pair_experts <- read.csv("../../outputs/derivatives/CoSMoMVPA/decoding-pairwise-within-script_grp-experts_rois-expansionIntersection_nbvoxels-43.csv")


### Manipulate the matrix to get something readable by ggplot
pair_controls <- as.data.frame(pair_controls)
pair_experts <- as.data.frame(pair_experts)

# rename area: VWFAfr to VWFA 
pair_experts$mask <- ifelse(pair_experts$mask == "VWFAfr", "VWFA", pair_experts$mask)
pair_controls$mask <- ifelse(pair_controls$mask == "VWFAfr", "VWFA", pair_controls$mask)

# Assign the script, to ease splitting the original accuracy matrix: 1 = French, 2 = Braille
pair_experts$script <- t(repmat(c(1,1,1,1,1,1,2,2,2,2,2,2), 1, nrow(pair_experts)/12))
pair_controls$script <- t(repmat(c(1,1,1,1,1,1,2,2,2,2,2,2), 1, nrow(pair_controls)/12))

# Assign group, to keep track once merged
pair_controls$group <- rep("control", nrow(pair_controls))
pair_experts$group <- rep("expert", nrow(pair_experts))

# remove tmaps, remove voxNb and image columns
pair_controls <- group_split(pair_controls, image)[[1]]
pair_controls <- subset(pair_controls, select = -c(4,5,6,7,8))

pair_experts <- group_split(pair_experts, image)[[1]]
pair_experts <- subset(pair_experts, select = -c(4,5,6,7,8))

# rename scripts 1 and 2 with french and braille
pair_controls$script <- ifelse(pair_controls$script == 1, "french", "braille")
pair_experts$script <- ifelse(pair_experts$script == 1, "french", "braille")

# Add number of decoding pair, to place the horizontal lines 
pair_experts$numDecoding <- t(repmat(c(1,2,3,4,5,6,7,8,9,10,11,12), 1,nrow(pair_experts)/12))
pair_controls$numDecoding <- t(repmat(c(1,2,3,4,5,6,7,8,9,10,11,12), 1,nrow(pair_controls)/12))


# calculate stats for error bars
stats_controls <- pair_controls %>% group_by(mask, decodingCondition, script, numDecoding) %>% 
  summarize(mean_accuracy = mean(accuracy), sd_accuracy = sd(accuracy), se_accuracy = sd(accuracy)/sqrt(6), .groups = 'keep') 

stats_experts <- pair_experts %>% group_by(mask, decodingCondition, script, numDecoding) %>% 
  summarize(mean_accuracy = mean(accuracy), sd_accuracy = sd(accuracy), se_accuracy = sd(accuracy)/sqrt(6), .groups = 'keep') 

# combine in general matrix and calculate stats for error bars
general <- rbind(pair_experts, pair_controls)
general$cluster <- paste(general$script, general$group, sep="_")
general$decodingCondition <- ifelse(general$group == "expert", 
                                    paste(general$decodingCondition,"_exp",sep=""), 
                                    paste(general$decodingCondition,"_ctr",sep=""))

stats_gen <- general %>% group_by(mask, decodingCondition, script, numDecoding, cluster) %>% 
  summarize(mean_accuracy = mean(accuracy), sd_accuracy = sd(accuracy), se_accuracy = sd(accuracy)/sqrt(6), .groups = 'keep') 



### Plots - new way

# VWFA
ggplot(subset(stats_gen, mask == "VWFA"), aes(x = decodingCondition, y = mean_accuracy)) + 
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
                  position = position_dodge(1), size = 1, linewidth = 2) +
  # Individual data clouds 
  geom_point(data = subset(general, mask == "VWFA"), 
             aes(x = reorder(decodingCondition, cluster), 
                 y = accuracy, 
                 colour = cluster),
             position = position_jitter(w = 0.3, h = 0.01),
             alpha = 0.5,
             legend = F) +
  geom_hline(yintercept = 0.5, size = .25, linetype = "dashed") +                
  theme_classic() +                                                              
  ylim(0.15,1) +                                                                    
  theme(axis.text.x = element_text(angle = 0, size = 15), 
        axis.text.y = element_text(size = 15), 
        axis.ticks = element_blank(),
        axis.title.y = element_text(size = 20)) +
  scale_x_discrete(limits=rev,                                                   
                   labels = c("     FRW\n     FPW","","     FRW\n     FNW","",
                              "     FRW\n     FFS","","     FPW\n     FNW","",
                              "     FPW\n     FFS","","     FNW\n     FFS","",
                              "     BRW\n     BPW","","     BRW\n     BNW","",
                              "     BRW\n     BFS","","     BPW\n     BNW","",
                              "     BPW\n     BFS","","     BNW\n     BFS","")) +
  labs(y = "Decoding accuracy")      

ggsave("figures/SNL_area-VWFA_pairwise-decoding_mean-accuracy.png", width = 3500, height = 1800, dpi = 320, units = "px")


# lLO 
ggplot(subset(stats_gen, mask == "lLO"), aes(x = decodingCondition, y = mean_accuracy)) + 
  scale_color_manual(name = "      ",
                     limits = c("french_expert",   "french_control",  "braille_expert",    "braille_control"),
                     values = c("#69B5A2",         "#699ae5",         "#FF9E4A",          "#da5F49"),
                     labels = c("expert - french", "control - french", "expert - braille", "control - braille")) +
  geom_pointrange(aes(x = decodingCondition, y = mean_accuracy, 
                      ymin = mean_accuracy - se_accuracy, 
                      ymax = mean_accuracy + se_accuracy, 
                      colour = cluster),
                  position = position_dodge(1), size = 1, linewidth = 2) +
  geom_point(data = subset(general, mask == "lLO"), 
             aes(x = reorder(decodingCondition, cluster), y = accuracy, 
                 colour = cluster),
             position = position_jitter(w = 0.3, h = 0.01),
             alpha = 0.5, legend = F) +
  geom_hline(yintercept = 0.5, size = .25, linetype = "dashed") +                
  theme_classic() +                                                              
  ylim(0.15,1) +                                                                    
  theme(axis.text.x = element_text(size = 15), axis.text.y = element_text(size = 15), 
        axis.ticks = element_blank(), axis.title.y = element_text(size = 20)) +
  scale_x_discrete(limits=rev,                                                   
                   labels = c("     FRW\n     FPW","","     FRW\n     FNW","",
                              "     FRW\n     FFS","","     FPW\n     FNW","",
                              "     FPW\n     FFS","","     FNW\n     FFS","",
                              "     BRW\n     BPW","","     BRW\n     BNW","",
                              "     BRW\n     BFS","","     BPW\n     BNW","",
                              "     BPW\n     BFS","","     BNW\n     BFS","")) +
  labs(y = "Decoding accuracy")      

ggsave("figures/SNL_area-lLO_pairwise-decoding_mean-accuracy.png", width = 3500, height = 1800, dpi = 320, units = "px")


# rLO 
ggplot(subset(stats_gen, mask == "rLO"), aes(x = decodingCondition, y = mean_accuracy)) + 
  scale_color_manual(name = "   ",
                     limits = c("french_expert",   "french_control",  "braille_expert",    "braille_control"),
                     values = c("#69B5A2",         "#699ae5",         "#FF9E4A",          "#da5F49"),
                     labels = c("expert - french", "control - french", "expert - braille", "control - braille")) +
  geom_pointrange(aes(x = decodingCondition, y = mean_accuracy, 
                      ymin = mean_accuracy - se_accuracy, 
                      ymax = mean_accuracy + se_accuracy, 
                      colour = cluster),
                  position = position_dodge(1), size = 1, linewidth = 2) +
  geom_point(data = subset(general, mask == "rLO"), 
             aes(x = reorder(decodingCondition, cluster), y = accuracy, 
                 colour = cluster),
             position = position_jitter(w = 0.3, h = 0.01),
             alpha = 0.5, legend = F) +
  geom_hline(yintercept = 0.5, size = .25, linetype = "dashed") +                
  theme_classic() +                                                              
  ylim(0.15,1) +                                                                    
  theme(axis.text.x = element_text(size = 15), axis.text.y = element_text(size = 15), 
        axis.ticks = element_blank(), axis.title.y = element_text(size = 20)) +
  scale_x_discrete(limits=rev,                                                   
                   labels = c("     FRW\n     FPW","","     FRW\n     FNW","",
                              "     FRW\n     FFS","","     FPW\n     FNW","",
                              "     FPW\n     FFS","","     FNW\n     FFS","",
                              "     BRW\n     BPW","","     BRW\n     BNW","",
                              "     BRW\n     BFS","","     BPW\n     BNW","",
                              "     BPW\n     BFS","","     BNW\n     BFS","")) +
  labs(y = "Decoding accuracy")        

ggsave("figures/SNL_area-rLO_pairwise-decoding_mean-accuracy.png", width = 3500, height = 1800, dpi = 320, units = "px")





### CROSS-SCRIPT DECODING

# Experts
cross_experts <- read.csv("../../outputs/derivatives/CoSMoMVPA/mvpa-decoding_grp-experts_task-wordsDecoding_condition-cross-script_nbvoxels-43.csv")

cross_experts <- as.data.frame(cross_experts)

# rename area: VWFAfr to VWFA 
cross_experts$mask <- ifelse(cross_experts$mask == "VWFAfr", "VWFA", cross_experts$mask)

# Drop unnecessary columns
# remove tmaps, remove voxNb and image columns
cross_experts <- group_split(cross_experts, image)[[1]]
cross_experts <- subset(cross_experts, select = -c(4,5,6,7,8))

# Add number of decoding pair, to place the horizontal lines 
cross_experts$numDecoding <- t(repmat(c(1,2,3,4,5,6), 1,nrow(cross_experts)/6))
cross_experts$decodingCondition <- ifelse(cross_experts$modality == "tr-braille_te-french", 
                                    paste(cross_experts$decodingCondition,"_BF",sep=""), 
                                    ifelse(cross_experts$modality == "tr-french_te-braille", 
                                           paste(cross_experts$decodingCondition,"_FB",sep=""),
                                           paste(cross_experts$decodingCondition,"_AVG",sep="")))

stats <- cross_experts %>% group_by(mask, decodingCondition, modality, numDecoding) %>% 
  summarize(mean_accuracy = mean(accuracy), sd_accuracy = sd(accuracy), se_accuracy = sd(accuracy)/sqrt(6), .groups = 'keep') 

### Plot the decodings 

# Both training - test conditions
ggplot(subset(stats, mask == "VWFA" & modality != "both"), aes(x = decodingCondition, y = mean_accuracy)) + 
  scale_color_manual(name = "script x group",
                     limits = c("tr-french_te-braille", "tr-braille_te-french"),
                     values = c("#69B5A2",              "#FF9E4A"),
                     labels = c("training FR, test BR", "training BR, test FR"),
                     aesthetics = c("colour", "fill")) +
  geom_pointrange(aes(x = decodingCondition, y = mean_accuracy, 
                      ymin = mean_accuracy - se_accuracy, 
                      ymax = mean_accuracy + se_accuracy, 
                      colour = modality),
                  position = position_dodge(1), size = 1, linewidth = 2) +
  geom_point(data = subset(cross_experts, mask == "VWFA" & modality != "both"),
             aes(x = reorder(decodingCondition, modality), y = accuracy,
                 colour = modality),
             position = position_jitter(w = 0.3, h = 0.01),
             alpha = 0.5, legend = F) +
  geom_hline(yintercept = 0.5, size = .25, linetype = "dashed") +            
  theme_classic() +                                                          
  ylim(0.15,1) +                                                                    
  theme(axis.text.x = element_text(size = 15), axis.text.y = element_text(size = 15), 
        axis.ticks = element_blank(), axis.title.y = element_text(size = 20)) +      
  scale_x_discrete(limits=rev,                                                
                   labels = c("         RW\n         PW","","         RW\n         NW","",
                              "         RW\n         FS","","         PW\n         NW","",
                              "         PW\n         FS","","         NW\n         FS","")) +
  labs(y = "Decoding accuracy")      

ggsave("figures/SNL_area-VWFA_crossmodal-decoding_mean-accuracy.png", width = 3000, height = 1800, dpi = 320, units = "px")

# Average
ggplot(subset(stats, mask == "VWFA" & modality == "both"), aes(x = decodingCondition, y = mean_accuracy)) + 
  scale_color_manual(name = "script x group",
                     limits = c("both"),
                     values = c("#8372AC"),
                     labels = c("average"),
                     aesthetics = c("colour", "fill")) +
  geom_pointrange(aes(x = decodingCondition, y = mean_accuracy, 
                      ymin = mean_accuracy - se_accuracy, 
                      ymax = mean_accuracy + se_accuracy, 
                      colour = modality),
                  position = position_dodge(1), size = 1, linewidth = 2) +
  geom_point(data = subset(cross_experts, mask == "VWFA" & modality == "both"),
             aes(x = reorder(decodingCondition, modality), y = accuracy,
                 colour = modality),
             position = position_jitter(w = 0.3, h = 0.01),
             alpha = 0.5, legend = F) +
  geom_hline(yintercept = 0.5, size = .25, linetype = "dashed") +            
  theme_classic() +                                                          
  ylim(0.15,1) +                                                                    
  theme(axis.text.x = element_text(size = 15), axis.text.y = element_text(size = 15), 
        axis.ticks = element_blank(), axis.title.y = element_text(size = 20)) +      
  scale_x_discrete(limits=rev,                                                
                   labels = c("RW\nPW","RW\nNW",
                              "RW\nFS","PW\nNW",
                              "PW\nFS","NW\nFS")) +
  labs(y = "Decoding accuracy")      

ggsave("figures/SNL_area-VWFA_crossmodal-decoding_average.png", width = 3000, height = 1800, dpi = 320, units = "px")


### RSA

# Cluster for area
vwfa_ctr_accu <- group_split(general, mask, group)[[1]]
vwfa_exp_accu <- group_split(general, mask, group)[[2]]

# make RDMs
vwfa_exp_fr <- group_split(vwfa_exp_accu, script)[[2]]
vwfa_exp_br <- group_split(vwfa_exp_accu, script)[[1]]
vwfa_ctr_fr <- group_split(vwfa_ctr_accu, script)[[2]]
vwfa_ctr_br <- group_split(vwfa_ctr_accu, script)[[1]]

# perform correlations
vwfa_EXFR_EXBR <- cor.test(vwfa_exp_fr[["accuracy"]], vwfa_exp_br[["accuracy"]])
vwfa_CTFR_CTBR <- cor.test(vwfa_ctr_fr[["accuracy"]], vwfa_ctr_br[["accuracy"]])
vwfa_EXFR_CTFR <- cor.test(vwfa_exp_fr[["accuracy"]], vwfa_ctr_fr[["accuracy"]])
vwfa_EXBR_CTFR <- cor.test(vwfa_exp_br[["accuracy"]], vwfa_ctr_fr[["accuracy"]])
vwfa_EXFR_CTBR <- cor.test(vwfa_exp_fr[["accuracy"]], vwfa_ctr_br[["accuracy"]])
vwfa_EXBR_CTBR <- cor.test(vwfa_exp_br[["accuracy"]], vwfa_ctr_br[["accuracy"]])

# average decodings 
vwfa_exp_br_means <- aggregate(vwfa_exp_br$accuracy, list(vwfa_exp_br$decodingCondition), FUN=mean)
vwfa_exp_fr_means <- aggregate(vwfa_exp_fr$accuracy, list(vwfa_exp_fr$decodingCondition), FUN=mean) 
vwfa_ctr_br_means <- aggregate(vwfa_ctr_br$accuracy, list(vwfa_ctr_br$decodingCondition), FUN=mean)
vwfa_ctr_fr_means <- aggregate(vwfa_ctr_fr$accuracy, list(vwfa_ctr_fr$decodingCondition), FUN=mean) 

# make RDM - manually since they're small
vwfa_exp_br_rdm = c(vwfa_exp_br_means[[4,2]],vwfa_exp_br_means[[2,2]],vwfa_exp_br_means[[1,2]],NaN,vwfa_exp_br_means[[5,2]],vwfa_exp_br_means[[3,2]],NaN,vwfa_exp_br_means[[1,2]],
                    vwfa_exp_br_means[[6,2]],NaN,vwfa_exp_br_means[[3,2]],vwfa_exp_br_means[[2,2]],NaN,vwfa_exp_br_means[[6,2]],vwfa_exp_br_means[[5,2]],vwfa_exp_br_means[[4,2]])
vwfa_exp_fr_rdm = c(vwfa_exp_fr_means[[4,2]],vwfa_exp_fr_means[[2,2]],vwfa_exp_fr_means[[1,2]],NaN,vwfa_exp_fr_means[[5,2]],vwfa_exp_fr_means[[3,2]],NaN,vwfa_exp_fr_means[[1,2]],
                    vwfa_exp_fr_means[[6,2]],NaN,vwfa_exp_fr_means[[3,2]],vwfa_exp_fr_means[[2,2]],NaN,vwfa_exp_fr_means[[6,2]],vwfa_exp_fr_means[[5,2]],vwfa_exp_fr_means[[4,2]])
vwfa_ctr_br_rdm = c(vwfa_ctr_br_means[[4,2]],vwfa_ctr_br_means[[2,2]],vwfa_ctr_br_means[[1,2]],NaN,vwfa_ctr_br_means[[5,2]],vwfa_ctr_br_means[[3,2]],NaN,vwfa_ctr_br_means[[1,2]],
                    vwfa_ctr_br_means[[6,2]],NaN,vwfa_ctr_br_means[[3,2]],vwfa_ctr_br_means[[2,2]],NaN,vwfa_ctr_br_means[[6,2]],vwfa_ctr_br_means[[5,2]],vwfa_ctr_br_means[[4,2]])
vwfa_ctr_fr_rdm = c(vwfa_ctr_fr_means[[4,2]],vwfa_ctr_fr_means[[2,2]],vwfa_ctr_fr_means[[1,2]],NaN,vwfa_ctr_fr_means[[5,2]],vwfa_ctr_fr_means[[3,2]],NaN,vwfa_ctr_fr_means[[1,2]],
                    vwfa_ctr_fr_means[[6,2]],NaN,vwfa_ctr_fr_means[[3,2]],vwfa_ctr_fr_means[[2,2]],NaN,vwfa_ctr_fr_means[[6,2]],vwfa_ctr_fr_means[[5,2]],vwfa_ctr_fr_means[[4,2]])

# Re-arrange labels to make ggplot happy
fx <- c("FRW", "FPW", "FNW", "FFS"); fy <- c("FFS", "FNW", "FPW", "FRW")
bx <- c("BRW", "BPW", "BNW", "BFS"); by <- c("BFS", "BNW", "BPW", "BRW")
rdm_exp_vwfa_fr <- expand.grid(X=fx, Y=fy); rdm_exp_vwfa_fr$accuracy <- vwfa_exp_fr_rdm
rdm_exp_vwfa_br <- expand.grid(X=bx, Y=by); rdm_exp_vwfa_br$accuracy <- vwfa_exp_br_rdm
rdm_ctr_vwfa_fr <- expand.grid(X=fx, Y=fy); rdm_ctr_vwfa_fr$accuracy <- vwfa_ctr_fr_rdm
rdm_ctr_vwfa_br <- expand.grid(X=bx, Y=by); rdm_ctr_vwfa_br$accuracy <- vwfa_ctr_br_rdm

### Plots
# VWFA - EXP - FR
ggplot(rdm_exp_vwfa_fr, aes(X, Y, fill = accuracy)) + 
  geom_tile() + 
  theme_classic() +  
  theme(axis.title.x=element_blank(), axis.ticks.x=element_blank(),
        axis.text.x = element_text(colour="#000000", size=30),
        axis.line.x = element_blank(), 
        axis.title.y=element_blank(), axis.ticks.y=element_blank(), 
        axis.text.y = element_text(colour="#000000", size=30),
        axis.line.y = element_blank()) +
  scale_fill_gradient2(low = "#ffffff", 
                       mid = "#FFFFFF", 
                       high = "#69b5a2",
                       na.value = "#FFFFFF", limit = c(0.1,1)) + 
  coord_fixed()

ggsave("figures/SNL_area-VWFA_rsa-experts-french.png", width = 3600, height = 3000, dpi = 320, units = "px")

# VWFA - BR
ggplot(rdm_exp_vwfa_br, aes(X, Y, fill = accuracy)) + 
  geom_tile() + 
  theme_classic() +  
  theme(axis.title.x=element_blank(), axis.ticks.x=element_blank(),
        axis.text.x = element_text(colour="#000000", size=30),
        axis.line.x = element_blank(), 
        axis.title.y=element_blank(), axis.ticks.y=element_blank(), 
        axis.text.y = element_text(colour="#000000", size=30),
        axis.line.y = element_blank()) +
  scale_fill_gradient2(low = "#ffffff", 
                       mid = "#FFFFFF",  
                       high = "#ff9e4a", 
                       na.value = "#FFFFFF", limit = c(0.1,1)) + 
  coord_fixed()

ggsave("figures/SNL_area-VWFA_rsa-experts-braille.png", width = 3600, height = 3000, dpi = 320, units = "px")

# VWFA - CTR - FR
ggplot(rdm_ctr_vwfa_fr, aes(X, Y, fill = accuracy)) + 
  geom_tile() + 
  theme_classic() +  
  theme(axis.title.x=element_blank(), axis.ticks.x=element_blank(),
        axis.text.x = element_text(colour="#000000", size=30),
        axis.line.x = element_blank(), 
        axis.title.y=element_blank(), axis.ticks.y=element_blank(), 
        axis.text.y = element_text(colour="#000000", size=30),
        axis.line.y = element_blank()) +
  scale_fill_gradient2(low = "#ffffff", 
                       mid = "#FFFFFF",
                       high = "#699ae5", 
                       na.value = "#FFFFFF", limit = c(0.1,1)) + 
  coord_fixed()

ggsave("figures/SNL_area-VWFA_rsa-controls-french.png", width = 3600, height = 3000, dpi = 320, units = "px")

# VWFA - BR
ggplot(rdm_ctr_vwfa_br, aes(X, Y, fill = accuracy)) + 
  geom_tile() + 
  theme_classic() +  
  theme(axis.title.x=element_blank(), axis.ticks.x=element_blank(),
        axis.text.x = element_text(colour="#000000", size=30),
        axis.line.x = element_blank(), 
        axis.title.y=element_blank(), axis.ticks.y=element_blank(), 
        axis.text.y = element_text(colour="#000000", size=30),
        axis.line.y = element_blank()) +
  scale_fill_gradient2(low = "#ffffff", 
                       mid = "#FFFFFF",
                       high = "#da5F49",
                       na.value = "#FFFFFF", limit = c(0.1,1)) + 
  coord_fixed()

ggsave("figures/SNL_area-VWFA_rsa-controls-braille.png", width = 3600, height = 3000, dpi = 320, units = "px")


# all correlations within VWFA
corr_vwfa_eFR_eBR <- cor.test(vwfa_exp_fr_means[["x"]], vwfa_exp_br_means[["x"]])
corr_vwfa_cFR_cBR <- cor.test(vwfa_ctr_fr_means[["x"]], vwfa_ctr_br_means[["x"]])
corr_vwfa_eFR_cBR <- cor.test(vwfa_exp_fr_means[["x"]], vwfa_ctr_br_means[["x"]])
corr_vwfa_cFR_eBR <- cor.test(vwfa_ctr_fr_means[["x"]], vwfa_exp_br_means[["x"]])
corr_vwfa_eFR_cFR <- cor.test(vwfa_exp_fr_means[["x"]], vwfa_ctr_fr_means[["x"]])
corr_vwfa_cBR_eBR <- cor.test(vwfa_ctr_br_means[["x"]], vwfa_exp_br_means[["x"]])