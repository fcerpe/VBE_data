source("viz_supportFunctions.R")

# Source for checking colorblind-friendliness: 
# https://davidmathlogic.com/colorblind/#%2369B5A2-%23FF9E4A-%23699AE5-%234C75B3-%23DA5F49-%238B70CA
#
# State of the art colours:
# - Green (expert group, french script) ->   #69B5A2
# - Blue (control group, french script) ->   #4C75B3
# - Orange (expert group, braille script) -> #FF9E4A
# - Red (control group, braille script) ->   #DA5F49
# - Purple (average of cross-decoding) ->    #8B70CA


### Pairwise decodings - four main colours 
pairwise <- viz_dataset_import("pairwise", "within", "all", "IXI549Space", "expansion")
pairwise <- viz_dataset_clean(pairwise)
pairwise <- pairwise %>% filter(mask == "VWFA")
pairwise_stats <- viz_dataset_stats(pairwise)

# Plot - feel free to modify colors in scale and save the hex codes in the name of the file
ggplot(pairwise_stats, aes(x = decodingCondition, y = mean_accuracy)) + 
  scale_color_manual(name = "    ",
                     limits = c("french_experts",   "french_controls",  "braille_experts",    "braille_controls"),
                     values = c("#69B5A2",         "#4C75B3",         "#FF9E4A",          "#DA5F49"),
                     labels = c("expert - french", "control - french", "expert - braille", "control - braille")) +
  # Mean and SE bars
  geom_pointrange(aes(x = decodingCondition, y = mean_accuracy, 
                      ymin = mean_accuracy - se_accuracy, ymax = mean_accuracy + se_accuracy, 
                      colour = cluster),
                  position = position_dodge(1), size = .75, linewidth = 1.7) +
  # Individual data clouds 
  geom_point(data = pairwise, aes(x = reorder(decodingCondition, cluster),
                                y = accuracy, colour = cluster),
             position = position_jitter(w = 0.3, h = 0.01), alpha = 0.3, legend = F) +
  # Chance-level
  geom_hline(yintercept = 0.5, size = .25, linetype = "dashed") +  
  # Style options
  theme_classic() +                                                              
  ylim(0,1) +                                                                    
  theme(axis.text.x = element_text(angle = 45,  vjust=1, hjust=1, size = 10), 
        axis.ticks = element_blank(),
        axis.title.x = element_text(size = 15), axis.title.y = element_text(size = 15)) +
  # Labels
  scale_x_discrete(limits=rev,                                                   
                   labels = c("\nFRW - FPW"," ", "\nFRW - FNW"," ", "\nFRW - FFS"," ", 
                              "\nFPW - FNW"," ", "\nFPW - FFS"," ", "\nFNW - FFS"," ",
                              "\nBRW - BPW"," ", "\nBRW - BNW"," ", "\nBRW - BFS"," ", 
                              "\nBPW - BNW"," ", "\nBPW - BFS"," ", "\nBNW - BFS"," ")) +
  labs(x = "Decoding pair", y = "Accuracy")      

ggsave("figures/plot-sandbox_green-69b5a2_blue-4c75b3_orange-ff9e4a_red-da5f49.png", width = 3000, height = 1800, dpi = 320, units = "px")



### Cross-decoding - one additional colour
cross <- viz_dataset_import("pairwise", "cross", "experts", "IXI549Space", "expansion")
cross <- viz_dataset_clean(cross)
cross <- cross %>% filter(mask == "VWFA")
cross_stats <- viz_dataset_stats(cross)

# Plot - feel free to modify colors in scale and save the hex codes in the name of the file
ggplot(subset(cross_stats, modality == "both"), aes(x = decodingCondition, y = mean_accuracy)) + 
  scale_color_manual(name = "     ",
                     limits = c("both"), values = c("#8B70CA"), labels = c("average")) +
  # Mean and SE bars
  geom_pointrange(aes(x = decodingCondition, 
                      y = mean_accuracy, 
                      ymin = mean_accuracy - se_accuracy, ymax = mean_accuracy + se_accuracy, 
                      colour = modality),
                  position = position_dodge(1), size = 1, linewidth = 2) +
  # Individual data clouds 
  geom_point(data = subset(cross, modality == "both"),
             aes(x = reorder(decodingCondition, modality),
                 y = accuracy, colour = modality),
             position = position_jitter(w = 0.3, h = 0.01), alpha = 0.5, legend = F) +
  geom_hline(yintercept = 0.5, size = .25, linetype = "dashed") +            
  theme_classic() +                                                          
  ylim(0.15,1) +                                                                    
  theme(axis.text.x = element_text(size = 10), axis.title.x = element_text(size = 15),
        axis.text.y = element_text(size = 10), axis.title.y = element_text(size = 15),
        axis.ticks = element_blank()) +      
  scale_x_discrete(limits=rev,                                                
                   labels = c("RW\nPW", "RW\nNW", "RW\nFS","PW\nNW", "PW\nFS","NW\nFS")) +
  labs(x = "Decoding pair", y = "Decoding accuracy", title = "Cross-script decoding")

ggsave("figures/plot-sandbox_purple-8b70ca.png", width = 3000, height = 1800, dpi = 320, units = "px")



