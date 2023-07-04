
setwd("~/Desktop/GitHub/VisualBraille_data/code/visualization")

library("readxl")
library("tidyverse")
library("reshape2")
library("gridExtra")

decodingMeans <- read_excel("/Users/cerpelloni/Desktop/GitHub/VisualBraille_data/code/mvpa/comparison_experts_means.xlsx")
decodingScores <- read_excel("/Users/cerpelloni/Desktop/GitHub/VisualBraille_data/code/mvpa/comparison_experts_scores.xlsx")

# Modify the data to get a color-coding column, to split between images
df_means <- as.data.frame(decodingMeans)
df_scores <- as.data.frame(decodingScores)

# divide different images
means_div <- group_split(df_means, image)
scores_div <- group_split(df_scores, image)

# Take only the image we care about (BETA)
means_beta <- means_div[[1]]
means_beta = mutate(means_beta, image = NULL)

scores_beta <- scores_div[[1]]
scores_beta = mutate(scores_beta, image = NULL)

# Take only the voxel size we care about (50)
scores_beta_div <- group_split(scores_beta, nbVoxels)
scores50 <- scores_beta_div[[1]]

beta_div <- group_split(means_beta, nbVoxels)
b50 <- beta_div[[1]]

## FOR PPP POSTER
# mean decoding
plotB50 <- ggplot(b50, aes(x = decodingCondition, y = accuracy), middle = mean(accuracy))
plotB50 + geom_boxplot(outlier.shape = NA, aes(colour = script)) + 
  theme_classic() + 
  geom_hline(aes(yintercept = 0.5), size = .25, linetype = "dashed") +  
  ylim(0,1) +
  geom_jitter(aes(colour = script), width = 0.3) +
  theme(axis.text.x=element_blank(), axis.ticks.x=element_blank()) + 
  facet_grid(. ~ factor(area, levels = c("VWFAfr", "lLO", "rLO")), switch = "x", labeller = label_value) + 
  labs(x = "Area", y = "Accuracy", title = "Mean decoding acccuracy - beta")

ggsave("mean_accuracy_b50.png", width = 2600, height = 1600, dpi = 320, units = "px")

# single conditions
plotS50 <- ggplot(scores50, aes(x = decodingCondition, y = accuracy), middle = mean(accuracy))
plotS50 + geom_boxplot(outlier.shape = NA, aes(colour = script)) + 
  theme_classic() + 
  geom_hline(aes(yintercept = 0.5), size = .25, linetype = "dashed") +  
  ylim(0,1) +
  geom_jitter(width = 0.1, size = 1, aes(colour = script)) +
  facet_grid(. ~ factor(area, levels = c("VWFAfr", "lLO", "rLO"), labels = c("VWFA", "lLO", "rLO")), switch = "x", labeller = label_value) + 
  theme(axis.text.x = element_text(angle = 45, vjust=1, hjust=1)) + 
  scale_x_discrete(limits = c("frw_v_fpw","frw_v_fnw","frw_v_ffs","fpw_v_fnw","fpw_v_ffs","fnw_v_ffs",
                              "brw_v_bpw","brw_v_bnw","brw_v_bfs","bpw_v_bnw","bpw_v_bfs","bnw_v_bfs"),
                   labels = c("FRW - FPW", "FRW - FNW", "FRW - FFS", "FPW - FNW",
                              "FPW - FFS", "FNW - FFS", "BRW - BPW", "BRW - BNW",
                              "BRW - BFS", "BPW - BNW", "BPW - BFS", "BNW - BFS")) +
  labs(x = "Area", y = "Accuracy")

ggsave("nbVox-50_PPP_beta.png", width = 2600, height = 1300, dpi = 320, units = "px")


## RDM 
#

scores50_div <- group_split(scores50, area)
scoresVWFA <- scores50_div[[1]]
vwfa_div <- group_split(scoresVWFA, script)
vwfa_br <- vwfa_div[[1]]
vwfa_fr <- vwfa_div[[2]]

# perform correlation 
cor.test(vwfa_fr[["accuracy"]], vwfa_br[["accuracy"]])

# average decodings 
vwfa_br_means <- aggregate(vwfa_br$accuracy, list(vwfa_br$decodingCondition), FUN=mean)
vwfa_fr_means <- aggregate(vwfa_fr$accuracy, list(vwfa_fr$decodingCondition), FUN=mean) 

# make RDM - manually since they're small
rdm_br = c(vwfa_br_means[[4,2]], vwfa_br_means[[2,2]], vwfa_br_means[[1,2]], NaN,
           vwfa_br_means[[5,2]], vwfa_br_means[[3,2]], NaN, vwfa_br_means[[1,2]],
           vwfa_br_means[[6,2]], NaN, vwfa_br_means[[3,2]], vwfa_br_means[[2,2]],
           NaN, vwfa_br_means[[6,2]], vwfa_br_means[[5,2]], vwfa_br_means[[4,2]])

rdm_fr = c(vwfa_fr_means[[4,2]], vwfa_fr_means[[2,2]], vwfa_fr_means[[1,2]], NaN,
           vwfa_fr_means[[5,2]], vwfa_fr_means[[3,2]], NaN,                  vwfa_fr_means[[1,2]],
           vwfa_fr_means[[6,2]], NaN,                  vwfa_fr_means[[3,2]], vwfa_fr_means[[2,2]],
           NaN,                  vwfa_fr_means[[6,2]], vwfa_fr_means[[5,2]], vwfa_fr_means[[4,2]])



# Dummy data
x <- c("RW", "PW", "NW", "FS")
y <- c("FS", "NW", "PW", "RW")
rdm <- expand.grid(X=x, Y=y)
rdm$accuracy <- rdm_fr

# Heatmaps

# FR
ggplot(rdm, aes(X, Y, fill= accuracy)) + 
  geom_tile() + theme_classic() +
  theme(axis.title.x=element_blank(), axis.ticks.x=element_blank(),
        axis.title.y=element_blank(), axis.ticks.y=element_blank(),
        axis.text.x = element_text(face="bold", colour="#000000", size=20),
        axis.text.y = element_text(face="bold", colour="#000000", size=20),
        axis.line.x = element_blank(), axis.line.y = element_blank()) +
  scale_fill_gradient2(low = "#FFFFFF", mid = "#FFFFFF", high = "#19772a", na.value = "#FFFFFF",
                        limit = c(0.1,1)) + 
  guides(fill = guide_colourbar(barwidth = 0.7, barheight = 20, ticks = FALSE)) +
  coord_fixed()

ggsave("rdm_fr.png", width = 2000, height = 2000, dpi = 320, units = "px")

# BR
# Dummy data
x <- c("RW", "PW", "NW", "FS")
y <- c("FS", "NW", "PW", "RW")
rdm <- expand.grid(X=x, Y=y)
rdm$accuracy <- rdm_br

ggplot(rdm, aes(X, Y, fill= accuracy)) + 
  geom_tile() + theme_classic() +
  theme(axis.title.x=element_blank(), axis.ticks.x=element_blank(),
        axis.title.y=element_blank(), axis.ticks.y=element_blank(),
        axis.text.x = element_text(face="bold", colour="#000000", size=20),
        axis.text.y = element_text(face="bold", colour="#000000", size=20),
        axis.line.x = element_blank(), axis.line.y = element_blank()) +
  scale_fill_gradient2(low = "#FFFFFF", mid = "#FFFFFF", high = "#19772a", na.value = "#FFFFFF",
                       limit = c(0.1,1)) + 
  guides(fill = guide_colourbar(barwidth = 0.7, barheight = 20, ticks = FALSE)) +
  coord_fixed() 

ggsave("rdm_br.png", width = 2000, height = 2000, dpi = 320, units = "px")
