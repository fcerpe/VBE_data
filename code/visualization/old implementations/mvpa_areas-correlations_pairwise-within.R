setwd("~/Desktop/GitHub/VisualBraille_data/code/visualization")

library("readxl")
library("tidyverse")
library("reshape2")
library("gridExtra")
library('pracma')
library('data.table')
library('corrplot')

### Load matrices of decoding accuracies for both groups 

# Controls
ctrl_accuracies <- 
  read.csv("../../outputs/derivatives/CoSMoMVPA/mvpa-decoding_grp-controls_task-wordsDecoding_condition-pairwise-within-script_nbvoxels-73.csv")
  
# Experts
exp_accuracies <- 
  read.csv("../../outputs/derivatives/CoSMoMVPA/mvpa-decoding_grp-experts_task-wordsDecoding_condition-pairwise-within-script_nbvoxels-73.csv")

# Modify the data to get a color-coding column, to split between images
ctrl_accuracies <- as.data.frame(ctrl_accuracies)
exp_accuracies <- as.data.frame(exp_accuracies)

# Drop unnecessary columns
ctrl_accuracies <- subset(ctrl_accuracies, select = -c(4,7,8))
exp_accuracies <- subset(exp_accuracies, select = -c(4,7,8))

# Assign the script, to ease splitting the original accuracy matrix
# 1 = French, 2 = Braille
extraCol <- repmat(c(1,1,1,1,1,1,2,2,2,2,2,2), 1,36)
extraCol <- t(extraCol)

ctrl_accuracies$script <- extraCol
exp_accuracies$script <- extraCol

# divide the matrix for area, image, script
ctrl_div <- group_split(ctrl_accuracies, mask,image,script)
exp_div <- group_split(exp_accuracies, mask,image,script)

# Assign each group / area / script to a variable 
accu_control_vwfa_fr <- ctrl_div[[1]]; accu_control_vwfa_fr <- subset(accu_control_vwfa_fr, select = -c(4,5))
accu_control_vwfa_br <- ctrl_div[[2]]; accu_control_vwfa_br <- subset(accu_control_vwfa_br, select = -c(4,5))
accu_control_llo_fr <- ctrl_div[[5]];  accu_control_llo_fr <- subset(accu_control_llo_fr, select = -c(4,5))
accu_control_llo_br <- ctrl_div[[6]];  accu_control_llo_br <- subset(accu_control_llo_br, select = -c(4,5))
accu_control_rlo_fr <- ctrl_div[[9]];  accu_control_rlo_fr <- subset(accu_control_rlo_fr, select = -c(4,5))
accu_control_rlo_br <- ctrl_div[[10]]; accu_control_rlo_br <- subset(accu_control_rlo_br, select = -c(4,5))
accu_expert_vwfa_fr <- exp_div[[1]];   accu_expert_vwfa_fr <- subset(accu_expert_vwfa_fr, select = -c(4,5))
accu_expert_vwfa_br <- exp_div[[2]];   accu_expert_vwfa_br <- subset(accu_expert_vwfa_br, select = -c(4,5))
accu_expert_llo_fr <- exp_div[[5]];    accu_expert_llo_fr <- subset(accu_expert_llo_fr, select = -c(4,5))
accu_expert_llo_br <- exp_div[[6]];    accu_expert_llo_br <- subset(accu_expert_llo_br, select = -c(4,5))
accu_expert_rlo_fr <- exp_div[[9]];    accu_expert_rlo_fr <- subset(accu_expert_rlo_fr, select = -c(4,5))
accu_expert_rlo_br <- exp_div[[10]];   accu_expert_rlo_br <- subset(accu_expert_rlo_br, select = -c(4,5))

# Get average RDM for each area 
accu_control_vwfa_fr_means <- aggregate(accu_control_vwfa_fr$accuracy, list(accu_control_vwfa_fr$decodingCondition), FUN=mean)
accu_control_vwfa_br_means <- aggregate(accu_control_vwfa_br$accuracy, list(accu_control_vwfa_br$decodingCondition), FUN=mean)
accu_control_llo_fr_means <- aggregate(accu_control_llo_fr$accuracy, list(accu_control_llo_fr$decodingCondition), FUN=mean)
accu_control_llo_br_means <- aggregate(accu_control_llo_br$accuracy, list(accu_control_llo_br$decodingCondition), FUN=mean)
accu_control_rlo_fr_means <- aggregate(accu_control_rlo_fr$accuracy, list(accu_control_rlo_fr$decodingCondition), FUN=mean)
accu_control_rlo_br_means <- aggregate(accu_control_rlo_br$accuracy, list(accu_control_rlo_br$decodingCondition), FUN=mean)
accu_expert_vwfa_fr_means <- aggregate(accu_expert_vwfa_fr$accuracy, list(accu_expert_vwfa_fr$decodingCondition), FUN=mean)
accu_expert_vwfa_br_means <- aggregate(accu_expert_vwfa_br$accuracy, list(accu_expert_vwfa_br$decodingCondition), FUN=mean)
accu_expert_llo_fr_means <- aggregate(accu_expert_llo_fr$accuracy, list(accu_expert_llo_fr$decodingCondition), FUN=mean)
accu_expert_llo_br_means <- aggregate(accu_expert_llo_br$accuracy, list(accu_expert_llo_br$decodingCondition), FUN=mean)
accu_expert_rlo_fr_means <- aggregate(accu_expert_rlo_fr$accuracy, list(accu_expert_rlo_fr$decodingCondition), FUN=mean)
accu_expert_rlo_br_means <- aggregate(accu_expert_rlo_br$accuracy, list(accu_expert_rlo_br$decodingCondition), FUN=mean)



### PERFORM CORRELATIONS

# Combine matrices into a list
all_c_areas <- list(
  list(name = "c_vwfa_fr", numbers = accu_control_vwfa_fr_means$x), list(name = "c_vwfa_br", numbers = accu_control_vwfa_br_means$x),
  list(name = "c_llo_fr", numbers = accu_control_llo_fr_means$x),   list(name = "c_llo_br", numbers = accu_control_llo_br_means$x),
  list(name = "c_rlo_fr", numbers = accu_control_rlo_fr_means$x),   list(name = "c_rlo_br", numbers = accu_control_rlo_br_means$x))

all_e_areas <- list(
  list(name = "e_vwfa_fr", numbers = accu_expert_vwfa_fr_means$x),  list(name = "e_vwfa_br", numbers = accu_expert_vwfa_br_means$x),
  list(name = "e_llo_fr", numbers = accu_expert_llo_fr_means$x),    list(name = "e_llo_br", numbers = accu_expert_llo_br_means$x),
  list(name = "e_rlo_fr", numbers = accu_expert_rlo_fr_means$x),    list(name = "e_rlo_br", numbers = accu_expert_rlo_br_means$x))

# Initialize empty matrices to store correlation results
correlation_c <- data.table(Area1 = character(), Area2 = character(), Correlation = numeric())
correlation_e <- data.table(Area1 = character(), Area2 = character(), Correlation = numeric())

# square matrices for better visualization
num_c <- length(all_c_areas)
corr_c_mat <- matrix(NA, nrow = num_c, ncol = num_c, byrow = TRUE)
rownames(corr_c_mat) <- c("VWFA_FR", "VWFA_BR","lLO_FR","lLO_BR","rLO_FR","rLO_BR")
colnames(corr_c_mat) <- c("VWFA_FR", "VWFA_BR","lLO_FR","lLO_BR","rLO_FR","rLO_BR")

num_e <- length(all_c_areas)
corr_e_mat <- matrix(NA, nrow = num_e, ncol = num_e)
rownames(corr_e_mat) <- c("VWFA_FR", "VWFA_BR","lLO_FR","lLO_BR","rLO_FR","rLO_BR")
colnames(corr_e_mat) <- c("VWFA_FR", "VWFA_BR","lLO_FR","lLO_BR","rLO_FR","rLO_BR")

# Loop through all the items of the list and 
# compute pairwise correlation between them

# CONTROLS
for (i in 1:length(all_c_areas)) {
  for (j in i:length(all_c_areas)) {
    cat("Correlation between ", i, "and ", j, ":\n")
    # get correlation  
    corr_res <- cor(all_c_areas[[i]]$numbers, all_c_areas[[j]]$numbers) 
    # save as table format to add it 
    result <- data.table(Area1 = all_c_areas[[i]]$name, Area2 = all_c_areas[[j]]$name, Correlation = corr_res)
    # add to the main table
    correlation_c <- rbind(correlation_c, result)
    # print it on screen
    cat(corr_res) 
    # save also the heatmap values
    corr_c_mat[i, j] <- corr_res
    corr_c_mat[j, i] <- corr_res # Fill in lower triangular part of the matrix
    cat("\n")
  }
}

# EXPERTS
for (i in 1:length(all_e_areas)) {
  for (j in i:length(all_e_areas)) {
    cat("Correlation between ", i, "and ", j, ":\n")
    # get correlation  
    corr_res <- cor(all_e_areas[[i]]$numbers, all_e_areas[[j]]$numbers) 
    # save as table format to add it 
    result <- data.table(Area1 = all_e_areas[[i]]$name, Area2 = all_e_areas[[j]]$name, Correlation = corr_res)
    # add to the main table
    correlation_e <- rbind(correlation_e, result)
    # print it on screen
    cat(corr_res) 
    # save also the heatmap values
    corr_e_mat[i, j] <- corr_res
    corr_e_mat[j, i] <- corr_res # Fill in lower triangular part of the matrix
    cat("\n")
  }
}

# Re-arrange items in matrix.
# There must be a easier way
corr_c_values = c(corr_c_mat[[1,6]], corr_c_mat[[2,6]], corr_c_mat[[3,6]], corr_c_mat[[4,6]], corr_c_mat[[5,6]], corr_c_mat[[6,6]],
                  corr_c_mat[[1,5]], corr_c_mat[[2,5]], corr_c_mat[[3,5]], corr_c_mat[[4,5]], corr_c_mat[[5,5]], corr_c_mat[[6,5]],
                  corr_c_mat[[1,4]], corr_c_mat[[2,4]], corr_c_mat[[3,4]], corr_c_mat[[4,4]], corr_c_mat[[5,4]], corr_c_mat[[6,4]],
                  corr_c_mat[[1,3]], corr_c_mat[[2,3]], corr_c_mat[[3,3]], corr_c_mat[[4,3]], corr_c_mat[[5,3]], corr_c_mat[[6,3]],
                  corr_c_mat[[1,2]], corr_c_mat[[2,2]], corr_c_mat[[3,2]], corr_c_mat[[4,2]], corr_c_mat[[5,2]], corr_c_mat[[6,2]],
                  corr_c_mat[[1,1]], corr_c_mat[[2,1]], corr_c_mat[[3,1]], corr_c_mat[[4,1]], corr_c_mat[[5,1]], corr_c_mat[[6,1]])

corr_e_values = c(corr_e_mat[[1,6]], corr_e_mat[[2,6]], corr_e_mat[[3,6]], corr_e_mat[[4,6]], corr_e_mat[[5,6]], corr_e_mat[[6,6]],
                  corr_e_mat[[1,5]], corr_e_mat[[2,5]], corr_e_mat[[3,5]], corr_e_mat[[4,5]], corr_e_mat[[5,5]], corr_e_mat[[6,5]],
                  corr_e_mat[[1,4]], corr_e_mat[[2,4]], corr_e_mat[[3,4]], corr_e_mat[[4,4]], corr_e_mat[[5,4]], corr_e_mat[[6,4]],
                  corr_e_mat[[1,3]], corr_e_mat[[2,3]], corr_e_mat[[3,3]], corr_e_mat[[4,3]], corr_e_mat[[5,3]], corr_e_mat[[6,3]],
                  corr_e_mat[[1,2]], corr_e_mat[[2,2]], corr_e_mat[[3,2]], corr_e_mat[[4,2]], corr_e_mat[[5,2]], corr_e_mat[[6,2]],
                  corr_e_mat[[1,1]], corr_e_mat[[2,1]], corr_e_mat[[3,1]], corr_e_mat[[4,1]], corr_e_mat[[5,1]], corr_e_mat[[6,1]])

# Create ggplot-friendly matrices
x <- c("VWFA_FR", "VWFA_BR", "lLO_FR", "lLO_BR", "rLO_FR",  "rLO_BR")
y <- c("rLO_BR",  "rLO_FR",  "lLO_BR", "lLO_FR", "VWFA_BR", "VWFA_FR") # Second one is inverted, that's how ggplot like it
corr_c_plot <- expand.grid(Area1=x, Area2=y)
corr_c_plot$correlation <- corr_c_values

x <- c("VWFA_FR", "VWFA_BR", "lLO_FR", "lLO_BR", "rLO_FR",  "rLO_BR")
y <- c("rLO_BR",  "rLO_FR",  "lLO_BR", "lLO_FR", "VWFA_BR", "VWFA_FR") # Second one is inverted, that's how ggplot like it
corr_e_plot <- expand.grid(Area1=x, Area2=y)
corr_e_plot$correlation <- corr_e_values



# PLOT CORRELATIONS 

# Controls
ggplot(as.data.frame(corr_c_plot), aes(x=Area1, y=Area2, fill= correlation)) +
  geom_tile() + theme_classic() +
  theme(axis.title.x=element_blank(), axis.ticks.x=element_blank(),
        axis.title.y=element_blank(), axis.ticks.y=element_blank(),
        axis.text.x = element_text(face="bold", colour="#000000", size=9),
        axis.text.y = element_text(face="bold", colour="#000000", size=9),
        axis.line.x = element_blank(), axis.line.y = element_blank()) +
  geom_text(aes(label = round(correlation, 2))) +
  scale_fill_gradient2(low = "#ffffff", high = "#ff0000", limit = c(-0.2,1)) + 
  guides(fill = guide_colourbar(barwidth = 0.7, barheight = 20, ticks = FALSE)) +
  labs(title = "Correlations between areas - controls")
  coord_fixed()

ggsave("figures/areas-correlations_controls.png", width = 2000, height = 1600, dpi = 320, units = "px")

# Experts
ggplot(as.data.frame(corr_e_plot), aes(x=Area1, y=Area2, fill= correlation)) +
  geom_tile() + theme_classic() +
  theme(axis.title.x=element_blank(), axis.ticks.x=element_blank(),
        axis.title.y=element_blank(), axis.ticks.y=element_blank(),
        axis.text.x = element_text(face="bold", colour="#000000", size=9),
        axis.text.y = element_text(face="bold", colour="#000000", size=9),
        axis.line.x = element_blank(), axis.line.y = element_blank()) +
  geom_text(aes(label = round(correlation, 2))) +
  scale_fill_gradient2(low = "#ffffff", high = "#ff0000",  limit = c(-0.2,1)) + 
  guides(fill = guide_colourbar(barwidth = 0.7, barheight = 20, ticks = FALSE)) +
  labs(title = "Correlations between areas - experts")
coord_fixed()

ggsave("figures/areas-correlations_experts.png", width = 2000, height = 1600, dpi = 320, units = "px")
