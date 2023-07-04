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
  read.csv("../../outputs/derivatives/CoSMoMVPA/mvpa-decoding_grp-controls_task-wordsDecoding_condition-pairwise-within-script_nbvoxels-73.csv")

exp_accuracies <- 
  read.csv("../../outputs/derivatives/CoSMoMVPA/mvpa-decoding_grp-experts_task-wordsDecoding_condition-pairwise-within-script_nbvoxels-73.csv")



### Manipulate the matrix to get something readable by ggplot

ctrl_accuracies <- as.data.frame(ctrl_accuracies)
exp_accuracies <- as.data.frame(exp_accuracies)

# Drop unnecessary columns
ctrl_accuracies <- subset(ctrl_accuracies, select = -c(4,7,8))
exp_accuracies <- subset(exp_accuracies, select = -c(4,7,8))

# Assign the script, to ease splitting the original accuracy matrix: 1 = French, 2 = Braille
extraCol <- repmat(c(1,1,1,1,1,1,2,2,2,2,2,2), 1,36)
extraCol <- t(extraCol)
ctrl_accuracies$script <- extraCol
exp_accuracies$script <- extraCol

# divide the matrix for area, image
ctrl_div <- group_split(ctrl_accuracies, mask, image, script)
exp_div <- group_split(exp_accuracies, mask, image, script)

# Assign each group x area to a variable 
c_vwfa_fr <- ctrl_div[[1]]
c_vwfa_br <- ctrl_div[[2]]
c_llo_fr <- ctrl_div[[5]]
c_llo_br <- ctrl_div[[6]]
c_rlo_fr <- ctrl_div[[9]]
c_rlo_br <- ctrl_div[[10]]
e_vwfa_fr <- exp_div[[1]]
e_vwfa_br <- exp_div[[2]]
e_llo_fr <- exp_div[[5]]
e_llo_br <- exp_div[[6]]
e_rlo_fr <- exp_div[[9]]
e_rlo_br <- exp_div[[10]]


# average decodings 
c_vwfa_fr_means <- aggregate(c_vwfa_fr$accuracy, list(c_vwfa_fr$decodingCondition), FUN=mean)
c_llo_fr_means <- aggregate(c_llo_fr$accuracy, list(c_llo_fr$decodingCondition), FUN=mean)
c_rlo_fr_means <- aggregate(c_rlo_fr$accuracy, list(c_rlo_fr$decodingCondition), FUN=mean)
c_vwfa_br_means <- aggregate(c_vwfa_br$accuracy, list(c_vwfa_br$decodingCondition), FUN=mean)
c_llo_br_means <- aggregate(c_llo_br$accuracy, list(c_llo_br$decodingCondition), FUN=mean)
c_rlo_br_means <- aggregate(c_rlo_br$accuracy, list(c_rlo_br$decodingCondition), FUN=mean)
e_vwfa_fr_means <- aggregate(e_vwfa_fr$accuracy, list(e_vwfa_fr$decodingCondition), FUN=mean)
e_llo_fr_means <- aggregate(e_llo_fr$accuracy, list(e_llo_fr$decodingCondition), FUN=mean)
e_rlo_fr_means <- aggregate(e_rlo_fr$accuracy, list(e_rlo_fr$decodingCondition), FUN=mean)
e_vwfa_br_means <- aggregate(e_vwfa_br$accuracy, list(e_vwfa_br$decodingCondition), FUN=mean)
e_llo_br_means <- aggregate(e_llo_br$accuracy, list(e_llo_br$decodingCondition), FUN=mean)
e_rlo_br_means <- aggregate(e_rlo_br$accuracy, list(e_rlo_br$decodingCondition), FUN=mean)


### Perform correlations between areas and groups

# Combine matrices into a list
all_areas <- list(
  list(name = "c_vwfa_fr", numbers = c_vwfa_fr$accuracy), list(name = "c_vwfa_br", numbers = c_vwfa_br$accuracy),
  list(name = "c_llo_fr", numbers = c_llo_fr$accuracy),   list(name = "c_llo_br", numbers = c_llo_br$accuracy), 
  list(name = "c_rlo_fr", numbers = c_rlo_fr$accuracy),   list(name = "c_rlo_br", numbers = c_rlo_br$accuracy), 
  list(name = "e_vwfa_fr", numbers = e_vwfa_fr$accuracy), list(name = "e_vwfa_br", numbers = e_vwfa_br$accuracy),
  list(name = "e_llo_fr", numbers = e_llo_fr$accuracy),   list(name = "e_llo_br", numbers = e_llo_br$accuracy), 
  list(name = "e_rlo_fr", numbers = e_rlo_fr$accuracy),   list(name = "e_rlo_br", numbers = e_rlo_br$accuracy))

# Initialize empty matrices to store correlation results
correlation <- data.table(Area1 = character(), Area2 = character(), Correlation = numeric())

# square matrices for better visualization
num <- length(all_areas)
corr_mat <- matrix(NA, nrow = num, ncol = num)
rownames(corr_mat) <- c("ctrl VWFA fr", "ctrl VWFA br", "ctrl lLO fr", "ctrl lLO br", "ctrl rLO fr", "ctrl rLO br", 
                        "exp VWFA fr", "exp VWFA br", "exp lLO fr", "exp lLO br", "exp rLO fr", "exp rLO br")

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



### Single RDMs for each area / group

# Once and for all: adjust labels
x <- c("RW", "PW", "NW", "FS")
y <- c("FS", "NW", "PW", "RW")

# Manually re-arrange matrices 
# Experts VWFA french
e_vwfa_fr_mat = c(e_vwfa_fr_means[[4,2]], e_vwfa_fr_means[[2,2]], e_vwfa_fr_means[[1,2]], NaN, e_vwfa_fr_means[[5,2]], e_vwfa_fr_means[[3,2]], NaN, e_vwfa_fr_means[[1,2]],e_vwfa_fr_means[[6,2]], NaN, e_vwfa_fr_means[[3,2]], e_vwfa_fr_means[[2,2]], NaN, e_vwfa_fr_means[[6,2]], e_vwfa_fr_means[[5,2]], e_vwfa_fr_means[[4,2]])
rdm_e_vwfa_fr <- expand.grid(X=x, Y=y)
rdm_e_vwfa_fr$accuracy <- e_vwfa_fr_mat

# Experts lLO french
e_llo_fr_mat = c(e_llo_fr_means[[4,2]], e_llo_fr_means[[2,2]], e_llo_fr_means[[1,2]], NaN, e_llo_fr_means[[5,2]], e_llo_fr_means[[3,2]], NaN, e_llo_fr_means[[1,2]], e_llo_fr_means[[6,2]], NaN, e_llo_fr_means[[3,2]], e_llo_fr_means[[2,2]], NaN, e_llo_fr_means[[6,2]], e_llo_fr_means[[5,2]], e_llo_fr_means[[4,2]])
rdm_e_llo_fr <- expand.grid(X=x, Y=y)
rdm_e_llo_fr$accuracy <- e_llo_fr_mat

# Experts rLO french
e_rlo_fr_mat = c(e_rlo_fr_means[[4,2]], e_rlo_fr_means[[2,2]], e_rlo_fr_means[[1,2]], NaN, e_rlo_fr_means[[5,2]], e_rlo_fr_means[[3,2]], NaN, e_rlo_fr_means[[1,2]],e_rlo_fr_means[[6,2]], NaN, e_rlo_fr_means[[3,2]], e_rlo_fr_means[[2,2]], NaN, e_rlo_fr_means[[6,2]], e_rlo_fr_means[[5,2]], e_rlo_fr_means[[4,2]])
rdm_e_rlo_fr <- expand.grid(X=x, Y=y)
rdm_e_rlo_fr$accuracy <- e_rlo_fr_mat

# Experts VWFA braille
e_vwfa_br_mat = c(e_vwfa_br_means[[4,2]], e_vwfa_br_means[[2,2]], e_vwfa_br_means[[1,2]], NaN, e_vwfa_br_means[[5,2]], e_vwfa_br_means[[3,2]], NaN, e_vwfa_br_means[[1,2]],e_vwfa_br_means[[6,2]], NaN, e_vwfa_br_means[[3,2]], e_vwfa_br_means[[2,2]], NaN, e_vwfa_br_means[[6,2]], e_vwfa_br_means[[5,2]], e_vwfa_br_means[[4,2]])
rdm_e_vwfa_br <- expand.grid(X=x, Y=y)
rdm_e_vwfa_br$accuracy <- e_vwfa_br_mat

# Experts lLO braille
e_llo_br_mat = c(e_llo_br_means[[4,2]], e_llo_br_means[[2,2]], e_llo_br_means[[1,2]], NaN, e_llo_br_means[[5,2]], e_llo_br_means[[3,2]], NaN, e_llo_br_means[[1,2]],e_llo_br_means[[6,2]], NaN, e_llo_br_means[[3,2]], e_llo_br_means[[2,2]], NaN, e_llo_br_means[[6,2]], e_llo_br_means[[5,2]], e_llo_br_means[[4,2]])
rdm_e_llo_br <- expand.grid(X=x, Y=y)
rdm_e_llo_br$accuracy <- e_llo_br_mat

# Experts rLO braille
e_rlo_br_mat = c(e_rlo_br_means[[4,2]], e_rlo_br_means[[2,2]], e_rlo_br_means[[1,2]], NaN, e_rlo_br_means[[5,2]], e_rlo_br_means[[3,2]], NaN, e_rlo_br_means[[1,2]],e_rlo_br_means[[6,2]], NaN, e_rlo_br_means[[3,2]], e_rlo_br_means[[2,2]], NaN, e_rlo_br_means[[6,2]], e_rlo_br_means[[5,2]], e_rlo_br_means[[4,2]])
rdm_e_rlo_br <- expand.grid(X=x, Y=y)
rdm_e_rlo_br$accuracy <- e_rlo_br_mat

# Controls VWFA french
c_vwfa_fr_mat = c(c_vwfa_fr_means[[4,2]], c_vwfa_fr_means[[2,2]], c_vwfa_fr_means[[1,2]], NaN, c_vwfa_fr_means[[5,2]], c_vwfa_fr_means[[3,2]], NaN, c_vwfa_fr_means[[1,2]],c_vwfa_fr_means[[6,2]], NaN, c_vwfa_fr_means[[3,2]], c_vwfa_fr_means[[2,2]], NaN, c_vwfa_fr_means[[6,2]], c_vwfa_fr_means[[5,2]], c_vwfa_fr_means[[4,2]])
rdm_c_vwfa_fr <- expand.grid(X=x, Y=y)
rdm_c_vwfa_fr$accuracy <- c_vwfa_fr_mat

# Controls lLO french
c_llo_fr_mat = c(c_llo_fr_means[[4,2]], c_llo_fr_means[[2,2]], c_llo_fr_means[[1,2]], NaN, c_llo_fr_means[[5,2]], c_llo_fr_means[[3,2]], NaN, c_llo_fr_means[[1,2]],c_llo_fr_means[[6,2]], NaN, c_llo_fr_means[[3,2]], c_llo_fr_means[[2,2]], NaN, c_llo_fr_means[[6,2]], c_llo_fr_means[[5,2]], c_llo_fr_means[[4,2]])
rdm_c_llo_fr <- expand.grid(X=x, Y=y)
rdm_c_llo_fr$accuracy <- c_llo_fr_mat

# Controls rLO french
c_rlo_fr_mat = c(c_rlo_fr_means[[4,2]], c_rlo_fr_means[[2,2]], c_rlo_fr_means[[1,2]], NaN, c_rlo_fr_means[[5,2]], c_rlo_fr_means[[3,2]], NaN, c_rlo_fr_means[[1,2]],c_rlo_fr_means[[6,2]], NaN, c_rlo_fr_means[[3,2]], c_rlo_fr_means[[2,2]], NaN, c_rlo_fr_means[[6,2]], c_rlo_fr_means[[5,2]], c_rlo_fr_means[[4,2]])
rdm_c_rlo_fr <- expand.grid(X=x, Y=y)
rdm_c_rlo_fr$accuracy <- c_rlo_fr_mat

# Controls VWFA braille
c_vwfa_br_mat = c(c_vwfa_br_means[[4,2]], c_vwfa_br_means[[2,2]], c_vwfa_br_means[[1,2]], NaN, c_vwfa_br_means[[5,2]], c_vwfa_br_means[[3,2]], NaN, c_vwfa_br_means[[1,2]],c_vwfa_br_means[[6,2]], NaN, c_vwfa_br_means[[3,2]], c_vwfa_br_means[[2,2]], NaN, c_vwfa_br_means[[6,2]], c_vwfa_br_means[[5,2]], c_vwfa_br_means[[4,2]])
rdm_c_vwfa_br <- expand.grid(X=x, Y=y)
rdm_c_vwfa_br$accuracy <- c_vwfa_br_mat

# Controls lLO braille
c_llo_br_mat = c(c_llo_br_means[[4,2]], c_llo_br_means[[2,2]], c_llo_br_means[[1,2]], NaN, c_llo_br_means[[5,2]], c_llo_br_means[[3,2]], NaN, c_llo_br_means[[1,2]],c_llo_br_means[[6,2]], NaN, c_llo_br_means[[3,2]], c_llo_br_means[[2,2]], NaN, c_llo_br_means[[6,2]], c_llo_br_means[[5,2]], c_llo_br_means[[4,2]])
rdm_c_llo_br <- expand.grid(X=x, Y=y)
rdm_c_llo_br$accuracy <- c_llo_br_mat

# Controls rLO braille
c_rlo_br_mat = c(c_rlo_br_means[[4,2]], c_rlo_br_means[[2,2]], c_rlo_br_means[[1,2]], NaN, c_rlo_br_means[[5,2]], c_rlo_br_means[[3,2]], NaN, c_rlo_br_means[[1,2]],c_rlo_br_means[[6,2]], NaN, c_rlo_br_means[[3,2]], c_rlo_br_means[[2,2]], NaN, c_rlo_br_means[[6,2]], c_rlo_br_means[[5,2]], c_rlo_br_means[[4,2]])
rdm_c_rlo_br <- expand.grid(X=x, Y=y)
rdm_c_rlo_br$accuracy <- c_rlo_br_mat


## Heatmaps
# Experts VWFA french
ggplot(rdm_e_vwfa_fr, aes(X, Y, fill= accuracy)) + geom_tile() + theme_classic() +
  theme(axis.title.x=element_blank(), axis.ticks.x=element_blank(), axis.title.y=element_blank(), axis.ticks.y=element_blank(),
        axis.text.x = element_text(face="bold", colour="#000000", size=9), axis.text.y = element_text(face="bold", colour="#000000", size=9),
        axis.line.x = element_blank(), axis.line.y = element_blank()) +
  geom_text(aes(label = round(accuracy, 2))) + scale_fill_gradient2(low = "#FFFFFF", high = "#19772a", limit = c(0,1), na.value = "white",) + 
  guides(fill = guide_colourbar(barwidth = 0.7, barheight = 20, ticks = FALSE)) + labs(title = "Pairwise decoding - VWFA - experts - french")
coord_fixed()
ggsave("figures/pairwise_RDM_exp-VWFA_fr.png", width = 2000, height = 1600, dpi = 320, units = "px")

# Experts lLO french
ggplot(rdm_e_llo_fr, aes(X, Y, fill= accuracy)) + geom_tile() + theme_classic() +
  theme(axis.title.x=element_blank(), axis.ticks.x=element_blank(), axis.title.y=element_blank(), axis.ticks.y=element_blank(),
        axis.text.x = element_text(face="bold", colour="#000000", size=9), axis.text.y = element_text(face="bold", colour="#000000", size=9),
        axis.line.x = element_blank(), axis.line.y = element_blank()) +
  geom_text(aes(label = round(accuracy, 2))) + scale_fill_gradient2(low = "#FFFFFF", high = "#19772a", limit = c(0,1), na.value = "white",) + 
  guides(fill = guide_colourbar(barwidth = 0.7, barheight = 20, ticks = FALSE)) + labs(title = "Pairwise decoding - lLO - experts - french")
coord_fixed()
ggsave("figures/pairwise_RDM_exp-lLO_fr.png", width = 2000, height = 1600, dpi = 320, units = "px")

# Experts rLO french
ggplot(rdm_e_rlo_fr, aes(X, Y, fill= accuracy)) + geom_tile() + theme_classic() +
  theme(axis.title.x=element_blank(), axis.ticks.x=element_blank(), axis.title.y=element_blank(), axis.ticks.y=element_blank(),
        axis.text.x = element_text(face="bold", colour="#000000", size=9), axis.text.y = element_text(face="bold", colour="#000000", size=9),
        axis.line.x = element_blank(), axis.line.y = element_blank()) +
  geom_text(aes(label = round(accuracy, 2))) + scale_fill_gradient2(low = "#FFFFFF", high = "#19772a", limit = c(0,1), na.value = "white",) + 
  guides(fill = guide_colourbar(barwidth = 0.7, barheight = 20, ticks = FALSE)) + labs(title = "Pairwise decoding - rLO - experts - french")
coord_fixed()
ggsave("figures/pairwise_RDM_exp-rLO_fr.png", width = 2000, height = 1600, dpi = 320, units = "px")

# Controls VWFA french
ggplot(rdm_c_vwfa_fr, aes(X, Y, fill= accuracy)) + geom_tile() + theme_classic() +
  theme(axis.title.x=element_blank(), axis.ticks.x=element_blank(), axis.title.y=element_blank(), axis.ticks.y=element_blank(),
        axis.text.x = element_text(face="bold", colour="#000000", size=9), axis.text.y = element_text(face="bold", colour="#000000", size=9),
        axis.line.x = element_blank(), axis.line.y = element_blank()) +
  geom_text(aes(label = round(accuracy, 2))) + scale_fill_gradient2(low = "#FFFFFF", high = "#C20238", limit = c(0,1), na.value = "white",) + 
  guides(fill = guide_colourbar(barwidth = 0.7, barheight = 20, ticks = FALSE)) + labs(title = "Pairwise decoding - VWFA - controls - french")
coord_fixed()
ggsave("figures/pairwise_RDM_ctrl-VWFA_fr.png", width = 2000, height = 1600, dpi = 320, units = "px")

# Controls lLO french
ggplot(rdm_c_llo_fr, aes(X, Y, fill= accuracy)) + geom_tile() + theme_classic() +
  theme(axis.title.x=element_blank(), axis.ticks.x=element_blank(), axis.title.y=element_blank(), axis.ticks.y=element_blank(),
        axis.text.x = element_text(face="bold", colour="#000000", size=9), axis.text.y = element_text(face="bold", colour="#000000", size=9),
        axis.line.x = element_blank(), axis.line.y = element_blank()) +
  geom_text(aes(label = round(accuracy, 2))) + scale_fill_gradient2(low = "#FFFFFF", high = "#C20238", limit = c(0,1), na.value = "white",) + 
  guides(fill = guide_colourbar(barwidth = 0.7, barheight = 20, ticks = FALSE)) + labs(title = "Pairwise decoding - lLO - controls - french")
coord_fixed()
ggsave("figures/pairwise_RDM_ctrl-lLO_fr.png", width = 2000, height = 1600, dpi = 320, units = "px")

# Controls rLO french
ggplot(rdm_c_rlo_fr, aes(X, Y, fill= accuracy)) + geom_tile() + theme_classic() +
  theme(axis.title.x=element_blank(), axis.ticks.x=element_blank(), axis.title.y=element_blank(), axis.ticks.y=element_blank(),
        axis.text.x = element_text(face="bold", colour="#000000", size=9), axis.text.y = element_text(face="bold", colour="#000000", size=9),
        axis.line.x = element_blank(), axis.line.y = element_blank()) +
  geom_text(aes(label = round(accuracy, 2))) + scale_fill_gradient2(low = "#FFFFFF", high = "#C20238", limit = c(0,1), na.value = "white",) + 
  guides(fill = guide_colourbar(barwidth = 0.7, barheight = 20, ticks = FALSE)) + labs(title = "Pairwise decoding - rLO - controls - french")
coord_fixed()
ggsave("figures/pairwise_RDM_ctrl-rLO_fr.png", width = 2000, height = 1600, dpi = 320, units = "px")

# Experts VWFA braille
ggplot(rdm_e_vwfa_br, aes(X, Y, fill= accuracy)) + geom_tile() + theme_classic() +
  theme(axis.title.x=element_blank(), axis.ticks.x=element_blank(), axis.title.y=element_blank(), axis.ticks.y=element_blank(),
        axis.text.x = element_text(face="bold", colour="#000000", size=9), axis.text.y = element_text(face="bold", colour="#000000", size=9),
        axis.line.x = element_blank(), axis.line.y = element_blank()) +
  geom_text(aes(label = round(accuracy, 2))) + scale_fill_gradient2(low = "#FFFFFF", high = "#19772a", limit = c(0,1), na.value = "white",) + 
  guides(fill = guide_colourbar(barwidth = 0.7, barheight = 20, ticks = FALSE)) + labs(title = "Pairwise decoding - VWFA - experts - braille")
coord_fixed()
ggsave("figures/pairwise_RDM_exp-VWFA_br.png", width = 2000, height = 1600, dpi = 320, units = "px")

# Experts lLO braille
ggplot(rdm_e_llo_br, aes(X, Y, fill= accuracy)) + geom_tile() + theme_classic() +
  theme(axis.title.x=element_blank(), axis.ticks.x=element_blank(), axis.title.y=element_blank(), axis.ticks.y=element_blank(),
        axis.text.x = element_text(face="bold", colour="#000000", size=9), axis.text.y = element_text(face="bold", colour="#000000", size=9),
        axis.line.x = element_blank(), axis.line.y = element_blank()) +
  geom_text(aes(label = round(accuracy, 2))) + scale_fill_gradient2(low = "#FFFFFF", high = "#19772a", limit = c(0,1), na.value = "white",) + 
  guides(fill = guide_colourbar(barwidth = 0.7, barheight = 20, ticks = FALSE)) + labs(title = "Pairwise decoding - lLO - experts - braille")
coord_fixed()
ggsave("figures/pairwise_RDM_exp-lLO_br.png", width = 2000, height = 1600, dpi = 320, units = "px")

# Experts rLO braille
ggplot(rdm_e_rlo_br, aes(X, Y, fill= accuracy)) + geom_tile() + theme_classic() +
  theme(axis.title.x=element_blank(), axis.ticks.x=element_blank(), axis.title.y=element_blank(), axis.ticks.y=element_blank(),
        axis.text.x = element_text(face="bold", colour="#000000", size=9), axis.text.y = element_text(face="bold", colour="#000000", size=9),
        axis.line.x = element_blank(), axis.line.y = element_blank()) +
  geom_text(aes(label = round(accuracy, 2))) + scale_fill_gradient2(low = "#FFFFFF", high = "#19772a", limit = c(0,1), na.value = "white",) + 
  guides(fill = guide_colourbar(barwidth = 0.7, barheight = 20, ticks = FALSE)) + labs(title = "Pairwise decoding - rLO - experts - braille")
coord_fixed()
ggsave("figures/pairwise_RDM_exp-rLO_br.png", width = 2000, height = 1600, dpi = 320, units = "px")

# Controls VWFA braille
ggplot(rdm_c_vwfa_br, aes(X, Y, fill= accuracy)) + geom_tile() + theme_classic() +
  theme(axis.title.x=element_blank(), axis.ticks.x=element_blank(), axis.title.y=element_blank(), axis.ticks.y=element_blank(),
        axis.text.x = element_text(face="bold", colour="#000000", size=9), axis.text.y = element_text(face="bold", colour="#000000", size=9),
        axis.line.x = element_blank(), axis.line.y = element_blank()) +
  geom_text(aes(label = round(accuracy, 2))) + scale_fill_gradient2(low = "#FFFFFF", high = "#C20238", limit = c(0,1), na.value = "white",) + 
  guides(fill = guide_colourbar(barwidth = 0.7, barheight = 20, ticks = FALSE)) + labs(title = "Pairwise decoding - VWFA - controls - braille")
coord_fixed()
ggsave("figures/pairwise_RDM_ctrl-VWFA_br.png", width = 2000, height = 1600, dpi = 320, units = "px")

# Controls lLO braille
ggplot(rdm_c_llo_br, aes(X, Y, fill= accuracy)) + geom_tile() + theme_classic() +
  theme(axis.title.x=element_blank(), axis.ticks.x=element_blank(), axis.title.y=element_blank(), axis.ticks.y=element_blank(),
        axis.text.x = element_text(face="bold", colour="#000000", size=9), axis.text.y = element_text(face="bold", colour="#000000", size=9),
        axis.line.x = element_blank(), axis.line.y = element_blank()) +
  geom_text(aes(label = round(accuracy, 2))) + scale_fill_gradient2(low = "#FFFFFF", high = "#C20238", limit = c(0,1), na.value = "white",) + 
  guides(fill = guide_colourbar(barwidth = 0.7, barheight = 20, ticks = FALSE)) + labs(title = "Pairwise decoding - lLO - controls - braille")
coord_fixed()
ggsave("figures/pairwise_RDM_ctrl-lLO_br.png", width = 2000, height = 1600, dpi = 320, units = "px")

# Controls rLO braille
ggplot(rdm_c_rlo_br, aes(X, Y, fill= accuracy)) + geom_tile() + theme_classic() +
  theme(axis.title.x=element_blank(), axis.ticks.x=element_blank(), axis.title.y=element_blank(), axis.ticks.y=element_blank(),
        axis.text.x = element_text(face="bold", colour="#000000", size=9), axis.text.y = element_text(face="bold", colour="#000000", size=9),
        axis.line.x = element_blank(), axis.line.y = element_blank()) +
  geom_text(aes(label = round(accuracy, 2))) + scale_fill_gradient2(low = "#FFFFFF", high = "#C20238", limit = c(0,1), na.value = "white",) + 
  guides(fill = guide_colourbar(barwidth = 0.7, barheight = 20, ticks = FALSE)) + labs(title = "Pairwise decoding - rLO - controls - braille")
coord_fixed()
ggsave("figures/pairwise_RDM_ctrl-rLO_br.png", width = 2000, height = 1600, dpi = 320, units = "px")
