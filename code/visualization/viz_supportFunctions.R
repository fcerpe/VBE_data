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
# - plot univariate activationss for a given area and the type of stimuli
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
      group_by(mask, decodingCondition, script, numDecoding, cluster) %>% 
      summarize(mean_accuracy = mean(accuracy), sd_accuracy = sd(accuracy), se_accuracy = sd(accuracy)/sqrt(6), .groups = 'keep') 
  }
    
  # Assign result
  viz_dataset_stats <- statsOut
}



### PLOT FUNCTIONS

# Univariate activation
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


# Multiclass decoding - COPIED
viz_plot_multiclass <- function(dataIn, statsIn, specs) {
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
               alpha = 0.3,
               legend = F) +
    geom_hline(yintercept = 0.25, size = .25, linetype = "dashed") +                
    theme_classic() +                                                              
    ylim(0,1) +                                                                    
    theme(axis.text.x = element_blank(), 
          axis.ticks = element_blank(),
          axis.title.x = element_text(size = 15), 
          axis.title.y = element_text(size = 15)) +
    facet_grid(~factor(mask, levels = c("VWFA", "lLO", "rLO")), 
               labeller = label_value) + 
    scale_x_discrete(limits=rev) +
    labs(y = "Accuracy", title = "multi-class decoding")      
  
  ggsave("figures/area-VWFA+LO_multiple-decoding_mean-accuracy.png", width = 3000, height = 1800, dpi = 320, units = "px")
  
}

# Cross-script decoding
viz_plot_cross <- function(dataIn, specs) {
  
}
  
# Visualize ANOVA results - much like JASP
viz_plot_anova <- function(dataIn, specs) {
  
}

  


### RSA
# RSA - stats






### STATS FUNCTIONS

# repeated measures ANOVA
# Assumptions on the dataset:
# - clean input  
# - the right number of scripts are present  
viz_rmANOVA <- function(tableIn, nbScripts) {
  
  # nbScripts determines how many within factors do we have
  if (nbScripts == 1) {
    anovaOut <- ezANOVA(data = tableIn, dv = accuracy, wid = subID, within = comparison, between = group, 
                        type = 3, detailed = TRUE)
  } else {
    anovaOut <- ezANOVA(data = tableIn, dv = accuracy, wid = subID, within = .(comparison, script), between = group,
                        type = 3, detailed = TRUE) 
  }
  # Return result
  viz_rmANOVA <- anovaOut
}



### MISC

# Compose name with specs of decoding analysed
# Creates first part of filename to be used in plots
viz_misc_specs <- function(decoding, modality, group, space, area) {
  
  specs <- paste("decoding-",decoding,"_modality-",modality,"_group-",group,"_space-",space,
                 "_area-", area, sep="")
  
  viz_misc_specs <- specs
}










