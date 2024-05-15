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


### Load examples for different plots 

## Pairwise decodings 
pairwise <- dataset_import("pairwise", "within", "all", "IXI549Space", "expansion")
pairwise <- dataset_clean(pairwise)
pairwise <- pairwise %>% filter(mask == "VWFA")
pairwise_stats <- dataset_stats(pairwise)

## Average of pairwise decodings
subAverages <- pairwise %>% group_by(subID, group, script, cluster) %>% summarize(mean_accu = mean(accuracy), sd_accu = sd(accuracy), se_accu = sd(accuracy)/sqrt(6), .groups = 'keep') 
averages <- subAverages %>% group_by(cluster) %>% summarize(mean_accuracy = mean(mean_accu), sd_accuracy = sd(mean_accu), se_accuracy = sd(mean_accu)/sqrt(6), .groups = 'keep') 


## Cross-decoding
cross <- dataset_import("pairwise", "cross", "experts", "IXI549Space", "expansion")
cross <- dataset_clean(cross)
cross <- cross %>% filter(mask == "VWFA")
cross <- cross %>% filter(modality == "both")
cross_stats <- dataset_stats(cross)
crossAverages <- cross %>% group_by(subID, group, script, cluster) %>% summarize(mean_accu = mean(accuracy), sd_accu = sd(accuracy), se_accu = sd(accuracy)/sqrt(6), .groups = 'keep') 
crossAvgStats <- crossAverages %>% group_by(cluster) %>% summarize(mean_accuracy = mean(mean_accu), sd_accuracy = sd(mean_accu), se_accuracy = sd(mean_accu)/sqrt(6), .groups = 'keep') 


## RSA
# Select the relevant decodings
temp <- pairwise_stats %>% filter(cluster == 'french_experts')
a <- temp$mean_accuracy
x <- c("RW", "PW", "NW", "FS")
y <- c("FS", "NW", "PW", "RW")
template = c(a[4], a[2], a[1], 0, a[5], a[3], 0, a[1], a[6], 0, a[3], a[2], 0, a[6], a[5], a[4])
rdm_template <- expand.grid(X=x, Y=y)
rdm_template$accuracy <- template


### Plots 

## Plot pairwise decodings
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
             position = position_jitter(w = 0.3, h = 0.01), alpha = 0.3,
             na.rm = FALSE, legend = F) +
  
  # Chance-level
  geom_hline(yintercept = 0.5, size = .25, linetype = "dashed") +  
  
  # Style options
  theme_classic() +                                                              
  ylim(0.2,1) +                                                                    
  theme(axis.text.x = element_text(size = 12, family = "Avenir", color = "black", vjust = 1, hjust = 0), 
        axis.text.y = element_text(size = 12, family = "Avenir", color = "black"), 
        axis.ticks = element_blank(),
        axis.title.x = element_text(size = 12, family = "Avenir", color = "black", vjust = 0), 
        axis.title.y = element_text(size = 12, family = "Avenir", color = "black", vjust = 2),
        legend.position = "none") +
  
  # Labels
  scale_x_discrete(limits=rev,                                                   
                   labels = c("RW\nPW"," ", "RW\nNW"," ", "RW\nFS"," ", 
                              "PW\nNW"," ", "PW\nFS"," ", "NW\nFS"," ",
                              "RW\nPW"," ", "RW\nNW"," ", "RW\nFS"," ", 
                              "PW\nNW"," ", "PW\nFS"," ", "NW\nFS"," ")) +
  labs(x = "Decoded pairs", y = "Decoding accuracy (%)")      

ggsave("figures/plot-pairwise_paper.png", width = 3000, height = 1800, dpi = 500, units = "px")



## Plot pairwise average
ggplot(averages, aes(x = cluster, y = mean_accuracy)) + 
  scale_color_manual(name = "    ",
                     limits = c("french_experts",   "french_controls",  "braille_experts",    "braille_controls"),
                     values = c("#69B5A2",         "#4C75B3",         "#FF9E4A",          "#da5F49"),
                     labels = c("expert - french", "control - french", "expert - braille", "control - braille")) +
  
  # Mean and SE bars
  geom_pointrange(aes(x = cluster, 
                      y = mean_accuracy, 
                      ymin = mean_accuracy - se_accuracy, 
                      ymax = mean_accuracy + se_accuracy, 
                      colour = cluster),
                  position = position_dodge(1), size = .75, linewidth = 1.7) +
  
  # Individual data clouds 
  geom_point(data = subAverages, 
             aes(x = cluster, 
                 y = mean_accu, 
                 colour = cluster),
             position = position_jitter(w = 0.3, h = 0.01),
             alpha = 0.3,
             na.rm = FALSE) +
  geom_hline(yintercept = 0.50, size = .25, linetype = "dashed") +                
  theme_classic() +                                                              
  ylim(0.2,1) +                                                                    
  theme(axis.text.x = element_text(size = 12, family = "Avenir", color = "black"), 
        axis.text.y = element_text(size = 12, family = "Avenir", color = "black"), 
        axis.ticks = element_blank(),
        axis.title.x = element_text(size = 12, family = "Avenir", color = "black", vjust = 0), 
        axis.title.y = element_text(size = 12, family = "Avenir", color = "black", vjust = 2),
        legend.position = "none") +
  
  scale_x_discrete(limits = rev,
                   labels = c("Latin\nExperts",
                              "Latin\nControls",
                              "Braille\nExperts",
                              "Braille\nControls")) +
  labs(x = "Script x group", y = "Decoding accuracy (%)")      

ggsave("figures/plot-pairwise-averages_paper.png", width = 2200, height = 1800, dpi = 500, units = "px")



## Plot cross-decoding
ggplot(subset(cross_stats, modality == "both"), aes(x = decodingCondition, y = mean_accuracy)) + 
  scale_color_manual(name = "     ",
                     limits = c("both"), values = c("#8B70CA"), labels = c("average")) +
  # Mean and SE bars
  geom_pointrange(aes(x = decodingCondition, 
                      y = mean_accuracy, 
                      ymin = mean_accuracy - se_accuracy, ymax = mean_accuracy + se_accuracy, 
                      colour = modality),
                  position = position_dodge(1), size = .75, linewidth = 1.7) +
  # Individual data clouds 
  geom_point(data = subset(cross, modality == "both"),
             aes(x = reorder(decodingCondition, modality),
                 y = accuracy, colour = modality),
             position = position_jitter(w = 0.3, h = 0.01), alpha = 0.5, legend = F) +
  geom_hline(yintercept = 0.5, size = .25, linetype = "dashed") +            
  theme_classic() +                                                          
  ylim(0.2,1) +                                                                    
  theme(axis.text.x = element_text(size = 12, family = "Avenir", color = "black"), 
        axis.text.y = element_blank(), 
        axis.ticks = element_blank(),
        axis.title.x = element_text(size = 12, family = "Avenir", color = "black", vjust = 0), 
        axis.title.y = element_blank(),
        legend.position = "none") +
  scale_x_discrete(limits=rev,                                                
                   labels = c("RW\nPW", "RW\nNW", "RW\nFS", "PW\nNW", "PW\nFS", "NW\nFS")) +
  labs(x = "Decoded pairs", y = "Decoding accuracy (%)")

ggsave("figures/plot-cross_paper.png", width = 2200, height = 1800, dpi = 500, units = "px")



## Plot cross-decoding average
ggplot(crossAvgStats, aes(x = cluster, y = mean_accuracy)) + 
  scale_color_manual(name = "condtions",
                     limits = c("NA_experts"),
                     values = c("#8B70CA"),
                     labels = c("average")) +
  # Mean and SE bars
  geom_pointrange(aes(x = cluster, 
                      y = mean_accuracy, 
                      ymin = mean_accuracy - se_accuracy, 
                      ymax = mean_accuracy + se_accuracy, 
                      colour = cluster),
                  position = position_dodge(1), size = .75, linewidth = 1.7) +
  # Individual data clouds 
  geom_point(data = crossAverages,
             aes(x = cluster,
                 y = mean_accu,
                 colour = cluster),
             position = position_jitter(w = 0.3, h = 0.01),
             alpha = 0.5) +
  geom_hline(yintercept = 0.5, size = .25, linetype = "dashed") +            
  theme_classic() +                                                          
  ylim(0.2,1) +                                                                    
  theme(axis.text.x = element_text(size = 12, family = "Avenir", color = "black"), 
        axis.text.y = element_text(size = 12, family = "Avenir", color = "black"), 
        axis.ticks = element_blank(),
        axis.title.x = element_text(size = 12, family = "Avenir", color = "black", vjust = 0), 
        axis.title.y = element_text(size = 12, family = "Avenir", color = "black", vjust = 2),
        legend.position = "none") +
  scale_x_discrete(limits=rev, labels = c('Mean of\ndecoded pairs')) +
  labs(x = "cut", y = "Decoding accuracy (%)")

ggsave("figures/plot-cross-average_paper.png", width = 1000, height = 1800, dpi = 500, units = "px")



## Plot RSA
ggplot(rdm_template, aes(X, Y, fill= accuracy)) + 
  geom_tile() + 
  theme_classic() +
  annotate("rect", xmin = 0.5, xmax = 4.5, ymin = 0.5, ymax = 4.5,
           alpha = 0,
           color = "#69B5A2",
           linewidth = .5,
           linetype = 1) + 
  theme(axis.title.x=element_blank(), 
        axis.ticks.x=element_blank(), 
        axis.line.x = element_blank(), 
        axis.text.x = element_blank(), 
        axis.title.y=element_blank(), 
        axis.ticks.y=element_blank(),
        axis.line.y = element_blank(),
        axis.text.y = element_blank(),
        legend.position = "none",
        plot.margin = unit(c(0,0,0,0), "pt")) + 
  scale_fill_gradient2(high = "#69B5A2", 
                       limit = c(0,1), 
                       na.value = "white") + 
  guides(fill = guide_colourbar(barwidth = 0.7, 
                                barheight = 20, 
                                ticks = FALSE)) + 
coord_fixed()

ggsave("figures/plot-rsa_paper.png", width = 1700, height = 1700, dpi = 700, units = "px")

