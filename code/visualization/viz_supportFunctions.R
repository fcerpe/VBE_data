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
# - perfrom rmANOVA on one script
# - perfrom rmANOVA on one script
# - perfrom RSA and bootstrap


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
viz_dataset_import <- function(decoding, modality, group, space, roi) {
  
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
viz_dataset_clean <- function(dataIn) {
  
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
  
  viz_cleanDataset <- dataIn
}


# Summarize information for plots
viz_dataset_stats <- function(dataIn) {
  
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
  viz_dataset_stats <- statsOut
}



### PLOT FUNCTIONS

# Univariate activation - TBD
viz_plot_univariate <- function(dataIn, specs) {
}


# Pairwise decoding - mean accuracy 
viz_plot_pairwise <- function(dataIn, statsIn, specs) {
  
  # Compose filename and path to save figure
  savename <- paste(specs, "_plot-mean-accuracy.png", sep="")
  
  # Get the plot
  ggplot(statsIn, aes(x = decodingCondition, y = mean_accuracy)) + 
    scale_color_manual(name = "    ",
                       limits = c("french_experts",   "french_controls",  "braille_experts",    "braille_controls"),
                       values = c("#69B5A2",         "#699ae5",         "#FF9E4A",          "#da5F49"),
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
  
  # Save plot
  ggsave(savename, width = 3000, height = 1800, dpi = 320, units = "px")
}


# Multiclass decoding - mean accuracy
viz_plot_multiclass <- function(dataIn, statsIn, specs) {
  
  # Compose filename and path to save figure
  savename <- paste(specs, "_plot-mean-accuracy.png", sep="")
  
  ggplot(statsIn, aes(x = decodingCondition, y = mean_accuracy)) + 
    scale_color_manual(name = "    ",
                       limits = c("french_experts",   "french_controls",  "braille_experts",    "braille_controls"),
                       values = c("#69B5A2",         "#699ae5",         "#FF9E4A",          "#da5F49"),
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
viz_plot_cross <- function(dataIn, statsIn, specs) {
  
  ## Compose three plots: 
  # - only average of directions
  # - both directions
  # - all options, both directions + average
  
  # Compose filenames and path to save figure
  savename_mean <- paste(specs, "_plot-mean-accuracy_direction-average.png", sep="")
  savename_both <- paste(specs, "_plot-mean-accuracy_direction-both.png", sep="")
  savename_all <- paste(specs, "_plot-mean-accuracy_direction-all.png", sep="")
  
  
  ## Plot: only average
  ggplot(subset(statsIn, modality == "both"), aes(x = decodingCondition, y = mean_accuracy)) + 
    scale_color_manual(name = "condtions",
                       limits = c("both"),
                       values = c("#8372AC"),
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
    labs(x = "Decoding pair", y = "Decoding accuracy", title = "Cross-script decoding")
  
  # Save plot
  ggsave(savename_mean, width = 3000, height = 1800, dpi = 320, units = "px")
  
  
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
    labs(x = "Decoding pair", y = "Decoding accuracy", title = "Cross-script decoding")
  
  # Save plot
  ggsave(savename_both, width = 3000, height = 1800, dpi = 320, units = "px")
  
  
  ## Plot: all
  ggplot(statsIn, aes(x = decodingCondition, y = mean_accuracy)) + 
    scale_color_manual(name = "condtions", limits = c("tr-braille_te-french", "tr-french_te-braille", "both"),
                       values = c("#69B5A2", "#FF9E4A", "#8372AC"),
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
    labs(x = "Decoding pair", y = "Decoding accuracy", title = "Cross-script decoding")
  
  # Save plot
  ggsave(savename_all, width = 3000, height = 1800, dpi = 320, units = "px")
}

  
# ANOVA results - pairwise decodings
viz_plot_anova <- function(dataIn, specs, scrCond) {
  
  # Compose filename and path to save figure
  savename <- paste(specs, "_plot-ANOVA-",scrCond,".png", sep="")
  
  # Pick conditions based on script
  # Only needed for either script, in case of both we need to modify the plotting script 
  switch(scrCond, 
         french = {
           limits = c("french_experts", "french_controls")
           values = c("#69B5A2", "#699ae5")
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

    # Plot with pairwise slopes 
    ggplot(dataIn, aes(x = comparison, y = mean_accuracy, color = cluster)) +
      scale_color_manual(name = " ", 
                         limits = c("french_experts", "french_controls", "braille_experts", "braille_controls"),
                         values = c("#69B5A2", "#699ae5",  "#FF9E4A", "#da5F49"), 
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
  ggplot(dataIn, aes(x = numDecoding, y = mean_accuracy, color = cluster)) +
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
viz_plot_anova_group <- function(dataIn, specs) {
 
  # Compose filename and path to save figure
  savename <- paste(specs, "_plot-ANOVA-groups.png", sep="")
  
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
viz_plot_anova_cross <- function(dataIn, specs) {
  
  # Compose filename and path to save figure
  savename <- paste(specs, "_plot-ANOVA-both.png", sep="")
  
  # Filter data to keep only 'both' direction
  dataIn <- dataIn %>% filter(modality == "both")
  
  limits = c("both")
  values = c("#8372AC")
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
viz_plot_mds <- function(dataIn, specs) {
}


# Pairwise decoding - RDMs
viz_plot_rsa <- function(dataIn, statsIn, specs) {
  
  nameList <- c(paste(specs, "_plot-rdm-expfr.png", sep=""), 
                paste(specs, "_plot-rdm-expbr.png", sep=""), 
                paste(specs, "_plot-rdm-ctrfr.png", sep=""), 
                paste(specs, "_plot-rdm-ctrbr.png", sep=""),
                paste(specs, "_plot-rdm-model.png", sep=""))
  
  viz_build_RDM(statsIn, "#69B5A2", "french_experts")
  ggsave(nameList[1], width = 2000, height = 1600, dpi = 320, units = "px")
  
  viz_build_RDM(statsIn, "#699ae5", "french_controls")
  ggsave(nameList[2], width = 2000, height = 1600, dpi = 320, units = "px")
  
  viz_build_RDM(statsIn, "#FF9E4A", "braille_experts")
  ggsave(nameList[3], width = 2000, height = 1600, dpi = 320, units = "px")
  
  viz_build_RDM(statsIn, "#da5F49", "braille_controls")
  ggsave(nameList[4], width = 2000, height = 1600, dpi = 320, units = "px")
  
  # Extra: make model RDM
  viz_build_RDM(statsIn, "black", "model")
  ggsave(nameList[5], width = 2000, height = 1600, dpi = 320, units = "px")
  
}



### STATS 

# repeated measures ANOVA
# Assumptions on the dataset:
# - clean input  
# - the right number of scripts are present  
viz_stats_rmANOVA <- function(dataIn, nbScripts) {
  
  # nbScripts determines how many within factors do we have
  if (nbScripts == 1) {
    anovaOut <- ezANOVA(data = dataIn, dv = accuracy, wid = subID, within = comparison, between = group, 
                        type = 3, return_aov = TRUE)
  } else {
    anovaOut <- ezANOVA(data = dataIn, dv = accuracy, wid = subID, within = .(comparison, script), between = group,
                        type = 3) 
  }
  # Return result
  viz_stats_rmANOVA <- anovaOut
}


# One-way ANOVA on cross-decoding accuracies
viz_stats_crossANOVA <- function(dataIn) {
  
  # Filter data to keep only 'both' direction
  dataIn <- dataIn %>% filter(modality == "both")
  
  anovaOut <- ezANOVA(data = dataIn, 
                      dv = accuracy, 
                      wid = subID, 
                      within = comparison, 
                      type = 3, 
                      return_aov = TRUE)
  
  
  # Return result
  viz_stats_crossANOVA <- anovaOut
}


# Summarize rmANOVA results into readable table
viz_stats_summary <- function(dataIn, analysis, specs) {
  
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
  savename <- paste(specs, "_analysis-", analysis, ".csv", sep="")
  savename_pdf <- paste(specs, "_analysis-", analysis, ".pdf", sep="")
  
  # Save as csv
  write.csv(dataAnova, savename, row.names = FALSE)
  
  pdf(savename_pdf, height=11, width=10)
  grid.table(dataAnova)
  dev.off()
  
}


# RSA: correlations with model
viz_stats_rsa <- function(dataIn, statsIn, specs) {
}



### MISC

# Compose name with specs of decoding analysed
# Creates first part of filename to be used in plots
viz_make_specs <- function(decoding, modality, group, space, area) {
  
  specs <- paste("figures/decoding-",decoding,"_modality-",modality,"_group-",group,"_space-",space,
                 "_area-", area, sep="")
  
  viz_misc_specs <- specs
}


viz_build_RDM <- function(statsIn, thisColor, thisCluster) {
  
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
                         na.value = "white",) + 
    guides(fill = guide_colourbar(barwidth = 0.7, 
                                  barheight = 20, 
                                  ticks = FALSE)) + 
    labs(title = thisCluster)
  coord_fixed()
  
}





