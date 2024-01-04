### VBE - Process one ROI 
#
# Support function to manage one ROI fully  


# Add all necessary libraries
library("readxl")
library("tidyverse")
library("reshape2")
library("gridExtra")
library("pracma")
library("dplyr")
library("data.table")
library("ez")

source("viz_supportFunctions.R")



# Process one ROI:
# - load files
# - plot results
# - do stats
viz_processROI <- function(method, area) {
  
  
  
  ### Pairwise decoding 
  
  ## Import
  # Get options relative to the file
  decoding <- "pairwise"
  modality <- "within"
  group <- "all"
  space <- "IXI549Space"
  roi <- method
  
  # Load file
  pairwise <- viz_dataset_import(decoding, modality, group, space, roi)
  
  # Clean file: remove unnecessary lines, add information about group and script
  pairwise <- viz_dataset_clean(pairwise)
  
  # In the case of expansion, we clustered three ROIs
  # Separate them and keep only the relevant one
  if(method == 'expansion')
    pairwise <- pairwise %>% filter(mask == area)
  
  
  ## Stats
  # Separate scripts
  pairwise_fr <- pairwise %>% filter(script == "french")
  pairwise_br <- pairwise %>% filter(script == "braille")
  
  # Run ANOVAs
  pairwise_anova_fr <- viz_rmANOVA(pairwise_fr, 1)
  pairwise_anova_br <- viz_rmANOVA(pairwise_br, 1)
  pairwise_anova_both <- viz_rmANOVA(pairwise, 2)
  
  # so far so good
  
  ## Plots
  # Generate filename
  name_specs <- viz_misc_specs(decoding, modality, group, space, area)
  
  # Summarize information for plot
  pairwise_stats <- viz_dataset_stats(pairwise)
  
  # Pairwise decoding
  viz_plot_pairwise(pairwise, pairwise_stats, name_specs)
  
  # Visualize ANOVAs
  # viz_plot_anova(pairwise_anova_both, name_specs)
  # viz_plot_anova(pairwise_anova_fr, name_specs)
  # viz_plot_anova(pairwise_anova_br, name_specs)
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  # Additional plot: univariate activationfor the eight different stimuli conditions
  # Univariate activation
  # viz_plot_univariate(pairwise, name_specs)
  
  
  # DELETE WHEN DONE
  # print("method", method)
  # print("area", area)
  # viz_processROI <- 0
  
}