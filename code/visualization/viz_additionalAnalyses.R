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
# * save Chi2 as csv result ~

# Figures:
# TBD
# Statistical analyses:
# TBD
  
  
# Pixel RDM
# make matrices of pixel distance, from information for each stimulus
stats_pixel_RDM <- function() {
  
  # Load the tsv
  data <- read.delim("../stats/reports/stimuli_pixel_information.tsv", header = TRUE, sep = "\t")
  
  # Ensure the pixels column is treated as a character vector
  data$pixels <- as.character(data$pixels)
  
  # Convert 'pixels' column from string to numeric vector
  data$pixels <- lapply(data$pixels, function(x) as.numeric(strsplit(x, ",")[[1]]))
  
  # Check the structure of the data
  str(data)
  
  # Ensure the pixels column is in the correct format (numeric vectors)
  pixels_matrix <- do.call(rbind, data$pixels)  # Combine the list of numeric vectors into a matrix
  
  # Combine 'class' and 'stimulus' into a unique identifier for each pair
  data$class_stimulus <- paste(data$class, data$stimulus, sep = "_")
  
  # Now create a unique combination of 'class' and 'stimulus'
  unique_combinations <- unique(data$class_stimulus)
  
  # Initialize empty distance matrices
  corr_matrix <- matrix(NA, nrow = length(unique_combinations), ncol = length(unique_combinations))
  eucl_matrix <- matrix(NA, nrow = length(unique_combinations), ncol = length(unique_combinations))
  
  rownames(distance_matrix) <- unique_combinations
  colnames(distance_matrix) <- unique_combinations
  
  
  ## 1 - correlation 
  
  # Calculate the distance matrix based on correlation for each combination of 'class' and 'stimulus'
  for (i in 1:length(unique_combinations)) {
    for (j in i:length(unique_combinations)) {
      # Get the pixel vectors for the i-th and j-th combinations
      i_pixels <- pixels_matrix[data$class_stimulus == unique_combinations[i], ]
      j_pixels <- pixels_matrix[data$class_stimulus == unique_combinations[j], ]
      
      # Calculate correlation between the pixel vectors
      if (length(i_pixels) > 0 & length(j_pixels) > 0) {
        correlation <- cor(i_pixels, j_pixels)  # Correlation between pixel vectors
        corr_matrix[i, j] <- 1 - correlation  # Convert correlation to distance
        corr_matrix[j, i] <- corr_matrix[i, j]  # Symmetric distance matrix
      }
    }
  }
  
  # View the resulting distance matrix
  print(corr_matrix)
  

  ## Euclidean distance
  
  # Calculate the distance matrix based on Euclidean distance for each combination of 'class' and 'stimulus'
  for (i in 1:length(unique_combinations)) {
    for (j in i:length(unique_combinations)) {
      # Get the pixel vectors for the i-th and j-th combinations
      i_pixels <- data$pixels[[which(data$class_stimulus == unique_combinations[i])]]
      j_pixels <- data$pixels[[which(data$class_stimulus == unique_combinations[j])]]
      
      # Compute the Euclidean distance (sum of squared differences)
      euclidean_distance <- sqrt(sum((i_pixels - j_pixels)^2))
      
      # Store the distance in the matrix
      eucl_matrix[i, j] <- euclidean_distance
      eucl_matrix[j, i] <- euclidean_distance  # Symmetric distance matrix
    }
  }
  
  # View the resulting distance matrix
  print(eucl_matrix)
  
  # literal difference (-) of arrays?
  
  
}
  
# Braille sensitivity
# differences in univariate activation for BW and SBW (localizer stimuli) 
# in different areas
# With and without eye movements
stats_eyeMovements <- function() {
  
  # Load report
  eye <- read.csv("../stats/reports/braille_sensitivity_tmaps_eyeMovements.txt")
  
  # cast as dataframe
  eye <- as.data.frame(eye)
  
  # modify subject column to only keep number
  eye$subject <- as.numeric(gsub('sub-0*', '', eye$subject))
  
  # rename activation field to avoid confusion 
  eye$activation <- eye$mean_activation
  eye <- subset(eye, select = -c(5))
  
  # Add number of decoding pair, to place the horizontal lines 
  eye$contrast <- t(repmat(c(1,2), 1,nrow(eye)/2))
  
  # cluster group and condition together, for viz
  eye$cluster <- ifelse(eye$contrast == 1, 
                        ifelse(eye$group == "expert", "EI", "CI"),
                        ifelse(eye$group == "expert", "ES", "CS"))
  
  # calculate stats for error bars
  stats_eye <- eye %>% group_by(group, area, cluster, condition, contrast) %>% 
    summarize(mean_activation = mean(activation), sd_activation = sd(activation), se_activation = sd(activation)/sqrt(6),
              .groups = 'keep') 
  
  stats_eye[order(stats_eye$group, decreasing = TRUE), ]
  
  
  # Plot bars 
  # - with subject labels 
  ggplot(stats_eye, 
         aes(x = cluster, y = mean_activation, fill = cluster, color = group)) + 
    geom_col(aes(x = cluster, y = mean_activation), 
             position = "dodge", 
             size = 1) +
    geom_errorbar(aes(ymin = mean_activation - se_activation, ymax = mean_activation + se_activation), 
                  width = 0, color = "black") +
    scale_fill_manual(values = c("CI" = "#da5F49", "CS" = "#FFFFFF", "EI" = "#FF9E4A", "ES" = "#FFFFFF"), 
                      labels = c("controls - braille", 
                                 "controls - scrambled", 
                                 "experts - braille", 
                                 "experts - scrambled")) +
    scale_color_manual(values = c("control" = "#da5F49", "expert" = "#FF9E4A"), 
                       guide = "none") +
    
    # Individual data clouds
    geom_point(data = eye, aes(x = cluster,  y = activation), position = position_jitter(w = 0.3, h = 0.01),
               color = "#999999", 
               alpha = 0.4) +
    theme_classic() +               
    theme(axis.text.x = element_text(size = 12, family = "Avenir", color = "black"), 
          axis.text.y = element_text(size = 12, family = "Avenir", color = "black"), 
          axis.ticks = element_blank(),
          axis.title.x = element_text(size = 12, family = "Avenir", color = "black", vjust = 0), 
          axis.title.y = element_text(size = 12, family = "Avenir", color = "black", vjust = 0),
          legend.position = "none") +
    facet_grid(~factor(area, levels = c("VWFA", "lLO", "rLO", "V1", "lPosTemp")), 
               labeller = label_value) +
    scale_x_discrete(labels = "") +
    labs(x = "Area", y = "Univariate activation")
  
  ggsave("../../outputs/derivatives/figures/braille-selectivity_group-all_area-all_plot-eyeMovements.png", width = 3000, height = 1800, dpi = 500, units = "px")
  
  # Create subsets based on group and area
  tests_eye <- split(eye, list(eye$group, eye$area, eye$condition))
  
  # Initialize an empty dataframe to store t-test results
  t_test_results <- data.frame(
    group1 = character(), group2 = character(), stat = numeric(), p_value = numeric(), df = numeric())
  
  for (iGroup in c(1:10)) {
    
    group1 <- tests_eye[[iGroup]]$activation
    group2 <- tests_eye[[iGroup+10]]$activation
    
    t_result <- t.test(group1, group2, paired = TRUE)
    
    t_test_results <- rbind(t_test_results, data.frame(
      group1 = paste(unique(tests_eye[[iGroup]]$group), 
                     unique(tests_eye[[iGroup]]$area), 
                     unique(tests_eye[[iGroup]]$condition), sep="_"),
      group2 = paste(unique(tests_eye[[iGroup+10]]$group), 
                     unique(tests_eye[[iGroup+10]]$area), 
                     unique(tests_eye[[iGroup+10]]$condition), sep="_"),
      stat = t_result$statistic,
      p_value = t_result$p.value,
      df = t_result$parameter[[1]]
    ))
  }
  
  t_test_results$pvalFDR <- p.adjust(t_test_results$p_value, "fdr")
  
  t_test_results <- data.frame(lapply(t_test_results, as.character), stringsAsFactors = F)
  
  write.csv(t_test_results, '../../outputs/derivatives/results/braille-selectivity_group-all_area-all_analysis-eyeMovements-ttests.csv', row.names = F)
}
  

stats_brailleSensitivity <- function() {
  
  # Load report
  braille <- read.csv("../stats/reports/braille_sensitivity_tmaps.txt")
  
  # cast as dataframe
  braille <- as.data.frame(braille)
  
  # modify subject column to only keep number
  braille$subject <- as.numeric(gsub('sub-0*', '', braille$subject))
  
  # rename activation field to avoid confusion 
  braille$activation <- braille$mean_activation
  braille <- subset(braille, select = -c(5))
  
  # Add number of decoding pair, to place the horizontal lines 
  braille$contrast <- t(repmat(c(1,2), 1,nrow(braille)/2))
  
  # cluster group and condition together, for viz
  braille$cluster <- ifelse(braille$contrast == 1, 
                            ifelse(braille$group == "expert", "EI", "CI"),
                            ifelse(braille$group == "expert", "ES", "CS"))
  
  # calculate stats for error bars
  stats_braille <- braille %>% group_by(group, area, cluster, condition, contrast) %>% 
    summarize(mean_activation = mean(activation), sd_activation = sd(activation), se_activation = sd(activation)/sqrt(6),
              .groups = 'keep') 
  
  stats_braille[order(stats_braille$group, decreasing = TRUE), ]
  
  
  # Plot bars 
  # - with subject labels 
  ggplot(stats_braille, 
         aes(x = cluster, y = mean_activation, fill = cluster, color = group)) + 
    geom_col(aes(x = cluster, y = mean_activation), 
             position = "dodge", 
             size = 1) +
    geom_errorbar(aes(ymin = mean_activation - se_activation, ymax = mean_activation + se_activation), 
                  width = 0, color = "black") +
    scale_fill_manual(values = c("CI" = "#da5F49", "CS" = "#FFFFFF", "EI" = "#FF9E4A", "ES" = "#FFFFFF"), 
                      labels = c("controls - braille", 
                                 "controls - scrambled", 
                                 "experts - braille", 
                                 "experts - scrambled")) +
    scale_color_manual(values = c("control" = "#da5F49", "expert" = "#FF9E4A"), 
                       guide = "none") +
    
    # Individual data clouds
    geom_point(data = eye, aes(x = cluster,  y = activation), position = position_jitter(w = 0.3, h = 0.01),
               color = "#999999", 
               alpha = 0.4) +
    theme_classic() +               
    theme(axis.text.x = element_text(size = 12, family = "Avenir", color = "black"), 
          axis.text.y = element_text(size = 12, family = "Avenir", color = "black"), 
          axis.ticks = element_blank(),
          axis.title.x = element_text(size = 12, family = "Avenir", color = "black", vjust = 0), 
          axis.title.y = element_text(size = 12, family = "Avenir", color = "black", vjust = 0),
          legend.position = "none") +
    facet_grid(~factor(area, levels = c("VWFA", "lLO", "rLO", "V1", "lPosTemp")), 
               labeller = label_value) +
    scale_x_discrete(labels = "") +
    labs(x = "Area", y = "Univariate activation")
  
  ggsave("../../outputs/derivatives/figures/braille-selectivity_group-all_area-all_plot-bw-contrast.png", width = 3000, height = 1800, dpi = 500, units = "px")
  
  # Create subsets based on group and area
  tests_braille <- split(braille, list(braille$group, braille$area, braille$condition))
  
  # Initialize an empty dataframe to store t-test results
  t_test_results <- data.frame(
    group1 = character(), group2 = character(), stat = numeric(), p_value = numeric(), df = numeric())
  
  for (iGroup in c(1:10)) {
    
    group1 <- tests_braille[[iGroup]]$activation
    group2 <- tests_braille[[iGroup+10]]$activation
    
    t_result <- t.test(group1, group2, paired = TRUE)
    
    t_test_results <- rbind(t_test_results, data.frame(
      group1 = paste(unique(tests_braille[[iGroup]]$group), 
                     unique(tests_braille[[iGroup]]$area), 
                     unique(tests_braille[[iGroup]]$condition), sep="_"),
      group2 = paste(unique(tests_braille[[iGroup+10]]$group), 
                     unique(tests_braille[[iGroup+10]]$area), 
                     unique(tests_braille[[iGroup+10]]$condition), sep="_"),
      stat = t_result$statistic,
      p_value = t_result$p.value,
      df = t_result$parameter[[1]]
    ))
  }
  
  # Adjust p-values for false detection rate
  t_test_results$pvalFDR <- p.adjust(t_test_results$p_value, "fdr")
  
  # Save table in outputs
  t_test_results <- data.frame(lapply(t_test_results, as.character), stringsAsFactors = F)
  
  write.csv(t_test_results, '../../outputs/derivatives/results/braille-selectivity_group-all_area-all_analysis-univariate-ttests.csv', row.names = F)
}  

# Behavioural analysis
# responses to MVPA task - correct answers, missed targets, false detections
# stats_behaviouralResponses()
  
  
# Comparison between groups in terms of Braille activation
# Chi-square test on the number of subjects in each group that present VWFA 
# activation for Braille
stats_groupsDifference <- function() {
    
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
  
  # - cross-decoding
  make_legend_square(tab = mockTable, 
                     lim = c("braille_experts"),
                     lab = c("Average cross-decoding"), 
                     val = c("#8B70CA"), 
                     savename = "../../outputs/derivatives/figures/plot-legend_group-cross_order-just-avg_shape-squares.png")
  
  
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
  
  # - cross-decoding
  make_legend_circle(tab = mockTable, 
                     lim = c("braille_experts"),
                     lab = c("Average cross-decoding"), 
                     val = c("#8B70CA"), 
                     savename = "../../outputs/derivatives/figures/plot-legend_group-cross_order-just-avg_shape-circles.png")
  
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
  




