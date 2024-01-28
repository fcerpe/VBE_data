setwd("~/Desktop/GitHub/VisualBraille_data/code/visualization")

library("readxl")
library("tidyverse")
library("reshape2")
library("gridExtra")
library('pracma')
library('data.table')
library('corrplot')

### Load matrices of decoding accuracies for "linguistic condition" decoding
exp_accuracies <- 
  read.csv("/Volumes/fcerpe_ssd/VisualBraille_data/outputs/derivatives/CoSMoMVPA/decoding-pairwise_modality-within_group-all_space-IXI549Space_rois-expansion_nbvoxels-43.csv")


### Manipulate the matrix to get something readable by ggplot
exp_accuracies <- as.data.frame(exp_accuracies)

# Drop unnecessary columns
exp_accuracies <- subset(exp_accuracies, select = -c(4,7,8))

# Assign the script, to ease splitting the original accuracy matrix: 1 = French, 2 = Braille
extraCol <- repmat(c(1,1,1,1,1,1,2,2,2,2,2,2), 1,102)
extraCol <- t(extraCol)
exp_accuracies$script <- extraCol

# divide the matrix for area, image
exp_div <- group_split(exp_accuracies, mask, image, script)

# Assign each group x area to a variable 
e_vwfa_fr <- exp_div[[1]]



# average decodings 
e_vwfa_fr_means <- aggregate(e_vwfa_fr$accuracy, list(e_vwfa_fr$decodingCondition), FUN=mean)


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

# Controls rLO braille
ggplot(rdm_c_rlo_br, aes(X, Y, fill= accuracy)) + geom_tile() + theme_classic() +
  theme(axis.title.x=element_blank(), axis.ticks.x=element_blank(), axis.title.y=element_blank(), axis.ticks.y=element_blank(),
        axis.text.x = element_text(face="bold", colour="#000000", size=9), axis.text.y = element_text(face="bold", colour="#000000", size=9),
        axis.line.x = element_blank(), axis.line.y = element_blank()) +
  geom_text(aes(label = round(accuracy, 2))) + scale_fill_gradient2(low = "#FFFFFF", high = "#C20238", limit = c(0,1), na.value = "white",) + 
  guides(fill = guide_colourbar(barwidth = 0.7, barheight = 20, ticks = FALSE)) + labs(title = "Pairwise decoding - rLO - controls - braille")
coord_fixed()
ggsave("figures/pairwise_RDM_ctrl-rLO_br.png", width = 2000, height = 1600, dpi = 320, units = "px")
