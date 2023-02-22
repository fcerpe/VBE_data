library("readxl")
library("tidyverse")
library("reshape2")
library("gridExtra")

decodingMeans <- read_excel("/Users/cerpelloni/Desktop/GitHub/VisualBraille_data/code/mvpa/comparison_experts_means_modified.xlsx")

# Modify the data to get a color-coding column, to split between images
df_means <- as.data.frame(decodingMeans)

df_means$scriptColor = df_means$decodingCondition

# divide different images: two plots
means_div <- group_split(df_means, image)

# Divide beta into 3 voxels sizes. Longer code, easier plot
means_beta <- means_div[[1]]
means_tmap <- means_div[[2]]

means_beta = unite(means_beta, ids, c(area, decodingCondition))
means_beta = mutate(means_beta, image = NULL)
means_tmap = unite(means_tmap, ids, c(area, decodingCondition))
means_tmap = mutate(means_tmap, image = NULL)

plotBeta <- ggplot(means_beta, aes(x = ids, y = accuracy))
plotBeta + geom_boxplot(outlier.shape = NA, aes(colour = scriptColor)) + 
  theme_classic() + 
  geom_hline(aes(yintercept = 0.5), size = .25, linetype = "dashed") +  
  ylim(0,1) +
  geom_jitter(aes(colour = scriptColor), width = 0.2) +
  facet_grid(cols = vars(nbVoxels)) + 
  labs(x = "Area", y = "Accuracy", title = "Mean decoding acccuracy - beta")

plotTmap <- ggplot(means_tmap, aes(x = ids, y = accuracy))
plotTmap + geom_boxplot(outlier.shape = NA, aes(colour = scriptColor)) + 
  theme_classic() + 
  geom_hline(aes(yintercept = 0.5), size = .25, linetype = "dashed") +  
  ylim(0,1) +
  geom_jitter(aes(colour = scriptColor), width = 0.2) +
  facet_grid(cols = vars(nbVoxels)) + 
  labs(x = "Area", y = "Accuracy", title = "Mean decoding acccuracy - tmap")


