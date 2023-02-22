library("readxl")
library("tidyverse")
library("reshape2")
library("gridExtra")

decodingScores <- read_excel("/Users/cerpelloni/Desktop/GitHub/VisualBraille_data/code/mvpa/comparison_experts_scores.xlsx")

# Modify the data to get a color-coding column, to split between images
df_scores <- as.data.frame(decodingScores)

# divide different images: two plots
means_div <- group_split(df_scores, image)

# Divide beta into 3 voxels sizes. Longer code, easier plot
means_beta <- means_div[[1]]
means_tmap <- means_div[[2]]

means_beta = mutate(means_beta, image = NULL)
means_tmap = mutate(means_tmap, image = NULL)

beta_div <- group_split(means_beta, nbVoxels)
beta50 <- beta_div[[1]]
beta65 <- beta_div[[2]]
beta81 <- beta_div[[3]]

## BETA - 50 voxels
plotBeta50 <- ggplot(beta50, aes(x = decodingCondition, y = accuracy), middle = mean(accuracy))
plotBeta50 + geom_boxplot(outlier.shape = NA, aes(colour = script)) + 
  theme_classic() + 
  geom_hline(aes(yintercept = 0.5), size = .25, linetype = "dashed") +  
  ylim(0,1) +
  geom_jitter(width = 0.3) +
  facet_grid(. ~ nbVoxels + factor(area, levels = c("VWFAfr", "lLO", "rLO")), switch = "x", labeller = label_value) + 
  theme(axis.text.x = element_text(angle = 90)) + 
  scale_x_discrete(limits = c("frw_v_fpw","frw_v_fnw","frw_v_ffs","fpw_v_fnw","fpw_v_ffs","fnw_v_ffs",
                              "brw_v_bpw","brw_v_bnw","brw_v_bfs","bpw_v_bnw","bpw_v_bfs","bnw_v_bfs"),
                   labels = c("FRW - FPW", "FRW - FNW", "FRW - FFS", "FPW - FNW",
                              "FPW - FFS", "FNW - FFS", "BRW - BPW", "BRW - BNW",
                              "BRW - BFS", "BPW - BNW", "BPW - BFS", "BNW - BFS")) +
  labs(x = "nbVoxels x Area", y = "Accuracy", title = "Mean decoding acccuracy - beta")

ggsave("nbVox-50_decoding-accuracy_beta.png", width = 2600, height = 1600, dpi = 320, units = "px")

## BETA - 65 voxels
plotBeta65 <- ggplot(beta65, aes(x = decodingCondition, y = accuracy), middle = mean(accuracy))
plotBeta65 + geom_boxplot(outlier.shape = NA, aes(colour = script)) + 
  theme_classic() + 
  geom_hline(aes(yintercept = 0.5), size = .25, linetype = "dashed") +  
  ylim(0,1) +
  geom_jitter(width = 0.3) +
  facet_grid(. ~ nbVoxels + factor(area, levels = c("VWFAfr", "lLO", "rLO")), switch = "x", labeller = label_value) + 
  theme(axis.text.x = element_text(angle = 90)) + 
  scale_x_discrete(limits = c("frw_v_fpw","frw_v_fnw","frw_v_ffs","fpw_v_fnw","fpw_v_ffs","fnw_v_ffs",
                              "brw_v_bpw","brw_v_bnw","brw_v_bfs","bpw_v_bnw","bpw_v_bfs","bnw_v_bfs"),
                   labels = c("FRW - FPW", "FRW - FNW", "FRW - FFS", "FPW - FNW",
                              "FPW - FFS", "FNW - FFS", "BRW - BPW", "BRW - BNW",
                              "BRW - BFS", "BPW - BNW", "BPW - BFS", "BNW - BFS")) +
  labs(x = "nbVoxels x Area", y = "Accuracy", title = "Mean decoding acccuracy - beta")

ggsave("nbVox-65_decoding-accuracy_beta.png", width = 2600, height = 1600, dpi = 320, units = "px")

## BETA - 81 voxels
plotBeta81 <- ggplot(beta81, aes(x = decodingCondition, y = accuracy), middle = mean(accuracy))
plotBeta81 + geom_boxplot(outlier.shape = NA, aes(colour = script)) + 
  theme_classic() + 
  geom_hline(aes(yintercept = 0.5), size = .25, linetype = "dashed") +  
  ylim(0,1) +
  geom_jitter(width = 0.3) +
  facet_grid(. ~ nbVoxels + factor(area, levels = c("VWFAfr", "lLO", "rLO")), switch = "x", labeller = label_value) + 
  theme(axis.text.x = element_text(angle = 90)) + 
  scale_x_discrete(limits = c("frw_v_fpw","frw_v_fnw","frw_v_ffs","fpw_v_fnw","fpw_v_ffs","fnw_v_ffs",
                              "brw_v_bpw","brw_v_bnw","brw_v_bfs","bpw_v_bnw","bpw_v_bfs","bnw_v_bfs"),
                   labels = c("FRW - FPW", "FRW - FNW", "FRW - FFS", "FPW - FNW",
                              "FPW - FFS", "FNW - FFS", "BRW - BPW", "BRW - BNW",
                              "BRW - BFS", "BPW - BNW", "BPW - BFS", "BNW - BFS")) +
  labs(x = "nbVoxels x Area", y = "Accuracy", title = "Mean decoding acccuracy - beta")

ggsave("nbVox-81_decoding-accuracy_beta.png", width = 2600, height = 1600, dpi = 320, units = "px")


tmap_div <- group_split(means_tmap, nbVoxels)
tmap50 <- tmap_div[[1]]
tmap65 <- tmap_div[[2]]
tmap81 <- tmap_div[[3]]

## TMAP - 50 voxels
plotTmap50 <- ggplot(tmap50, aes(x = decodingCondition, y = accuracy), middle = mean(accuracy))
plotTmap50 + geom_boxplot(outlier.shape = NA, aes(colour = script)) + 
  theme_classic() + 
  geom_hline(aes(yintercept = 0.5), size = .25, linetype = "dashed") +  
  ylim(0,1) +
  geom_jitter(width = 0.3) +
  facet_grid(. ~ nbVoxels + factor(area, levels = c("VWFAfr", "lLO", "rLO")), switch = "x", labeller = label_value) + 
  theme(axis.text.x = element_text(angle = 90)) + 
  scale_x_discrete(limits = c("frw_v_fpw","frw_v_fnw","frw_v_ffs","fpw_v_fnw","fpw_v_ffs","fnw_v_ffs",
                              "brw_v_bpw","brw_v_bnw","brw_v_bfs","bpw_v_bnw","bpw_v_bfs","bnw_v_bfs"),
                   labels = c("FRW - FPW", "FRW - FNW", "FRW - FFS", "FPW - FNW",
                              "FPW - FFS", "FNW - FFS", "BRW - BPW", "BRW - BNW",
                              "BRW - BFS", "BPW - BNW", "BPW - BFS", "BNW - BFS")) +
  labs(x = "nbVoxels x Area", y = "Accuracy", title = "Mean decoding acccuracy - tmap")

ggsave("nbVox-50_decoding-accuracy_tmap.png", width = 2600, height = 1600, dpi = 320, units = "px")

## TMAP - 65 voxels
plotTmap65 <- ggplot(tmap65, aes(x = decodingCondition, y = accuracy), middle = mean(accuracy))
plotTmap65 + geom_boxplot(outlier.shape = NA, aes(colour = script)) + 
  theme_classic() + 
  geom_hline(aes(yintercept = 0.5), size = .25, linetype = "dashed") +  
  ylim(0,1) +
  geom_jitter(width = 0.3) +
  facet_grid(. ~ nbVoxels + factor(area, levels = c("VWFAfr", "lLO", "rLO")), switch = "x", labeller = label_value) + 
  theme(axis.text.x = element_text(angle = 90)) + 
  scale_x_discrete(limits = c("frw_v_fpw","frw_v_fnw","frw_v_ffs","fpw_v_fnw","fpw_v_ffs","fnw_v_ffs",
                              "brw_v_bpw","brw_v_bnw","brw_v_bfs","bpw_v_bnw","bpw_v_bfs","bnw_v_bfs"),
                   labels = c("FRW - FPW", "FRW - FNW", "FRW - FFS", "FPW - FNW",
                              "FPW - FFS", "FNW - FFS", "BRW - BPW", "BRW - BNW",
                              "BRW - BFS", "BPW - BNW", "BPW - BFS", "BNW - BFS")) +
  labs(x = "nbVoxels x Area", y = "Accuracy", title = "Mean decoding acccuracy - tmap")

ggsave("nbVox-65_decoding-accuracy_tmap.png", width = 2600, height = 1600, dpi = 320, units = "px")

## TMAP - 81 voxels
plotTmap81 <- ggplot(tmap81, aes(x = decodingCondition, y = accuracy), middle = mean(accuracy))
plotTmap81 + geom_boxplot(outlier.shape = NA, aes(colour = script)) + 
  theme_classic() + 
  geom_hline(aes(yintercept = 0.5), size = .25, linetype = "dashed") +  
  ylim(0,1) +
  geom_jitter(width = 0.3) +
  facet_grid(. ~ nbVoxels + factor(area, levels = c("VWFAfr", "lLO", "rLO")), switch = "x", labeller = label_value) + 
  theme(axis.text.x = element_text(angle = 90)) + 
  scale_x_discrete(limits = c("frw_v_fpw","frw_v_fnw","frw_v_ffs","fpw_v_fnw","fpw_v_ffs","fnw_v_ffs",
                              "brw_v_bpw","brw_v_bnw","brw_v_bfs","bpw_v_bnw","bpw_v_bfs","bnw_v_bfs"),
                   labels = c("FRW - FPW", "FRW - FNW", "FRW - FFS", "FPW - FNW",
                              "FPW - FFS", "FNW - FFS", "BRW - BPW", "BRW - BNW",
                              "BRW - BFS", "BPW - BNW", "BPW - BFS", "BNW - BFS")) +
  labs(x = "nbVoxels x Area", y = "Accuracy", title = "Mean decoding acccuracy - tmap")

ggsave("nbVox-81_decoding-accuracy_tmap.png", width = 2600, height = 1600, dpi = 320, units = "px")
