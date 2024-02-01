# VBE - additional plots
#
# Supplementary / standalone plots that don't fit into the main pipeline
# to be called from viz_main

### Set up working directory and libraries 

# Add all necessary libraries

# Figures:
# - 
# - 
# - 
#
# Statistical analyses:
# - 
# - 
# - 
viz_additionalAnalyses <- function() {
  
  # Braille sensitivity
  # differences in univariate activation for BW and SBW (localizer stimuli) 
  # in different areas
  # With and without eye movements
  stats_brailleSensitivity()
  
  
  # Behavioural analysis
  # responses to MVPA task - correct answers, missed targets, false detections
  stats_behaviouralResponses()
  
  # Comparison between groups in terms of Braille activation
  # Chi-square test on the number of subjects in each group that present VWFA 
  # activation for Braille
  stats_brailleActivations()
  
  # Language ROI selection
  # visualization of how many subject show activation in all the parcels from 
  # Fedorenko and colleagues (Fedorenko et al., 2010)
  roi_selectLanguageROIs()
  
  
  # Psycho-Physiological Interaction
  # interactions between VWFA and l-PTL for both 
  stats_PPI()
  
  
  # Signal-to-noise ratio
  # from tSNR maps and ROIs, plot tSNR for each task, run, subject 
  stats_tSNR()


}





