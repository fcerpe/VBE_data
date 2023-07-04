setwd("~/Desktop/GitHub/VisualBraille_data/code/visualization")

library("readxl")
library("tidyverse")
library("reshape2")
library("gridExtra")
library('pracma')
library('data.table')
library('corrplot')

### Load matrices of decoding accuracies for both groups 

# Experts
exp_accuracies <- 
  read.csv("../../outputs/derivatives/CoSMoMVPA/mvpa-decoding_grp-experts_task-wordsDecoding_condition-pairwise-within-script_nbvoxels-73.csv")

# Controls
ctrl_accuracies <- 
  read.csv("../../outputs/derivatives/CoSMoMVPA/mvpa-decoding_grp-controls_task-wordsDecoding_condition-pairwise-within-script_nbvoxels-73.csv")

# Modify the data to get a color-coding column, to split between images
exp_accuracies <- as.data.frame(exp_accuracies)
ctrl_accuracies <- as.data.frame(ctrl_accuracies)

# Drop unnecessary columns
exp_accuracies <- subset(exp_accuracies, select = -c(4,7,8))
ctrl_accuracies <- subset(ctrl_accuracies, select = -c(4,7,8))

# Rename VWFA
exp_accuracies$mask <- ifelse(exp_accuracies$mask == "VWFAfr", "VWFA", exp_accuracies$mask)
ctrl_accuracies$mask <- ifelse(ctrl_accuracies$mask == "VWFAfr", "VWFA", ctrl_accuracies$mask)

# Assign the script, to ease splitting the original accuracy matrix
# 1 = French, 2 = Braille
extraCol <- repmat(c(1,1,1,1,1,1,2,2,2,2,2,2), 1,36)
extraCol <- t(extraCol)
exp_accuracies$script <- extraCol
ctrl_accuracies$script <- extraCol

# divide the matrix for area, image, script
exp_div <- group_split(exp_accuracies, subID,mask,image,script)
ctrl_div <- group_split(ctrl_accuracies, subID,mask,image,script)



### PERFORM CORRELATIONS FOR EACH SUBJECT

# Re-create nice table to make plotting easier
corr_table <- data.frame(subID=rep(c(6,7,8,9,12,13,10,11,18,19,20,21), each=3),
                                 mask=rep(c('VWFA', 'lLO','rLO'), times=12),
                                 correlation = rep(0, times=36), 
                                 group = rep(c('expert','control'), each = 18))

# Assign each group / area / script to a variable 
accu_s6_vwfa_fr <- exp_div[[1]]; accu_s6_vwfa_br <- exp_div[[2]]; corr_table$correlation[1] = cor(accu_s6_vwfa_fr$accuracy, accu_s6_vwfa_br$accuracy)
accu_s6_llo_fr <- exp_div[[5]];  accu_s6_llo_br <- exp_div[[6]];  corr_table$correlation[2] = cor(accu_s6_llo_fr$accuracy, accu_s6_llo_br$accuracy)
accu_s6_rlo_fr <- exp_div[[9]];  accu_s6_rlo_br <- exp_div[[10]]; corr_table$correlation[3] = cor(accu_s6_rlo_fr$accuracy, accu_s6_rlo_br$accuracy)

accu_s7_vwfa_fr <- exp_div[[13]]; accu_s7_vwfa_br <- exp_div[[14]]; corr_table$correlation[4] = cor(accu_s7_vwfa_fr$accuracy, accu_s7_vwfa_br$accuracy)
accu_s7_llo_fr <- exp_div[[17]]; accu_s7_llo_br <- exp_div[[18]];   corr_table$correlation[5] = cor(accu_s7_llo_fr$accuracy, accu_s7_llo_br$accuracy)
accu_s7_rlo_fr <- exp_div[[21]]; accu_s7_rlo_br <- exp_div[[22]];   corr_table$correlation[6] = cor(accu_s7_rlo_fr$accuracy, accu_s7_rlo_br$accuracy)

accu_s8_vwfa_fr <- exp_div[[25]]; accu_s8_vwfa_br <- exp_div[[26]]; corr_table$correlation[7] = cor(accu_s8_vwfa_fr$accuracy, accu_s8_vwfa_br$accuracy)
accu_s8_llo_fr <- exp_div[[29]]; accu_s8_llo_br <- exp_div[[30]];   corr_table$correlation[8] = cor(accu_s8_llo_fr$accuracy, accu_s8_llo_br$accuracy)
accu_s8_rlo_fr <- exp_div[[33]]; accu_s8_rlo_br <- exp_div[[34]];   corr_table$correlation[9] = cor(accu_s8_rlo_fr$accuracy, accu_s8_rlo_br$accuracy)

accu_s9_vwfa_fr <- exp_div[[37]]; accu_s9_vwfa_br <- exp_div[[38]]; corr_table$correlation[10] = cor(accu_s9_vwfa_fr$accuracy, accu_s9_vwfa_br$accuracy)
accu_s9_llo_fr <- exp_div[[41]]; accu_s9_llo_br <- exp_div[[42]];   corr_table$correlation[11] = cor(accu_s9_llo_fr$accuracy, accu_s9_llo_br$accuracy)
accu_s9_rlo_fr <- exp_div[[45]]; accu_s9_rlo_br <- exp_div[[46]];   corr_table$correlation[12] = cor(accu_s9_rlo_fr$accuracy, accu_s9_rlo_br$accuracy)

accu_s12_vwfa_fr <- exp_div[[49]]; accu_s12_vwfa_br <- exp_div[[50]]; corr_table$correlation[13] = cor(accu_s12_vwfa_fr$accuracy, accu_s12_vwfa_br$accuracy)
accu_s12_llo_fr <- exp_div[[53]]; accu_s12_llo_br <- exp_div[[54]];   corr_table$correlation[14] = cor(accu_s12_llo_fr$accuracy, accu_s12_llo_br$accuracy)
accu_s12_rlo_fr <- exp_div[[57]]; accu_s12_rlo_br <- exp_div[[58]];   corr_table$correlation[15] = cor(accu_s12_rlo_fr$accuracy, accu_s12_rlo_br$accuracy)

accu_s13_vwfa_fr <- exp_div[[61]]; accu_s13_vwfa_br <- exp_div[[62]]; corr_table$correlation[16] = cor(accu_s13_vwfa_fr$accuracy, accu_s13_vwfa_br$accuracy)
accu_s13_llo_fr <- exp_div[[65]]; accu_s13_llo_br <- exp_div[[66]];   corr_table$correlation[17] = cor(accu_s13_llo_fr$accuracy, accu_s13_llo_br$accuracy)
accu_s13_rlo_fr <- exp_div[[69]]; accu_s13_rlo_br <- exp_div[[70]];   corr_table$correlation[18] = cor(accu_s13_rlo_fr$accuracy, accu_s13_rlo_br$accuracy)

accu_s10_vwfa_fr <- ctrl_div[[1]]; accu_s10_vwfa_br <- ctrl_div[[2]]; corr_table$correlation[19] = cor(accu_s10_vwfa_fr$accuracy, accu_s10_vwfa_br$accuracy)
accu_s10_llo_fr <- ctrl_div[[5]];  accu_s10_llo_br <- ctrl_div[[6]];  corr_table$correlation[20] = cor(accu_s10_llo_fr$accuracy, accu_s10_llo_br$accuracy)
accu_s10_rlo_fr <- ctrl_div[[9]];  accu_s10_rlo_br <- ctrl_div[[10]]; corr_table$correlation[21] = cor(accu_s10_rlo_fr$accuracy, accu_s10_rlo_br$accuracy)

accu_s11_vwfa_fr <- ctrl_div[[13]]; accu_s11_vwfa_br <- ctrl_div[[14]]; corr_table$correlation[22] = cor(accu_s11_vwfa_fr$accuracy, accu_s11_vwfa_br$accuracy)
accu_s11_llo_fr <- ctrl_div[[17]];  accu_s11_llo_br <- ctrl_div[[18]];  corr_table$correlation[23] = cor(accu_s11_llo_fr$accuracy, accu_s11_llo_br$accuracy)
accu_s11_rlo_fr <- ctrl_div[[21]];  accu_s11_rlo_br <- ctrl_div[[22]];  corr_table$correlation[24] = cor(accu_s11_rlo_fr$accuracy, accu_s11_rlo_br$accuracy)

accu_s18_vwfa_fr <- ctrl_div[[25]]; accu_s18_vwfa_br <- ctrl_div[[26]]; corr_table$correlation[25] = cor(accu_s18_vwfa_fr$accuracy, accu_s18_vwfa_br$accuracy)
accu_s18_llo_fr <- ctrl_div[[29]];  accu_s18_llo_br <- ctrl_div[[30]];  corr_table$correlation[26] = cor(accu_s18_llo_fr$accuracy, accu_s18_llo_br$accuracy)
accu_s18_rlo_fr <- ctrl_div[[33]];  accu_s18_rlo_br <- ctrl_div[[34]];  corr_table$correlation[27] = cor(accu_s18_rlo_fr$accuracy, accu_s18_rlo_br$accuracy)

accu_s19_vwfa_fr <- ctrl_div[[37]]; accu_s19_vwfa_br <- ctrl_div[[38]]; corr_table$correlation[28] = cor(accu_s19_vwfa_fr$accuracy, accu_s19_vwfa_br$accuracy)
accu_s19_llo_fr <- ctrl_div[[41]];  accu_s19_llo_br <- ctrl_div[[42]];  corr_table$correlation[29] = cor(accu_s19_llo_fr$accuracy, accu_s19_llo_br$accuracy)
accu_s19_rlo_fr <- ctrl_div[[45]];  accu_s19_rlo_br <- ctrl_div[[46]];  corr_table$correlation[30] = cor(accu_s19_rlo_fr$accuracy, accu_s19_rlo_br$accuracy)

accu_s20_vwfa_fr <- ctrl_div[[49]]; accu_s20_vwfa_br <- ctrl_div[[50]]; corr_table$correlation[31] = cor(accu_s20_vwfa_fr$accuracy, accu_s20_vwfa_br$accuracy)
accu_s20_llo_fr <- ctrl_div[[53]];  accu_s20_llo_br <- ctrl_div[[54]];  corr_table$correlation[32] = cor(accu_s20_llo_fr$accuracy, accu_s20_llo_br$accuracy)
accu_s20_rlo_fr <- ctrl_div[[57]];  accu_s20_rlo_br <- ctrl_div[[58]];  corr_table$correlation[33] = cor(accu_s20_rlo_fr$accuracy, accu_s20_rlo_br$accuracy)

accu_s21_vwfa_fr <- ctrl_div[[61]]; accu_s21_vwfa_br <- ctrl_div[[62]]; corr_table$correlation[34] = cor(accu_s21_vwfa_fr$accuracy, accu_s21_vwfa_br$accuracy)
accu_s21_llo_fr <- ctrl_div[[65]];  accu_s21_llo_br <- ctrl_div[[66]];  corr_table$correlation[35] = cor(accu_s21_llo_fr$accuracy, accu_s21_llo_br$accuracy)
accu_s21_rlo_fr <- ctrl_div[[69]];  accu_s21_rlo_br <- ctrl_div[[70]];  corr_table$correlation[36] = cor(accu_s21_rlo_fr$accuracy, accu_s21_rlo_br$accuracy)



# PLOT CORRELATIONS AS BOXPLOT

plot_corr <- ggplot(corr_table, aes(x = group, y = correlation, label = subID), middle = mean(correlation))
plot_corr + geom_boxplot(outlier.shape = NA, aes(colour = group)) +
  scale_color_manual(name = "group",
                     values = c("expert" = "#FF9E4A",
                                "control" = "#69B5A2"),
                     labels = c("expert", "control")) +
  theme_classic() +
  ylim(-1,1) +
  geom_jitter(width = 0.3, alpha = 0.7, aes(colour = group)) + geom_text(hjust = 0, vjust = 0) +
  theme(axis.text.x = element_text(angle = 90)) +
  facet_grid(~factor(mask, levels = c("VWFA", "lLO", "rLO")), labeller = label_value) + 
  scale_x_discrete(limits=rev, labels = c("Expert","Control")) +
  labs(x = "Area x Group", y = "Correlation", title = "Correlation between scripts across areas")

ggsave("figures/areas-intersubject-variance.png", width = 3000, height = 1800, dpi = 320, units = "px")
