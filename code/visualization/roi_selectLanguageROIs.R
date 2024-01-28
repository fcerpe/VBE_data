

# Add all necessary libraries
library("readxl")
library("tidyverse")
library("reshape2")
library("gridExtra")
library("pracma")
library("dplyr")
library("data.table")


cosmoFolder <- "../rois/reports/roi_reports_languageROIs_voxThres-80_09-Jan-2024.txt"

dfOut <- read.csv(cosmoFolder)
dfOut <- as.data.frame(dfOut)

dfOut <- dfOut %>% filter(enough == 1)
dfOut$cluster <- paste(dfOut$hemi, dfOut$area, sep="_")
result <- dfOut %>% count(cluster)


lang <- dfOut %>% group_by(hemi, area) %>% 
  summarize(amount = count(area),
            .groups = 'keep') 