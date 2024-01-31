### VBE - Process one ROI 
#
# Support function to manage one ROI fully  
source("viz_supportFunctions.R")


# Process one ROI:
# - load files
# - plot results
# - do stats
viz_processROI <- function(method, area) {
  
  # ---------------------------------------------------------------------------#
  
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
  pairwise_anova_fr <- viz_stats_rmANOVA(pairwise_fr, 1)
  pairwise_anova_br <- viz_stats_rmANOVA(pairwise_br, 1)
  pairwise_anova_both <- viz_stats_rmANOVA(pairwise, 2)
  
  # Generate filename
  name_specs <- viz_make_specs(decoding, modality, group, space, area)
  
  # Make summary table to show 
  viz_stats_summary(pairwise_anova_fr, "french", name_specs)
  viz_stats_summary(pairwise_anova_br, "braille", name_specs)
  viz_stats_summary(pairwise_anova_both, "both", name_specs)
  
  
  ## Plots
  # Summarize information for plot
  pairwise_stats <- viz_dataset_stats(pairwise)
  pairwise_stats_fr <- viz_dataset_stats(pairwise_fr)
  pairwise_stats_br <- viz_dataset_stats(pairwise_br)

  # Decoding
  viz_plot_pairwise(pairwise, pairwise_stats, name_specs)
  
  # RSA 
  viz_plot_rsa(pairwise, pairwise_stats, name_specs)
  
  # Visualize ANOVAs
  viz_plot_anova(pairwise_stats_fr, name_specs, "french")
  viz_plot_anova(pairwise_stats_br, name_specs, "braille")
  viz_plot_anova(pairwise_stats, name_specs, "both")
  viz_plot_anova_group(pairwise_stats, name_specs)
  
  
  # ---------------------------------------------------------------------------#
  
  ### Multiclass decoding 
  
  ## Load correct file
  decoding <- "multiclass"

  multiclass <- viz_dataset_import(decoding, modality, group, space, roi)
  multiclass <- viz_dataset_clean(multiclass)

  if(method == 'expansion')
    multiclass <- multiclass %>% filter(mask == area)

  # Generate filename
  name_specs <- viz_make_specs(decoding, modality, group, space, area)
  

  ## Stats - permutations done in MATLAB, rest is here
  
  # T-tests on differences between decodings
  viz_stats_multiclass(multiclass, name_specs)
  

  ## Plots
  
  # Summarize information for plot
  multiclass_stats <- viz_dataset_stats(multiclass)

  viz_plot_multiclass(multiclass, multiclass_stats, name_specs)
  
  
  
  # ---------------------------------------------------------------------------#
  
  ### Cross-script decoding 
  
  ## Load correct file
  decoding <- "pairwise"
  modality <- "cross"
  group <- "experts"

  cross <- viz_dataset_import(decoding, modality, group, space, roi)
  cross <- viz_dataset_clean(cross)

  if(method == 'expansion')
    cross <- cross %>% filter(mask == area)

  # Generate filename
  name_specs <- viz_make_specs(decoding, modality, group, space, area)
  
  
  ## Stats
  # One-way ANOVA
  cross_anova <- viz_stats_crossANOVA(cross)
  viz_stats_summary(cross_anova, "both", name_specs)
  
  
  ## Plots
  # Summarize information for plot
  cross_stats <- viz_dataset_stats(cross)

  # Plot: all modalities, only both, two directions
  viz_plot_cross(cross, cross_stats, name_specs)
  
  # Visualize ANOVAs
  viz_plot_anova_cross(cross_stats, name_specs)
  

}