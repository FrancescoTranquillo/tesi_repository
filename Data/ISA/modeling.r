library(tidyverse)
library(dplyr)
library(lubridate)
library(here)
library(readxl)
library(caret)
library(DataExplorer)

df_backed <-
  read.csv2(file = "CHIAMATA-4-ISACOS.csv",
            header = T,
            stringsAsFactors = T)

#rimuovo colonne delle date e colonne inutili come: test di tenuta,
#prelevato da, numero ciclo, inizio ciclo, giorno, chiamata

df_backed <- df_backed[,-c(47,48,2,53,45)]

#conversione multipla delle feature da int a fattori
cols = c(39:87, 2)
df_backed[,cols] %<>% lapply(function(x) fct_explicit_na(as.character(x)))
View(names(df_backed))

plot_missing(df_backed)
plot_histogram(df_backed)

data <- data[,-c(6:36)]
create_report(data)
# pre processing

#one-hot encoding 
dummies <- dummyVars(~.,data = df_backed)
head(predict(dummies, newdata = df_backed))

dummied <- as.data.frame(predict(dummies, newdata = df_backed))
df_backed <- dummied

#scaling
pp_df_no_nzv <- preProcess(df_backed[ , -which(names(df_backed) %in% "TARGET")],
           method = c("range", "nzv","medianImpute" ))

pp_df_no_nzv
data <- predict(pp_df_no_nzv, newdata = df_backed[,-which(names(df_backed) %in% "TARGET")])


data$TARGET <- factor(df_backed$TARGET)
levels(data$TARGET) <- c("neg", "pos")
df_backed$TARGET <- factor(df_backed$TARGET)
levels(df_backed$TARGET) <- c("neg", "pos")
#data splitting
trainIndex <- createDataPartition(data$TARGET, p = .8, 
                                  list = FALSE, 
                                  times = 1)
training <- data[ trainIndex,]
testing <-  data[-trainIndex,]

set.seed(9560)
down_train <- downSample(x = data[, -which(names(df_backed) %in% "TARGET")],
                         y = data$TARGET)
down_train <- down_train[,-63]
table(down_train$TARGET)  



mod0 <- train(TARGET ~ ., data = training,
              method = "svmLinear",
              na.action = na.pass,
              trControl = trainControl( verboseIter = T))
saveRDS(mod0, "model0.rds")
my_model <- readRDS("model.rds")
predictions <- predict(mod0, testing)
confusionMatrix(predictions, testing$TARGET,mode = "everything",positive = "pos")
