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
# * check for overlap with previous dataset cleanings
# * improve modularity
# * save Chi2 as csv result 

# Figures:
# TBD
# Statistical analyses:
# TBD
  
  
# Low-level RDM
# make matrices of pixel distance, from information for each stimulus
stats_pixel_RDMs <- function() {
  
  # Load the csv files 
  br_number <- read.csv('../stats/reports/rdm_number_braille.csv', header = F)
  fr_number <- read.csv('../stats/reports/rdm_number_french.csv', header = F)
  br_position <- read.csv('../stats/reports/rdm_position_braille.csv', header = F)
  fr_position <- read.csv('../stats/reports/rdm_position_french.csv', header = F)
  
  labels <- c('RW1', 'RW2', 'RW3', 'RW4', 'RW5', 'RW6', 'RW7', 'RW8', 'RW9', 'RW10', 'RW11', 'RW12',
              'PW1', 'PW2', 'PW3', 'PW4', 'PW5', 'PW6', 'PW7', 'PW8', 'PW9', 'PW10', 'PW11', 'PW12', 
              'NW1', 'NW2', 'NW3', 'NW4', 'NW5', 'NW6', 'NW7', 'NW8', 'NW9', 'NW10', 'NW11', 'NW12',
              'FS1', 'FS2', 'FS3', 'FS4', 'FS5', 'FS6', 'FS7', 'FS8', 'FS9', 'FS10', 'FS11', 'FS12')
  
  # Call plotting for each matrix
  # Pure RDM, no outlines to cluster stimuli 
  build_stimulus_RDM(br_number, labels, "#de3d03", "braille - number of white pixels", FALSE)
  ggsave('../../outputs/derivatives/figures/RSA/rdm_number_braille_outlines-false.png', width = 1700, height = 1700, dpi = 300, units = "px")
  
  build_stimulus_RDM(fr_number, labels, "#0C8F5A", "french - number of white pixels", FALSE)
  ggsave('../../outputs/derivatives/figures/RSA/rdm_number_french_outlines-false.png', width = 1700, height = 1700, dpi = 300, units = "px")
  
  build_stimulus_RDM(br_position, labels, "#de3d03", "braille - overlap difference", FALSE)
  ggsave('../../outputs/derivatives/figures/RSA/rdm_position_braille_outlines-false.png', width = 1700, height = 1700, dpi = 300, units = "px")
  
  build_stimulus_RDM(fr_position, labels, "#0C8F5A", "french - overlap difference", FALSE)
  ggsave('../../outputs/derivatives/figures/RSA/rdm_position_french_outlines-false.png', width = 1700, height = 1700, dpi = 300, units = "px")
  
  # With outlines
  build_stimulus_RDM(br_number, labels, "#de3d03", "braille - number of white pixels", TRUE)
  ggsave('../../outputs/derivatives/figures/RSA/rdm_number_braille_outlines-true.png', width = 1700, height = 1700, dpi = 300, units = "px")
  
  build_stimulus_RDM(fr_number, labels, "#0C8F5A", "french - number of white pixels", TRUE)
  ggsave('../../outputs/derivatives/figures/RSA/rdm_number_french_outlines-true.png', width = 1700, height = 1700, dpi = 300, units = "px")
  
  build_stimulus_RDM(br_position, labels, "#de3d03", "braille - overlap difference", TRUE)
  ggsave('../../outputs/derivatives/figures/RSA/rdm_position_braille_outlines-true.png', width = 1700, height = 1700, dpi = 300, units = "px")
  
  build_stimulus_RDM(fr_position, labels, "#0C8F5A", "french - overlap difference", TRUE)
  ggsave('../../outputs/derivatives/figures/RSA/rdm_position_french_outlines-true.png', width = 1700, height = 1700, dpi = 300, units = "px")
  
  
  ## Average matrices per condition
  br_num_average <- average_conditions(br_number)
  fr_num_average <- average_conditions(fr_number)
  br_pos_average <- average_conditions(br_position)
  fr_pos_average <- average_conditions(fr_position)
  
  labels <- c('RW', 'PW', 'NW', 'FS')
  
  build_lowlevel_RDM(br_num_average, labels, "#de3d03", "braille - number of white pixels (average)")
  ggsave('../../outputs/derivatives/figures/RSA/rdm_number_average_braille.png', width = 1700, height = 1700, dpi = 300, units = "px")
  
  build_lowlevel_RDM(fr_num_average, labels, "#0C8F5A", "french - number of white pixels (average)")
  ggsave('../../outputs/derivatives/figures/RSA/rdm_number_average_french.png', width = 1700, height = 1700, dpi = 300, units = "px")
  
  build_lowlevel_RDM(br_pos_average, labels, "#de3d03", "braille - overlap difference (average)")
  ggsave('../../outputs/derivatives/figures/RSA/rdm_position_average_braille.png', width = 1700, height = 1700, dpi = 300, units = "px")
  
  build_lowlevel_RDM(fr_pos_average, labels, "#0C8F5A", "french - overlap difference (average)")
  ggsave('../../outputs/derivatives/figures/RSA/rdm_position_average_french.png', width = 1700, height = 1700, dpi = 300, units = "px")
  
  ## Correlate visual models and linguistic one
  mlang <- c(1,2,3,1,2,1)
  mlatin <- c(fr_pos_average[2],fr_pos_average[3],fr_pos_average[4],fr_pos_average[7],fr_pos_average[8],fr_pos_average[12])
  mbraille <- c(br_pos_average[2],br_pos_average[3],br_pos_average[4],br_pos_average[7],br_pos_average[8],br_pos_average[12])

  # collect in a list
  models <- list(array1 = mlang, array2 = mlatin, array3 = mbraille)
  
  # Get all pairwise combinations
  combinations <- combn(names(models), 2, simplify = FALSE)
  
  # Compute correlations and p-values
  results <- data.frame(Model1 = character(), Model2 = character(), Correlation = numeric(), P_value = numeric(), stringsAsFactors = FALSE)
  
  for (pair in combinations) {
    test <- cor.test(models[[pair[1]]], models[[pair[2]]])
    
    results <- rbind(results, data.frame(
      Model1 = pair[1],
      Model2 = pair[2],
      Correlation = test$estimate,
      P_value = test$p.value
    ))
  }
  
}

stats_strokes_rdm <- function() {
  
  ### Individual number of strokes 
  
  br_strokes <- read.csv('../stats/reports/rdm_strokes_braille.csv', header = F)
  fr_strokes <- read.csv('../stats/reports/rdm_strokes_french.csv', header = F)
  
  labels <- c('RW1', 'RW2', 'RW3', 'RW4', 'RW5', 'RW6', 'RW7', 'RW8', 'RW9', 'RW10', 'RW11', 'RW12',
              'PW1', 'PW2', 'PW3', 'PW4', 'PW5', 'PW6', 'PW7', 'PW8', 'PW9', 'PW10', 'PW11', 'PW12', 
              'NW1', 'NW2', 'NW3', 'NW4', 'NW5', 'NW6', 'NW7', 'NW8', 'NW9', 'NW10', 'NW11', 'NW12',
              'FS1', 'FS2', 'FS3', 'FS4', 'FS5', 'FS6', 'FS7', 'FS8', 'FS9', 'FS10', 'FS11', 'FS12')
  
  build_stimulus_RDM(br_strokes, labels, "#de3d03", "braille - number of dots", FALSE)
  ggsave('../../outputs/derivatives/figures/RSA/rdm_strokes_braille.png', width = 1700, height = 1700, dpi = 300, units = "px")
  
  build_stimulus_RDM(fr_strokes, labels, "#0C8F5A", "french - number of strokes", FALSE)
  ggsave('../../outputs/derivatives/figures/RSA/rdm_strokes_french.png', width = 1700, height = 1700, dpi = 300, units = "px")
  
  ## Average matrices per condition
  br_str_average <- average_conditions(br_strokes)
  fr_str_average <- average_conditions(fr_strokes)
  
  labels <- c('RW', 'PW', 'NW', 'FS')
  
  build_lowlevel_RDM(br_str_average, labels, "#de3d03", "braille - number of dots (average)")
  ggsave('../../outputs/derivatives/figures/RSA/rdm_strokes_average_braille.png', width = 1700, height = 1700, dpi = 300, units = "px")
  
  build_lowlevel_RDM(fr_str_average, labels, "#0C8F5A", "french - number of strokes (average)")
  ggsave('../../outputs/derivatives/figures/RSA/rdm_strokes_average_french.png', width = 1700, height = 1700, dpi = 300, units = "px")
  
  ## Correlate visual models and linguistic one
  mlang <- c(1,2,3,1,2,1)
  mlatin <- c(fr_str_average[2],fr_str_average[3],fr_str_average[4],fr_str_average[7],fr_str_average[8],fr_str_average[12])
  mbraille <- c(br_str_average[2],br_str_average[3],br_str_average[4],br_str_average[7],br_str_average[8],br_str_average[12])
  
  # collect in a list
  models <- list(array1 = mlang, array2 = mlatin, array3 = mbraille)
  
  # Get all pairwise combinations
  combinations <- combn(names(models), 2, simplify = FALSE)
  
  # Compute correlations and p-values
  results <- data.frame(Model1 = character(), Model2 = character(), Correlation = numeric(), P_value = numeric(), stringsAsFactors = FALSE)
  
  for (pair in combinations) {
    test <- cor.test(models[[pair[1]]], models[[pair[2]]])
    
    results <- rbind(results, data.frame(
      Model1 = pair[1],
      Model2 = pair[2],
      Correlation = test$estimate,
      P_value = test$p.value
    ))
  }

  
  ### Average number of strokes 
  
  br_avgstroke <- read.csv('../stats/reports/rdm_avgstroke_braille.csv', header = F)
  fr_avgstroke <- read.csv('../stats/reports/rdm_avgstroke_french.csv', header = F)
  
  labels <- c('RW', 'PW', 'NW', 'FS')
  
  build_lowlevel_RDM(br_strokes, labels, "#de3d03", "braille - number of strokes (average)")
  ggsave('../../outputs/derivatives/figures/RSA/rdm_average-stroke_braille.png', width = 1700, height = 1700, dpi = 300, units = "px")
  
  build_lowlevel_RDM(fr_strokes, labels, "#0C8F5A", "french - number of strokes (average)")
  ggsave('../../outputs/derivatives/figures/RSA/rdm_average-stroke_french.png', width = 1700, height = 1700, dpi = 300, units = "px")

  ## Correlate visual models and linguistic one
  mlang <- c(1,2,3,1,2,1)
  mStrLatin <- c(fr_strokes$V1[2],fr_strokes$V1[3],fr_strokes$V1[4],fr_strokes$V2[3],fr_strokes$V2[4],fr_strokes$V3[4])
  mStrBraille <- c(br_strokes$V1[2],br_strokes$V1[3],br_strokes$V1[4],br_strokes$V2[3],br_strokes$V2[4],br_strokes$V3[4])
  
  # collect in a list
  models <- list(array1 = mlang, array2 = mStrLatin, array3 = mStrBraille)
  
  # Get all pairwise combinations
  combinations <- combn(names(models), 2, simplify = FALSE)
  
  # Compute correlations and p-values
  avgresults <- data.frame(Model1 = character(), Model2 = character(), Correlation = numeric(), P_value = numeric(), stringsAsFactors = FALSE)
  
  for (pair in combinations) {
    test <- cor.test(models[[pair[1]]], models[[pair[2]]])
    
    avgresults <- rbind(results, data.frame(
      Model1 = pair[1],
      Model2 = pair[2],
      Correlation = test$estimate,
      P_value = test$p.value
    ))
  }
  
}

  
# t-test to compare within-modality decoding in l-PosTemp and in VWFA
stats_decoding_comparison <- function() {
  
  # Load and clean files 
  vwfa <- dataset_import("pairwise", "within", "all", "IXI549Space", "expansion")
  vwfa <- dataset_clean(vwfa)
  vwfa <- vwfa %>% filter(mask == "VWFA")
  
  postemp <- dataset_import("pairwise", "within", "all", "IXI549Space", "language")
  postemp <- dataset_clean(postemp)
  
  
  # Compute averages 
  vwfaAvg <- vwfa %>% group_by(subID, group, script, cluster) %>% 
                      summarize(mean_accu = mean(accuracy), sd_accu = sd(accuracy), se_accu = sd(accuracy)/sqrt(6), .groups = 'keep') 
  postempAvg <- postemp %>% group_by(subID, group, script, cluster) %>% 
                            summarize(mean_accu = mean(accuracy), sd_accu = sd(accuracy), se_accu = sd(accuracy)/sqrt(6), .groups = 'keep') 
  
  
  # Cluster the values for script and group 
  vwfaEF <- vwfaAvg %>% filter(cluster == "french_experts")
  vwfaEB <- vwfaAvg %>% filter(cluster == "braille_experts")
  vwfaCF <- vwfaAvg %>% filter(cluster == "french_controls")
  vwfaCB <- vwfaAvg %>% filter(cluster == "braille_controls")
  
  postempEF <- postempAvg %>% filter(cluster == "french_experts")
  postempEB <- postempAvg %>% filter(cluster == "braille_experts")
  postempCF <- postempAvg %>% filter(cluster == "french_controls")
  postempCB <- postempAvg %>% filter(cluster == "braille_controls")
  
  
  # Prepare table to store t-tests
  tests_table <- data.table(g1name = character(), g1accuracy = numeric(), 
                            g2name = character(), g2accuracy = numeric(), 
                            ttest = numeric(), cohen = numeric(), df = numeric(), pvalUncorr = numeric())
  
  
  # Get correlations 
  result <- compare_accuracies(vwfaEF$cluster[1], vwfaEF$mean_accu, postempEF$cluster[1], postempEF$mean_accu, NA, FALSE)
  tests_table <- rbind(tests_table, result)
  
  result <- compare_accuracies(vwfaEB$cluster[1], vwfaEB$mean_accu, postempEB$cluster[1], postempEB$mean_accu, NA, FALSE)
  tests_table <- rbind(tests_table, result)
  
  result <- compare_accuracies(vwfaCF$cluster[1], vwfaCF$mean_accu, postempCF$cluster[1], postempCF$mean_accu, NA, FALSE)
  tests_table <- rbind(tests_table, result)
  
  result <- compare_accuracies(vwfaCB$cluster[1], vwfaCB$mean_accu, postempCB$cluster[1], postempCB$mean_accu, NA, FALSE)
  tests_table <- rbind(tests_table, result)
  
  
  # Adjust p-values for false detection rate
  tests_table$pvalFDR <- p.adjust(tests_table$pvalUncorr, "fdr")
  
  # Save table in outputs
  savename <- "../../outputs/derivatives/results/MVPA/decoding-pairwise_modality-within_group-all_space-IXI549Space_areas-vwfa-postemp_stats-ttest-comparison.csv"
  
  tests_table <- data.frame(lapply(tests_table, as.character), stringsAsFactors = F)
  write.csv(tests_table, "", row.names = F)
  
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
# responses to MVPA task - correct answers, missed targets, false detections.
# Plots only control group and percentage of correct answers, as asked by reviewer
stats_behaviouralResponses <- function() {

  # Load report
  beh <- read.csv("../stats/reports/behaviouralReport.txt")
  
  ### Manipulate the matrix to get something readable by ggplot
  beh <- as.data.frame(beh)
  
  # Correct names of stimuli for real words
  beh <- beh %>% mutate(trial_type = ifelse(trial_type %in% c("frw_liv", "frw_nli", "frw_mix"), "frw", trial_type))
  beh <- beh %>% mutate(trial_type = ifelse(trial_type %in% c("brw_liv", "brw_nli", "brw_mix"), "brw", trial_type))
  
  # add cluster information
  beh <- beh %>% mutate(cluster = ifelse(subject %in% c("sub-006", "sub-009", "sub-012"), 
                                         ifelse(trial_type %in% c("frw","fpw","fnw","ffs"), 
                                                "french_expert", "braille_expert"),
                                         ifelse(trial_type %in% c("frw","fpw","fnw","ffs"), 
                                                "french_control", "braille_control")))
  # specify group in trial_type
  beh$trial_type <- ifelse(beh$subject %in% c("sub-006","sub-009","sub-012"),
                           paste(beh$trial_type,"_exp",sep=""), 
                           paste(beh$trial_type,"_ctr",sep=""))
  
  
  ## delete experts, keep only controls 
  beh <- beh %>% filter(!cluster %in% c("french_expert","braille_expert"))
  
  # response as facotr, to be counted
  beh$response_type <- as.factor(beh$response_type)
  
  # subejcts as number, to ease printing in barplot
  beh$subject <- as.numeric(gsub('sub-0*', '', beh$subject))
  
  # summarize behavioural responses: for each sub / stim, how many correct, miss, fp?
  counts_beh <- beh %>% group_by(subject, trial_type, cluster, .drop = FALSE) %>% count(response_type)
  
  stats_beh <- counts_beh %>% group_by(trial_type, response_type, cluster) %>% summarize(mean_resp = mean(n), .groups = 'keep')  
  
  ## Calculate responses as percentage of correct answers (ignore False Positives)
  result <- counts_beh %>% filter(response_type %in% c("correct", "miss")) %>%
    group_by(subject, trial_type, cluster) %>% 
    summarise(correct_count = sum(n[response_type == "correct"]),
              miss_count = sum(n[response_type == "miss"]),
              percentage = (correct_count / (correct_count + miss_count)) * 100
    ) %>%
    select(subject, trial_type, cluster, percentage)
  
  # Filter out sub-009, partial data
  percentages_beh <- result %>% filter(subject != "9")
  
  stats_percent <- percentages_beh %>% group_by(trial_type, cluster) %>% 
    summarize(mean_resp = mean(percentage), sd_resp = sd(percentage), .groups = 'keep')  
  
  ## Plot percentage of correct answers 
  ggplot(data = stats_percent, aes(x = trial_type, y = mean_resp)) + 
    geom_col(aes(x = trial_type, y = mean_resp, fill = cluster), alpha = 0.7) +
    scale_fill_manual(name = "Script",
                      values = c("#da5F49", "#699ae5"),
                      labels = c("braille alphabet", "latin alphabet"),
                      aesthetics = c("colour", "fill")) +
    geom_point(data = percentages_beh, aes(x = trial_type, y = percentage, colour = cluster),
               position = position_jitter(w = 0.3, h = 0.01, seed = NA), alpha = 0.8, na.rm = FALSE) +
    geom_errorbar(aes(ymin = mean_resp - sd_resp, ymax = mean_resp + sd_resp), width = 0, color = "black") +
    theme_classic() +                                                              
    theme(axis.ticks = element_blank()) +
    scale_x_discrete(limits=rev, labels = c("FRW","FPW","FNW","FFS","BRW","BPW","BNW","BFS")) +
    labs(x = "Stimulus condition", y = "Average correct responses (%)", title = "Percentage correct answers")      
  
  ggsave("../../outputs/derivatives/figures/beh-percentages.png", width = 3000, height = 1800, dpi = 320, units = "px")
  
}
  
  
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
  

# Function to extract 4x4 blocks and calculate their averages
average_conditions <- function(mat) {
  
  # Set fixed block size
  size <- 12
  n <- nrow(mat)
  
  # Initiate matrix with averages
  averages <- matrix(NA, nrow = n / size, ncol = n / size)
  
  # Extract blocks and compute averages
  row_idx <- 1
  for (i in seq(1, n, by = size)) {
    col_idx <- 1
    for (j in seq(1, n, by = size)) {
      block <- mat[i:(i + size - 1), j:(j + size - 1)]
      averages[row_idx, col_idx] <- (sum(block[,1]) + sum(block[,2]) + sum(block[,3]) + sum(block[,4]) + 
                                     sum(block[,5]) + sum(block[,6]) + sum(block[,7]) + sum(block[,8]) + 
                                     sum(block[,9]) + sum(block[,10]) + sum(block[,11]) + sum(block[,12]))/144
      col_idx <- col_idx + 1
    }
    row_idx <- row_idx + 1
  }
  return(averages)
}


