
# Add all necessary libraries
source("viz_supportFunctions.R")

# Load file
v1 <- dataset_import('pairwise', 'within', 'all', 'IXI549Space', 'earlyVisual')
loca <- dataset_import('pairwise', 'within', 'all', 'IXI549Space', 'expansion')
postemp <- dataset_import('pairwise', 'within', 'all', 'IXI549Space', 'language')


# Call extraction for all the data
v1 <- rearrange_table(v1, 'V1')
vwfa <- rearrange_table(loca, 'VWFA')
llo <- rearrange_table(loca, 'lLO')
rlo <- rearrange_table(loca, 'rLO')
postemp <- rearrange_table(postemp, 'PosTemp')

# Save all the data
write.csv(v1, '../mvpa/mvpa_stats/mvpa_area-V1_desc-jasp-compatible.csv', row.names = FALSE)
write.csv(vwfa, '../mvpa/mvpa_stats/mvpa_area-VWFA_desc-jasp-compatible.csv', row.names = FALSE)
write.csv(llo, '../mvpa/mvpa_stats/mvpa_area-lLO_desc-jasp-compatible.csv', row.names = FALSE)
write.csv(rlo, '../mvpa/mvpa_stats/mvpa_area-rLO_desc-jasp-compatible.csv', row.names = FALSE)
write.csv(postemp, '../mvpa/mvpa_stats/mvpa_area-PosTemp_desc-jasp-compatible.csv', row.names = FALSE)




rearrange_table <- function(tableIn, area) {
  
  # Clean file: remove unnecessary lines, add information about group and script
  tableIn <- dataset_clean(tableIn)
  
  # In the case of expansion, separate three ROIs
  if(area == 'VWFA' || area == 'lLO' || area == 'rLO')
    tableIn <- tableIn %>% filter(mask == area)
  
  # remove group indication
  tableIn$decodingCondition <- gsub("_exp|_ctr", "", tableIn$decodingCondition)
  
  # Get subset of relevant columns
  tableIn <- tableIn[c("subID", "accuracy", "decodingCondition")]
  
  # Pivot table to make JASP happy
  tableOut <- pivot_wider(tableIn, names_from = decodingCondition, values_from = accuracy)
  
  # Add group column
  tableOut <- tableOut %>% mutate(Group = ifelse(subID %in% c(6, 7, 8, 9, 12, 13), "experts", "novices"))
  
  # Reorder the columns to have the new column in the second position
  tableOut <- tableOut %>% select(subID, Group, everything())
  
  rearrange_table <- tableOut
  
  
}
