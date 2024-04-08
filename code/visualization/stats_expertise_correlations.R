
# Tentative correlation between univariate activation in the [BW > SBW] contrast
# and expertise in years of practice

# Peak activation 
zscore <- c(5.09, 5.23, NA, 3.50, 4.23, 5.39)

# Cluster size
cluster <- c(113, 92, NA, 7, 37, 79)

# DICE overlap
dice <- c(51, 44, NA, 8, 34, 53)

# Expertise in years
years <- c(13, 1, 2, 5, 21, 5)

# Expertise in Words-per-minute (our reading list)
wpm <- c(23, 8, 11, 6, 10, 15)

# Correlations: each expertise measure with each univariate result
corr_wpm_zscore = cor.test(wpm, zscore)
corr_wpm_cluster = cor.test(wpm, cluster)
corr_wpm_dice = cor.test(wpm, dice)
corr_years_zscore = cor.test(years, zscore)
corr_years_cluster = cor.test(years, cluster)
corr_years_dice = cor.test(years, dice)
