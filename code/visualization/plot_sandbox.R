source("viz_supportFunctions.R")

# Load file - use support functions
pairwise <- viz_dataset_import("pairwise", "within", "all", "IXI549Space", "expansion")
pairwise <- viz_dataset_clean(pairwise)
pairwise <- pairwise %>% filter(mask == "VWFA")
pairwise_stats <- viz_dataset_stats(pairwise)

# Reasons to change the blue to a darker one
# https://davidmathlogic.com/colorblind/#%2369B5A2-%23FF9E4A-%23699AE5-%234C75B3-%23DA5F49

# Plot - sandbox to try different options / colors / etc
# Feel free to modify colors in scale and save the hex codes in the name of the file
ggplot(pairwise_stats, aes(x = decodingCondition, y = mean_accuracy)) + 
  scale_color_manual(name = "    ",
                     limits = c("french_experts",   "french_controls",  "braille_experts",    "braille_controls"),
                     values = c("#69B5A2",         "#4C75B3",         "#FF9E4A",          "#da5F49"),
                     labels = c("expert - french", "control - french", "expert - braille", "control - braille")) +
  
  # Mean and SE bars
  geom_pointrange(aes(x = decodingCondition, 
                      y = mean_accuracy, 
                      ymin = mean_accuracy - se_accuracy, 
                      ymax = mean_accuracy + se_accuracy, 
                      colour = cluster),
                  position = position_dodge(1), size = .75, linewidth = 1.7) +
  
  # Individual data clouds 
  geom_point(data = pairwise, aes(x = reorder(decodingCondition, cluster),
                                y = accuracy,
                                colour = cluster),
             position = position_jitter(w = 0.3, h = 0.01),
             alpha = 0.3,
             legend = F) +
  
  # Chance-level
  geom_hline(yintercept = 0.5, size = .25, linetype = "dashed") +  
  
  # Style options
  theme_classic() +                                                              
  ylim(0,1) +                                                                    
  theme(axis.text.x = element_text(angle = 45,  vjust=1, hjust=1, size = 10), 
        axis.ticks = element_blank(),
        axis.title.x = element_text(size = 15), 
        axis.title.y = element_text(size = 15)) +
  
  # Labels
  scale_x_discrete(limits=rev,                                                   
                   labels = c("\nFRW - FPW"," ", "\nFRW - FNW"," ", "\nFRW - FFS"," ", 
                              "\nFPW - FNW"," ", "\nFPW - FFS"," ", "\nFNW - FFS"," ",
                              "\nBRW - BPW"," ", "\nBRW - BNW"," ", "\nBRW - BFS"," ", 
                              "\nBPW - BNW"," ", "\nBPW - BFS"," ", "\nBNW - BFS"," ")) +
  labs(x = "Decoding pair", y = "Accuracy")      


ggsave("figures/plot-sandbox_green-69b5a2_blue-4c75b3_orange-ff9e4a_red-da5f49.png", width = 3000, height = 1800, dpi = 320, units = "px")


