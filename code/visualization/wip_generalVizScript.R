setwd("~/Desktop/GitHub/VisualBraille_data/code/visualization")

library("readxl")
library("tidyverse")
library("reshape2")
library("gridExtra")
library("pracma")
library("dplyr")

### Load files



# MVPA Result
mvpaData <- read.csv()

# Univariate Report 
univariateData <- read.csv("../stats/univariateReport_vwfa.txt")