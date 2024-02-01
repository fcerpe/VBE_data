

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

print("calling works")