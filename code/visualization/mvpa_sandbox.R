# create vectors with your own data. 
# 17/02 - copy-pasted from MATLAB

sub <- c('mean','sub-006','sub-007','sub-008','sub-009','sub-012','sub-013')
area <- c('VWFAfr','VWFAfr','VWFAfr','VWFAfr','VWFAfr','VWFAfr','VWFAfr')
tmap_decoding <- c(0.7037, 0.7569, 0.6806, 0.7222, 0.6875, 0.6319, 0.7431)
beta_decoding <- c(0.7257, 0.7917, 0.7500, 0.7153, 0.7153, 0.6181, 0.7639)

ggplot(data.frame(beta_decoding, tmap_decoding), aes(x = as.factor(c(1,2)), y = 1, fill = as.factor(4), color = as.factor(4)))+
    geom_boxplot(alpha = 0.3, color = "black", outlier.shape = NA)
  
# plotDecodingScores <- ggplot(decodingScores, aes(, meanAccuracy))
p <- ggplot(mpg, aes(class, hwy))
p + geom_boxplot()
p + geom_boxplot(outlier.shape = NA) + geom_jitter(aes(class, displ), width = 0.2)


q <- ggplot(mpg, aes(class, displ))
q + geom_jitter(width = 0.2)


# combine vectors into a list
data <- list(beta_decoding, tmap_decoding)

# create a boxplot of the data