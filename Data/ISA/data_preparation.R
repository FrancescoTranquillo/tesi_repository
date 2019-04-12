library(tidyverse)
library(dplyr)
library(lubridate)
library(here)
library(ggplot2)
library(readxl)
library(caret)
library(magrittr)
library(devtools)
library(NeuralNetTools)

source_url('https://gist.githubusercontent.com/fawda123/7471137/raw/466c1474d0a505ff044412703516c34f1a4684a5/nnet_plot_update.r')

#importa tabella degli scontrini

df <-
  read.csv2(file = "tabella_scontrini.csv",
            header = T,
            stringsAsFactors = F)

#conversione date e factors
df$INIZIO.CICLO <-
  parse_date_time(df$INIZIO.CICLO, orders = "dmy hms")
df$CICLO.REGOLARE <-
  factor(df$CICLO.REGOLARE)
df$TIPO.CICLO <- factor(df$TIPO.CICLO)

#quanto tempo passa tra un ciclo irregolare e l'altro? ####
df_irregolari <- df[which(df$CICLO.REGOLARE == "0"),]

col1 <- seq(1, 548, by = 2)
time1 <- df_irregolari[col1,]

time2 <- df_irregolari[-col1,]

timediff <-
  difftime(time2$INIZIO.CICLO, time1$INIZIO.CICLO, units = "days")
summary(as.numeric(timediff))
hist(as.numeric(timediff), main = "Distribuzione delle differenze temporali tra cicli irregolari\n in giorni")
table(as.numeric(timediff))
difftime(time2[274, 1], time1[274, 1])

timetable <- data.frame(
  "t1" = time1$INIZIO.CICLO,
  "t2" = time2$INIZIO.CICLO,
  "timediff" = timediff
) %>% .[order(.$timediff, decreasing = T), ]
head(timetable)
summary(as.numeric(timediff))

#caricamento coswin ####
coswin <- read.csv2(file = "coswin-isa/108841.csv",
                    header = T,
                    stringsAsFactors = F) %>%
  .[, 24] %>%
  as.character(.) %>%
  dmy_hm(.) %>%
  as_date(.) %>%
  .[which(complete.cases(.))] %>%
  unique(.)


#aggiunta colonna dei giorni nella tabella di scontrini
df <- df %>%
  mutate("GIORNO" = as_date(.$INIZIO.CICLO))

#aggiunta della colonna CHIAMATA nella tabella degli scontrini
#l'istanza avrà CHIAMATA = 1 se il giorno corrisponde ad una delle date in coswin

df <- df %>%
  mutate("CHIAMATA" = factor(ifelse(.$GIORNO %in% coswin, 1, 0)))

table(df$CHIAMATA)


#forte class imbalance


#scrivo una funzione che data la tabella degli scontrini (!), crea la variabile CHIAMATA-X con X uguale
#al numero di giorni che precedono una chiamata.
#ad esempio per una predizione di 3 giorni, assegno CHIAMATA-3 = 1 anche ai 3 giorni precedenti
#all'effettiva chiamata.
back_assign <- function(table, x) {
  df_ch_1 <- unique(table$GIORNO[which(table$CHIAMATA == 1)])
  a <-
    sapply(
      X = df_ch_1,
      FUN = function(date)
        format(date - days(1:x), format = "%Y-%m-%d"),
      simplify = T
    )
  
  col_name <<- paste0("CHIAMATA-", x)
  df_backed <-
    table %>% mutate(., !!col_name := factor(ifelse(.$GIORNO %in% as.Date(a), 1, 0)))
  table(df_backed$col_name)
  
  return(df_backed)
}

#predizione a X giorni
df_backed <- back_assign(df, 4)
#riordino le colonne in ordine alfabetico per conversione multipla
df_backed<-df_backed[,order(colnames(df_backed),decreasing=TRUE)]

#rimuovo colonne delle date e colonne inutili
View(names(df_backed))
df_backed <- df_backed[,-c(46,47,2,53,44,38)]
View(names(df_backed))
glimpse(df_backed)

#conversione multipla
cols = c(37:86, 2)
df_backed[,cols] %<>% lapply(function(x) fct_explicit_na(as.character(x)))
View(names(df_backed))

#data splitting
trainIndex <- createDataPartition(df_backed$`CHIAMATA-4`, p = .8, 
                                  list = FALSE, 
                                  times = 1)
training <- df_backed[ trainIndex,]
testing <-  df_backed[-trainIndex,]

names(training)[names(training) == "CHIAMATA-4"] <- "TARGET"
names(testing)[names(testing) == "CHIAMATA-4"] <- "TARGET"
y = training$TARGET
Y=testing$TARGET
#one hot encoding
dummies_model <- dummyVars(TARGET ~ ., data=training,sep = "_")
trainData_mat <- predict(dummies_model, newdata = training)
trainData <- data.frame(trainData_mat)

preProcess_range_model <- preProcess(trainData, method=c('range','medianImpute'))
trainData <- predict(preProcess_range_model, newdata = trainData)

training <- trainData
training$TARGET <- y

dummies_model_test <- dummyVars(TARGET~., data=testing)
testData_mat <- predict(dummies_model_test, newdata=testing)
testData <- data.frame(testData_mat)

preProcess_range_model_test <- preProcess(testData, method=c('range','medianImpute'))
testData <- predict(preProcess_range_model_test, newdata = testData)
testing <- testData
testing$TARGET <- Y


fitControl <- trainControl(
  method = 'cv',                   # k-fold cross validation
  number = 5,                      # number of folds
  savePredictions = 'final',       # saves predictions for optimal tuning parameter
  classProbs = F,                  # should class probabilities be returned
  summaryFunction=twoClassSummary  # results summary function
) 

nnet <- train(TARGET ~ .,data=training,
  method = "nnet",
  trControl=fitControl,
  tuneLength= 5

)

predictions <- predict(nb,newdata = testing)
confusionMatrix(reference = testing$TARGET, data = predictions, mode='everything')

varimp_nnet <- varImp(nnet)
plot(varimp_nnet, main="Variable Importance with NNET",top = 10)

svm <- train(TARGET ~ .,data=training,
              method = "svmRadial"
              
)
varimp_svm <- varImp(svm)
plot(varimp_svm, main="Variable Importance with SVM",top = 10)
plot(svm)

nb <- train(TARGET ~ .,data=training,
            method = "bayesglm",
            trControl=trainControl(verboseIter=T)
)
plot(nb)

models_compare <- resamples(list(NNET=nnet,
                                 SVM=svm,
                                 NaiveBayes_GLM=nb))
summary(models_compare)
# Draw box plots to compare models
scales <- list(x=list(relation="free"), y=list(relation="free"))
bwplot(models_compare, scales=scales)
