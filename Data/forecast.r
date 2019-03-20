#long short term memory neural network for abnormalities identification
#and prediction in time series

#load files
library(farff)
library(tidyverse)
library(caret)
library(ggplot2)
library(forecast)
train<-readARFF(path = "./Data/Wafer_TRAIN.arff")
test<-readARFF(path="./Data/Wafer_TEST.arff")

# Prepare training labels
labels = train$target

ggplot(train, aes(att1, att5))+geom_line()
head(train)
myts<-ts(train$att5,frequency = 17)
plot(myts)
# Seasonal decomposition
fit <- stl(myts, s.window="period")
plot(fit)
# additional plots
monthplot(myts)
library(forecast)
seasonplot(myts)
