# VBE - additional plots
#
# Supplementary / standalone plots that don't fit into the main pipeline
# to be called from viz_main

### Set up working directory and libraries 

# Add all necessary libraries
  library(ggplot2)
  library(gridExtra)
  library(gtable)

# TO-DO
# * make general plot function
# * check scripts in this function for overlap with previous dataset cleanings
# * give up and put scripts here, as much modular as possible
# * save Chi2 as csv result

# Figures:
# TBD
# Statistical analyses:
# TBD
  
# Braille sensitivity
# differences in univariate activation for BW and SBW (localizer stimuli) 
# in different areas
# With and without eye movements
# stats_brailleSensitivity()
  
  
# Behavioural analysis
# responses to MVPA task - correct answers, missed targets, false detections
# stats_behaviouralResponses()
  
  
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
# roi_selectLanguageROIs()
  

# Psycho-Physiological Interaction
# interactions between VWFA and l-PTL for both 
# stats_PPI()
  
  
# Signal-to-noise ratio
# from tSNR maps and ROIs, plot tSNR for each task, run, subject 
# stats_tSNR()


  
# Make standard legends
plot_legends <- function() {
    
  # mock data 
  mockTable <- data.frame (cluster = c("french_experts", 
                                       "french_controls", 
                                       "braille_experts", 
                                       "braille_controls",
                                       "model"),
                           values = c(1,1,1,1,1))
    
  ## SQUARE LEGENDS
  # - four group*script pairs (exp-fr, ctr-fr, exp-br, ctr-br)
  # - order by script (french first, then braille)
  make_legend_square(tab = mockTable, 
                   lim = c("french_experts", "french_controls", "braille_experts", "braille_controls"),
                   lab = c("French - Experts", "French - Controls", "Braille - Experts", "Braille - Controls"), 
                   val = c("#69B5A2", "#4C75B3",  "#FF9E4A", "#da5F49"), 
                   savename = "../../outputs/derivatives/figures/plot-legend_group-neural_oreder-script_shape-squares.png")
    
  # - four group*script pairs (exp-fr, exp-br, ctr-fr, ctr-br)
  # - order by script (experts first, then controls)
  make_legend_square(tab = mockTable, 
                   lim = c("french_experts", "braille_experts", "french_controls", "braille_controls"),
                   lab = c("French - Experts", "Braille - Experts", "French - Controls", "Braille - Controls"), 
                   val = c("#69B5A2", "#FF9E4A", "#4C75B3", "#da5F49"), 
                   savename = "../../outputs/derivatives/figures/plot-legend_group-neural_order-group_shape-squares.png")
    
  # - two group*script pairs (just french)
  make_legend_square(tab = mockTable, 
                   lim = c("french_experts", "french_controls"),
                   lab = c("French - Experts", "French - Controls"), 
                   val = c("#69B5A2", "#4C75B3"), 
                   savename = "../../outputs/derivatives/figures/plot-legend_group-neural_order-just-french_shape-squares.png")
  
  # - two group*script pairs (just braille)
  make_legend_square(tab = mockTable, 
                   lim = c("braille_experts", "braille_controls"),
                   lab = c("Braille - Experts", "Braille - Controls"), 
                   val = c("#FF9E4A", "#da5F49"), 
                   savename = "../../outputs/derivatives/figures/plot-legend_group-neural_order-just-braille_shape-squares.png")
    
  
  ## CIRCLE LEGENDS
  # - four group*script pairs (exp-fr, ctr-fr, exp-br, ctr-br)
  # - order by script (french first, then braille)
  make_legend_circle(tab = mockTable, 
                   lim = c("french_experts", "french_controls", "braille_experts", "braille_controls"),
                   lab = c("French - Experts", "French - Controls", "Braille - Experts", "Braille - Controls"), 
                   val = c("#69B5A2", "#4C75B3",  "#FF9E4A", "#da5F49"), 
                   savename = "../../outputs/derivatives/figures/plot-legend_group-neural_order-script_shape-circles.png")
  
  # - four group*script pairs (exp-fr, exp-br, ctr-fr, ctr-br)
  # - order by script (experts first, then controls)
  make_legend_circle(tab = mockTable, 
                   lim = c("french_experts", "braille_experts", "french_controls", "braille_controls"),
                   lab = c("French - Experts", "Braille - Experts", "French - Controls", "Braille - Controls"), 
                   val = c("#69B5A2", "#FF9E4A", "#4C75B3", "#da5F49"), 
                   savename = "../../outputs/derivatives/figures/plot-legend_group-neural_order-group_shape-circles.png")
  
  # - two group*script pairs (just french)
  make_legend_circle(tab = mockTable, 
                   lim = c("french_experts", "french_controls"),
                   lab = c("French - Experts", "French - Controls"), 
                   val = c("#69B5A2", "#4C75B3"), 
                   savename = "../../outputs/derivatives/figures/plot-legend_group-neural_order-just-french_shape-circles.png")
  
  # - two group*script pairs (just braille)
  make_legend_circle(tab = mockTable, 
                   lim = c("braille_experts", "braille_controls"),
                   lab = c("Braille - Experts", "Braille - Controls"), 
                   val = c("#FF9E4A", "#da5F49"), 
                   savename = "../../outputs/derivatives/figures/plot-legend_group-neural_order-just-braille_shape-circles.png")
  
}


# Plot the graph / legend with squares
make_legend_square <- function(tab, lim, lab, val, savename) {
    
   ggplot(tab, aes(x = cluster, y = values, color = cluster)) +
     geom_col(aes(x = cluster, y = values, fill = cluster)) +
     scale_color_manual(name = " ", limits = lim, values = val, labels = lab, 
                        aesthetics = c("colour", "fill")) + 
     theme_classic() +                                                              
     theme(axis.ticks = element_blank(), 
           legend.key.size = unit(2, 'cm'), 
           legend.text = element_text(size = 30)) +
     scale_x_discrete(limits = rev, labels = c(" ", " ", " ", " ", " ")) 
    
   ggsave(savename, width = 2000, height = 1500, dpi = 320, units = "px")
    
}


# Plot the graph / legend with dots
make_legend_circle <- function(tab, lim, lab, val, savename) {
  
  ggplot(tab, aes(x = cluster, y = values, color = cluster)) +
    geom_point(size = 20) +
    scale_color_manual(name = " ", limits = lim, values = val, labels = lab, 
                       aesthetics = c("colour", "fill")) + 
    theme_classic() +                                                              
    theme(axis.ticks = element_blank(), 
          legend.text = element_text(size = 30)) +
    scale_x_discrete(limits = rev, labels = c(" ", " ", " ", " ", " ")) 
  
  ggsave(savename, width = 2000, height = 1500, dpi = 320, units = "px")
  
}
  
# DOES NOT WORK
make_legend_rsa <- function() {
  
  a <- data.frame(x = 1, ef = rep(0, 100), eb = rep(1, 100), cf = rep(2, 100), cb = rep(3, 100), mo = rep(4, 100))
  
  set.seed(123)
  x <- rep(1:100, each = 4)
  A <- rep(c("A",NA,NA,NA), times = 100)
  B <- rep(c(NA,"B",NA,NA), times = 100)
  C <- rep(c(NA,NA,"C",NA), times = 100)
  D <- rep(c(NA,NA,NA,"D"), times = 100)
  y <- runif(400, min = -1, max = 1)
  cluster <- paste(x, condition, sep = "_")
  
  df <- data.frame(x, condition, y, cluster)
  
  ggplot(df, aes(x = x, y = y)) +
    geom_point(aes(fill1 = A)) +
    geom_point(data = subset(df, condition == "B"), aes(fill2 = B)) +
    geom_point(data = subset(df, condition == "C"), aes(fill3 = C)) +
    geom_point(data = subset(df, condition == "D"), aes(fill4 = D)) +
    scale_fill_multi(aesthetics = c("fill1", "fill2", "fill3", "fill4"),
                     colours = list(c("white", "#69B5A2"),
                                    c("white", "#FF9E4A"),
                                    c("white", "#4C75B3"),
                                    c("white", "#da5F49"))) + 
    theme_classic() +                                                              
    theme(axis.ticks = element_blank(), 
          legend.text = element_text(size = 30)) +
    scale_x_discrete(limits = rev, labels = c(" ", " ", " ", " ", " "))  
  
  
  
  # Setup dummy data
  df <- rbind(data.frame(x = 1:3, y = 1, A = c(0, 0.5, 1), B = NA, C = NA, D = NA),
              data.frame(x = 1:3, y = 2, A = NA, B = c(0, 0.5, 1), C = NA, D = NA),
              data.frame(x = 1:3, y = 3, A = NA, B = NA, C = c(0, 0.5, 1), D = NA),
              data.frame(x = 1:3, y = 4, A = NA, B = NA, C = NA, D = c(0, 0.5, 1)))
  
  ggplot(df, aes(x, y)) +
    geom_raster(aes(fill1 = A)) +
    geom_raster(aes(fill2 = B)) +
    geom_raster(aes(fill3 = C)) +
    geom_raster(aes(fill4 = D)) +
    scale_fill_multi(aesthetics = c("fill1", "fill2", "fill3", "fill4"),
                     colours = list(c("white", "#69B5A2"),
                                    c("white", "#FF9E4A"),
                                    c("white", "#4C75B3"),
                                    c("white", "#da5F49")),
                     values = NULL, labels = NULL, minor_breaks = NULL, position = 'right') + 
    coord_fixed()
  
  
  
  
  
}




