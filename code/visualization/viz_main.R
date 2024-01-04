### VISUAL BRAILLE EXPERTISE - DATA VISUALIZATION
#
# Main script to visualize results and perfrom statistical analysis in R  

### Set up working directory and libraries 

# Add all necessary libraries
library("readxl")
library("tidyverse")
library("reshape2")
library("gridExtra")
library("pracma")
library("dplyr")
library("data.table")

source("viz_processROI.R")



### Start pipeline
# 
# For each of the following ROIs:
# - VWFA
# - l- and r-LO
# - l-PosTemp
# - V1
#
# 1. extract decoding accuracy results for  
#    * multiclass decoding,
#    * pairwise decoding,
#    * cross decoding (only in the experts subgroup)
#
# 2. creates representational dissimilarity matrices (RDMs) of the pairwise 
#    decoding accuracies
#
# 3. visualize (all plots are saved in data_viz/figures)
#    * multiclass decoding
#    * pairwise decoding
#    * cross decoding (only in the experts subgroup)
#    * representational similarity analysis (RSA) of pairwise decodings
#    * multidimensional scaling for both groups
# 
# 4. perfrom statistical anlyses
#    * repeated measures ANOVA (rmANOVA) on pairwise decodings for French script
#    * rmANOVA on pairwise decodings for Braille script
#    * rmANOVA on pairwise decodings for both scripts


# VWFA
viz_processROI("expansion", "VWFA")

# left LO
viz_processROI("expansion", "lLO")

# right LO
viz_processROI("expansion", "rLO")

# left Posterior Temporal
viz_processROI("language", "lPosTemp")

# V1
viz_processROI("earlyVisual", "V1")







