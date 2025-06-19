
library("readxl")
library("tidyverse")
library("reshape2")
library("gridExtra")
library("pracma")
library("dplyr")

### Load matrices of decoding accuracies for both groups 

# Load report
beh <- read.csv("../stats/reports/behaviouralReport.txt")

### Manipulate the matrix to get something readable by ggplot
beh <- as.data.frame(beh)

# Correct names of stimuli for real words
beh <- beh %>% mutate(trial_type = ifelse(trial_type %in% c("frw_liv", "frw_nli", "frw_mix"), "frw", trial_type))
beh <- beh %>% mutate(trial_type = ifelse(trial_type %in% c("brw_liv", "brw_nli", "brw_mix"), "brw", trial_type))

# add cluster information
beh <- beh %>% mutate(cluster = ifelse(subject %in% c("sub-006", "sub-009", "sub-012"), 
                                       ifelse(trial_type %in% c("frw","fpw","fnw","ffs"), 
                                             "french_expert", "braille_expert"),
                                       ifelse(trial_type %in% c("frw","fpw","fnw","ffs"), 
                                              "french_control", "braille_control")))

# delete experts, keep only controls 
beh <- beh %>% filter(!cluster %in% c("french_expert","braille_expert"))


# specify group in trial_type
beh$trial_type <- ifelse(beh$subject %in% c("sub-006","sub-009","sub-012"),
                         paste(beh$trial_type,"_exp",sep=""), 
                         paste(beh$trial_type,"_ctr",sep=""))

# response as facotr, to be counted
beh$response_type <- as.factor(beh$response_type)

# subejcts as number, to ease printing in braplot
beh$subject <- as.numeric(gsub('sub-0*', '', beh$subject))

# summarize behavioural responses: for each sub / stim, how many correct, miss, fp?
counts_beh <- beh %>% group_by(subject, trial_type, cluster, .drop = FALSE) %>% count(response_type)

stats_beh <- counts_beh %>% group_by(trial_type, response_type, cluster) %>% 
  summarize(mean_resp = mean(n),
            .groups = 'keep')  

# Calculate responses as percentage of correct answers (ignore False Positives)
result <- counts_beh %>% filter(response_type %in% c("correct", "miss")) %>%
                         group_by(subject, trial_type, cluster) %>% 
                         summarise(correct_count = sum(n[response_type == "correct"]),
                                   miss_count = sum(n[response_type == "miss"]),
                                   percentage = (correct_count / (correct_count + miss_count)) * 100
                                  ) %>%
                                  select(subject, trial_type, cluster, percentage)

# Filter out sub-009, partial data
percentages_beh <- result %>% filter(subject != "9")

stats_percent <- percentages_beh %>% group_by(trial_type, cluster) %>% 
  summarize(mean_resp = mean(percentage), sd_resp = sd(percentage), .groups = 'keep')  


### PLOTS 
# Percentage of correct answers 
ggplot(data = stats_percent, aes(x = trial_type, y = mean_resp)) + 
  geom_col(aes(x = trial_type, y = mean_resp, fill = cluster), alpha = 0.7) +
  scale_fill_manual(name = "Script",
                    values = c("#da5F49", "#699ae5"),
                    labels = c("braille alphabet", "latin alphabet"),
                    aesthetics = c("colour", "fill")) +
  geom_point(data = percentages_beh, 
             aes(x = trial_type, 
                 y = percentage, 
                 colour = cluster),
             position = position_jitter(w = 0.3, h = 0.01, seed = NA),
             alpha = 0.8, na.rm = FALSE) +
  geom_errorbar(aes(ymin = mean_resp - sd_resp, ymax = mean_resp + sd_resp), 
                width = 0, color = "black") +
  theme_classic() +                                                              
  theme(axis.ticks = element_blank()) +
  scale_x_discrete(limits=rev,                                                   
                   labels = c("FRW","FPW","FNW","FFS",
                              "BRW","BPW","BNW","BFS")) +
  labs(x = "Stimulus condition", y = "Average correct responses (%)", title = "Percentage correct answers")      

ggsave("../../outputs/derivatives/figures/beh-percentages.png", width = 3000, height = 1800, dpi = 320, units = "px")


# Miss
ggplot(data = subset(stats_beh, response_type == "miss"), aes(x = trial_type, y = mean_resp)) + 
  geom_col(aes(x = trial_type, y = mean_resp, fill = cluster)) +
  scale_fill_manual(name = "script x group",
                    values = c("#da5F49",           "#FF9E4A",          "#699ae5",          "#69B5A2"),
                    labels = c("braille - control", "braille - expert", "french - control", "french - expert"),
                    aesthetics = c("colour", "fill")) +
  theme_classic() +                                                              
  theme(axis.ticks = element_blank()) +
  scale_x_discrete(limits=rev,                                                   
                   labels = c("\t\t\t\t\tFRW"," ", "\t\t\t\t\tFPW"," ",
                              "\t\t\t\t\tFNW"," ", "\t\t\t\t\tFFS"," ",
                              "\t\t\t\t\tBRW"," ", "\t\t\t\t\tBPW"," ",
                              "\t\t\t\t\tBNW"," ", "\t\t\t\t\tBFS"," ")) +
  labs(x = "Stimulus condition", y = "Average missed responses", title = "Errors - miss")      

ggsave("../../outputs/derivatives/figures/beh-misses.png", width = 3000, height = 1800, dpi = 320, units = "px")


# FP
ggplot(data = subset(stats_beh, response_type == "false_positive"), aes(x = trial_type, y = mean_resp)) + 
  geom_col(aes(x = trial_type, y = mean_resp, fill = cluster)) +
  scale_fill_manual(name = "script x group",
                    values = c("#da5F49",           "#FF9E4A",          "#699ae5",          "#69B5A2"),
                    labels = c("braille - control", "braille - expert", "french - control", "french - expert"),
                    aesthetics = c("colour", "fill")) +
  theme_classic() +                                                              
  theme(axis.ticks = element_blank()) +
  scale_x_discrete(limits=rev,                                                   
                   labels = c("\t\t\t\t\tFRW"," ", "\t\t\t\t\tFPW"," ",
                              "\t\t\t\t\tFNW"," ", "\t\t\t\t\tFFS"," ",
                              "\t\t\t\t\tBRW"," ", "\t\t\t\t\tBPW"," ",
                              "\t\t\t\t\tBNW"," ", "\t\t\t\t\tBFS"," ")) +
  labs(x = "Stimulus condition", y = "Average fp responses", title = "Errors - false positive")      

ggsave("../../outputs/derivatives/figures/beh-fp.png", width = 3000, height = 1800, dpi = 320, units = "px")

# correct
ggplot(data = subset(stats_beh, response_type == "correct"), aes(x = trial_type, y = mean_resp)) + 
  geom_col(aes(x = trial_type, y = mean_resp, fill = cluster)) +
  scale_fill_manual(name = "script x group",
                    values = c("#da5F49",           "#FF9E4A",          "#699ae5",          "#69B5A2"),
                    labels = c("braille - control", "braille - expert", "french - control", "french - expert"),
                    aesthetics = c("colour", "fill")) +
  theme_classic() +                                                              
  theme(axis.ticks = element_blank()) +
  scale_x_discrete(limits=rev,                                                   
                   labels = c("\t\t\t\t\tFRW"," ", "\t\t\t\t\tFPW"," ",
                              "\t\t\t\t\tFNW"," ", "\t\t\t\t\tFFS"," ",
                              "\t\t\t\t\tBRW"," ", "\t\t\t\t\tBPW"," ",
                              "\t\t\t\t\tBNW"," ", "\t\t\t\t\tBFS"," ")) +
  labs(x = "Stimulus condition", y = "Average correct responses", title = "Correct responses")      

ggsave("../../outputs/derivatives/figures/beh-correct.png", width = 3000, height = 1800, dpi = 320, units = "px")









