
setwd("~/Desktop/GitHub/VisualBraille_data/code/visualization")

library("readxl")
library("tidyverse")
library("reshape2")
library("gridExtra")
library("pracma")
library("dplyr")
library("data.table")

### Load slopes report and plot mean slope  

# Load slopes report
slopes <- read.csv("../ppi/slopesReport.txt")

# Manipulate the matrix to get something readable by ggplot
slopes <- as.data.frame(slopes)

# Add cluster, for coloring purposes
slopes$cluster <- ifelse(slopes$script == "french", 
                       ifelse(slopes$group == "expert",
                              "french_expert",
                              "french_control"),
                       ifelse(slopes$group == "expert",
                              "braille_expert",
                              "braille_control"))

slopes$specify <- ifelse(slopes$group == "expert", 
                         paste(slopes$condition,"_exp",sep=""), 
                         paste(slopes$condition,"_ctr",sep=""))

# Sub-010, 018, 023 do not present any area in posTemp that is correlated with VWFA
# Select rows where 'subject' is not in the specified list
slopes <- slopes[!(slopes$subject %in% c("sub-010", "sub-018", "sub-023")), ]


# calculate stats for error bars
stats_slopes <- slopes %>% group_by(group, script, specify, cluster) %>% 
  summarize(mean_slope = mean(slope), sd_slope = sd(slope), se_slope = sd(slope)/sqrt(6),
            mean_intercept = mean(intercept), sd_intercept = sd(intercept), se_intercept = sd(intercept)/sqrt(6),
            .groups = 'keep')



### Load all the datapoints 

allPoints <- read.csv("../ppi/datapointsPPI.txt")

# Manipulate the matrix to get something readable by ggplot
allPoints <- as.data.frame(allPoints)

# Sub-010, 018, 023 do not present any area in posTemp that is correlated with VWFA
# Select rows where 'subject' is not in the specified list
allPoints <- allPoints[!(allPoints$subject %in% c(10, 18, 23)), ]



### Calculate correlations between groups and scripts

# Split groups according to condition
fw_exp <-  subset(allPoints, cluster == "french_expert" & condition == "fw")
sfw_exp <- subset(allPoints, cluster == "french_expert" & condition == "sfw")
bw_exp <-  subset(allPoints, cluster == "braille_expert" & condition == "bw")
sbw_exp <- subset(allPoints, cluster == "braille_expert" & condition == "sbw")
fw_ctr <-  subset(allPoints, cluster == "french_control" & condition == "fw")
sfw_ctr <- subset(allPoints, cluster == "french_control" & condition == "sfw")
bw_ctr <-  subset(allPoints, cluster == "braille_control" & condition == "bw")
sbw_ctr <- subset(allPoints, cluster == "braille_control" & condition == "sbw")

fw_exp_split <- group_split(fw_exp, subject)
sfw_exp_split <- group_split(sfw_exp, subject)
bw_exp_split <- group_split(bw_exp, subject)
sbw_exp_split <- group_split(sbw_exp, subject)
fw_ctr_split <- group_split(fw_ctr, subject)
sfw_ctr_split <- group_split(sfw_ctr, subject)
bw_ctr_split <- group_split(bw_ctr, subject)
sbw_ctr_split <- group_split(sbw_ctr, subject)

# create correlation table containing all the results
corr_table <- data.table(subject = character(), condition = character(), correlation = numeric())

# for each condition, calculate correlations within a participant
for (i in 1:length(fw_exp_split)) {
  corr_res <- cor(fw_exp_split[[i]]$x, fw_exp_split[[i]]$y) 
  result <- data.table(subject = fw_exp_split[[i]]$subject[1], 
                       condition = fw_exp_split[[i]]$condition[1], 
                       correlation = corr_res)
  corr_table <- rbind(corr_table, result)
}
for (i in 1:length(sfw_exp_split)) {
  corr_res <- cor(sfw_exp_split[[i]]$x, sfw_exp_split[[i]]$y) 
  result <- data.table(subject = sfw_exp_split[[i]]$subject[1], 
                       condition = sfw_exp_split[[i]]$condition[1], 
                       correlation = corr_res)
  corr_table <- rbind(corr_table, result)
}
for (i in 1:length(bw_exp_split)) {
  corr_res <- cor(bw_exp_split[[i]]$x, bw_exp_split[[i]]$y) 
  result <- data.table(subject = bw_exp_split[[i]]$subject[1], 
                       condition = bw_exp_split[[i]]$condition[1], 
                       correlation = corr_res)
  corr_table <- rbind(corr_table, result)
}
for (i in 1:length(sbw_exp_split)) {
  corr_res <- cor(sbw_exp_split[[i]]$x, sbw_exp_split[[i]]$y) 
  result <- data.table(subject = sbw_exp_split[[i]]$subject[1], 
                       condition = sbw_exp_split[[i]]$condition[1], 
                       correlation = corr_res)
  corr_table <- rbind(corr_table, result)
}
for (i in 1:length(fw_ctr_split)) {
  corr_res <- cor(fw_ctr_split[[i]]$x, fw_ctr_split[[i]]$y) 
  result <- data.table(subject = fw_ctr_split[[i]]$subject[1], 
                       condition = fw_ctr_split[[i]]$condition[1], 
                       correlation = corr_res)
  corr_table <- rbind(corr_table, result)
}
for (i in 1:length(sfw_ctr_split)) {
  corr_res <- cor(sfw_ctr_split[[i]]$x, sfw_ctr_split[[i]]$y) 
  result <- data.table(subject = sfw_ctr_split[[i]]$subject[1], 
                       condition = sfw_ctr_split[[i]]$condition[1], 
                       correlation = corr_res)
  corr_table <- rbind(corr_table, result)
}
for (i in 1:length(bw_ctr_split)) {
  corr_res <- cor(bw_ctr_split[[i]]$x, bw_ctr_split[[i]]$y) 
  result <- data.table(subject = bw_ctr_split[[i]]$subject[1], 
                       condition = bw_ctr_split[[i]]$condition[1], 
                       correlation = corr_res)
  corr_table <- rbind(corr_table, result)
}
for (i in 1:length(sbw_ctr_split)) {
  corr_res <- cor(sbw_ctr_split[[i]]$x, sbw_ctr_split[[i]]$y) 
  result <- data.table(subject = sbw_ctr_split[[i]]$subject[1], 
                       condition = sbw_ctr_split[[i]]$condition[1], 
                       correlation = corr_res)
  corr_table <- rbind(corr_table, result)
}

# Are correlations significantly different from one another?

# List to store t-test results
t_test_results <- list()

# Unique labels in the data
unique_conditions <- unique(corr_table$condition)

# Loop through each unique label and perform a t-test
# for (i in 1:(length(unique_conditions) - 1)) {
#   for (j in (i + 1):length(unique_conditions)) {
#     cond1 <- unique_conditions[i]
#     cond2 <- unique_conditions[j]
#     
#     # Subset data for the two labels
#     subset_data1 <- subset(corr_table, condition  == cond1)
#     subset_data2 <- subset(corr_table, condition  == cond2)
#     
#     # Perform a two-sample t-test
#     t_test_result <- t.test(subset_data1, subset_data2)
#     
#     # Store the t-test result in the list
#     t_test_results[[paste(label1, "-", label2)]] <- t_test_result
#   }
# }

# Print t-test results
# for (label_pair in names(t_test_results)) {
#   cat("T-Test Results for", label_pair, ":\n")
#   print(t_test_results[[label_pair]])
#   cat("\n")
# }

# add cluster
corr_table <- corr_table %>%
              mutate(group = ifelse(subject %in% c(6, 7, 8, 9, 13), "expert", "control"))
corr_table <- corr_table %>%
              mutate(script = ifelse(condition %in% c("fw","sfw"), "french", "braille"))
corr_table$cluster <- paste(corr_table$script,corr_table$group,sep="_")

corr_table$condition <- ifelse(corr_table$group == "expert", 
                               paste(corr_table$condition,"_exp",sep=""), 
                               paste(corr_table$condition,"_ctr",sep=""))

# calculate stats for error bars
stats_corr <- corr_table %>% group_by(condition, cluster) %>% 
  summarize(mean_corr = mean(correlation), sd_corr = sd(correlation), se_corr = sd(correlation)/sqrt(6),
            .groups = 'keep')

stats_diff <- slopes_diff %>% group_by(group, script, specify, cluster) %>% 
  summarize(mean_diff = mean(difference), sd_diff = sd(difference), se_diff = sd(difference)/sqrt(6),
            .groups = 'keep')


### Export

# original slopes table
slopes <- slopes %>%
  mutate(intact = ifelse(substr(condition, 1, 1) %in% c("f", "b"), "intact", "scrambled"))
write.csv(slopes, "slopes.csv", row.names=FALSE)

# difference table
slopes_diff <- data.frame()
# make new table, with everything but the slopes and the intercept to only keep the difference
for (i in c(1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 
            21, 23, 25, 27, 29, 31, 33, 35, 37, 39, 
            41, 43, 45, 47, 49, 51, 53, 55, 57, 59, 61, 63)) {
  diff <- data.table(subject = slopes$subject[i], 
                     group = slopes$group[i], 
                     script = slopes$script[i], 
                     condition = slopes$condition[i], 
                     difference = slopes$slope[i] - slopes$slope[i+1], 
                     cluster = slopes$cluster[i], 
                     specify = slopes$specify[i])
  slopes_diff <- rbind(slopes_diff, diff)
  
}
write.csv(slopes_diff, "slopes_diff.csv", row.names=FALSE)




### PLOTS

# Bar plot of average slope inclination
ggplot(stats_slopes, aes(x = condition, y = mean_slope)) + 
  geom_col(aes(x = condition, y = mean_slope, fill = cluster)) +
  geom_errorbar(aes(ymin = mean_slope - se_slope, ymax = mean_slope + se_slope), width = 0) +
  scale_fill_manual(name = "script x group",
                    limits = c("french_expert",   "braille_expert",   "french_control",   "braille_control"),
                    values = c("#69B5A2",         "#FF9E4A",          "#699ae5",          "#da5F49"),
                    labels = c("french - expert", "braille - expert", "french - control", "braille - control")) +
  # Individual data clouds
  geom_point(data = slopes, 
             aes(x = reorder(condition, cluster),
                 y = slope),
             position = position_jitter(w = 0.3, h = 0.01),
             alpha = 0.3) +
  theme_classic() +                                                              # white background, simple theme
  theme(axis.ticks = element_blank()) +
  scale_x_discrete(limits = c("bw_ctr","bw_exp","fw_ctr","fw_exp","sbw_ctr","sbw_exp","sfw_ctr","sfw_exp"),
                   labels = c("BW","BW","FW","FW","SBW","SBW","SFW","SFW")) +
  labs(x = "Stimulus condition", y = "Slope inclination", title = "Average slope in PPI: VWFA x LPosTEmp")

ggsave("figures/cond-PPI_areas-VWFA-LPosTemp_mean-slope.png", width = 3000, height = 1800, dpi = 320, units = "px")


# Bar plot of differences in slopes
ggplot(data = subset(stats_diff, !is.na(mean_diff)), aes(x = specify, y = mean_diff)) + 
  geom_col(aes(x = specify, y = mean_diff, fill = cluster)) +
  geom_errorbar(aes(ymin = mean_diff - se_diff, ymax = mean_diff + se_diff), width = 0) +
  scale_fill_manual(name = "script x group",
                    limits = c("french_expert",   "braille_expert",   "french_control",   "braille_control"),
                    values = c("#69B5A2",         "#FF9E4A",          "#699ae5",          "#da5F49"),
                    labels = c("french - expert", "braille - expert", "french - control", "braille - control")) +
  
  # Individual data clouds
  geom_point(data = subset(slopes_diff, !is.na(difference)), 
             aes(x = reorder(specify, cluster),
                 y = difference),
             position = position_jitter(w = 0.3, h = 0.01),
             alpha = 0.3,
             legend = F) +
  theme_classic() +                                                              # white background, simple theme
  theme(axis.ticks = element_blank()) +
  scale_x_discrete(limits = rev,
                   labels = c("EXP-FR","CTR-FR","EXP-BR","CTR-BR")) +
  labs(y = "VWFA-LPosTemp slopes difference", title = "Average mean slope in PPI: VWFA x LPosTemp")

ggsave("figures/cond-PPI_areas-VWFA-LPosTemp_mean-difference.png", width = 3000, height = 1800, dpi = 320, units = "px")


# Scatter plot of group expert and script french
ggplot(data = subset(allPoints, cluster == "french_expert"), aes(x = x, y = y)) + 
  scale_color_manual(name = "script x group",
                     values = c("#69B5A2"),
                     labels = c("french - expert"),
                     aesthetics = c("colour", "fill")) +
  geom_point(aes(color = cluster), alpha = 0.1) + 
  # Individual slopes
  # Expert group - FW and SFW (dashed)
  geom_abline(data = subset(slopes, slopes$cluster == "french_expert" & slopes$condition == "fw_exp"),
              aes(intercept = intercept, slope = slope, color = cluster), 
              alpha = 0.4) +
  geom_abline(data = subset(slopes, slopes$cluster == "french_expert" & slopes$condition == "sfw_exp"),
              aes(intercept = intercept, slope = slope, color = cluster), 
              linetype = "dashed", alpha = 0.4) +
  # General slopes
  # Expert group - FW and SFW (dashed)
  geom_smooth(data = subset(allPoints, cluster == "french_expert" & condition == "fw"),
              method = "lm", se = T) + 
  geom_smooth(data = subset(allPoints, cluster == "french_expert" & condition == "sfw"),
              method = "lm", linetype = "dashed", se = T) + 
  theme_classic() +     
  xlim(-2.3, 2.3) + 
  ylim(-2.3, 2.3) +
  theme(axis.ticks = element_blank()) +
  labs(x = "VWFA Activation", y = "Left Posterior Tempoeral response", 
       title = "PPI - VWFA x LPosTemp interaction - Group: experts, Script: french")

ggsave("figures/cond-PPI_areas-VWFA-LPosTemp_scatter-french-exp.png", width = 3000, height = 1800, dpi = 320, units = "px")


# Scatter plot of group expert and script braille
ggplot(data = subset(allPoints, cluster == "braille_expert"), aes(x = x, y = y)) + 
  scale_color_manual(name = "script x group",
                     values = c("#FF9E4A"),
                     labels = c("braille - expert"),
                     aesthetics = c("colour", "fill")) +
  geom_point(aes(color = cluster), alpha = 0.1) + 
  # Individual slopes
  # Expert group - FW and SFW (dashed)
  geom_abline(data = subset(slopes, slopes$cluster == "braille_expert" & slopes$condition == "bw_exp"),
              aes(intercept = intercept, slope = slope, color = cluster), 
              alpha = 0.4) +
  geom_abline(data = subset(slopes, slopes$cluster == "braille_expert" & slopes$condition == "sbw_exp"),
              aes(intercept = intercept, slope = slope, color = cluster), 
              linetype = "dashed", alpha = 0.4) +
  # General slopes
  # Expert group - FW and SFW (dashed)
  geom_smooth(data = subset(allPoints, cluster == "braille_expert" & condition == "bw"),
              method = "lm", se = T) + 
  geom_smooth(data = subset(allPoints, cluster == "braille_expert" & condition == "sbw"),
              method = "lm", linetype = "dashed", se = T) + 
  theme_classic() +     
  xlim(-2.3, 2.3) + 
  ylim(-2.3, 2.3) +
  theme(axis.ticks = element_blank()) +
  labs(x = "VWFA Activation", y = "Left Posterior Tempoeral response", 
       title = "PPI - VWFA x LPosTemp interaction - Group: experts, Script: braille")

ggsave("figures/cond-PPI_areas-VWFA-LPosTemp_scatter-braille-exp.png", width = 3000, height = 1800, dpi = 320, units = "px")


# Scatter plot of group controls and script french
ggplot(data = subset(allPoints, cluster == "french_control"), aes(x = x, y = y)) + 
  scale_color_manual(name = "script x group",
                     values = c("#699ae5"),
                     labels = c("french - control"),
                     aesthetics = c("colour", "fill")) +
  geom_point(aes(color = cluster), alpha = 0.1) + 
  # Individual slopes
  # Expert group - FW and SFW (dashed)
  geom_abline(data = subset(slopes, slopes$cluster == "french_control" & slopes$condition == "fw_ctr"),
              aes(intercept = intercept, slope = slope, color = cluster), 
              alpha = 0.4) +
  geom_abline(data = subset(slopes, slopes$cluster == "french_control" & slopes$condition == "sfw_ctr"),
              aes(intercept = intercept, slope = slope, color = cluster), 
              linetype = "dashed", alpha = 0.4) +
  # General slopes
  # Expert group - FW and SFW (dashed)
  geom_smooth(data = subset(allPoints, cluster == "french_control" & condition == "fw"),
              method = "lm", se = T) + 
  geom_smooth(data = subset(allPoints, cluster == "french_control" & condition == "sfw"),
              method = "lm", linetype = "dashed", se = T) + 
  theme_classic() +     
  xlim(-2.3, 2.3) + 
  ylim(-2.3, 2.3) +
  theme(axis.ticks = element_blank()) +
  labs(x = "VWFA Activation", y = "Left Posterior Tempoeral response", 
       title = "PPI - VWFA x LPosTemp interaction - Group: controls, Script: french")

ggsave("figures/cond-PPI_areas-VWFA-LPosTemp_scatter-french-ctr.png", width = 3000, height = 1800, dpi = 320, units = "px")

# Scatter plot of group controls and script braille
ggplot(data = subset(allPoints, cluster == "braille_control"), aes(x = x, y = y)) + 
  scale_color_manual(name = "script x group",
                     values = c("#da5F49"),
                     labels = c("braille - control"),
                     aesthetics = c("colour", "fill")) +
  geom_point(aes(color = cluster), alpha = 0.1) + 
  # Individual slopes
  # Control group - BW and SBW (dashed)
  geom_abline(data = subset(slopes, slopes$cluster == "braille_control" & slopes$condition == "bw_ctr"),
              aes(intercept = intercept, slope = slope, color = cluster), 
              alpha = 0.4) +
  geom_abline(data = subset(slopes, slopes$cluster == "braille_control" & slopes$condition == "sbw_ctr"),
              aes(intercept = intercept, slope = slope, color = cluster), 
              linetype = "dashed", alpha = 0.4) +
  # General slopes
  # Control group - BW and SBW (dashed)
  geom_smooth(data = subset(allPoints, cluster == "braille_control" & condition == "bw"),
              method = "lm", se = T) + 
  geom_smooth(data = subset(allPoints, cluster == "braille_control" & condition == "sbw"),
              method = "lm", linetype = "dashed", se = T) + 
  theme_classic() +     
  xlim(-2.3, 2.3) + 
  ylim(-2.3, 2.3) +
  theme(axis.ticks = element_blank()) +
  labs(x = "VWFA Activation", y = "Left Posterior Tempoeral response", 
       title = "PPI - VWFA x LPosTemp interaction - Group: controls, Script: braille")

ggsave("figures/cond-PPI_areas-VWFA-LPosTemp_scatter-braille-ctr.png", width = 3000, height = 1800, dpi = 320, units = "px")


# Scatter plot all together - just slopes
ggplot(allPoints, aes(x = x, y = y)) + 
  scale_fill_manual(name = "script x group",
                    limits = c("french_expert",   "braille_expert",   "french_control",   "braille_control"),
                    values = c("#69B5A2",         "#FF9E4A",          "#699ae5",          "#da5F49"),
                    labels = c("french - expert", "braille - expert", "french - control", "braille - control"),
                    aesthetics = c("colour", "fill")) +
  # Individual slopes
  # Expert group - FW and SFW (dashed)
  geom_abline(data = subset(slopes, slopes$cluster == "french_expert" & slopes$condition == "fw_exp"),
              aes(intercept = intercept, slope = slope, color = cluster), 
              alpha = 0.2) +
  geom_abline(data = subset(slopes, slopes$cluster == "french_expert" & slopes$condition == "sfw_exp"),
              aes(intercept = intercept, slope = slope, color = cluster), 
              linetype = "dashed", alpha = 0.2) +
  # Expert group - BW and SBW (dashed)
  geom_abline(data = subset(slopes, slopes$cluster == "braille_expert" & slopes$condition == "bw_exp"),
              aes(intercept = intercept, slope = slope, color = cluster), 
              alpha = 0.2) +
  geom_abline(data = subset(slopes, slopes$cluster == "braille_expert" & slopes$condition == "sbw_exp"),
              aes(intercept = intercept, slope = slope, color = cluster), 
              linetype = "dashed", alpha = 0.2) +
  # Control group - FW and SFW (dashed)
  geom_abline(data = subset(slopes, slopes$cluster == "french_control" & slopes$condition == "fw_ctr"),
              aes(intercept = intercept, slope = slope, color = cluster), 
              alpha = 0.2) +
  geom_abline(data = subset(slopes, slopes$cluster == "french_control" & slopes$condition == "sfw_ctr"),
              aes(intercept = intercept, slope = slope, color = cluster), 
              linetype = "dashed", alpha = 0.2) +
  # Control group - FW and SFW (dashed)
  geom_abline(data = subset(slopes, slopes$cluster == "braille_control" & slopes$condition == "bw_ctr"),
              aes(intercept = intercept, slope = slope, color = cluster), 
              alpha = 0.2) +
  geom_abline(data = subset(slopes, slopes$cluster == "braille_control" & slopes$condition == "sbw_ctr"),
              aes(intercept = intercept, slope = slope, color = cluster), 
              linetype = "dashed", alpha = 0.2) +
  # General slopes
  # Expert group - FW and SFW (dashed)
  geom_smooth(data = subset(allPoints, cluster == "french_expert" & condition == "fw"),
              aes(color = cluster), method = "lm", se = FALSE) + 
  geom_smooth(data = subset(allPoints, cluster == "french_expert" & condition == "sfw"),
              aes(color = cluster), method = "lm", linetype = "dashed", se = FALSE) + 
  # Expert group - BW and SBW (dashed)
  geom_smooth(data = subset(allPoints, cluster == "braille_expert" & condition == "bw"),
              aes(color = cluster), method = "lm", se = FALSE) + 
  geom_smooth(data = subset(allPoints, cluster == "braille_expert" & condition == "sbw"),
              aes(color = cluster), method = "lm", linetype = "dashed", se = FALSE) + 
  # Control group - FW and SFW (dashed)
  geom_smooth(data = subset(allPoints, cluster == "french_control" & condition == "fw"),
              aes(color = cluster), method = "lm", se = FALSE) + 
  geom_smooth(data = subset(allPoints, cluster == "french_control" & condition == "sfw"),
              aes(color = cluster), method = "lm", linetype = "dashed", se = FALSE) + 
  # Control group - BW and SBW (dashed)
  geom_smooth(data = subset(allPoints, cluster == "braille_control" & condition == "bw"),
              aes(color = cluster), method = "lm", se = FALSE) + 
  geom_smooth(data = subset(allPoints, cluster == "braille_control" & condition == "sbw"),
              aes(color = cluster), method = "lm", linetype = "dashed", se = FALSE) + 
  theme_classic() +     
  xlim(-2.3, 2.3) + 
  ylim(-2.3, 2.3) +
  theme(axis.ticks = element_blank()) +
  labs(x = "VWFA Activation", y = "Left Posterior Tempoeral response", title = "PPI - VWFA x LPosTemp interaction")

ggsave("figures/cond-PPI_areas-VWFA-LPosTemp_just-slopes.png", width = 3000, height = 1800, dpi = 320, units = "px")










