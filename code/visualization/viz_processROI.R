### VBE - Process one ROI 
#
# Support function to manage one ROI fully  
source("viz_supportFunctions.R")


# Process one ROI:
# - load files
# - plot results
# - do stats
viz_processROI <- function(method, area) {
  
  # -------------------------------------------------------------------------- #
  
  ### Pairwise decoding 
  
  ## Import
  # Get options relative to the file
  decoding <- "pairwise"
  modality <- "within"
  group <- "all"
  space <- "IXI549Space"
  roi <- method
  
  # Load file
  pairwise <- dataset_import(decoding, modality, group, space, roi)
  
  # Clean file: remove unnecessary lines, add information about group and script
  pairwise <- dataset_clean(pairwise)
  
  # In the case of expansion, we clustered three ROIs
  # Separate them and keep only the relevant one
  if(method == 'expansion')
    pairwise <- pairwise %>% filter(mask == area)
  
  # Separate scripts
  pairwise_fr <- pairwise %>% filter(script == "french")
  pairwise_br <- pairwise %>% filter(script == "braille")
  
  
  ## Stats
  # Generate filename
  name_specs <- make_specs(decoding, modality, group, space, area)
  
  # Run ANOVAs
  pairwise_anova_fr <- stats_rmANOVA(pairwise_fr, 1)
  pairwise_anova_br <- stats_rmANOVA(pairwise_br, 1)
  pairwise_anova_both <- stats_rmANOVA(pairwise, 2)
  
  # Make summary table to show 
  stats_summary(pairwise_anova_fr, "french", name_specs)
  stats_summary(pairwise_anova_br, "braille", name_specs)
  stats_summary(pairwise_anova_both, "both", name_specs)
  
  # t-tests on pairwise averages
  stats_pairwise_average(pairwise, name_specs)
  
  
  ## Plots
  # Summarize information for plot
  pairwise_stats <- dataset_stats(pairwise)
  pairwise_stats_fr <- dataset_stats(pairwise_fr)
  pairwise_stats_br <- dataset_stats(pairwise_br)

  # Decoding
  plot_pairwise(pairwise, pairwise_stats, name_specs)
  plot_pairwise_average(pairwise, name_specs)
  
  
  # RSA 
  plot_rsa(pairwise, pairwise_stats, name_specs)
  
  # Visualize ANOVAs
  plot_anova(pairwise, pairwise_stats_fr, name_specs, "french")
  plot_anova(pairwise, pairwise_stats_br, name_specs, "braille")
  plot_anova(pairwise, pairwise_stats, name_specs, "both")
  plot_anova_group(pairwise_stats, name_specs)
  
  
  # -------------------------------------------------------------------------- #
  
  ### Multiclass decoding 
  
  ## Load correct file
  decoding <- "multiclass"

  multiclass <- dataset_import(decoding, modality, group, space, roi)
  multiclass <- dataset_clean(multiclass)

  if(method == 'expansion')
    multiclass <- multiclass %>% filter(mask == area)

  # Generate filename
  name_specs <- make_specs(decoding, modality, group, space, area)
  

  ## Stats - permutations done in MATLAB, rest is here
  
  # T-tests on differences between decodings
  stats_multiclass(multiclass, name_specs)
  

  ## Plots
  
  # Summarize information for plot
  multiclass_stats <- dataset_stats(multiclass)

  plot_multiclass(multiclass, multiclass_stats, name_specs)
  
  
  
  # -------------------------------------------------------------------------- #
  
  ### Cross-script decoding 
  
  ## Load correct file
  decoding <- "pairwise"
  modality <- "cross"
  group <- "experts"

  cross <- dataset_import(decoding, modality, group, space, roi)
  cross <- dataset_clean(cross)

  if(method == 'expansion')
    cross <- cross %>% filter(mask == area)

  # Generate filename
  name_specs <- make_specs(decoding, modality, group, space, area)
  
  
  ## Stats
  # One-way ANOVA
  cross_anova <- stats_anova_cross(cross)
  stats_summary(cross_anova, "both", name_specs)
  
  # T-tests against chance 
  stats_cross(cross, name_specs)
  
  
  ## Plots
  # Summarize information for plot
  cross_stats <- dataset_stats(cross)

  # Plot: all modalities, only both, two directions
  plot_cross(cross, cross_stats, name_specs)
  
  plot_cross_average(cross, name_specs)
  
  # Visualize ANOVAs
  plot_anova_cross(cross_stats, name_specs)
  
}