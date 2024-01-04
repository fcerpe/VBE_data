### Set up working directory and libraries 

# Working directory is current file path


# Add all necessary libraries and support functions
library("data.table")  # Read tables
library("readxl")
library("tidyverse")   # Organize dataframes
library("reshape2")    
library("dplyr")      
library("gridExtra")   
library("pracma")
library("ez")          # Perform ANOVAs
library("emmeans")
library("ggplot2")     # Visualize data

source("viz_supportFunctions.R")


### Specify options - move in another function

# which ROIs?
# - expansion = VWFA, lLO, rLO 
# - language = l-PosTemp
# - earlyVisual = V1
roi <- "expansion"

# which space? 
# - IXI549Space = bidSPM pipeline
# - MNI152NLin2009cAsym = fmriprep pipeline
space <- "IXI549Space"

# Group: all, experts, controls
group <- "all"

# Decoding: 'pairwise' or 'multiclass'
decoding <- "pairwise"

# Modality: 'within' or 'cross' (only for pairwise decoding)
modality <- "within"


### Load file 

# Set the path and the filename
cosmoFolder <- "../../outputs/derivatives/CoSMoMVPA/"
fileToLoad <- paste(cosmoFolder, 
                    "decoding-",  decoding,
                    "_modality-", modality,
                    "_group-",    group,
                    "_space-",    space,
                    "_rois-",     roi,
                    "_nbvoxels-43.csv", sep="")
dec <- viz_importCsv(fileToLoad)


### Extract relevant data from general table

# Rename 'VWFAfr' to 'VWFA' 
dec$mask <- ifelse(dec$mask == "VWFAfr", "VWFA", dec$mask)

# Add group information
experts <- c(6, 7, 8, 9, 12, 13)
controls <- c(10, 11, 18, 19, 20, 21, 22, 23, 24, 26, 27, 28)
dec <- dec %>% mutate(group = ifelse(subID %in% experts, "experts", "controls"))

# Add script information
dec <- dec %>% mutate(script = case_when(
  substr(decodingCondition, 1, 1) == "f" ~ "french",
  substr(decodingCondition, 1, 1) == "b" ~ "braille",
  TRUE ~ NA_character_))

# Generalize decodingCondition variable
dec$decodingCondition <- sub("^[fb]([a-z]+)_v_[fb]([a-z]+)$", "\\1_v_\\2", dec$decodingCondition)


# Keep only betas
dec <- dec %>% filter(image != "tmap")

# Remove unnecessary columns: image(now that there are only betas), maskVoxNb, 
#                             chosenVoxNb, ffxSmooth, roiSource, betas
dec <- dec %>% select(-one_of(c("image", "maskVoxNb", "choosenVoxNb", "ffxSmooth", "roiSource")))

# Split the dataset according to the mask
if(roi == 'expansion') {
  vwfa <- group_split(dec, mask)[[1]]
  llo <- group_split(dec, mask)[[2]]
  rlo <- group_split(dec, mask)[[3]]
}


### Perfrom rmANOVAs - it works

vwfa_anova <- ezANOVA(data = vwfa,
                      dv = accuracy, 
                      wid = subID, 
                      within = .(decodingCondition, script), 
                      between = group, 
                      type = 3,
                      detailed = TRUE) 


### Visualize results 

# Points showing different decoding accuracies
# Lines joining points
# Different colors for groups
# Different plots (split) for scripts
# Labels
# Autosave

# interaction_plot <- ggplot(vwfa, aes(x = decodingCondition, y = accuracy, color = script)) +
#   geom_line(aes(group = group), size = 1) +
#   geom_point() +
#   labs(x = "IV1", y = "Dependent Variable", color = "script") +
#   theme_minimal()


