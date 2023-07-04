setwd("~/Desktop/GitHub/VisualBraille_data/code/visualization")

library("readxl")
library("tidyverse")
library("reshape2")
library("gridExtra")
library('pracma')
library('data.table')
library('corrplot')

### Load matrices of decoding accuracies for "linguistic condition" decoding

ctrl_accuracies <- 
  read.csv("../../outputs/derivatives/CoSMoMVPA/mvpa-decoding_grp-controls_task-wordsDecoding_condition-linguistic-condition_nbvoxels-73.csv")

exp_accuracies <- 
  read.csv("../../outputs/derivatives/CoSMoMVPA/mvpa-decoding_grp-experts_task-wordsDecoding_condition-linguistic-condition_nbvoxels-73.csv")



### Manipulate the matrix to get something readable by ggplot

ctrl_accuracies <- as.data.frame(ctrl_accuracies)
exp_accuracies <- as.data.frame(exp_accuracies)

# Drop unnecessary columns
ctrl_accuracies <- subset(ctrl_accuracies, select = -c(4,7,8))
exp_accuracies <- subset(exp_accuracies, select = -c(4,7,8))

ctrl_accuracies$mask <- ifelse(ctrl_accuracies$mask == "VWFAfr", "VWFA", ctrl_accuracies$mask)
exp_accuracies$mask <- ifelse(exp_accuracies$mask == "VWFAfr", "VWFA", exp_accuracies$mask)

# divide the matrix for area, image
ctrl_div <- group_split(ctrl_accuracies, mask,image)
exp_div <- group_split(exp_accuracies, mask,image)

# Assign each group x area to a variable 
accu_control_vwfa <- ctrl_div[[1]]
accu_control_llo <- ctrl_div[[3]]
accu_control_rlo <- ctrl_div[[5]]
accu_expert_vwfa <- exp_div[[1]]
accu_expert_llo <- exp_div[[3]]
accu_expert_rlo <- exp_div[[5]]

# average decodings to show them on the 
ctrl_vwfa_means <- aggregate(accu_control_vwfa$accuracy, list(accu_control_vwfa$decodingCondition), FUN=mean)
ctrl_llo_means <- aggregate(accu_control_llo$accuracy, list(accu_control_llo$decodingCondition), FUN=mean)
ctrl_rlo_means <- aggregate(accu_control_rlo$accuracy, list(accu_control_rlo$decodingCondition), FUN=mean)
exp_vwfa_means <- aggregate(accu_expert_vwfa$accuracy, list(accu_expert_vwfa$decodingCondition), FUN=mean)
exp_llo_means <- aggregate(accu_expert_llo$accuracy, list(accu_expert_llo$decodingCondition), FUN=mean)
exp_rlo_means <- aggregate(accu_expert_rlo$accuracy, list(accu_expert_rlo$decodingCondition), FUN=mean)



### Perform correlations between areas and groups

# Combine matrices into a list
all_areas <- list(
  list(name = "c_vwfa", numbers = accu_control_vwfa$accuracy), list(name = "c_llo", numbers = accu_control_llo$accuracy), 
  list(name = "c_rlo", numbers = accu_control_rlo$accuracy),   list(name = "e_vwfa", numbers = accu_expert_vwfa$accuracy),
  list(name = "e_llo", numbers = accu_expert_llo$accuracy), list(name = "e_rlo", numbers = accu_expert_rlo$accuracy))

# Initialize empty matrices to store correlation results
correlation <- data.table(Area1 = character(), Area2 = character(), Correlation = numeric())

# square matrices for better visualization
num <- length(all_areas)
corr_mat <- matrix(NA, nrow = num, ncol = num)
rownames(corr_mat) <- c("VWFA - ctrl", "lLO - ctrl","rLO - ctrl","VWFA - exp","lLO - exp","rLO - exp")

# Loop through all the items of the list and compute pairwise correlation between them
for (i in 1:length(all_areas)) {
  for (j in i:length(all_areas)) {
    cat("Correlation between ", i, "and ", j, ":\n")
    # get correlation  
    corr_res <- cor(all_areas[[i]]$numbers, all_areas[[j]]$numbers) 
    # save as table format to add it 
    result <- data.table(Area1 = all_areas[[i]]$name, Area2 = all_areas[[j]]$name, Correlation = corr_res)
    # add to the main table
    correlation_c <- rbind(correlation, result)
    # print it on screen
    cat(corr_res) 
    # save also the heatmap values
    corr_mat[i, j] <- corr_res
    corr_mat[j, i] <- corr_res # Fill in lower triangular part of the matrix
    cat("\n")
  }
}



### Plots



### Decdoing boxplots

# Experts 
accu_exp_plot <- ggplot(exp_accuracies, aes(x = decodingCondition, y = accuracy), middle = mean(accuracy))
accu_exp_plot + geom_boxplot(outlier.shape = NA, show.legend = NA, colour = "#0000ff") + 
  theme_classic() +
  geom_hline(aes(yintercept = 0.5), size = .25, linetype = "dashed") +
  ylim(0,1) +
  geom_jitter(colour = "#0000ff", width = 0.3) +
  theme(axis.text.x = element_text(angle = 90)) +
  facet_grid(~factor(mask, levels = c("VWFA", "lLO", "rLO")), labeller = label_value) + 
  scale_x_discrete(limits=rev, labels = c("RW - PW", "RW - NW", "RW - FS", "PW - NW", "PW - FS", "NW - FS")) +
  labs(x = "Area", y = "Accuracy", title = "Mean decoding acccuracy - experts")

ggsave("figures/linguistic-decoding_mean-accuracy_experts.png", width = 3000, height = 2100, dpi = 320, units = "px")


# Controls
accu_ctrl_plot <- ggplot(ctrl_accuracies, aes(x = decodingCondition, y = accuracy), middle = mean(accuracy))
accu_ctrl_plot + geom_boxplot(outlier.shape = NA, show.legend = NA, colour = "#0000ff") + 
  theme_classic() +
  geom_hline(aes(yintercept = 0.5), size = .25, linetype = "dashed") +
  ylim(0,1) +
  geom_jitter(colour = "#0000ff", width = 0.3) +
  theme(axis.text.x = element_text(angle = 90)) +
  facet_grid(~factor(mask, levels = c("VWFA", "lLO", "rLO")), labeller = label_value) + 
  scale_x_discrete(limits=rev, labels = c("RW - PW", "RW - NW", "RW - FS", "PW - NW", "PW - FS", "NW - FS")) +
  labs(x = "Area", y = "Accuracy", title = "Mean decoding acccuracy - controls")

ggsave("figures/linguistic-decoding_mean-accuracy_controls.png", width = 3000, height = 2100, dpi = 320, units = "px")


### Single RDMs for each area / group

# Once and for all: adjust labels
x <- c("RW", "PW", "NW", "FS")
y <- c("FS", "NW", "PW", "RW")

# Manually re-arrange matrices 
# Experts VWFA
exp_vwfa_mat = c(exp_vwfa_means[[4,2]], exp_vwfa_means[[2,2]], exp_vwfa_means[[1,2]], NaN, exp_vwfa_means[[5,2]], exp_vwfa_means[[3,2]], NaN, exp_vwfa_means[[1,2]],
                exp_vwfa_means[[6,2]], NaN, exp_vwfa_means[[3,2]], exp_vwfa_means[[2,2]], NaN, exp_vwfa_means[[6,2]], exp_vwfa_means[[5,2]], exp_vwfa_means[[4,2]])
rdm_exp_vwfa <- expand.grid(X=x, Y=y)
rdm_exp_vwfa$accuracy <- exp_vwfa_mat

# Experts lLO
exp_llo_mat = c(exp_llo_means[[4,2]], exp_llo_means[[2,2]], exp_llo_means[[1,2]], NaN, exp_llo_means[[5,2]], exp_llo_means[[3,2]], NaN, exp_llo_means[[1,2]],
                 exp_llo_means[[6,2]], NaN, exp_llo_means[[3,2]], exp_llo_means[[2,2]], NaN, exp_llo_means[[6,2]], exp_llo_means[[5,2]], exp_llo_means[[4,2]])
rdm_exp_llo <- expand.grid(X=x, Y=y)
rdm_exp_llo$accuracy <- exp_llo_mat

# Experts rLO
exp_rlo_mat = c(exp_rlo_means[[4,2]], exp_rlo_means[[2,2]], exp_rlo_means[[1,2]], NaN, exp_rlo_means[[5,2]], exp_rlo_means[[3,2]], NaN, exp_rlo_means[[1,2]],
                 exp_rlo_means[[6,2]], NaN, exp_rlo_means[[3,2]], exp_rlo_means[[2,2]], NaN, exp_rlo_means[[6,2]], exp_rlo_means[[5,2]], exp_rlo_means[[4,2]])
rdm_exp_rlo <- expand.grid(X=x, Y=y)
rdm_exp_rlo$accuracy <- exp_rlo_mat

# Controls VWFA
ctrl_vwfa_mat = c(ctrl_vwfa_means[[4,2]], ctrl_vwfa_means[[2,2]], ctrl_vwfa_means[[1,2]], NaN, ctrl_vwfa_means[[5,2]], ctrl_vwfa_means[[3,2]], NaN, ctrl_vwfa_means[[1,2]],
                 ctrl_vwfa_means[[6,2]], NaN, ctrl_vwfa_means[[3,2]], ctrl_vwfa_means[[2,2]], NaN, ctrl_vwfa_means[[6,2]], ctrl_vwfa_means[[5,2]], ctrl_vwfa_means[[4,2]])
rdm_ctrl_vwfa <- expand.grid(X=x, Y=y)
rdm_ctrl_vwfa$accuracy <- ctrl_vwfa_mat

# Controls lLO
ctrl_llo_mat = c(ctrl_llo_means[[4,2]], ctrl_llo_means[[2,2]], ctrl_llo_means[[1,2]], NaN, ctrl_llo_means[[5,2]], ctrl_llo_means[[3,2]], NaN, ctrl_llo_means[[1,2]],
                 ctrl_llo_means[[6,2]], NaN, ctrl_llo_means[[3,2]], ctrl_llo_means[[2,2]], NaN, ctrl_llo_means[[6,2]], ctrl_llo_means[[5,2]], ctrl_llo_means[[4,2]])
rdm_ctrl_llo <- expand.grid(X=x, Y=y)
rdm_ctrl_llo$accuracy <- ctrl_llo_mat

# Controls rLO
ctrl_rlo_mat = c(ctrl_rlo_means[[4,2]], ctrl_rlo_means[[2,2]], ctrl_rlo_means[[1,2]], NaN, ctrl_rlo_means[[5,2]], ctrl_rlo_means[[3,2]], NaN, ctrl_rlo_means[[1,2]],
                 ctrl_rlo_means[[6,2]], NaN, ctrl_rlo_means[[3,2]], ctrl_rlo_means[[2,2]], NaN, ctrl_rlo_means[[6,2]], ctrl_rlo_means[[5,2]], ctrl_rlo_means[[4,2]])
rdm_ctrl_rlo <- expand.grid(X=x, Y=y)
rdm_ctrl_rlo$accuracy <- ctrl_rlo_mat


## Heatmaps
# Experts VWFA
ggplot(rdm_exp_vwfa, aes(X, Y, fill= accuracy)) + geom_tile() + theme_classic() +
  theme(axis.title.x=element_blank(), axis.ticks.x=element_blank(), axis.title.y=element_blank(), axis.ticks.y=element_blank(),
        axis.text.x = element_text(face="bold", colour="#000000", size=9), axis.text.y = element_text(face="bold", colour="#000000", size=9),
        axis.line.x = element_blank(), axis.line.y = element_blank()) +
  geom_text(aes(label = round(accuracy, 2))) + scale_fill_gradient2(low = "#FFFFFF", high = "#19772a", limit = c(0,1), na.value = "white",) + 
  guides(fill = guide_colourbar(barwidth = 0.7, barheight = 20, ticks = FALSE)) + labs(title = "Linguistic decoding - VWFA - experts")
coord_fixed()
ggsave("figures/linguistic-decoding_RDM_exp-VWFA.png", width = 2000, height = 1600, dpi = 320, units = "px")

# Experts lLO
ggplot(rdm_exp_llo, aes(X, Y, fill= accuracy)) + geom_tile() + theme_classic() +
  theme(axis.title.x=element_blank(), axis.ticks.x=element_blank(), axis.title.y=element_blank(), axis.ticks.y=element_blank(),
        axis.text.x = element_text(face="bold", colour="#000000", size=9), axis.text.y = element_text(face="bold", colour="#000000", size=9),
        axis.line.x = element_blank(), axis.line.y = element_blank()) +
  geom_text(aes(label = round(accuracy, 2))) + scale_fill_gradient2(low = "#FFFFFF", high = "#19772a", limit = c(0,1), na.value = "white",) + 
  guides(fill = guide_colourbar(barwidth = 0.7, barheight = 20, ticks = FALSE)) + labs(title = "Linguistic decoding - lLO - experts")
coord_fixed()
ggsave("figures/linguistic-decoding_RDM_exp-lLO.png", width = 2000, height = 1600, dpi = 320, units = "px")

# Experts rLO
ggplot(rdm_exp_rlo, aes(X, Y, fill= accuracy)) + geom_tile() + theme_classic() +
  theme(axis.title.x=element_blank(), axis.ticks.x=element_blank(), axis.title.y=element_blank(), axis.ticks.y=element_blank(),
        axis.text.x = element_text(face="bold", colour="#000000", size=9), axis.text.y = element_text(face="bold", colour="#000000", size=9),
        axis.line.x = element_blank(), axis.line.y = element_blank()) +
  geom_text(aes(label = round(accuracy, 2))) + scale_fill_gradient2(low = "#FFFFFF", high = "#19772a", limit = c(0,1), na.value = "white",) + 
  guides(fill = guide_colourbar(barwidth = 0.7, barheight = 20, ticks = FALSE)) + labs(title = "Linguistic decoding - rLO - experts")
coord_fixed()
ggsave("figures/linguistic-decoding_RDM_exp-rLO.png", width = 2000, height = 1600, dpi = 320, units = "px")

# Controls VWFA
ggplot(rdm_ctrl_vwfa, aes(X, Y, fill= accuracy)) + geom_tile() + theme_classic() +
  theme(axis.title.x=element_blank(), axis.ticks.x=element_blank(), axis.title.y=element_blank(), axis.ticks.y=element_blank(),
        axis.text.x = element_text(face="bold", colour="#000000", size=9), axis.text.y = element_text(face="bold", colour="#000000", size=9),
        axis.line.x = element_blank(), axis.line.y = element_blank()) +
  geom_text(aes(label = round(accuracy, 2))) + scale_fill_gradient2(low = "#FFFFFF", high = "#C20238", limit = c(0,1), na.value = "white",) + 
  guides(fill = guide_colourbar(barwidth = 0.7, barheight = 20, ticks = FALSE)) + labs(title = "Linguistic decoding - VWFA - controls")
coord_fixed()
ggsave("figures/linguistic-decoding_RDM_ctrl-VWFA.png", width = 2000, height = 1600, dpi = 320, units = "px")

# Controls lLO
ggplot(rdm_ctrl_llo, aes(X, Y, fill= accuracy)) + geom_tile() + theme_classic() +
  theme(axis.title.x=element_blank(), axis.ticks.x=element_blank(), axis.title.y=element_blank(), axis.ticks.y=element_blank(),
        axis.text.x = element_text(face="bold", colour="#000000", size=9), axis.text.y = element_text(face="bold", colour="#000000", size=9),
        axis.line.x = element_blank(), axis.line.y = element_blank()) +
  geom_text(aes(label = round(accuracy, 2))) + scale_fill_gradient2(low = "#FFFFFF", high = "#C20238", limit = c(0,1), na.value = "white",) + 
  guides(fill = guide_colourbar(barwidth = 0.7, barheight = 20, ticks = FALSE)) + labs(title = "Linguistic decoding - lLO - controls")
coord_fixed()
ggsave("figures/linguistic-decoding_RDM_ctrl-lLO.png", width = 2000, height = 1600, dpi = 320, units = "px")

# Controls rLO
ggplot(rdm_ctrl_rlo, aes(X, Y, fill= accuracy)) + geom_tile() + theme_classic() +
  theme(axis.title.x=element_blank(), axis.ticks.x=element_blank(), axis.title.y=element_blank(), axis.ticks.y=element_blank(),
        axis.text.x = element_text(face="bold", colour="#000000", size=9), axis.text.y = element_text(face="bold", colour="#000000", size=9),
        axis.line.x = element_blank(), axis.line.y = element_blank()) +
  geom_text(aes(label = round(accuracy, 2))) + scale_fill_gradient2(low = "#FFFFFF", high = "#C20238", limit = c(0,1), na.value = "white",) + 
  guides(fill = guide_colourbar(barwidth = 0.7, barheight = 20, ticks = FALSE)) + labs(title = "Linguistic decoding - rLO - controls")
coord_fixed()
ggsave("figures/linguistic-decoding_RDM_ctrl-rLO.png", width = 2000, height = 1600, dpi = 320, units = "px")



### Correlation between areas

corr_values = c(corr_mat[[1,6]], corr_mat[[2,6]], corr_mat[[3,6]], corr_mat[[4,6]], corr_mat[[5,6]], corr_mat[[6,6]],
                corr_mat[[1,5]], corr_mat[[2,5]], corr_mat[[3,5]], corr_mat[[4,5]], corr_mat[[5,5]], corr_mat[[6,5]],
                corr_mat[[1,4]], corr_mat[[2,4]], corr_mat[[3,4]], corr_mat[[4,4]], corr_mat[[5,4]], corr_mat[[6,4]],
                corr_mat[[1,3]], corr_mat[[2,3]], corr_mat[[3,3]], corr_mat[[4,3]], corr_mat[[5,3]], corr_mat[[6,3]],
                corr_mat[[1,2]], corr_mat[[2,2]], corr_mat[[3,2]], corr_mat[[4,2]], corr_mat[[5,2]], corr_mat[[6,2]],
                corr_mat[[1,1]], corr_mat[[2,1]], corr_mat[[3,1]], corr_mat[[4,1]], corr_mat[[5,1]], corr_mat[[6,1]])

# Create ggplot-friendly matrices
x <- c("VWFA - ctrl", "lLO - ctrl", "rLO - ctrl", "VWFA - exp", "lLO - exp",  "rLO - exp")
y <- c("rLO - exp",   "lLO - exp",  "VWFA - exp", "rLO - ctrl", "lLO - ctrl", "VWFA - ctrl") # Second one is inverted, that's how ggplot like it
corr_plot <- expand.grid(Area1=x, Area2=y)
corr_plot$correlation <- corr_values

# Heatmap
# Controls
ggplot(as.data.frame(corr_plot), aes(x=Area1, y=Area2, fill= correlation)) +  geom_tile() + theme_classic() +
  theme(axis.title.x=element_blank(), axis.ticks.x=element_blank(),  axis.title.y=element_blank(), axis.ticks.y=element_blank(),
        axis.text.x = element_text(face="bold", colour="#000000", size=9),  axis.text.y = element_text(face="bold", colour="#000000", size=9),
        axis.line.x = element_blank(), axis.line.y = element_blank()) +  geom_text(aes(label = round(correlation, 2))) +
  scale_fill_gradient2(low = "#ffeeee", high = "#ff0000", limit = c(-0.2,1)) + 
  guides(fill = guide_colourbar(barwidth = 0.7, barheight = 20, ticks = FALSE)) +  labs(title = "Correlations between areas - controls")
coord_fixed()
ggsave("figures/linguistic-condition_areas-correlations.png", width = 2000, height = 1600, dpi = 320, units = "px")

