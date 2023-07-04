
setwd("~/Desktop/GitHub/VisualBraille_data/code/stats")

library("readxl")
library("tidyverse")
library("reshape2")
library("gridExtra")

# Read the table containing experts' VWFA coordinates
coordinates <- as.data.frame(read_excel("experts_vwfa_coordinates.xlsx"))



# Split according to the contrast used 
contrast_division <- group_split(coordinates, Area)
vwfa_fr <- contrast_division[[2]]
vwfa_br <- contrast_division[[1]]

# make some order
vwfa_fr <- subset(vwfa_fr, select = -c(1, 2))
vwfa_br <- subset(vwfa_br, select = -c(1, 2))

# Run t-test on the sets of coordinates
ttest_x <- t.test(vwfa_fr$X, vwfa_br$X)
ttest_y <- t.test(vwfa_fr$Y, vwfa_br$Y)
ttest_z <- t.test(vwfa_fr$Z, vwfa_br$Z)
