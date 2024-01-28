
setwd("~/Desktop/GitHub/VisualBraille_data/code/visualization")

library("readxl")
library("tidyverse")
library("reshape2")
library("gridExtra")
library("pracma")
library("dplyr")

### Load matrices

# VWFA - one single ROI
vwfa <- read.csv("/Users/cerpelloni/Desktop/GitHub/VisualBraille_data/code/stats/univariateReport_vwfa.txt")
# SPLIT - anterior and posterior VWFA
split <- read.csv("/Users/cerpelloni/Desktop/GitHub/VisualBraille_data/code/stats/univariateReport_split.txt")
# POSTEMP - from Fedorenko et al.
postemp <- read.csv("/Users/cerpelloni/Desktop/GitHub/VisualBraille_data/code/stats/univariateReport_postemp.txt")
# LOC - left and right LO from our localizer
loc <- read.csv("/Users/cerpelloni/Desktop/GitHub/VisualBraille_data/code/stats/univariateReport_loc.txt")
# V1 - bilateral from visfatlas
v1 <- read.csv("/Users/cerpelloni/Desktop/GitHub/VisualBraille_data/code/stats/univariateReport_v1_jubrain.txt")




### Manipulate the matrix

# as dataframe
vwfa <- as.data.frame(vwfa)
split <- as.data.frame(split)
postemp <- as.data.frame(postemp)
loc <- as.data.frame(loc)
v1 <- as.data.frame(v1)

# rename mean column to avoid confusion 
vwfa$average_activation <- vwfa$mean
split$average_activation <- split$mean
postemp$average_activation <- postemp$mean
loc$average_activation <- loc$mean
v1$average_activation <- v1$mean

# remove unnecessary columns
vwfa <- subset(vwfa, select = -c(5,7))
split <- subset(split, select = -c(7))
postemp <- subset(postemp, select = -c(5,7))
loc <- subset(loc, select = -c(7))
v1 <- subset(v1, select = -c(5,7))

# modify subject column to only keep number
vwfa$subject <- as.numeric(gsub('sub-0*', '', vwfa$subject))
split$subject <- as.numeric(gsub('sub-0*', '', split$subject))
postemp$subject <- as.numeric(gsub('sub-0*', '', postemp$subject))
loc$subject <- as.numeric(gsub('sub-0*', '', loc$subject))
v1$subject <- as.numeric(gsub('sub-0*', '', v1$subject))

# Add number of decoding pair, to place the horizontal lines 
vwfa$contrast <- t(repmat(c(1,2,3,4,5,6,7,8), 1,nrow(vwfa)/8))
vwfa$script <- t(repmat(c(1,1,1,1,2,2,2,2), 1,nrow(vwfa)/8))
split$contrast <- t(repmat(c(1,2,3,4,5,6,7,8), 1,nrow(split)/8))
split$script <- t(repmat(c(1,1,1,1,2,2,2,2), 1,nrow(split)/8))
postemp$contrast <- t(repmat(c(1,2,3,4,5,6,7,8), 1,nrow(postemp)/8))
postemp$script <- t(repmat(c(1,1,1,1,2,2,2,2), 1,nrow(postemp)/8))
loc$contrast <- t(repmat(c(1,2,3,4,5,6,7,8), 1,nrow(loc)/8))
loc$script <- t(repmat(c(1,1,1,1,2,2,2,2), 1,nrow(loc)/8))
v1$contrast <- t(repmat(c(1,2,3,4,5,6,7,8), 1,nrow(v1)/8))
v1$script <- t(repmat(c(1,1,1,1,2,2,2,2), 1,nrow(v1)/8))

# Add cluster information, for coloring purposes
vwfa$cluster <- ifelse(vwfa$script == 1, ifelse(vwfa$group == "expert", "french_expert", "french_control"),
                                         ifelse(vwfa$group == "expert", "braille_expert", "braille_control"))
split$cluster <- ifelse(split$script == 1, ifelse(split$group == "expert", "french_expert", "french_control"),
                                           ifelse(split$group == "expert", "braille_expert", "braille_control"))
postemp$cluster <- ifelse(postemp$script == 1, ifelse(postemp$group == "expert", "french_expert", "french_control"),
                                               ifelse(postemp$group == "expert", "braille_expert", "braille_control"))
loc$cluster <- ifelse(loc$script == 1, ifelse(loc$group == "expert", "french_expert", "french_control"),
                                       ifelse(loc$group == "expert", "braille_expert", "braille_control"))
v1$cluster <- ifelse(v1$script == 1, ifelse(v1$group == "expert", "french_expert", "french_control"),
                      ifelse(v1$group == "expert", "braille_expert", "braille_control"))

# rename conditions to specify group (exp, ctr) 
vwfa$condition <- ifelse(vwfa$group == "expert", paste(vwfa$condition,"_exp",sep=""), paste(vwfa$condition,"_ctr",sep=""))
split$condition <- ifelse(split$group == "expert", paste(split$condition,"_exp",sep=""), paste(split$condition,"_ctr",sep=""))
postemp$condition <- ifelse(postemp$group == "expert", paste(postemp$condition,"_exp",sep=""), paste(postemp$condition,"_ctr",sep=""))
loc$condition <- ifelse(loc$group == "expert", paste(loc$condition,"_exp",sep=""), paste(loc$condition,"_ctr",sep=""))
v1$condition <- ifelse(v1$group == "expert", paste(v1$condition,"_exp",sep=""), paste(v1$condition,"_ctr",sep=""))


# calculate stats for error bars
stats_vwfa <- vwfa %>% group_by(condition, script, contrast, cluster, group) %>% 
  summarize(mean_activation = mean(average_activation), sd_activation = sd(average_activation), se_activation = sd(average_activation)/sqrt(6),
            .groups = 'keep') 
stats_split <- split %>% group_by(mask, condition, script, contrast, cluster, group) %>% 
  summarize(mean_activation = mean(average_activation), sd_activation = sd(average_activation), se_activation = sd(average_activation)/sqrt(6),
            .groups = 'keep')  
stats_postemp <- postemp %>% group_by(condition, script, contrast, cluster, group) %>% 
  summarize(mean_activation = mean(average_activation), sd_activation = sd(average_activation), se_activation = sd(average_activation)/sqrt(6),
            .groups = 'keep') 
stats_loc <- loc %>% group_by(mask, condition, script, contrast, cluster, group) %>% 
  summarize(mean_activation = mean(average_activation), sd_activation = sd(average_activation), se_activation = sd(average_activation)/sqrt(6),
            .groups = 'keep')
stats_v1 <- v1 %>% group_by(condition, script, contrast, cluster, group) %>% 
  summarize(mean_activation = mean(average_activation), sd_activation = sd(average_activation), se_activation = sd(average_activation)/sqrt(6),
            .groups = 'keep')




### PLOTS

## WITH SUBJECT LABEL

# VWFA - average activation across the whole area
ggplot(stats_vwfa, aes(x = condition, y = mean_activation)) + 
  geom_col(aes(x = condition, y = mean_activation, fill = cluster)) +
  geom_errorbar(aes(ymin = mean_activation - se_activation, ymax = mean_activation + se_activation), width = 0) +
  scale_fill_manual(name = "script x group",
                     values = c("#da5F49",           "#FF9E4A",          "#699ae5",          "#69B5A2"),
                     labels = c("braille - control", "braille - expert", "french - control", "french - expert")) +
  # Individual data clouds 
  geom_text(data = vwfa,
             aes(x = reorder(condition, cluster),
                 y = average_activation, label = subject),
             alpha = 0.8, size = 3, vjust = -0.5, hjust = 1.5, check_overlap = T) +
  geom_point(data = vwfa, aes(x = reorder(condition, cluster),  y = average_activation),
            alpha = 0.4) +
  theme_classic() +                                                              
  theme(axis.ticks = element_blank()) +
  scale_x_discrete(limits=rev,                                                   
                   labels = c("\t\t\tFRW"," ", "\t\t\tFPW"," ", "\t\t\tFNW"," ", "\t\t\tFFS"," ",
                              "\t\t\tBRW"," ", "\t\t\tBPW"," ", "\t\t\tBNW"," ", "\t\t\tBFS"," ")) +
  labs(x = "Stimulus condition", y = "Mean univariate activation", title = "Univariate acitvation in VWFA")      

ggsave("figures/cond-VWFA_univariate_average-activation_with-labels.png", width = 3000, height = 1800, dpi = 320, units = "px")


# SPLIT 
ggplot(stats_split, aes(x = condition, y = mean_activation)) + 
  geom_col(aes(x = condition, y = mean_activation, fill = cluster)) +
  geom_errorbar(aes(ymin = mean_activation - se_activation, ymax = mean_activation + se_activation), width = 0) +
  scale_fill_manual(name = "script x group",
                    values = c("#da5F49",           "#FF9E4A",          "#699ae5",          "#69B5A2"),
                    labels = c("braille - control", "braille - expert", "french - control", "french - expert")) +
  # Individual data clouds 
  geom_text(data = split,
            aes(x = reorder(condition, cluster),
                y = average_activation, label = subject),
            alpha = 0.8, size = 3, vjust = -0.5, hjust = 1.5, check_overlap = T) +
  geom_point(data = split, aes(x = reorder(condition, cluster),  y = average_activation),
             alpha = 0.4) +
  theme_classic() +                                                              
  theme(axis.ticks = element_blank()) +
  facet_grid(~factor(mask, levels = c("antVWFA", "posVWFA")), 
             labeller = label_value) +  
  scale_x_discrete(limits=rev,                                                   
                   labels = c("\t\t\tFRW"," ", "\t\t\tFPW"," ", "\t\t\tFNW"," ", "\t\t\tFFS"," ",
                              "\t\t\tBRW"," ", "\t\t\tBPW"," ", "\t\t\tBNW"," ", "\t\t\tBFS"," ")) +
  labs(x = "Stimulus condition", y = "Mean univariate activation", title = "Univariate acitvation in ant- and pos-VWFA")      

ggsave("figures/cond-splitVWFA_univariate_average-activation_with-labels.png", width = 3000, height = 1800, dpi = 320, units = "px")


# POSTEMP - average activation across the whole area
ggplot(stats_postemp, aes(x = condition, y = mean_activation)) + 
  geom_col(aes(x = condition, y = mean_activation, fill = cluster)) +
  geom_errorbar(aes(ymin = mean_activation - se_activation, ymax = mean_activation + se_activation), width = 0) +
  scale_fill_manual(name = "script x group",
                    values = c("#da5F49",           "#FF9E4A",          "#699ae5",          "#69B5A2"),
                    labels = c("braille - control", "braille - expert", "french - control", "french - expert")) +
  # Individual data clouds 
  geom_text(data = postemp,
            aes(x = reorder(condition, cluster),
                y = average_activation, label = subject),
            alpha = 0.8, size = 3, vjust = -0.5, hjust = 1.5, check_overlap = T) +
  geom_point(data = postemp, aes(x = reorder(condition, cluster),  y = average_activation),
             alpha = 0.4) +
  theme_classic() +                                                              
  theme(axis.ticks = element_blank()) +
  scale_x_discrete(limits=rev,                                                   
                   labels = c("\t\t\tFRW"," ", "\t\t\tFPW"," ", "\t\t\tFNW"," ", "\t\t\tFFS"," ",
                              "\t\t\tBRW"," ", "\t\t\tBPW"," ", "\t\t\tBNW"," ", "\t\t\tBFS"," ")) +
  labs(x = "Stimulus condition", y = "Mean univariate activation", title = "Univariate acitvation in PosTemp")      

ggsave("figures/cond-PosTemp_univariate_average-activation_with-labels.png", width = 3000, height = 1800, dpi = 320, units = "px")


# LOC 
ggplot(stats_loc, aes(x = condition, y = mean_activation)) + 
  geom_col(aes(x = condition, y = mean_activation, fill = cluster)) +
  geom_errorbar(aes(ymin = mean_activation - se_activation, ymax = mean_activation + se_activation), width = 0) +
  scale_fill_manual(name = "script x group",
                    values = c("#da5F49",           "#FF9E4A",          "#699ae5",          "#69B5A2"),
                    labels = c("braille - control", "braille - expert", "french - control", "french - expert")) +
  # Individual data clouds 
  geom_text(data = loc,
            aes(x = reorder(condition, cluster),
                y = average_activation, label = subject),
            alpha = 0.8, size = 3, vjust = -0.5, hjust = 1.5, check_overlap = T) +
  geom_point(data = loc, aes(x = reorder(condition, cluster),  y = average_activation),
             alpha = 0.4) +
  theme_classic() +                                                              
  theme(axis.ticks = element_blank()) +
  facet_grid(~factor(mask, levels = c("lLO", "rLO")), 
             labeller = label_value) +  
  scale_x_discrete(limits=rev,                                                   
                   labels = c("\t\t\tFRW"," ", "\t\t\tFPW"," ", "\t\t\tFNW"," ", "\t\t\tFFS"," ",
                              "\t\t\tBRW"," ", "\t\t\tBPW"," ", "\t\t\tBNW"," ", "\t\t\tBFS"," ")) +
  labs(x = "Stimulus condition", y = "Mean univariate activation", title = "Univariate acitvation in left and right LO")      

ggsave("figures/cond-LOC_univariate_average-activation_with-labels.png", width = 3000, height = 1800, dpi = 320, units = "px")


# V1 - average activation across the whole area
ggplot(stats_v1, aes(x = condition, y = mean_activation)) + 
  geom_col(aes(x = condition, y = mean_activation, fill = cluster)) +
  geom_errorbar(aes(ymin = mean_activation - se_activation, ymax = mean_activation + se_activation), width = 0) +
  scale_fill_manual(name = "script x group",
                    values = c("#da5F49",           "#FF9E4A",          "#699ae5",          "#69B5A2"),
                    labels = c("braille - control", "braille - expert", "french - control", "french - expert")) +
  # Individual data clouds 
  geom_text(data = v1,
            aes(x = reorder(condition, cluster),
                y = average_activation, label = subject),
            alpha = 0.8, size = 3, vjust = -0.5, hjust = 1.5, check_overlap = T) +
  geom_point(data = v1, aes(x = reorder(condition, cluster),  y = average_activation),
             alpha = 0.4) +
  theme_classic() +                                                              
  theme(axis.ticks = element_blank()) +
  scale_x_discrete(limits=rev,                                                   
                   labels = c("\t\t\tFRW"," ", "\t\t\tFPW"," ", "\t\t\tFNW"," ", "\t\t\tFFS"," ",
                              "\t\t\tBRW"," ", "\t\t\tBPW"," ", "\t\t\tBNW"," ", "\t\t\tBFS"," ")) +
  labs(x = "Stimulus condition", y = "Mean univariate activation", title = "Univariate acitvation in V1")      

ggsave("figures/cond-V1-jubrain_univariate_average-activation_with-labels.png", width = 3000, height = 1800, dpi = 320, units = "px")



## WITH JUST INDIVIDUAL DOTS

# VWFA
ggplot(stats_vwfa, aes(x = condition, y = mean_activation)) + 
  geom_col(aes(x = condition, y = mean_activation, fill = cluster)) +
  geom_errorbar(aes(ymin = mean_activation - se_activation, ymax = mean_activation + se_activation), width = 0) +
  scale_fill_manual(name = "script x group",
                    values = c("#da5F49",           "#FF9E4A",          "#699ae5",          "#69B5A2"),
                    labels = c("braille - control", "braille - expert", "french - control", "french - expert"),
                    aesthetics = c("colour", "fill")) +
  # Individual data clouds 
  geom_point(data = vwfa,
             aes(x = reorder(condition, cluster), 
                 y = average_activation, 
                 colour = cluster),
             position = position_jitter(w = 0.3, h = 0.01),
             alpha = 0.4) +
  theme_classic() +                                                              
  theme(axis.ticks = element_blank()) +
  scale_x_discrete(limits=rev,                                                   
                   labels = c("\t\t\tFRW"," ", "\t\t\tFPW"," ", "\t\t\tFNW"," ", "\t\t\tFFS"," ",
                              "\t\t\tBRW"," ", "\t\t\tBPW"," ", "\t\t\tBNW"," ", "\t\t\tBFS"," ")) +
  labs(x = "Stimulus condition", y = "Mean univariate activation", title = "Univariate acitvation in VWFA")      

ggsave("figures/cond-VWFA_univariate_average-activation.png", width = 3000, height = 1800, dpi = 320, units = "px")

# LOC
ggplot(stats_loc, aes(x = condition, y = mean_activation)) + 
  geom_col(aes(x = condition, y = mean_activation, fill = cluster)) +
  geom_errorbar(aes(ymin = mean_activation - se_activation, ymax = mean_activation + se_activation), width = 0) +
  scale_fill_manual(name = "script x group",
                    values = c("#da5F49",           "#FF9E4A",          "#699ae5",          "#69B5A2"),
                    labels = c("braille - control", "braille - expert", "french - control", "french - expert"),
                    aesthetics = c("colour", "fill")) +
  # Individual data clouds 
  geom_point(data = loc,
            aes(x = reorder(condition, cluster), 
                y = average_activation, 
                colour = cluster),
            position = position_jitter(w = 0.3, h = 0.01),
            alpha = 0.4) +
  theme_classic() +                                                              
  theme(axis.ticks = element_blank()) +
  facet_grid(~factor(mask, levels = c("lLO", "rLO")), 
             labeller = label_value) +  
  scale_x_discrete(limits=rev,                                                   
                   labels = c("\t\t\tFRW"," ", "\t\t\tFPW"," ", "\t\t\tFNW"," ", "\t\t\tFFS"," ",
                              "\t\t\tBRW"," ", "\t\t\tBPW"," ", "\t\t\tBNW"," ", "\t\t\tBFS"," ")) +
  labs(x = "Stimulus condition", y = "Mean univariate activation", title = "Univariate acitvation in left and right LO")      

ggsave("figures/cond-LOC_univariate_average-activation.png", width = 3000, height = 1800, dpi = 320, units = "px")

# POSTEMP - average activation across the whole area
ggplot(stats_postemp, aes(x = condition, y = mean_activation)) + 
  geom_col(aes(x = condition, y = mean_activation, fill = cluster)) +
  geom_errorbar(aes(ymin = mean_activation - se_activation, ymax = mean_activation + se_activation), width = 0) +
  scale_fill_manual(name = "script x group",
                    values = c("#da5F49",           "#FF9E4A",          "#699ae5",          "#69B5A2"),
                    labels = c("braille - control", "braille - expert", "french - control", "french - expert"),
                    aesthetics = c("colour", "fill")) +
  # Individual data clouds 
  geom_point(data = postemp,
             aes(x = reorder(condition, cluster), 
                 y = average_activation, 
                 colour = cluster),
             position = position_jitter(w = 0.3, h = 0.01),
             alpha = 0.4) +
  theme_classic() +                                                              
  theme(axis.ticks = element_blank()) +
  scale_x_discrete(limits=rev,                                                   
                   labels = c("\t\t\tFRW"," ", "\t\t\tFPW"," ", "\t\t\tFNW"," ", "\t\t\tFFS"," ",
                              "\t\t\tBRW"," ", "\t\t\tBPW"," ", "\t\t\tBNW"," ", "\t\t\tBFS"," ")) +
  labs(x = "Stimulus condition", y = "Mean univariate activation", title = "Univariate acitvation in left and right LO")      

ggsave("figures/cond-PosTemp_univariate_average-activation.png", width = 3000, height = 1800, dpi = 320, units = "px")

# SPLIT 
ggplot(stats_split, aes(x = condition, y = mean_activation)) + 
  geom_col(aes(x = condition, y = mean_activation, fill = cluster)) +
  geom_errorbar(aes(ymin = mean_activation - se_activation, ymax = mean_activation + se_activation), width = 0) +
  scale_fill_manual(name = "script x group",
                    values = c("#da5F49",           "#FF9E4A",          "#699ae5",          "#69B5A2"),
                    labels = c("braille - control", "braille - expert", "french - control", "french - expert"),
                    aesthetics = c("colour", "fill")) +
  # Individual data clouds 
  geom_point(data = split,
             aes(x = reorder(condition, cluster), 
                 y = average_activation, 
                 colour = cluster),
             position = position_jitter(w = 0.3, h = 0.01),
             alpha = 0.4) +
  theme_classic() +                                                              
  theme(axis.ticks = element_blank()) +
  facet_grid(~factor(mask, levels = c("antVWFA", "posVWFA")), 
             labeller = label_value) +  
  scale_x_discrete(limits=rev,                                                   
                   labels = c("\t\t\tFRW"," ", "\t\t\tFPW"," ", "\t\t\tFNW"," ", "\t\t\tFFS"," ",
                              "\t\t\tBRW"," ", "\t\t\tBPW"," ", "\t\t\tBNW"," ", "\t\t\tBFS"," ")) +
  labs(x = "Stimulus condition", y = "Mean univariate activation", title = "Univariate acitvation in ant- and pos-VWFA")      

ggsave("figures/cond-splitVWFA_univariate_average-activation.png", width = 3000, height = 1800, dpi = 320, units = "px")
