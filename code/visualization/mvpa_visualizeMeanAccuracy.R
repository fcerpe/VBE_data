
setwd("~/Desktop/GitHub/VisualBraille_data/code/visualization")

library("readxl")
library("tidyverse")
library("reshape2")
library("gridExtra")

decodingMeans <- read_excel("/Users/cerpelloni/Desktop/GitHub/VisualBraille_data/code/mvpa/comparison_experts_means.xlsx")

# Modify the data to get a color-coding column, to split between images
df_means <- as.data.frame(decodingMeans)

# divide different images: two plots
means_div <- group_split(df_means, image)

# Divide beta into 3 voxels sizes. Longer code, easier plot
means_beta <- means_div[[1]]
means_tmap <- means_div[[2]]

means_beta = mutate(means_beta, image = NULL)
means_tmap = mutate(means_tmap, image = NULL)

plotBeta <- ggplot(means_beta, aes(x = decodingCondition, y = accuracy), middle = mean(accuracy))
plotBeta + geom_boxplot(outlier.shape = NA, aes(colour = script)) + 
  theme_classic() + 
  geom_hline(aes(yintercept = 0.5), size = .25, linetype = "dashed") +  
  ylim(0,1) +
  geom_jitter(aes(colour = script), width = 0.3) +
  theme(axis.text.x=element_blank(), axis.ticks.x=element_blank()) + 
  facet_grid(. ~ nbVoxels + factor(area, levels = c("VWFAfr", "lLO", "rLO")), switch = "x", labeller = label_value) + 
  labs(x = "nbVoxels x Area", y = "Accuracy", title = "Mean decoding acccuracy - beta")

ggsave("mean_accuracy_beta.png", width = 2600, height = 1600, dpi = 320, units = "px")


plotTmap <- ggplot(means_tmap, aes(x = decodingCondition, y = accuracy))
plotTmap + geom_boxplot(outlier.shape = NA, aes(colour = script)) + 
  theme_classic() + 
  geom_hline(aes(yintercept = 0.5), size = .25, linetype = "dashed") +  
  ylim(0,1) +
  geom_jitter(aes(colour = script), width = 0.3) +
  theme(axis.text.x=element_blank(), axis.ticks.x=element_blank()) + 
  facet_grid(. ~ nbVoxels + factor(area, levels = c("VWFAfr", "lLO", "rLO")), switch = "x", labeller = label_value) + 
  labs(x = "nbVoxels x Area", y = "Accuracy", title = "Mean decoding acccuracy - tmap")

ggsave("mean_accuracy_tmap.png", width = 2600, height = 1600, dpi = 320, units = "px")


## FOR PPP POSTER
# visualize only 50 voxels 

beta_div <- group_split(means_beta, nbVoxels)
b50 <- beta_div[[1]]

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



