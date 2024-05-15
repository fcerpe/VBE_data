## FIGURES FOR CAOs 2024 poster


# Add all necessary libraries
source("viz_processROI.R")
source("viz_additionalAnalyses.R")

# VWFA
output <- get_stuff("VWFA")
get_plot(output)

# V1
output <- get_stuff("V1")
get_plot(output)

# lLO
output <- get_stuff("lLO")
get_plot(output)

# PosTemp
output <- get_stuff("lPosTemp")
get_plot(output)


get_plot <- function(output){

pairwise <- output[[1]]
cross  <- output[[2]]
name <- output[[3]]


# Pairwise
pairwise <- pairwise %>% group_by(subID, group, script, cluster) %>% 
  summarize(mean_accu = mean(accuracy), sd_accu = sd(accuracy), se_accu = sd(accuracy)/sqrt(6), .groups = 'keep') 
pairStats <- pairwise %>% group_by(cluster) %>% 
  summarize(mean_accuracy = mean(mean_accu), sd_accuracy = sd(mean_accu), se_accuracy = sd(mean_accu)/sqrt(6), .groups = 'keep') 

# Cross
cross <- cross %>% filter(modality == "both")
cross <- cross %>% group_by(subID, group, script, cluster) %>% 
  summarize(mean_accu = mean(accuracy), sd_accu = sd(accuracy), se_accu = sd(accuracy)/sqrt(6), .groups = 'keep') 
crossStats <- cross %>% group_by(cluster) %>% 
  summarize(mean_accuracy = mean(mean_accu), sd_accuracy = sd(mean_accu), se_accuracy = sd(mean_accu)/sqrt(6), .groups = 'keep') 


# Join into one table
single <- rbind(cross, pairwise)
stats <- rbind(crossStats, pairStats)

# Plot table
# Compose filename and path to save figure
savename <- paste("../../outputs/derivatives/figures/poster/", name, "_plot-pairwise-with-cross.png", sep="")


ggplot(stats, aes(x = cluster, y = mean_accuracy)) + 
  scale_color_manual(name = "    ",
                     limits = c("french_experts",   "french_controls",  "braille_experts",    "braille_controls", "AA_experts"),
                     values = c("#69B5A2",         "#4C75B3",         "#FF9E4A",          "#da5F49",              "#8B70CA"),
                     labels = c("expert - french", "control - french", "expert - braille", "control - braille",   "cross")) +
  # Mean and SE bars
  geom_pointrange(aes(x = cluster, 
                      y = mean_accuracy, 
                      ymin = mean_accuracy - se_accuracy, 
                      ymax = mean_accuracy + se_accuracy, 
                      colour = cluster),
                  position = position_dodge(1), size = .75, linewidth = 1.7) +
  # Individual data clouds 
  geom_point(data = single, 
             aes(x = cluster, 
                 y = mean_accu, 
                 colour = cluster),
             position = position_jitter(w = 0.3, h = 0.01),
             alpha = 0.3, na.rm = FALSE) +
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
                              "Braille\nControls",
                              "CD\nExperts")) +
  labs(x = "Script x group", y = "Decoding accuracy (%)")      

ggsave(savename, width = 2300, height = 1800, dpi = 500, units = "px")

}

get_stuff <- function(area){
  
  # Get options relative to the file
  decoding <- "pairwise"
  modality <- "within"
  group <- "all"
  space <- "IXI549Space"
  if (area %in% c("VWFA", "rLO", "lLO")) {
    roi <- "expansion"
  } else if (area == "lPosTemp") {
    roi <- "language"
  } else if (area == "V1") {
    roi <- "earlyVisual"
  }
  
  pairwise <- dataset_import(decoding, modality, group, space, roi)
  pairwise <- dataset_clean(pairwise)
  if(roi == 'expansion'){pairwise <- pairwise %>% filter(mask == area)}
  name_specs <- make_specs(decoding, modality, group, space, area)

  decoding <- "pairwise"
  modality <- "cross"
  group <- "experts"
  cross <- dataset_import(decoding, modality, group, space, roi)
  cross <- dataset_clean(cross)
  if(roi == 'expansion'){cross <- cross %>% filter(mask == area)}
  cross$cluster <- ifelse(cross$cluster == "NA_experts", "AA_experts", cross$cluster)
 
  return(list(pairwise, cross, name_specs))
}
