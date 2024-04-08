### SUPPORTING FUNCTIONS FOR ANALYSES SCRIPTS - VISUAL BRAILLE EXPERTISE 
#
# Create different functions to ease processing of fMRI results
# Functions that you can find here:
#
## IMPORT
# - import data given filename
# - prepare general table with dplyr
# - set working directory
#
## PLOTS
# - plot mean accuracies for multiclass decoding
# - plot mean accuracies for pairwise decodings
# - plot mean accuracies for cross decoding
# - plot univariate activations for a given area and the type of stimuli
#
# STATS
# - perform rmANOVA on one script
# - perform rmANOVA on one script
# - perform RSA and bootstrap


### Set up working directory and libraries 

# Add all necessary libraries
library("readxl")
library("tidyverse")
library("reshape2")
library("gridExtra")
library("pracma")
library("dplyr")
library("data.table")
library("ez")



# TO DO
# - add MDS plot
# - add univariate plot
# - adjust filename of plots (move to derivatives/figures/)



### IMPORT FUNCTIONS

# Load a csv and save it as dataframe
dataset_import <- function(decoding, modality, group, space, roi) {
  
  # CoSMoMVPA folder is common to all files
  cosmoFolder <- "../../outputs/derivatives/CoSMoMVPA/"
  
  # Compose filename
  fileToFind <- paste("decoding-",  decoding,
                      "_modality-", modality,
                      "_group-",    group,
                      "_space-",    space,
                      "_rois-",     roi, sep="")
  
  # Find filename, number of voxels changes based on file
  matching_files <- list.files(cosmoFolder, pattern = fileToFind, full.names = TRUE)
  
  # Read the csv file and cast it as dataframe
  dfOut <- read.csv(matching_files[1])
  dfOut <- as.data.frame(dfOut)
}


# Process dataframe 
# What are the common aspects to fix? 
# What are specifics of different analyses?
dataset_clean <- function(dataIn) {
  
  # Rename 'VWFAfr' to 'VWFA' 
  dataIn$mask <- ifelse(dataIn$mask == "VWFAfr", "VWFA", dataIn$mask)
  
  # Add general comparison variable decodingCondition variable
  dataIn$comparison <- sub("^[fb]([a-z]+)_v_[fb]([a-z]+)$", "\\1_v_\\2", dataIn$decodingCondition)
  
  # Add group information
  experts <- c(6, 7, 8, 9, 12, 13)
  controls <- c(10, 11, 18, 19, 20, 21, 22, 23, 24, 26, 27, 28)
  dataIn <- dataIn %>% mutate(group = ifelse(subID %in% experts, "experts", "controls"))
  
  # Add script information
  dataIn <- dataIn %>% mutate(script = case_when(
                              substr(decodingCondition, 1, 1) == "f" ~ "french",
                              substr(decodingCondition, 1, 1) == "b" ~ "braille",
                              TRUE ~ NA_character_))
  
  # Add number of decoding
  dataIn$numDecoding <- as.integer(factor(dataIn$decodingCondition, levels = unique(dataIn$decodingCondition)))
  
  
  # Add cluster information
  dataIn$cluster <- paste(dataIn$script, dataIn$group, sep="_")
  dataIn$decodingCondition <- ifelse(dataIn$group == "experts", paste(dataIn$decodingCondition,"_exp",sep=""), 
                                                                paste(dataIn$decodingCondition,"_ctr",sep=""))
  
  # Keep only betas
  dataIn <- dataIn %>% filter(image != "tmap")
  
  # Remove unnecessary columns: image(now that there are only betas), maskVoxNb, 
  #                             chosenVoxNb, ffxSmooth, roiSource, betas
  dataIn <- dataIn %>% select(-one_of(c("image", "maskVoxNb", "choosenVoxNb", "ffxSmooth", "roiSource")))
  
  cleanDataset <- dataIn
}


# Summarize information for plots
dataset_stats <- function(dataIn) {
  
  if ("modality" %in% colnames(dataIn)) {
    # 'modality' is present, cross-decoding condition
    statsOut <- dataIn %>% group_by(mask, decodingCondition, modality, numDecoding) %>% 
      summarize(mean_accuracy = mean(accuracy), sd_accuracy = sd(accuracy), se_accuracy = sd(accuracy)/sqrt(6), .groups = 'keep') 
  }
  else {
    # No 'modality', it's within
    statsOut <- dataIn %>% 
      group_by(mask, decodingCondition, script, numDecoding, comparison, cluster) %>% 
      summarize(mean_accuracy = mean(accuracy), sd_accuracy = sd(accuracy), se_accuracy = sd(accuracy)/sqrt(6), .groups = 'keep') 
  }
    
  # Assign result
  dataset_stats <- statsOut
}



### PLOT FUNCTIONS

# Univariate activation - TBD
plot_univariate <- function(dataIn, specs) {
}


# Pairwise decoding - accuracy 
plot_pairwise <- function(dataIn, statsIn, specs) {
  
  # Compose filename and path to save figure
  savename <- paste("../../outputs/derivatives/figures/MVPA/", specs, "_plot-pairwise.png", sep="")
  
  # Get the plot
  ggplot(statsIn, aes(x = decodingCondition, y = mean_accuracy)) + 
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
    geom_point(data = dataIn, aes(x = reorder(decodingCondition, cluster),
                           y = accuracy,
                           colour = cluster),
               position = position_jitter(w = 0.3, h = 0.01),
               alpha = 0.3,
               legend = F) +
    
    # Chance-level
    geom_hline(yintercept = 0.5, size = .25, linetype = "dashed") +  
    
    # Style options
    theme_classic() +                                                              
    ylim(0.2,1) +        
    theme(axis.text.x = element_text(vjust=1, hjust=0, size = 10), 
          axis.ticks = element_blank(),
          axis.title.x = element_text(size = 15), axis.title.y = element_text(size = 15)) +
    
    # Labels
    scale_x_discrete(limits=rev,                                                   
                     labels = c("FRW\nFPW"," ", "FRW\nFNW"," ", "FRW\nFFS"," ", 
                                "FPW\nFNW"," ", "FPW\nFFS"," ", "FNW\nFFS"," ",
                                "BRW\nBPW"," ", "BRW\nBNW"," ", "BRW\nBFS"," ", 
                                "BPW\nBNW"," ", "BPW\nBFS"," ", "BNW\nBFS"," ")) +
    
    labs(x = "", y = "Decoding accuracy")          
  
  # Save plot
  ggsave(savename, width = 3000, height = 1800, dpi = 320, units = "px")
}


# Pairwise decoding - average of conditions
plot_pairwise_average <- function(dataIn, specs) {
  
  # Calculate custom stats: 
  # average of pairwise decoding is first calculated on the subject, 
  # then subjects from the same group are clustered together
  subAverages <- dataIn %>% group_by(subID, group, script, cluster) %>% 
    summarize(mean_accu = mean(accuracy), sd_accu = sd(accuracy), se_accu = sd(accuracy)/sqrt(6), .groups = 'keep') 
  
  statsIn <- subAverages %>% group_by(cluster) %>% 
    summarize(mean_accuracy = mean(mean_accu), sd_accuracy = sd(mean_accu), se_accuracy = sd(mean_accu)/sqrt(6), .groups = 'keep') 
  
  # Compose filename and path to save figure
  savename <- paste("../../outputs/derivatives/figures/MVPA/", specs, "_plot-pairwise-average.png", sep="")
  
  
  ggplot(statsIn, aes(x = cluster, y = mean_accuracy)) + 
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
               alpha = 0.3) +
    geom_hline(yintercept = 0.50, size = .25, linetype = "dashed") +                
    theme_classic() +                                                              
    ylim(0.2,1) +                                                                    
    theme(axis.text.x = element_blank(), 
          axis.ticks = element_blank(),
          axis.title.x = element_text(size = 15), 
          axis.title.y = element_text(size = 15)) +
    scale_x_discrete(limits=rev) +
    labs(y = "Accuracy", title = "average of pairwise decodings")      
  
  ggsave(savename, width = 2500, height = 1800, dpi = 320, units = "px")
  
  
  
}


# Multiclass decoding - mean accuracy
plot_multiclass <- function(dataIn, statsIn, specs) {
  
  # Compose filename and path to save figure
  savename <- paste("../../outputs/derivatives/figures/MVPA/", specs, "_plot-mean-accuracy.png", sep="")
  
  ggplot(statsIn, aes(x = decodingCondition, y = mean_accuracy)) + 
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
    geom_point(data = dataIn, 
               aes(x = reorder(decodingCondition, cluster), 
                   y = accuracy, 
                   colour = cluster),
               position = position_jitter(w = 0.3, h = 0.01),
               alpha = 0.3) +
    geom_hline(yintercept = 0.25, size = .25, linetype = "dashed") +                
    theme_classic() +                                                              
    ylim(0,1) +                                                                    
    theme(axis.text.x = element_blank(), 
          axis.ticks = element_blank(),
          axis.title.x = element_text(size = 15), 
          axis.title.y = element_text(size = 15)) +
    scale_x_discrete(limits=rev) +
    labs(y = "Accuracy", title = "multi-class decoding")      
  
  ggsave(savename, width = 2500, height = 1800, dpi = 320, units = "px")
  
}


# Cross-script decoding - mean accuracy
plot_cross <- function(dataIn, statsIn, specs) {
  
  ## Compose three plots: 
  # - only average of directions
  # - both directions
  # - all options, both directions + average
  
  # Compose filenames and path to save figure
  savename_mean <- paste("../../outputs/derivatives/figures/MVPA/", specs, "_plot-pairwise_direction-average.png", sep="")
  savename_both <- paste("../../outputs/derivatives/figures/MVPA/", specs, "_plot-pairwise_direction-both.png", sep="")
  savename_all <- paste("../../outputs/derivatives/figures/MVPA/", specs, "_plot-pairwise_direction-all.png", sep="")
  
  
  ## Plot: only average
  ggplot(subset(statsIn, modality == "both"), aes(x = decodingCondition, y = mean_accuracy)) + 
    scale_color_manual(name = "condtions",
                       limits = c("both"),
                       values = c("#8B70CA"),
                       labels = c("average")) +
    # Mean and SE bars
    geom_pointrange(aes(x = decodingCondition, 
                        y = mean_accuracy, 
                        ymin = mean_accuracy - se_accuracy, 
                        ymax = mean_accuracy + se_accuracy, 
                        colour = modality),
                    position = position_dodge(1), size = 1, linewidth = 2) +
    # Individual data clouds 
    geom_point(data = subset(dataIn, modality == "both"),
               aes(x = reorder(decodingCondition, modality),
                   y = accuracy,
                   colour = modality),
               position = position_jitter(w = 0.3, h = 0.01),
               alpha = 0.5,
               legend = F) +
    geom_hline(yintercept = 0.5, size = .25, linetype = "dashed") +            
    theme_classic() +                                                          
    ylim(0.15,1) +                                                                    
    theme(axis.text.x = element_text(size = 10), axis.title.x = element_text(size = 15),
          axis.text.y = element_text(size = 10), axis.title.y = element_text(size = 15),
          axis.ticks = element_blank()) +      
    scale_x_discrete(limits=rev,                                                
                     labels = c("RW\nPW", "RW\nNW", "RW\nFS","PW\nNW", "PW\nFS","NW\nFS")) +
    labs(x = " ", y = "Decoding accuracy", title = "Cross-script decoding")
  
  # Save plot
  ggsave(savename_mean, width = 2500, height = 1800, dpi = 320, units = "px")
  
  
  ## Plot: both directions
  ggplot(subset(statsIn, modality != "both"), aes(x = decodingCondition, y = mean_accuracy)) + 
    scale_color_manual(name = "condtions", limits = c("tr-braille_te-french", "tr-french_te-braille"),
                                           values = c("#69B5A2", "#FF9E4A"),
                                           labels = c("train on BR, test on FR", "train on FR, test on BR")) +
    # Mean and SE bars
    geom_pointrange(aes(x = decodingCondition, y = mean_accuracy, 
                        ymin = mean_accuracy - se_accuracy, ymax = mean_accuracy + se_accuracy, 
                        colour = modality),
                    position = position_dodge(1), size = 1, linewidth = 2) +
    # Individual data clouds 
    geom_point(data = subset(dataIn, modality != "both"),
               aes(x = reorder(decodingCondition, modality), y = accuracy, colour = modality),
               position = position_jitter(w = 0.3, h = 0.01), alpha = 0.5, legend = F) +
    geom_hline(yintercept = 0.5, size = .25, linetype = "dashed") +            
    theme_classic() +                                                          
    ylim(0.15,1) +                                                                    
    theme(axis.text.x = element_text(size = 10), axis.title.x = element_text(size = 15),
          axis.text.y = element_text(size = 10), axis.title.y = element_text(size = 15),
          axis.ticks = element_blank()) +      
    scale_x_discrete(limits=rev, labels = c("RW\nPW", "RW\nNW", "RW\nFS","PW\nNW", "PW\nFS","NW\nFS")) +
    labs(x = " ", y = "Decoding accuracy", title = "Cross-script decoding")
  
  # Save plot
  ggsave(savename_both, width = 3000, height = 1800, dpi = 320, units = "px")
  
  
  ## Plot: all
  ggplot(statsIn, aes(x = decodingCondition, y = mean_accuracy)) + 
    scale_color_manual(name = "condtions", limits = c("tr-braille_te-french", "tr-french_te-braille", "both"),
                       values = c("#69B5A2", "#FF9E4A", "#8B70CA"),
                       labels = c("train on BR, test on FR", "train on FR, test on BR", "average")) +
    # Mean and SE bars
    geom_pointrange(aes(x = decodingCondition, y = mean_accuracy, 
                        ymin = mean_accuracy - se_accuracy, ymax = mean_accuracy + se_accuracy, 
                        colour = modality),
                    position = position_dodge(1), size = 1, linewidth = 2) +
    # Individual data clouds 
    geom_point(data = dataIn,
               aes(x = reorder(decodingCondition, modality), y = accuracy, colour = modality),
               position = position_jitter(w = 0.3, h = 0.01), alpha = 0.5, legend = F) +
    geom_hline(yintercept = 0.5, size = .25, linetype = "dashed") +            
    theme_classic() +                                                          
    ylim(0.15,1) +                                                                    
    theme(axis.text.x = element_text(size = 10), axis.title.x = element_text(size = 15),
          axis.text.y = element_text(size = 10), axis.title.y = element_text(size = 15),
          axis.ticks = element_blank()) +      
    scale_x_discrete(limits=rev, labels = c("RW\nPW", "RW\nNW", "RW\nFS","PW\nNW", "PW\nFS","NW\nFS")) +
    labs(x = " ", y = "Decoding accuracy", title = "Cross-script decoding")
  
  # Save plot
  ggsave(savename_all, width = 3000, height = 1800, dpi = 320, units = "px")
}


# Cross-script decoding - average of conditions
plot_cross_average <- function(dataIn, specs) {
  
  dataIn <- dataIn %>% filter(modality == "both")
  
  subAverages <- dataIn %>% group_by(subID, group, script, cluster) %>% 
    summarize(mean_accu = mean(accuracy), sd_accu = sd(accuracy), se_accu = sd(accuracy)/sqrt(6), .groups = 'keep') 
  
  statsIn <- subAverages %>% group_by(cluster) %>% 
    summarize(mean_accuracy = mean(mean_accu), sd_accuracy = sd(mean_accu), se_accuracy = sd(mean_accu)/sqrt(6), .groups = 'keep') 
  
  # Compose filenames and path to save figure
  savename <- paste("../../outputs/derivatives/figures/MVPA/", specs, "_plot-pairwise-average_direction-both.png", sep="")
  
  ## Plot: only average
  ggplot(statsIn, aes(x = cluster, y = mean_accuracy)) + 
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
                    position = position_dodge(1), size = 1, linewidth = 2) +
    # Individual data clouds 
    geom_point(data = subAverages,
               aes(x = cluster,
                   y = mean_accu,
                   colour = cluster),
               position = position_jitter(w = 0.3, h = 0.01),
               alpha = 0.5) +
    geom_hline(yintercept = 0.5, size = .5, linetype = "dashed") +            
    theme_classic() +                                                          
    ylim(0.15,1) +                                                                    
    theme(axis.text.x = element_text(size = 10), axis.title.x = element_text(size = 15),
          axis.text.y = element_text(size = 10), axis.title.y = element_text(size = 15),
          axis.ticks = element_blank()) +      
    scale_x_discrete(limits=rev,                                                
                     labels = c("  ")) +
    labs(x = "Decoding pair", y = "Decoding accuracy", title = "Cross-script decoding")
  
  # Save plot
  ggsave(savename, width = 1200, height = 1800, dpi = 320, units = "px")
}

  
# ANOVA results - pairwise decodings
plot_anova <- function(dataIn, statsIn, specs, scrCond) {
  
  # Compose filename and path to save figure
  savename <- paste("../../outputs/derivatives/figures/ANOVAs/", specs, "_plot-ANOVA-", scrCond, ".png", sep="")
  savename_extra <- paste("../../outputs/derivatives/figures/ANOVAs/", specs, "_plot-ANOVA-with-decoding.png", sep="")
  
  
  # Pick conditions based on script
  # Only needed for either script, in case of both we need to modify the plotting script 
  switch(scrCond, 
         french = {
           limits = c("french_experts", "french_controls")
           values = c("#69B5A2", "#4C75B3")
           labels = c("Experts", "Controls")
           nums = 1:6
           labels_x = c("RW - PW", "RW - NW", "RW - FS", "PW - NW", "PW - FS", "NW - FS")
         }, 
         braille = {
           limits = c("braille_experts", "braille_controls")
           values = c("#FF9E4A", "#da5F49")
           labels = c("Experts", "Controls")
           nums = 7:12
           labels_x = c("RW - PW", "RW - NW", "RW - FS", "PW - NW", "PW - FS", "NW - FS")
         })
  
  # Make plot
  if(scrCond == "both"){
    
    ## Plot with slopes overlapped to actual decoding plot
    ggplot(statsIn, aes(x = decodingCondition, y = mean_accuracy, color = cluster)) + 
      scale_color_manual(name = "    ",
                         limits = c("french_experts",   "french_controls",  "braille_experts",    "braille_controls"),
                         values = c("#69B5A2",         "#4C75B3",         "#FF9E4A",          "#da5F49"),
                         labels = c("expert - french", "control - french", "expert - braille", "control - braille"),
                         aesthetics = c("colour", "fill")) +
      # Mean and SE bars
      geom_pointrange(aes(x = decodingCondition, 
                          y = mean_accuracy, 
                          ymin = mean_accuracy - se_accuracy, 
                          ymax = mean_accuracy + se_accuracy, 
                          colour = cluster),
                      position = position_dodge(1), size = .75, linewidth = 1.7) +
      
      # Conjunction line between comparisons
      geom_line(aes(group = cluster), size = 1) +
      
      # Individual data clouds 
      geom_point(data = dataIn, aes(x = reorder(decodingCondition, cluster),
                                    y = accuracy,
                                    colour = cluster),
                 position = position_jitter(w = 0.3, h = 0.01),
                 alpha = 0.3,
                 legend = F) +
      
      # Chance-level
      geom_hline(yintercept = 0.5, size = .25, linetype = "dashed") +  
      
      # Style options
      theme_classic() +                                                              
      ylim(0.3,1) +                                                                    
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
    
    # Save plot 
    ggsave(savename_extra, width = 3000, height = 1800, dpi = 320, units = "px")
    

    ## Plot with pairwise slopes 
    ggplot(statsIn, aes(x = comparison, y = mean_accuracy, color = cluster)) +
      scale_color_manual(name = " ", 
                         limits = c("french_experts", "french_controls", "braille_experts", "braille_controls"),
                         values = c("#69B5A2", "#4C75B3",  "#FF9E4A", "#da5F49"), 
                         labels = c("Experts", "Controls", "Experts", "Controls"), 
                         aesthetics = c("colour", "fill")) +
      geom_point(size = 3) +
      geom_line(aes(group = cluster), size = 1) +
      theme_classic() +                                                              
      ylim(0.3, 1) +                                                                    
      theme(axis.text.x = element_text(angle = 45,  vjust=1, hjust=1, size = 10), 
            axis.ticks = element_blank(),
            axis.title.x = element_text(size = 15), axis.title.y = element_text(size = 15)) +
      facet_grid(~factor(script, levels = c("french", "braille")), 
                 labeller = label_value) +
      scale_x_discrete(limits = rev, 
                       labels = c("RW - PW", "RW - NW", "RW - FS", "PW - NW", "PW - FS", "NW - FS",
                                  "RW - PW", "RW - NW", "RW - FS", "PW - NW", "PW - FS", "NW - FS")) +
      labs(x = "Decoding pair", y = "Accuracy") 
  }
  else {
  ggplot(statsIn, aes(x = numDecoding, y = mean_accuracy, color = cluster)) +
    scale_color_manual(name = " ",
                       limits = limits,
                       values = values,
                       labels = labels, 
                       aesthetics = c("colour", "fill")) +
    geom_point(size = 3) +
    geom_line(aes(group = cluster), size = 1) +
    
    # Style options
    theme_classic() +                                                              
    ylim(0.3, 1) +                                                                    
    theme(axis.text.x = element_text(angle = 45,  vjust=1, hjust=1, size = 10), 
          axis.ticks = element_blank(),
          axis.title.x = element_text(size = 15), 
          axis.title.y = element_text(size = 15)) +
    
    # Labels
    scale_x_continuous(breaks = nums,
                       labels = labels_x) +
    labs(x = "Decoding pair", y = "Accuracy") 
    
  }
  
  # Save plot 
  ggsave(savename, width = 3000, height = 1800, dpi = 320, units = "px")
}


# ANOVA both scripts
# JASP creates a plot with the average decoding for each script-group
plot_anova_group <- function(dataIn, specs) {
 
  # Compose filename and path to save figure
  savename <- paste("../../outputs/derivatives/figures/ANOVAs/", specs, "_plot-ANOVA-groups.png", sep="")
  
  # Compose extra stats
  statsIn <- dataIn %>% 
                    group_by(script, cluster) %>% 
                    summarize(group_accuracy = mean(mean_accuracy), .groups = 'keep') 
  statsIn$numScript <- c(2,2,1,1)
  statsIn$group <- c("controls", "experts", "controls", "experts")
  
  # Plot
  ggplot(statsIn, aes(x = script, y = group_accuracy, color = group)) +
    scale_color_manual(name = " ",
                       limits = c("experts", "controls"),
                       values = c("#E7CB3F", "#D25BAE"),
                       labels = c("Experts", "Controls"),
                       aesthetics = c("colour", "fill")) +
    geom_point(size = 3) +
    geom_line(aes(group = group), size = 1) +
    theme_classic() +                                                              
    ylim(0.3, 0.85) +                                                                    
    theme(axis.text.x = element_text(angle = 45,  vjust=1, hjust=1, size = 10), 
          axis.ticks = element_blank(),
          axis.title.x = element_text(size = 15), axis.title.y = element_text(size = 15)) +
    scale_x_discrete(limits = rev, labels = c("French", "Braille")) +
    labs(x = "Script", y = "Accuracy") 
  
  # Save plot 
  ggsave(savename, width = 1500, height = 1500, dpi = 320, units = "px")
}


# ANOVA results - pairwise decodings
plot_anova_cross <- function(dataIn, specs) {
  
  # Compose filename and path to save figure
  savename <- paste("../../outputs/derivatives/figures/ANOVAs/", specs, "_plot-ANOVA-both.png", sep="")
  
  # Filter data to keep only 'both' direction
  dataIn <- dataIn %>% filter(modality == "both")
  
  limits = c("both")
  values = c("#8B70CA")
  labels = c("Average of both train-test directions")
  nums = 1:6
  labels_x = c("RW - PW", "RW - NW", "RW - FS", "PW - NW", "PW - FS", "NW - FS")
         
  # Make plot
  ggplot(dataIn, aes(x = numDecoding, y = mean_accuracy, color = modality)) +
    scale_color_manual(name = " ",
                       limits = limits,
                       values = values,
                       labels = labels, 
                       aesthetics = c("colour", "fill")) +
    geom_point(size = 3) +
    geom_line(size = 1) +
    
    # Style options
    theme_classic() +                                                              
    ylim(0.3, 1) +                                                                    
    theme(axis.text.x = element_text(angle = 45,  vjust=1, hjust=1, size = 10), 
          axis.ticks = element_blank(),
          axis.title.x = element_text(size = 15), 
          axis.title.y = element_text(size = 15)) +
      
    # Labels
    scale_x_continuous(breaks = nums,
                       labels = labels_x) +
    labs(x = "Decoding pair", y = "Accuracy") 
  
  # Save plot 
  ggsave(savename, width = 3000, height = 1800, dpi = 320, units = "px")
}


# Multidimensional scaling - TBD
plot_mds <- function() {
  
  mds_experts <- read.csv("../../outputs/derivatives/results/MDS/mds-pairwise_group-experts_space-IXI549Space_rois-VWFAfr.csv", header = F)
  mds_controls <- read.csv("../../outputs/derivatives/results/MDS/mds-pairwise_group-controls_space-IXI549Space_rois-VWFAfr.csv", header = F)
  
  mds_experts$script <- c("FR","FR","FR","FR","BR","BR","BR","BR")
  mds_controls$script <- c("FR","FR","FR","FR","BR","BR","BR","BR")
  
  # Generalize stimulus: remove 'F' and 'B' at the start
  mds_experts$V1 <- c("RW","PW","NW","FS","RW","PW","NW","FS")
  mds_controls$V1 <- c("RW","PW","NW","FS","RW","PW","NW","FS")
  
  
  ## Experts
  ggplot(mds_experts, aes(x = V2, y = V3)) + 
    scale_color_manual(name = "    ",
                       limits = c("FR",   "BR"),
                       values = c("#69B5A2", "#FF9E4A"),
                       labels = c(" ", " "), ) +
    
    # geom_point(aes(colour = script), size = 4, alpha = 1) +
    geom_text(label = mds_experts$V1, size = 4.5, aes(colour = script)) +
    
    # Style options
    theme_classic() +                                                              
    xlim(-0.7,0.9) + ylim(-0.8,0.8) +                                                                     
    theme(axis.text = element_blank(), 
          axis.ticks = element_blank(),
          axis.line = element_blank(),
          axis.title = element_blank())
  
  # Save plot 
  ggsave("../../outputs/derivatives/figures/MDS/mds_group-experts_graph-labels.png", width = 1500, height = 1500, dpi = 320, units = "px")
  
  
  ## Controls
  ggplot(mds_controls, aes(x = V2, y = V3)) + 
    scale_color_manual(name = "    ",
                       limits = c("FR",   "BR"),
                       values = c("#4C75B3", "#da5F49"),
                       labels = c(" ", " "), ) +
    
    geom_point(aes(colour = script), size = 4, alpha = 1) +
    # geom_text(label = mds_controls$V1, size = 4.5, aes(colour = script)) +
    
    # Style options
    theme_classic() +                                                              
    xlim(-0.7,0.9) + ylim(-0.8,0.8) +                                                                     
    theme(axis.text = element_blank(), 
          axis.ticks = element_blank(),
          axis.line = element_blank(),
          axis.title = element_blank())
  
  # Save plot 
  ggsave("../../outputs/derivatives/figures/MDS/mds_group-controls_graph-dots.png", width = 1500, height = 1500, dpi = 320, units = "px")
  
}


# Pairwise decoding - RDMs
plot_rsa <- function(dataIn, statsIn, specs) {
  
  nameList <- c(paste("../../outputs/derivatives/figures/RSA/", specs, "_plot-rdm-expfr.png", sep=""), 
                paste("../../outputs/derivatives/figures/RSA/", specs, "_plot-rdm-expbr.png", sep=""), 
                paste("../../outputs/derivatives/figures/RSA/", specs, "_plot-rdm-ctrfr.png", sep=""), 
                paste("../../outputs/derivatives/figures/RSA/", specs, "_plot-rdm-ctrbr.png", sep=""),
                paste("../../outputs/derivatives/figures/RSA/", specs, "_plot-rdm-model.png", sep=""))
  
  build_RDM(statsIn, "#69B5A2", "french_experts")
  ggsave(nameList[1], width = 2000, height = 1600, dpi = 320, units = "px")
  
  build_RDM(statsIn, "#4C75B3", "french_controls")
  ggsave(nameList[2], width = 2000, height = 1600, dpi = 320, units = "px")
  
  build_RDM(statsIn, "#FF9E4A", "braille_experts")
  ggsave(nameList[3], width = 2000, height = 1600, dpi = 320, units = "px")
  
  build_RDM(statsIn, "#da5F49", "braille_controls")
  ggsave(nameList[4], width = 2000, height = 1600, dpi = 320, units = "px")
  
  # Extra: make model RDM
  build_RDM(statsIn, "black", "model")
  ggsave(nameList[5], width = 2000, height = 1600, dpi = 320, units = "px")
  
}



### STATS 

# repeated measures ANOVA
# Assumptions on the dataset:
# - clean input  
# - the right number of scripts are present  
stats_rmANOVA <- function(dataIn, nbScripts) {
  
  # nbScripts determines how many within factors do we have
  if (nbScripts == 1) {
    anovaOut <- ezANOVA(data = dataIn, dv = accuracy, wid = subID, within = comparison, between = group, 
                        type = 3, return_aov = TRUE)
  } else {
    anovaOut <- ezANOVA(data = dataIn, dv = accuracy, wid = subID, within = .(comparison, script), between = group,
                        type = 3) 
  }
  # Return result
  stats_rmANOVA <- anovaOut
}


# One-way ANOVA on cross-decoding accuracies
stats_anova_cross <- function(dataIn) {
  
  # Filter data to keep only 'both' direction
  dataIn <- dataIn %>% filter(modality == "both")
  
  anovaOut <- ezANOVA(data = dataIn, 
                      dv = accuracy, 
                      wid = subID, 
                      within = comparison, 
                      type = 3, 
                      return_aov = TRUE)
  
  
  # Return result
  stats_anova_cross <- anovaOut
}


# Summarize rmANOVA results into readable table
stats_summary <- function(dataIn, analysis, specs) {
  
  ## Import stats
  dataAnova <- dataIn$ANOVA
  
  # Trim decimals
  colsToTrim <- sapply(dataAnova, is.numeric)
  
  # Rounding only the numeric columns to 3 decimal places
  dataAnova[colsToTrim] <- lapply(dataAnova[colsToTrim], function(x) round(x, 3))
  
  
  # Change to a more inclusive name
  names(dataAnova)[which(names(dataAnova) == "p<.05")] <- "significance"
  
  # Assign asterisks:
  # p < 0.05,  *
  # p < 0.01,  **
  # p < 0.001, ***
  dataAnova$significance <- ifelse(dataAnova$p < 0.001, "***", 
                              ifelse(dataAnova$p < 0.01, "**",  
                                ifelse(dataAnova$p < 0.05, "*", "ns")))
  
  # Save p-values as character, to ease csv file
  dataAnova$p <- as.character(dataAnova$p)
  
  # Get filename
  savename <- paste("../../outputs/derivatives/results/ANOVAs/", specs, "_stats-ANOVA-", analysis, ".csv", sep="")
  savename_pdf <- paste("../../outputs/derivatives/results/ANOVAs/", specs, "_stats-ANOVA-", analysis, ".pdf", sep="")
  
  # Save as csv
  write.csv(dataAnova, savename, row.names = FALSE)
  
  pdf(savename_pdf, height=11, width=10)
  grid.table(dataAnova)
  dev.off()
  
}


# RSA: correlations with model - DONE IN MATLAB
# stats_rsa <- function(dataIn, statsIn, specs) {}


# Pairwise averages: t-tests against chance and against other averages
stats_pairwise_average <- function(dataIn, specs) {
  
  subAverages <- dataIn %>% group_by(subID, group, script, cluster) %>% 
    summarize(mean_accu = mean(accuracy), sd_accu = sd(accuracy), se_accu = sd(accuracy)/sqrt(6), 
              .groups = 'keep') 
  
  savename <- paste("../../outputs/derivatives/results/MVPA/", specs, "_stats-ttest-pairwise-averages.csv", sep="")
  
  expfr <- subAverages %>% filter(cluster == "french_experts")
  expbr <- subAverages %>% filter(cluster == "braille_experts")
  ctrfr <- subAverages %>% filter(cluster == "french_controls")
  ctrbr <- subAverages %>% filter(cluster == "braille_controls")
  
  tests_table <- data.table(g1name = character(), g1accuracy = numeric(), 
                            g2name = character(), g2accuracy = numeric(), 
                            ttest = numeric(), df = numeric(), pvalUncorr = numeric())
  
  # Manually calculate t-tests
  result <- compare_accuracies(expfr$cluster[1], expfr$mean_accu, expbr$cluster[1], expbr$mean_accu, NA, TRUE)
  tests_table <- rbind(tests_table, result)
  
  result <- compare_accuracies(expfr$cluster[1], expfr$mean_accu, ctrfr$cluster[1], ctrfr$mean_accu, NA, FALSE)
  tests_table <- rbind(tests_table, result) 
  
  result <- compare_accuracies(expfr$cluster[1], expfr$mean_accu, ctrbr$cluster[1], ctrbr$mean_accu, NA, FALSE)
  tests_table <- rbind(tests_table, result) 
  
  result <- compare_accuracies(expbr$cluster[1], expbr$mean_accu, ctrfr$cluster[1], ctrfr$mean_accu, NA, FALSE)
  tests_table <- rbind(tests_table, result) 
  
  result <- compare_accuracies(expbr$cluster[1], expbr$mean_accu, ctrbr$cluster[1], ctrbr$mean_accu, NA, FALSE)
  tests_table <- rbind(tests_table, result) 
  
  result <- compare_accuracies(ctrfr$cluster[1], ctrfr$mean_accu, ctrbr$cluster[1], ctrbr$mean_accu, NA, TRUE)
  tests_table <- rbind(tests_table, result) 
  
  # One-sample tests
  result <- compare_accuracies(expfr$cluster[1], expfr$mean_accu, "one-sample", NA, 0.5, NA)
  tests_table <- rbind(tests_table, result) 
  
  result <- compare_accuracies(expbr$cluster[1], expbr$mean_accu, "one-sample", NA, 0.5, NA)
  tests_table <- rbind(tests_table, result) 
  
  result <- compare_accuracies(ctrfr$cluster[1], ctrfr$mean_accu, "one-sample", NA, 0.5, NA)
  tests_table <- rbind(tests_table, result) 
  
  result <- compare_accuracies(ctrbr$cluster[1], ctrbr$mean_accu, "one-sample", NA, 0.5, NA)
  tests_table <- rbind(tests_table, result)   
  
  
  # Adjust p-values for false detection rate
  tests_table$pvalFDR <- p.adjust(tests_table$pvalUncorr, "fdr")
  
  # Save table in outputs
  tests_table <- data.frame(lapply(tests_table, as.character), stringsAsFactors = F)
  write.csv(tests_table, savename, row.names = F)
}


# Multiclass: t-tests against chance and against other averages
stats_multiclass <- function(dataIn, specs) {
  
  savename <- paste("../../outputs/derivatives/results/MVPA/", specs, "_stats-ttest-multiclass.csv", sep="")
  
  expfr <- dataIn %>% filter(cluster == "french_experts")
  expbr <- dataIn %>% filter(cluster == "braille_experts")
  ctrfr <- dataIn %>% filter(cluster == "french_controls")
  ctrbr <- dataIn %>% filter(cluster == "braille_controls")
  
  tests_table <- data.table(g1name = character(), g1accuracy = numeric(), 
                            g2name = character(), g2accuracy = numeric(), 
                            ttest = numeric(), df = numeric(), pvalUncorr = numeric())
  
  # Manually calculate t-tests
  result <- compare_accuracies(expfr$cluster[1], expfr$accuracy, expbr$cluster[1], expbr$accuracy, NA, TRUE)
  tests_table <- rbind(tests_table, result) 
  
  result <- compare_accuracies(expfr$cluster[1], expfr$accuracy, ctrfr$cluster[1], ctrfr$accuracy, NA, FALSE)
  tests_table <- rbind(tests_table, result) 
  
  result <- compare_accuracies(expfr$cluster[1], expfr$accuracy, ctrbr$cluster[1], ctrbr$accuracy, NA, FALSE)
  tests_table <- rbind(tests_table, result) 
  
  result <- compare_accuracies(expbr$cluster[1], expbr$accuracy, ctrfr$cluster[1], ctrfr$accuracy, NA, FALSE)
  tests_table <- rbind(tests_table, result) 
  
  result <- compare_accuracies(expbr$cluster[1], expbr$accuracy, ctrbr$cluster[1], ctrbr$accuracy, NA, FALSE)
  tests_table <- rbind(tests_table, result) 
  
  result <- compare_accuracies(ctrfr$cluster[1], ctrfr$accuracy, ctrbr$cluster[1], ctrbr$accuracy, NA, TRUE)
  tests_table <- rbind(tests_table, result) 
  
  # One-sample tests
  result <- compare_accuracies(expfr$cluster[1], expfr$accuracy, "one-sample", NA, 0.25, NA)
  tests_table <- rbind(tests_table, result) 
  
  result <- compare_accuracies(expbr$cluster[1], expbr$accuracy, "one-sample", NA, 0.25, NA)
  tests_table <- rbind(tests_table, result) 
  
  result <- compare_accuracies(ctrfr$cluster[1], ctrfr$accuracy, "one-sample", NA, 0.25, NA)
  tests_table <- rbind(tests_table, result) 
  
  result <- compare_accuracies(ctrbr$cluster[1], ctrbr$accuracy, "one-sample", NA, 0.25, NA)
  tests_table <- rbind(tests_table, result)   
  
  
  # Adjust p-values for false detection rate
  tests_table$pvalFDR <- p.adjust(tests_table$pvalUncorr, "fdr")
  
  # Save table in outputs
  tests_table <- data.frame(lapply(tests_table, as.character), stringsAsFactors = F)
  write.csv(tests_table, savename, row.names = F)
}


# Cross-decoding: t-tests against chance and against other averages
stats_cross <- function(dataIn, specs) {
  
  savename <- paste("../../outputs/derivatives/results/MVPA/", specs, "_stats-ttest-cross.csv", sep="")
  
  both <- dataIn %>% filter(modality == "both")
  RP <- both %>% filter(comparison == "rw_v_pw")
  RN <- both %>% filter(comparison == "rw_v_nw")
  RF <- both %>% filter(comparison == "rw_v_fs")
  PN <- both %>% filter(comparison == "pw_v_nw")
  PF <- both %>% filter(comparison == "pw_v_fs")
  NF <- both %>% filter(comparison == "nw_v_fs")
  
  subAverages <- dataIn %>% group_by(subID, group, script, cluster) %>% 
    summarize(mean_accu = mean(accuracy), sd_accu = sd(accuracy), se_accu = sd(accuracy)/sqrt(6), .groups = 'keep') 
  
  tests_table <- data.table(g1name = character(), g1accuracy = numeric(), 
                            g2name = character(), g2accuracy = numeric(), 
                            ttest = numeric(), df = numeric(), pvalUncorr = numeric())
  
  # Manually calculate one-sample t-tests
  result <- compare_accuracies(RP$comparison[1], RP$accuracy, "one-sample", NA, 0.5, NA)
  tests_table <- rbind(tests_table, result)  
  
  result <- compare_accuracies(RN$comparison[1], RN$accuracy, "one-sample", NA, 0.5, NA)
  tests_table <- rbind(tests_table, result)  
  
  result <- compare_accuracies(RF$comparison[1], RF$accuracy, "one-sample", NA, 0.5, NA)
  tests_table <- rbind(tests_table, result)  
  
  result <- compare_accuracies(PN$comparison[1], PN$accuracy, "one-sample", NA, 0.5, NA)
  tests_table <- rbind(tests_table, result)  
  
  result <- compare_accuracies(PF$comparison[1], PF$accuracy, "one-sample", NA, 0.5, NA)
  tests_table <- rbind(tests_table, result)  
  
  result <- compare_accuracies(NF$comparison[1], NF$accuracy, "one-sample", NA, 0.5, NA)
  tests_table <- rbind(tests_table, result)  
  
  result <- compare_accuracies("average", subAverages$mean_accu, "one-sample", NA, 0.5, NA)
  tests_table <- rbind(tests_table, result)  
  
  
  # Adjust p-values for false detection rate
  tests_table$pvalFDR <- p.adjust(tests_table$pvalUncorr, "fdr")
  
  # Save table in outputs
  tests_table <- data.frame(lapply(tests_table, as.character), stringsAsFactors = F)
  write.csv(tests_table, savename, row.names = F)
}



### MISC

# Compose name with specs of decoding analysed
# Creates first part of filename to be used in plots
make_specs <- function(decoding, modality, group, space, area) {
  
  specs <- paste("decoding-",decoding,"_modality-",modality,"_group-",group,"_space-",space,
                 "_area-", area, sep="")
  
  misc_specs <- specs
}


build_RDM <- function(statsIn, thisColor, thisCluster) {
  
  # Select the relevant decodings
  temp <- statsIn %>% filter(cluster == thisCluster)
  
  # If model is requested, manually make matrix
  
  if (thisCluster == "model") {
    a <- c(1/3, 2/3, 1/3, 3/3, 2/3, 1/3)
  } else {
    a <- temp$mean_accuracy
  } 
  
  # Add values to template RDM 
  # make labels
  x <- c("RW", "PW", "NW", "FS")
  y <- c("FS", "NW", "PW", "RW")
  
  # Manually re-arrange matrices 
  template = c(
    a[4], a[2], a[1], 0, 
    a[5], a[3], 0,    a[1],
    a[6], 0,    a[3], a[2], 
    0,    a[6], a[5], a[4])
  
  rdm_template <- expand.grid(X=x, Y=y)
  rdm_template$accuracy <- template
  
  # Plot with selected color 
  ggplot(rdm_template, aes(X, Y, fill= accuracy)) + 
    geom_tile() + 
    theme_classic() +
    theme(axis.title.x=element_blank(), 
          axis.ticks.x=element_blank(), 
          axis.line.x = element_blank(), 
          axis.text.x = element_text(face="bold", colour="black", size = 20), 
          axis.title.y=element_blank(), 
          axis.ticks.y=element_blank(),
          axis.line.y = element_blank(),
          axis.text.y = element_text(face="bold", colour="black", size = 20)) + 
    scale_fill_gradient2(high = thisColor, 
                         limit = c(0,1), 
                         na.value = "white") + 
    guides(fill = guide_colourbar(barwidth = 0.7, 
                                  barheight = 20, 
                                  ticks = FALSE)) + 
    labs(title = thisCluster)
  coord_fixed()
  
}


compare_accuracies <- function(g1name, g1accu, g2name, g2accu, chance, pair) {
  
  # if group2 is specified, two-sided t-test between groups
  # otherwise, one-sample t-test against specified chance level
  if (length(g2accu) > 1) {
    
    # compute average of the accuracy vectors
    g1mean <- mean(g1accu)
    g2mean <- mean(g2accu)
    
    # compute t-test between vectors
    ttest = t.test(g1accu, g2accu, alternative = "two.sided", paired = pair)
    
    # compose result array
    result <- data.table(g1name = g1name, g1accuracy = g1mean, 
                         g2name = g2name, g2accuracy = g2mean, 
                         ttest = ttest[[1]], df = ttest[2], pvalUncorr = ttest[3])
    
  } else {
    
    # compute average of the accuracy vector
    g1mean <- mean(g1accu)
    
    # compute t-test against chance
    ttest = t.test(g1accu, mu = chance, alternative = "greater")
    
    # compose result array
    result <- data.table(g1name = g1name, g1accuracy = g1mean, 
                         g2name = g2name, g2accuracy = NA, 
                         ttest = ttest[[1]], df = ttest[2], pvalUncorr = ttest[3])
  }
  
  # Assign result and return
  compare_accuracies <- result
  
  
}


