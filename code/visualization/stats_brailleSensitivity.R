
setwd("~/Desktop/GitHub/VisualBraille_data/code/visualization")

library("readxl")
library("tidyverse")
library("reshape2")
library("gridExtra")
library("pracma")
library("dplyr")

### Load report
braille <- read.csv("/Users/cerpelloni/Desktop/GitHub/VisualBraille_data/code/stats/braille_sensitivity_tmaps_eyeMovements.txt")

### Manipulate the matrix

# cast as dataframe
braille <- as.data.frame(braille)

# modify subject column to only keep number
braille$subject <- as.numeric(gsub('sub-0*', '', braille$subject))

# rename activation field to avoid confusion 
braille$activation <- braille$mean_activation
braille <- subset(braille, select = -c(5))

# Add number of decoding pair, to place the horizontal lines 
braille$contrast <- t(repmat(c(1,2), 1,nrow(braille)/2))

# cluster group and condition together, for viz
braille$cluster <- ifelse(braille$contrast == 1, 
                          ifelse(braille$group == "expert", "EI", "CI"),
                          ifelse(braille$group == "expert", "ES", "CS"))

# calculate stats for error bars
stats_braille <- braille %>% group_by(group, area, cluster, condition, contrast) %>% 
  summarize(mean_activation = mean(activation), sd_activation = sd(activation), se_activation = sd(activation)/sqrt(6),
            .groups = 'keep') 

stats_braille[order(stats_braille$group, decreasing = TRUE), ]

### PLOTS
## WITH SUBJECT LABELS
ggplot(stats_braille, aes(x = cluster, y = mean_activation)) + 
  geom_col(aes(x = cluster, y = mean_activation, fill = group)) +
  geom_errorbar(aes(ymin = mean_activation - se_activation, ymax = mean_activation + se_activation), width = 0) +
  scale_fill_manual(values = c("#da5F49", "#FF9E4A"),
                    labels = c("control", "expert"),
                    aesthetics = c("colour", "fill")) +
  # Individual data clouds
  geom_text(data = braille,
            aes(x = cluster,
                y = activation, label = subject),
            alpha = 0.8, size = 3, vjust = -0.5, hjust = 1.5, check_overlap = T) +
  geom_point(data = braille, aes(x = cluster,  y = activation),
             alpha = 0.4) +
  theme_classic() +                                                              
  theme(axis.ticks = element_blank()) +
  facet_grid(~factor(area, levels = c("VWFA", "lLO", "rLO", "V1", "lPosTemp")), 
             labeller = label_value) +
  scale_x_discrete(labels = stats_braille$condition) +
  labs(x = "Stimulus condition", y = "Mean univariate activation", title = "Univariate acitvation for BW and SBW")

ggsave("figures/braille-selectivity_eyeMovements_with-labels.png", width = 3000, height = 1800, dpi = 320, units = "px")

## WITH JUST INDIVIDUAL DOTS
ggplot(stats_braille, aes(x = cluster, y = mean_activation)) + 
  geom_col(aes(x = cluster, y = mean_activation, fill = group)) +
  geom_errorbar(aes(ymin = mean_activation - se_activation, ymax = mean_activation + se_activation), width = 0) +
  scale_fill_manual(values = c("#da5F49", "#FF9E4A"),
                    labels = c("control", "expert"),
                    aesthetics = c("colour", "fill")) +
  # Individual data clouds 
  geom_point(data = braille,
             aes(x = cluster, 
                 y = activation, 
                 colour = group),
             position = position_jitter(w = 0.3, h = 0.01),
             alpha = 0.4) +
  theme_classic() +                                                              
  theme(axis.ticks = element_blank()) +
  facet_grid(~factor(area, levels = c("VWFA", "lLO", "rLO", "V1", "lPosTemp")), 
             labeller = label_value) +
  scale_x_discrete(labels = stats_braille$condition) +
  labs(x = "Stimulus condition", y = "Mean univariate activation", title = "Univariate acitvation in for BW and SBW")      

ggsave("figures/braille-selectivity_eyeMovements_just-dots.png", width = 3000, height = 1800, dpi = 320, units = "px")


### compute t-tests

# Create subsets based on group and area
tests_braille <- split(braille, list(braille$group, braille$area, braille$condition))

# Initialize an empty dataframe to store t-test results
t_test_results <- data.frame(
  group1 = character(), group2 = character(), stat = numeric(), p_value = numeric())

for (iGroup in c(1:10)) {
  
  group1 <- tests_braille[[iGroup]]$activation
  group2 <- tests_braille[[iGroup+10]]$activation
  
  t_result <- t.test(group1, group2, paired = TRUE)
  
  t_test_results <- rbind(t_test_results, data.frame(
    group1 = paste(unique(tests_braille[[iGroup]]$group), 
                   unique(tests_braille[[iGroup]]$area), 
                   unique(tests_braille[[iGroup]]$condition), sep="_"),
    group2 = paste(unique(tests_braille[[iGroup+10]]$group), 
                   unique(tests_braille[[iGroup+10]]$area), 
                   unique(tests_braille[[iGroup+10]]$condition), sep="_"),
    stat = t_result$statistic,
    p_value = t_result$p.value
  ))
}

# Manually check the t-test table



