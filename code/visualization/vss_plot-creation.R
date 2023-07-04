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
  read.csv("../../outputs/derivatives/CoSMoMVPA/mvpa-decoding_grp-experts_task-wordsDecoding_condition-pairwise-within-script_nbvoxels-73.csv")



### Manipulate the matrix to get something readable by ggplot

ctrl_accuracies <- as.data.frame(ctrl_accuracies)
exp_accuracies <- as.data.frame(exp_accuracies)

# Assign the script, to ease splitting the original accuracy matrix: 1 = French, 2 = Braille
ctrl_accuracies$script <- t(repmat(c(1,1,1,1,1,1,2,2,2,2,2,2), 1,36))
exp_accuracies$script <- t(repmat(c(1,1,1,1,1,1,2,2,2,2,2,2), 1,36))

# Assign group, to keep track once merged
ctrl_accuracies$group <- rep("control", 432)
exp_accuracies$group <- rep("expert", 432)

# Join matrices and specify who's control and who's expert
accuracies <- rbind(exp_accuracies, ctrl_accuracies)

# Rename scripts and VWFA
accuracies$script <- ifelse(accuracies$script == 1, "french", "braille")
accuracies$mask <- ifelse(accuracies$mask == "VWFAfr", "VWFA", accuracies$mask)
# accuracies$group <- ifelse(accuracies$script == "french" & accuracies$group == "expert", 
#                            "experts - french script", accuracies$group)
# accuracies$group <- ifelse(accuracies$script == "braille" & accuracies$group == "expert", 
#                            "experts - braille script", accuracies$group)
# accuracies$group <- ifelse(accuracies$script == "french" & accuracies$group == "control", 
#                            "controls - french script", accuracies$group)
# accuracies$group <- ifelse(accuracies$script == "braille" & accuracies$group == "control", 
#                            "controls - braille script", accuracies$group)

# Drop unnecessary columns
accuracies <- subset(accuracies, select = -c(4,7,8))

# remove tmaps, remove voxNb and image columns
accuracies <- group_split(accuracies, image)[[1]]
accuracies <- subset(accuracies, select = -c(4,5))

# Cluster for area
vwfa_ctr_accu <- group_split(accuracies, mask, group)[[1]]
vwfa_exp_accu <- group_split(accuracies, mask, group)[[2]]
llo_ctr_accu <- group_split(accuracies, mask, group)[[3]]
llo_exp_accu <- group_split(accuracies, mask, group)[[4]]
rlo_ctr_accu <- group_split(accuracies, mask, group)[[5]]
rlo_exp_accu <- group_split(accuracies, mask, group)[[6]]



### Plots - mean decoding
# Plot 6 separate graphs, each area and group (for color purposes)
# Will need some manual work to put them in order later

# MODEL MVPA
vwfa_exp_plot <- ggplot(accuracies, aes(x = group, y = accuracy), middle = mean(accuracy))
vwfa_exp_plot + geom_boxplot(lwd = 0.75, outlier.shape = NA, aes(colour = group)) +   theme_classic() + 
  scale_color_manual(name = "Group and script", 
                     values = c("experts - french script"  = "#69B5A2", 
                                "experts - braille script" = "#FF9E4A",
                                "controls - french script"  = "#699ae5", 
                                "controls - braille script" = "#da5F49")) +
  geom_hline(aes(yintercept = 0.5), size = .25, linetype = "dashed") +  ylim(0.15,1)+
  scale_x_discrete(limits=rev)

ggsave("figures/imrf_mvpa_model.png", width = 3000, height = 000, dpi = 320, units = "px")

# VWFA - EXP
vwfa_exp_plot <- ggplot(vwfa_exp_accu, aes(x = decodingCondition, y = accuracy), middle = mean(accuracy))
vwfa_exp_plot + geom_boxplot(lwd = 0.75, outlier.shape = NA, aes(colour = script)) +   theme_classic() + 
  scale_color_manual(name = "Script", values = c("french" = "#69B5A2", "braille" = "#FF9E4A")) +
  geom_hline(aes(yintercept = 0.5), size = .25, linetype = "dashed") +  ylim(0.15,1) +  
  geom_jitter(aes(colour = script), width = 0.2, alpha = 0.8) +  
  theme(axis.text.x = element_text(angle = 45,  vjust=1, hjust=1, size = 20), 
        axis.text.y = element_text(size = 20), axis.title.x = element_blank(),
        axis.title.y = element_text(size = 25)) + 
  scale_x_discrete(limits=rev, labels = c("FRW - FPW", "FRW - FNW", "FRW - FFS", "FPW - FNW",
                                          "FPW - FFS", "FNW - FFS", "BRW - BPW", "BRW - BNW",
                                          "BRW - BFS", "BPW - BNW", "BPW - BFS", "BNW - BFS")) +
  labs(y = "Decoding accuracy")
ggsave("figures/vss_pairwise-decoding_vwfa-exp.png", width = 2000, height = 2000, dpi = 320, units = "px")

# VWFA - CTR
vwfa_ctr_plot <- ggplot(vwfa_ctr_accu, aes(x = decodingCondition, y = accuracy), middle = mean(accuracy))
vwfa_ctr_plot + geom_boxplot(lwd = 0.75, outlier.shape = NA, aes(colour = script)) +   theme_classic() +  
  scale_color_manual(name = "script", values = c("braille" = "#da5F49", "french" = "#699ae5")) +
  geom_hline(aes(yintercept = 0.5), size = .25, linetype = "dashed") +  ylim(0.15,1) +  
  geom_jitter(aes(colour = script), width = 0.2, alpha = 0.8) +  
  theme(axis.text.x = element_text(angle = 45,  vjust=1, hjust=1, size = 20), 
        axis.text.y = element_text(size = 20), axis.title.x = element_blank(),
        axis.title.y = element_text(size = 20)) + 
  scale_x_discrete(limits=rev, labels = c("FRW - FPW", "FRW - FNW", "FRW - FFS", "FPW - FNW",
                                          "FPW - FFS", "FNW - FFS", "BRW - BPW", "BRW - BNW",
                                          "BRW - BFS", "BPW - BNW", "BPW - BFS", "BNW - BFS")) +
  labs(y = "Decoding accuracy")
ggsave("figures/vss_pairwise-decoding_vwfa-ctr.png", width = 2000, height = 2000, dpi = 320, units = "px")

# lLO - EXP
llo_exp_plot <- ggplot(llo_exp_accu, aes(x = decodingCondition, y = accuracy), middle = mean(accuracy))
llo_exp_plot + geom_boxplot(lwd = 0.75, outlier.shape = NA, aes(colour = script)) +   theme_classic() + 
  scale_color_manual(name = "Script", values = c("french" = "#69B5A2", "braille" = "#FF9E4A")) +
  geom_hline(aes(yintercept = 0.5), size = .25, linetype = "dashed") +  ylim(0.15,1) +  
  geom_jitter(aes(colour = script), width = 0.2, alpha = 0.8) +  
  theme(axis.text.x = element_text(angle = 45,  vjust=1, hjust=1, size = 20), 
        axis.text.y = element_text(size = 20), axis.title.x = element_blank(),
        axis.title.y = element_text(size = 20)) + 
  scale_x_discrete(limits=rev, labels = c("FRW - FPW", "FRW - FNW", "FRW - FFS", "FPW - FNW",
                                          "FPW - FFS", "FNW - FFS", "BRW - BPW", "BRW - BNW",
                                          "BRW - BFS", "BPW - BNW", "BPW - BFS", "BNW - BFS")) +
  labs(y = "Decoding accuracy")
ggsave("figures/vss_pairwise-decoding_llo-exp.png", width = 2000, height = 2000, dpi = 320, units = "px")

# lLO - CTR
llo_ctr_plot <- ggplot(llo_ctr_accu, aes(x = decodingCondition, y = accuracy), middle = mean(accuracy))
llo_ctr_plot + geom_boxplot(lwd = 0.75, outlier.shape = NA, aes(colour = script)) +   theme_classic() +  
  scale_color_manual(name = "script", values = c("braille" = "#da5F49", "french" = "#699ae5")) +
  geom_hline(aes(yintercept = 0.5), size = .25, linetype = "dashed") +  ylim(0.15,1) +  
  geom_jitter(aes(colour = script), width = 0.2, alpha = 0.8) +  
  theme(axis.text.x = element_text(angle = 45,  vjust=1, hjust=1, size = 20), 
        axis.text.y = element_text(size = 20), axis.title.x = element_blank(),
        axis.title.y = element_text(size = 20)) + 
  scale_x_discrete(limits=rev, labels = c("FRW - FPW", "FRW - FNW", "FRW - FFS", "FPW - FNW",
                                          "FPW - FFS", "FNW - FFS", "BRW - BPW", "BRW - BNW",
                                          "BRW - BFS", "BPW - BNW", "BPW - BFS", "BNW - BFS")) +
  labs(y = "Decoding accuracy")
ggsave("figures/vss_pairwise-decoding_llo-ctr.png", width = 2000, height = 2000, dpi = 320, units = "px")

# rLO - EXP
rlo_exp_plot <- ggplot(rlo_exp_accu, aes(x = decodingCondition, y = accuracy), middle = mean(accuracy))
rlo_exp_plot + geom_boxplot(lwd = 0.75, outlier.shape = NA, aes(colour = script)) +   theme_classic() + 
  scale_color_manual(name = "Script", values = c("french" = "#69B5A2", "braille" = "#FF9E4A")) +
  geom_hline(aes(yintercept = 0.5), size = .25, linetype = "dashed") +  ylim(0.15,1) +  
  geom_jitter(aes(colour = script), width = 0.2, alpha = 0.8) +  
  theme(axis.text.x = element_text(angle = 45,  vjust=1, hjust=1, size = 20), 
        axis.text.y = element_text(size = 20), axis.title.x = element_blank(),
        axis.title.y = element_text(size = 20)) + 
  scale_x_discrete(limits=rev, labels = c("FRW - FPW", "FRW - FNW", "FRW - FFS", "FPW - FNW",
                                          "FPW - FFS", "FNW - FFS", "BRW - BPW", "BRW - BNW",
                                          "BRW - BFS", "BPW - BNW", "BPW - BFS", "BNW - BFS")) +
  labs(y = "Decoding accuracy")
ggsave("figures/vss_pairwise-decoding_rlo-exp.png", width = 2000, height = 2000, dpi = 320, units = "px")

# rLO - CTR
rlo_ctr_plot <- ggplot(rlo_ctr_accu, aes(x = decodingCondition, y = accuracy), middle = mean(accuracy))
rlo_ctr_plot + geom_boxplot(lwd = 0.75, outlier.shape = NA, aes(colour = script)) +   theme_classic() +  
  scale_color_manual(name = "script", values = c("braille" = "#da5F49", "french" = "#699ae5")) +
  geom_hline(aes(yintercept = 0.5), size = .25, linetype = "dashed") +  ylim(0.15,1) +  
  geom_jitter(aes(colour = script), width = 0.2, alpha = 0.8) +  
  theme(axis.text.x = element_text(angle = 45,  vjust=1, hjust=1, size = 20), 
        axis.text.y = element_text(size = 20), axis.title.x = element_blank(),
        axis.title.y = element_text(size = 20)) + 
  scale_x_discrete(limits=rev, labels = c("FRW - FPW", "FRW - FNW", "FRW - FFS", "FPW - FNW",
                                          "FPW - FFS", "FNW - FFS", "BRW - BPW", "BRW - BNW",
                                          "BRW - BFS", "BPW - BNW", "BPW - BFS", "BNW - BFS")) +
  labs(y = "Decoding accuracy")
ggsave("figures/vss_pairwise-decoding_rlo-ctr.png", width = 2000, height = 2000, dpi = 320, units = "px")



### RSA

# make RDMs
vwfa_exp_fr <- group_split(vwfa_exp_accu, script)[[2]]
vwfa_exp_br <- group_split(vwfa_exp_accu, script)[[1]]
vwfa_ctr_fr <- group_split(vwfa_ctr_accu, script)[[2]]
vwfa_ctr_br <- group_split(vwfa_ctr_accu, script)[[1]]
llo_exp_fr <- group_split(llo_exp_accu, script)[[2]]
llo_exp_br <- group_split(llo_exp_accu, script)[[1]]
rlo_exp_fr <- group_split(rlo_exp_accu, script)[[2]]
rlo_exp_br <- group_split(rlo_exp_accu, script)[[1]]


# perform correlations
vwfa_exp_corr <- cor.test(vwfa_exp_fr[["accuracy"]], vwfa_exp_br[["accuracy"]])
vwfa_ctr_corr <- cor.test(vwfa_ctr_fr[["accuracy"]], vwfa_ctr_br[["accuracy"]])


llo_corr <- cor.test(llo_exp_fr[["accuracy"]], llo_exp_br[["accuracy"]])
rlo_corr <- cor.test(rlo_exp_fr[["accuracy"]], rlo_exp_br[["accuracy"]])

# average decodings 
vwfa_exp_br_means <- aggregate(vwfa_exp_br$accuracy, list(vwfa_exp_br$decodingCondition), FUN=mean)
vwfa_exp_fr_means <- aggregate(vwfa_exp_fr$accuracy, list(vwfa_exp_fr$decodingCondition), FUN=mean) 
vwfa_ctr_br_means <- aggregate(vwfa_ctr_br$accuracy, list(vwfa_ctr_br$decodingCondition), FUN=mean)
vwfa_ctr_fr_means <- aggregate(vwfa_ctr_fr$accuracy, list(vwfa_ctr_fr$decodingCondition), FUN=mean) 
llo_exp_br_means <- aggregate(llo_exp_br$accuracy, list(llo_exp_br$decodingCondition), FUN=mean)
llo_exp_fr_means <- aggregate(llo_exp_fr$accuracy, list(llo_exp_fr$decodingCondition), FUN=mean) 
rlo_exp_br_means <- aggregate(rlo_exp_br$accuracy, list(rlo_exp_br$decodingCondition), FUN=mean)
rlo_exp_fr_means <- aggregate(rlo_exp_fr$accuracy, list(rlo_exp_fr$decodingCondition), FUN=mean) 

# make RDM - manually since they're small
vwfa_exp_br_rdm = c(vwfa_exp_br_means[[4,2]],vwfa_exp_br_means[[2,2]],vwfa_exp_br_means[[1,2]],NaN,vwfa_exp_br_means[[5,2]],vwfa_exp_br_means[[3,2]],NaN,vwfa_exp_br_means[[1,2]],
                    vwfa_exp_br_means[[6,2]],NaN,vwfa_exp_br_means[[3,2]],vwfa_exp_br_means[[2,2]],NaN,vwfa_exp_br_means[[6,2]],vwfa_exp_br_means[[5,2]],vwfa_exp_br_means[[4,2]])
vwfa_exp_fr_rdm = c(vwfa_exp_fr_means[[4,2]],vwfa_exp_fr_means[[2,2]],vwfa_exp_fr_means[[1,2]],NaN,vwfa_exp_fr_means[[5,2]],vwfa_exp_fr_means[[3,2]],NaN,vwfa_exp_fr_means[[1,2]],
                    vwfa_exp_fr_means[[6,2]],NaN,vwfa_exp_fr_means[[3,2]],vwfa_exp_fr_means[[2,2]],NaN,vwfa_exp_fr_means[[6,2]],vwfa_exp_fr_means[[5,2]],vwfa_exp_fr_means[[4,2]])
vwfa_ctr_br_rdm = c(vwfa_ctr_br_means[[4,2]],vwfa_ctr_br_means[[2,2]],vwfa_ctr_br_means[[1,2]],NaN,vwfa_ctr_br_means[[5,2]],vwfa_ctr_br_means[[3,2]],NaN,vwfa_ctr_br_means[[1,2]],
                    vwfa_ctr_br_means[[6,2]],NaN,vwfa_ctr_br_means[[3,2]],vwfa_ctr_br_means[[2,2]],NaN,vwfa_ctr_br_means[[6,2]],vwfa_ctr_br_means[[5,2]],vwfa_ctr_br_means[[4,2]])
vwfa_ctr_fr_rdm = c(vwfa_ctr_fr_means[[4,2]],vwfa_ctr_fr_means[[2,2]],vwfa_ctr_fr_means[[1,2]],NaN,vwfa_ctr_fr_means[[5,2]],vwfa_ctr_fr_means[[3,2]],NaN,vwfa_ctr_fr_means[[1,2]],
                    vwfa_ctr_fr_means[[6,2]],NaN,vwfa_ctr_fr_means[[3,2]],vwfa_ctr_fr_means[[2,2]],NaN,vwfa_ctr_fr_means[[6,2]],vwfa_ctr_fr_means[[5,2]],vwfa_ctr_fr_means[[4,2]])

llo_exp_br_rdm = c(llo_exp_br_means[[4,2]],llo_exp_br_means[[2,2]],llo_exp_br_means[[1,2]],NaN,llo_exp_br_means[[5,2]],llo_exp_br_means[[3,2]],NaN,llo_exp_br_means[[1,2]],
                    llo_exp_br_means[[6,2]],NaN,llo_exp_br_means[[3,2]],llo_exp_br_means[[2,2]],NaN,llo_exp_br_means[[6,2]],llo_exp_br_means[[5,2]],llo_exp_br_means[[4,2]])
llo_exp_fr_rdm = c(llo_exp_fr_means[[4,2]],llo_exp_fr_means[[2,2]],llo_exp_fr_means[[1,2]],NaN,llo_exp_fr_means[[5,2]],llo_exp_fr_means[[3,2]],NaN,llo_exp_fr_means[[1,2]],
                    llo_exp_fr_means[[6,2]],NaN,llo_exp_fr_means[[3,2]],llo_exp_fr_means[[2,2]],NaN,llo_exp_fr_means[[6,2]],llo_exp_fr_means[[5,2]],llo_exp_fr_means[[4,2]])
rlo_exp_br_rdm = c(rlo_exp_br_means[[4,2]],rlo_exp_br_means[[2,2]],rlo_exp_br_means[[1,2]],NaN,rlo_exp_br_means[[5,2]],rlo_exp_br_means[[3,2]],NaN,rlo_exp_br_means[[1,2]],
                    rlo_exp_br_means[[6,2]],NaN,rlo_exp_br_means[[3,2]],rlo_exp_br_means[[2,2]],NaN,rlo_exp_br_means[[6,2]],rlo_exp_br_means[[5,2]],rlo_exp_br_means[[4,2]])
rlo_exp_fr_rdm = c(rlo_exp_fr_means[[4,2]],rlo_exp_fr_means[[2,2]],rlo_exp_fr_means[[1,2]],NaN,rlo_exp_fr_means[[5,2]],rlo_exp_fr_means[[3,2]],NaN,rlo_exp_fr_means[[1,2]],
                    rlo_exp_fr_means[[6,2]],NaN,rlo_exp_fr_means[[3,2]],rlo_exp_fr_means[[2,2]],NaN,rlo_exp_fr_means[[6,2]],rlo_exp_fr_means[[5,2]],rlo_exp_fr_means[[4,2]])

# Re-arrange labels to make ggplot happy
fx <- c("FRW", "FPW", "FNW", "FFS"); fy <- c("FFS", "FNW", "FPW", "FRW")
bx <- c("BRW", "BPW", "BNW", "BFS"); by <- c("BFS", "BNW", "BPW", "BRW")
rdm_exp_vwfa_fr <- expand.grid(X=fx, Y=fy); rdm_exp_vwfa_fr$accuracy <- vwfa_exp_fr_rdm
rdm_exp_vwfa_br <- expand.grid(X=bx, Y=by); rdm_exp_vwfa_br$accuracy <- vwfa_exp_br_rdm
rdm_ctr_vwfa_fr <- expand.grid(X=fx, Y=fy); rdm_ctr_vwfa_fr$accuracy <- vwfa_ctr_fr_rdm
rdm_ctr_vwfa_br <- expand.grid(X=bx, Y=by); rdm_ctr_vwfa_br$accuracy <- vwfa_ctr_br_rdm
rdm_exp_llo_fr <- expand.grid(X=x, Y=y); rdm_llo_fr$accuracy <- llo_exp_fr_rdm
rdm_exp_llo_br <- expand.grid(X=x, Y=y); rdm_llo_br$accuracy <- llo_exp_br_rdm
rdm_ctr_rlo_fr <- expand.grid(X=x, Y=y); rdm_rlo_fr$accuracy <- rlo_exp_fr_rdm
rdm_ctr_rlo_br <- expand.grid(X=x, Y=y); rdm_rlo_br$accuracy <- rlo_exp_br_rdm



### Plots
# VWFA - EXP - FR
ggplot(rdm_exp_vwfa_fr, aes(X, Y, fill = accuracy)) + 
  geom_tile() + theme_classic() +  theme(axis.title.x=element_blank(), axis.ticks.x=element_blank(),
        axis.title.y=element_blank(), axis.ticks.y=element_blank(), axis.text.x = element_text(face="bold", colour="#000000", size=25),
        axis.text.y = element_text(face="bold", colour="#000000", size=25), axis.line.x = element_blank(), axis.line.y = element_blank()) +
  scale_fill_gradient2(low = "#ffffff", mid = "#FFFFFF", high = "#69b5a2", na.value = "#FFFFFF", limit = c(0.1,1)) + 
  guides(fill = guide_colourbar(barwidth = 0.8, barheight = 40, ticks = FALSE, title = "", label.theme = element_text(size = 20, angle = 0))) +  coord_fixed()
ggsave("figures/vss_rsa_vwfa-exp-fr.png", width = 3600, height = 3000, dpi = 320, units = "px")

# VWFA - BR
ggplot(rdm_exp_vwfa_br, aes(X, Y, fill = accuracy)) + 
  geom_tile() + theme_classic() +  theme(axis.title.x=element_blank(), axis.ticks.x=element_blank(),
        axis.title.y=element_blank(), axis.ticks.y=element_blank(), axis.text.x = element_text(face="bold", colour="#000000", size=25),
        axis.text.y = element_text(face="bold", colour="#000000", size=25), axis.line.x = element_blank(), axis.line.y = element_blank()) +
  scale_fill_gradient2(low = "#FFFFFF", mid = "#FFFFFF", high = "#ff9e4a", na.value = "#FFFFFF", limit = c(0.1,1)) + 
  guides(fill = guide_colourbar(barwidth = 0.8, barheight = 40, ticks = FALSE, title = "", label.theme = element_text(size = 20, angle = 0))) +  coord_fixed()
ggsave("figures/vss_rsa_vwfa-exp-br.png", width = 3600, height = 3000, dpi = 320, units = "px")

# VWFA - CTR - FR
ggplot(rdm_ctr_vwfa_fr, aes(X, Y, fill = accuracy)) + 
  geom_tile() + theme_classic() +  theme(axis.title.x=element_blank(), axis.ticks.x=element_blank(),
        axis.title.y=element_blank(), axis.ticks.y=element_blank(), axis.text.x = element_text(face="bold", colour="#000000", size=25),
        axis.text.y = element_text(face="bold", colour="#000000", size=25), axis.line.x = element_blank(), axis.line.y = element_blank()) +
  scale_fill_gradient2(low = "#FFFFFF", mid = "#FFFFFF", high = "#699ae5", na.value = "#FFFFFF", limit = c(0.1,1)) + 
  guides(fill = guide_colourbar(barwidth = 0.8, barheight = 40, ticks = FALSE, title = "", label.theme = element_text(size = 20, angle = 0))) +  coord_fixed()
ggsave("figures/vss_rsa_vwfa-ctr-fr.png", width = 3600, height = 3000, dpi = 320, units = "px")

# VWFA - BR
ggplot(rdm_ctr_vwfa_br, aes(X, Y, fill = accuracy)) + 
  geom_tile() + theme_classic() +  theme(axis.title.x=element_blank(), axis.ticks.x=element_blank(),
        axis.title.y=element_blank(), axis.ticks.y=element_blank(), axis.text.x = element_text(face="bold", colour="#000000", size=25),
        axis.text.y = element_text(face="bold", colour="#000000", size=25), axis.line.x = element_blank(), axis.line.y = element_blank()) +
  scale_fill_gradient2(low = "#FFFFFF", mid = "#FFFFFF", high = "#da5F49", na.value = "#FFFFFF", limit = c(0.1,1)) + 
  guides(fill = guide_colourbar(barwidth = 0.8, barheight = 40, ticks = FALSE, title = "", label.theme = element_text(size = 20, angle = 0))) +  coord_fixed()
ggsave("figures/vss_rsa_vwfa-ctr-br.png", width = 3600, height = 3000, dpi = 320, units = "px")

# all correlations within VWFA
vwfa_eFR_eBR <- cor.test(vwfa_exp_fr_means[["x"]], vwfa_exp_br_means[["x"]])
vwfa_cFR_cBR <- cor.test(vwfa_ctr_fr_means[["x"]], vwfa_ctr_br_means[["x"]])
vwfa_eFR_cBR <- cor.test(vwfa_exp_fr_means[["x"]], vwfa_ctr_br_means[["x"]])
vwfa_cFR_eBR <- cor.test(vwfa_ctr_fr_means[["x"]], vwfa_exp_br_means[["x"]])
vwfa_eFR_cFR <- cor.test(vwfa_exp_fr_means[["x"]], vwfa_ctr_fr_means[["x"]])
vwfa_cBR_eBR <- cor.test(vwfa_ctr_br_means[["x"]], vwfa_exp_br_means[["x"]])


## LOs

# lLO - FR
ggplot(rdm_llo_fr, aes(X, Y, fill = accuracy)) + 
  geom_tile() + theme_classic() +  theme(axis.title.x=element_blank(), axis.ticks.x=element_blank(),
        axis.title.y=element_blank(), axis.ticks.y=element_blank(), axis.text.x = element_text(face="bold", colour="#000000", size=15),
        axis.text.y = element_text(face="bold", colour="#000000", size=15), axis.line.x = element_blank(), axis.line.y = element_blank()) +
  scale_fill_gradient2(low = "#FFFFFF", mid = "#FFFFFF", high = "#69b5a2", na.value = "#FFFFFF", limit = c(0,1)) + 
  guides(fill = guide_colourbar(barwidth = 0.7, barheight = 20, ticks = FALSE)) +  coord_fixed()
ggsave("figures/vss_rsa_llo-exp-fr.png", width = 2000, height = 2000, dpi = 320, units = "px")

# lLO - BR
ggplot(rdm_llo_br, aes(X, Y, fill = accuracy)) + 
  geom_tile() + theme_classic() +  theme(axis.title.x=element_blank(), axis.ticks.x=element_blank(),
        axis.title.y=element_blank(), axis.ticks.y=element_blank(), axis.text.x = element_text(face="bold", colour="#000000", size=15),
        axis.text.y = element_text(face="bold", colour="#000000", size=15), axis.line.x = element_blank(), axis.line.y = element_blank()) +
  scale_fill_gradient2(low = "#FFFFFF", mid = "#FFFFFF", high = "#ff9e4a", na.value = "#FFFFFF", limit = c(0,1)) + 
  guides(fill = guide_colourbar(barwidth = 0.7, barheight = 20, ticks = FALSE)) +  coord_fixed()
ggsave("figures/vss_rsa_llo-exp-br.png", width = 2000, height = 2000, dpi = 320, units = "px")

# rLO - FR
ggplot(rdm_rlo_fr, aes(X, Y, fill = accuracy)) + 
  geom_tile() + theme_classic() +  theme(axis.title.x=element_blank(), axis.ticks.x=element_blank(),
        axis.title.y=element_blank(), axis.ticks.y=element_blank(), axis.text.x = element_text(face="bold", colour="#000000", size=15),
        axis.text.y = element_text(face="bold", colour="#000000", size=15), axis.line.x = element_blank(), axis.line.y = element_blank()) +
  scale_fill_gradient2(low = "#FFFFFF", mid = "#FFFFFF", high = "#69b5a2", na.value = "#FFFFFF", limit = c(0,1)) + 
  guides(fill = guide_colourbar(barwidth = 1, barheight = 20, ticks = FALSE, 
                                label.theme = element_text(size = 15), title.theme = element_blank())) +
  coord_fixed()
ggsave("figures/vss_rsa_rlo-exp-fr.png", width = 2000, height = 2000, dpi = 320, units = "px")

# rLO - BR
ggplot(rdm_rlo_br, aes(X, Y, fill = accuracy)) + 
  geom_tile() + theme_classic() +  theme(axis.title.x=element_blank(), axis.ticks.x=element_blank(),
        axis.title.y=element_blank(), axis.ticks.y=element_blank(), axis.text.x = element_text(face="bold", colour="#000000", size=15),
        axis.text.y = element_text(face="bold", colour="#000000", size=15), axis.line.x = element_blank(), axis.line.y = element_blank()) +
  scale_fill_gradient2(low = "#FFFFFF", mid = "#FFFFFF", high = "#ff9e4a", na.value = "#FFFFFF", limit = c(0,1)) + 
  guides(fill = guide_colourbar(barwidth = 1, barheight = 20, ticks = FALSE, 
                                label.theme = element_text(size = 15), title.theme = element_blank())) +
  coord_fixed()
ggsave("figures/vss_rsa_rlo-exp-br.png", width = 2000, height = 2000, dpi = 320, units = "px")

# two more graphs, but just for the legend
ggplot(rdm_rlo_fr, aes(X, Y, fill = accuracy)) +   geom_tile() + theme_classic() +  
  theme(axis.title.x=element_blank(), axis.ticks.x=element_blank(), axis.title.y=element_blank(), axis.ticks.y=element_blank(), axis.text.x = element_text(face="bold", colour="#000000", size=15), axis.text.y = element_text(face="bold", colour="#000000", size=15), axis.line.x = element_blank(), axis.line.y = element_blank()) +
  scale_fill_gradient2(low = "#FFFFFF", mid = "#FFFFFF", high = "#69b5a2", na.value = "#FFFFFF", limit = c(0,1)) + 
  guides(fill = guide_colourbar(barwidth = 1, barheight = 20, ticks = FALSE, label.theme = element_text(size = 15), title.theme = element_blank())) +
  coord_fixed()
ggsave("figures/vss_rsa_legend-fr.png", width = 2000, height = 2000, dpi = 320, units = "px")
ggplot(rdm_rlo_br, aes(X, Y, fill = accuracy)) + geom_tile() + theme_classic() +  
  theme(axis.title.x=element_blank(), axis.ticks.x=element_blank(), axis.title.y=element_blank(), axis.ticks.y=element_blank(), axis.text.x = element_text(face="bold", colour="#000000", size=15), axis.text.y = element_text(face="bold", colour="#000000", size=15), axis.line.x = element_blank(), axis.line.y = element_blank()) +
  scale_fill_gradient2(low = "#FFFFFF", mid = "#FFFFFF", high = "#ff9e4a", na.value = "#FFFFFF", limit = c(0,1)) + 
  guides(fill = guide_colourbar(barwidth = 1, barheight = 20, ticks = FALSE, label.theme = element_text(size = 15), title.theme = element_blank())) +
  coord_fixed()
ggsave("figures/vss_rsa_rlo-exp-br.png", width = 2000, height = 2000, dpi = 320, units = "px")

