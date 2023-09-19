
setwd("~/Desktop/GitHub/VisualBraille_data/code/visualization")

library("readxl")
library("tidyverse")
library("reshape2")
library("gridExtra")
library("pracma")
library("dplyr")

### Load matrices of decoding accuracies for both groups 

# Load report
data <- read.csv("/Users/cerpelloni/Desktop/GitHub/VisualBraille_data/code/stats/vwfa_unvariateReport.txt")



### Manipulate the matrix to get something readable by ggplot
data <- as.data.frame(data)

# remove unnecessary columns
data <- subset(data, select = -c(5))
data$average_activation <- data$mean
data <- subset(data, select = -c(6))

# Add number of decoding pair, to place the horizontal lines 
data$contrast <- t(repmat(c(1,2,3,4,5,6,7,8), 1,nrow(data)/8))
data$script <- t(repmat(c(1,1,1,1,2,2,2,2), 1,nrow(data)/8))

data$cluster <- ifelse(data$script == 1, 
                       ifelse(data$group == "expert",
                              "french_expert",
                              "french_control"),
                       ifelse(data$group == "expert",
                              "braille_expert",
                              "braille_control"))

data$condition <- ifelse(data$group == "expert", 
                         paste(data$condition,"_exp",sep=""), 
                         paste(data$condition,"_ctr",sep=""))

# calculate stats for error bars
stats_data <- data %>% group_by(condition, script, contrast, cluster, group) %>% 
  summarize(mean_activation = mean(average_activation), sd_activation = sd(average_activation), se_activation = sd(average_activation)/sqrt(6),
            mean_peak = mean(peak), sd_peak = sd(peak), se_peak = sd(peak)/sqrt(6),
            .groups = 'keep') 



### PLOTS

# VWFA - average activation across the whole area
ggplot(stats_data, aes(x = condition, y = mean_activation)) + 
  
  geom_col(aes(x = condition, y = mean_activation, fill = cluster)) +
  geom_errorbar(aes(ymin = mean_activation - se_activation, ymax = mean_activation + se_activation), width = 0) +
  scale_fill_manual(name = "script x group",
                    values = c("#da5F49",           "#FF9E4A",          "#699ae5",          "#69B5A2"),
                    labels = c("braille - control", "braille - expert", "french - control", "french - expert")) +
  
  # Individual data clouds 
  geom_point(data = data, 
             aes(x = reorder(condition, cluster),
                 y = average_activation),
             position = position_jitter(w = 0.3, h = 0.01),
             alpha = 0.3,
             legend = F) +
  theme_classic() +                                                              # white background, simple theme
  theme(axis.ticks = element_blank()) +
  scale_x_discrete(limits=rev,                                                   # customize x axis labels
                   labels = c("                 FRW"," ", "                 FPW"," ", 
                              "                 FNW"," ", "                 FFS"," ",
                              "                 BRW"," ", "                 BPW"," ", 
                              "                 BNW"," ", "                 BFS"," ")) +
  labs(x = "Stimulus condition", y = "Mean univariate activation", title = "Univariate acitvation in VWFA")      

ggsave("figures/area-VWFA_univariate_average-activation.png", width = 3000, height = 1800, dpi = 320, units = "px")


# VWFA - peak activation in the area
ggplot(stats_data, aes(x = condition, y = mean_peak)) + 
  
  geom_col(aes(x = condition, y = mean_peak, fill = cluster)) +
  geom_errorbar(aes(ymin = mean_peak - se_peak, ymax = mean_peak + se_peak), width = 0) +
  scale_fill_manual(name = "script x group",
                    values = c("#da5F49",           "#FF9E4A",          "#699ae5",          "#69B5A2"),
                    labels = c("braille - control", "braille - expert", "french - control", "french - expert")) +
  
  # Individual data clouds 
  geom_point(data = data, 
             aes(x = reorder(condition, cluster),
                 y = peak),
             position = position_jitter(w = 0.3, h = 0.01),
             alpha = 0.3,
             legend = F) +
  theme_classic() +     
  theme(axis.ticks = element_blank()) +
  scale_x_discrete(limits=rev,                                                   # customize x axis labels
                   labels = c("             FRW"," ", "             FPW"," ", 
                              "             FNW"," ", "             FFS"," ",
                              "             BRW"," ", "             BPW"," ", 
                              "             BNW"," ", "             BFS"," ")) +
  labs(x = "Stimulus condition", y = "Peak of activation", title = "Univariate acitvation in VWFA")      

ggsave("figures/area-VWFA_univariate_peak-activation.png", width = 3000, height = 1800, dpi = 320, units = "px")
