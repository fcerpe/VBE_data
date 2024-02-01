# VBE - additional plots
#
# Supplementary / standalone plots that don't fit into the main pipeline
# to be called from viz_main

### Set up working directory and libraries 

# Add all necessary libraries

# TO-DO
# * make general plot function
# * check scripts in this function for overlap with previous dataset cleanings
# * give up and put scripts here, as much modular as possible
# * save Chi2 as csv result

# Figures:
# TBD
# Statistical analyses:
# TBD
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
  stats_brailleActivations <- function() {
    
    # Analyses are done manually at this stage, no report / contrast to load
    # 
    # In univariate analyses, we computed Small Volume Correction (SVC) 
    # on the [BW > SBW] contrast, around VWFA coordinates for [FW > SFW] contrast.
    # Results show that: 
    # - in 5 out of 6 experts, there is a significant cluster
    # - in 1 out of 12 controls, there is a significant cluster
    
    # Set-up table 
    univariate <- matrix(c(1, 5, 
                           11, 1), 
                         ncol = 2, byrow = T)
    
    colnames(univariate) <- c("No","Yes")
    rownames(univariate) <- c("Expert","Control")
    data <- as.table(univariate)
    
    # Perform CHI-square test 
    chisq.test(univariate)
    
  }
  
  
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





