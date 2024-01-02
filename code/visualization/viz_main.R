### VISUAL BRAILLE EXPERTISE - DATA VISUALIZATION
#
# Main script to visualize results and perfrom statistical analysis in R  
# 
# If run completely, runs across ROIs:
# - VWFA
# - l- and r-LO
# - l-PosTemp
# - V1
#
# and perfroms the following:
#
# 1. extract decoding accuracy reuslts for  
#    * multiclass decoding,
#    * pairwise decoding,
#    * cross decoding (only in the experts subgroup)
#
# 2. creates rperesentational dissimilarity matrices (RDMs) of the pariwise 
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



### Set up working directory and libraries 

# Working directory is here
setwd(".")

# Add all necessary libraries
library("readxl")
library("tidyverse")
library("reshape2")
library("gridExtra")
library("pracma")
library("dplyr")
library("data.table")


### Specify options

# which ROIs?
# - expansion = VWFA, lLO, rLO 
# - language = l-PosTemp
# - earlyVisual = V1
roi = "expansion"

# which space? 
# - IXI549Space = bidSPM pipeline
# - MNI152NLin2009cAsym = fmriprep pipeline
space = "IXI549Space"



### Start pipeline

# TBD





