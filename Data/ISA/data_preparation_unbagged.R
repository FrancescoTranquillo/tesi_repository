library(tidyverse)
library(dplyr)
library(lubridate)
library(here)
library(readxl)
library(magrittr)
library(DataExplorer)
library(caret)
library(rlist)
library(nnet)
library(NeuralNetTools)
library(esquisse)
# library(pROC)

# Lo script unisce la tabella degli scontrini a quella di coswin, 
# aggiungendo le colonne chiamata e chiamata-x dove x sono i giorni precedenti
# all'effettiva chiamata

#importa tabella degli scontrini

df <-
  read.csv2(file = "tabella_scontrini_allarmi.csv",
            header = T,
            stringsAsFactors = F)

#conversione date e factors

n <- ncol(df)
df[,c(2,4:(n-2))] %<>% lapply(function(x) factor(x))

df$INIZIO.CICLO <-
  parse_date_time(df$INIZIO.CICLO, orders = "dmy hms")

# esquisse::esquisser()
#quanto tempo passa tra un ciclo irregolare e l'altro? ####
# df_irregolari <- df[which(df$CICLO.REGOLARE == "0"),]
# 
# col1 <- seq(1, 548, by = 2)
# time1 <- df_irregolari[col1,]
# 
# time2 <- df_irregolari[-col1,]
# 
# timediff <-
#   difftime(time2$INIZIO.CICLO, time1$INIZIO.CICLO, units = "days")
# summary(as.numeric(timediff))
# hist(as.numeric(timediff), main = "Distribuzione delle differenze temporali tra cicli irregolari\n in giorni")
# table(as.numeric(timediff))
# difftime(time2[274, 1], time1[274, 1])
# 
# timetable <- data.frame(
#   "t1" = time1$INIZIO.CICLO,
#   "t2" = time2$INIZIO.CICLO,
#   "timediff" = timediff
# ) %>% .[order(.$timediff, decreasing = T), ]
# head(timetable)
# summary(as.numeric(timediff))

#caricamento coswin####
# vengono eliminate le righe corrispondenti a chiamate relative all'inserimento
# nel db della macchina di un nuovo strumento.
coswin <- read.csv2(file = "coswin-isa/108841.csv",
                    header = T,
                    stringsAsFactors = F) %>% 
  .[-which(grepl("inseri|verifica|ordinaria", x = .$Descrizione,ignore.case = T)),24] %>% 
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

# identifico colonne con un solo livello


#aggiunta della bag-label
df <- df %>%
  mutate("CHIAMATA" = factor(ifelse(.$GIORNO %in% coswin, 1, 0)))
# "BAG"=factor(cut.Date(df$GIORNO, breaks = "5 days",labels = F)))



ignore_columns <- c("testo","TEST.DI.TENUTA","NUMERO.CICLO",
                    "INIZIO.CICLO")
df <- df[,-which(names(df) %in% ignore_columns)]

#conversione multipla delle feature da int a fattori
# cols = c(38:86,88, 2)
# df[,cols] %<>% lapply(function(x) fct_explicit_na(as.character(x)))
# df%<>%.[,-c(3,6:37)]
# 
#trovo i giorni in cui ci sono state chiamate a coswin
giorni_guasti <- unique(df[which(df$CHIAMATA==1),which(colnames(df)=="GIORNO")])

#trovo le date dei 5 giorni precedenti ad ognuno dei giorni appena trovati
# attraverso la funzione backprop
backprop <- function(giorno){
  as.list(seq(from=giorno,to =giorno-9, by = -1))
}

giorni_predittivi <- sapply(giorni_guasti, backprop)

# assegno flag=1 in corrispondenza dei giorni predittivi
df%<>%mutate(flag=ifelse(as.Date(df$GIORNO)%in%giorni_predittivi,1,0))

df_pos <- df[which(df$flag==1),] %>% 
  mutate("BAG"=factor(cut.Date(.$GIORNO, breaks = "10 days",labels = F)))
df_pos_bag <- as.list(split(df_pos,f = df_pos$BAG))
#le righe con flag=1 sono le bag positive

#bag "negative", separate in bags da 5 giorni
df_neg <- df[-which(df$flag==1),] %>% 
  mutate("BAG"=factor(cut.Date(.$GIORNO, breaks = "10 days",labels = F)))
df_neg_bag <- as.list(split(df_neg,f = df_neg$BAG))

# assegno ad ogni elemento delle bag create il flag 1 o 0
df_pos_bag <- lapply(df_pos_bag,function(x) list("INSTANCES"=x,
                                   "BAG_FLAG"=1))

df_neg_bag <- lapply(df_neg_bag,function(x) list("INSTANCES"=x,
                                                 "BAG_FLAG"=0))


# divido in train e test
train_pos <- sample(df_pos_bag, length(df_pos_bag)*0.75,replace = F)
train_neg <- sample(df_neg_bag, length(df_neg_bag)*0.75,replace = F)
train <- c(train_pos, train_neg)

test_pos <- sample(df_pos_bag, length(df_pos_bag)*0.25,replace = F)
test_neg <- sample(df_neg_bag, length(df_neg_bag)*0.25,replace = F)
test <- c(test_pos, test_neg)

#shuffling finale
train <- sample(train, length(train), replace = T)
test <- sample(test, length(test),replace=T)

#trasformazione di train nel dataframe di learning ####

train <- lapply(train, function(x) {
  list("INSTANCES"=x$INSTANCES[,-which(names(x$INSTANCES) %in% c("BAG","CHIAMATA", "GIORNO"))],
       "BAG_FLAG"=x$BAG_FLAG)
  })

#ciclando sulle bags, se il flag è 0, tutte le istances diventano esempi,
#se il flag è 1, viene creato un metaesempio tramite la funzione meta.

#la funzione "meta" prende in ingresso un dataframe e riporta in uscita
# un unico vettore con lo stesso numero di colonne del dataframe iniziale
# ma con un'unica riga. Il vettore rappresenta una "media" di tutte le righe 
# presenti nel dataframe iniziale, diventando così un meta-esempio da inserire nel
# dataset di esempi. 
# Se la variabile è categorica, viene utilizzata la funzione freq_factor
# ed il meta-esempio assumerà in quella variabile il valore più frequente
# altrimenti, se la variabile è numerica, viene calcolata la media aritmetica
# Nel caso delle variabili di allarme, la funzione meta assegnerà al meta-esempio
# il valore 1 se almeno una delle instances presenta valore 1 nella corrispettiva
# colonna di allarme, 0 altrimenti.

freq_factor <- function(factor_column){
  tt <- table(factor_column)
  return(names(tt[which.max(tt)]))
}
unify_alarms <- function(alarm_column){
  ifelse(1 %in% alarm_column,return(levels(alarm_column)[1]),return(levels(alarm_column)[2]))
}
meta <- function(df_instances){
  temps_columns <- grep("temp\\.",names(df_instances))
  alarm_columns <- grep("allarm|alarm",names(df_instances),ignore.case = T)
  
  fct <- summarise_all(df_instances[,-c(temps_columns,alarm_columns)],funs(freq_factor(.)))
  temps <- summarise_all(df_instances[,temps_columns],mean,na.rm=T)
  alarms <- summarise_all(df_instances[,alarm_columns], funs(freq_factor(.)))
  TARGET <- 1
  return(cbind(fct,temps,alarms,TARGET))
}


df_meta <- lapply(train,FUN = function(bag){
  if(bag$BAG_FLAG==1){
    meta_example <- cbind(bag$INSTANCES,TARGET=1)
  } else{
    examples <- cbind(bag$INSTANCES, TARGET=0)
  }
}) %>% do.call("rbind",.)

df_meta_pp_pre <- df_meta[,-which(names(df_meta) %in% c("BAG","CHIAMATA", "GIORNO","flag"))]

# pre processing ####
#one-hot encoding
df_meta_pp_1 <- df_meta_pp_pre[, sapply(df_meta_pp_pre, nlevels) > 1]
n <- length(df_meta_pp_pre)
df_meta_pp <- cbind(df_meta_pp_pre[,(n-2):n],df_meta_pp_1)
# df_meta_pp[,-which(names(df_meta_pp)%in%"TARGET")] <- factor(df_meta_pp[,-which(names(df_meta_pp)%in%"TARGET")])
dummies <- dummyVars(~.,data = df_meta_pp,fullRank = T)
 # head(predict(dummies, newdata = df_meta_pp))

dummied <- as.data.frame(predict(dummies, newdata = df_meta_pp))
df_meta_pp <- dummied


#scaling
pp_df_no_nzv <- preProcess(df_meta_pp[ , c(1:2)],
                           method = c("range","medianImpute"))

pp_df_no_nzv
data <- predict(pp_df_no_nzv, newdata = df_meta_pp[,-which(names(df_meta_pp) %in% "TARGET")])


data$TARGET <- factor(df_meta_pp$TARGET)
levels(data$TARGET) <- c("neg", "pos")
df_meta_pp$TARGET <- factor(df_meta_pp$TARGET)
levels(df_meta_pp$TARGET) <- c("neg", "pos")


# data splitting
trainIndex <- createDataPartition(data$TARGET, p = .75,
                                  list = FALSE,
                                  times = 1)
training <- data[ trainIndex,]
testing <-  data[-trainIndex,]

model_weights <- ifelse(training$TARGET == "pos",
                        (1/table(training$TARGET)[1]) * 0.5,
                        (1/table(training$TARGET)[2]) * 0.5)

fitControl1 <- trainControl(method = "repeatedcv",
                            number = 10, repeats = 3,
              
                           classProbs = TRUE,
                           verboseIter=T,
                           allowParallel = T,
                            sampling="down"
                           # summaryFunction = twoClassSummary,
                          )
table(training$TARGET)
#training ####
mod1 <- train(TARGET ~ temp.1+temp.2+ALTRO.1,
              data = training,
              method = "xgbTree",
              # tuneLength = 10,
              
              # weigths=model_weights,
              trControl = fitControl1)
              # tuneGrid=expand.grid(size=3,decay=0.1))
             #  )


predictions <- predict(mod1,newdata = testing)
confusionMatrix(predictions,testing$TARGET,positive = "pos",
                mode = "everything")

# mod2 <- train(TARGET ~ ., data = training,
#               method = "xgbTree",
#               trControl = fitControl1,
#               # tuneGrid=expand.grid(size=3, decay=0.05),
#               # maxit=500,
#               weights = model_weights,
#               metric="ROC"
# )
# 
# 
# gbm.down <- train(TARGET ~.,
#               data = training,
#               method = "glm",
#               trControl = fitControl1
#               )
# xgbtree.smote <- train(TARGET ~.,
#                    data = training,
#                    method = "xgbTree",
#                    trControl = fitControl1
# )
# 
# nnet <- train(
#   TARGET ~ .,
#   data = training,
#   method = "nnet",
#   trControl = fitControl1,
#   tuneLength = 10
# )
# 
# nnetGrid <-  expand.grid(size = seq(from = 1, to = 10, by = 1),
#                          decay = seq(from = 0.1, to = 0.5, by = 0.1))
# nnet2 <- train(
#   TARGET ~ .,
#   data = training,
#   method = "nnet",
#   tuneLength = 10,
#   trControl=trainControl(verboseIter=T,method = "boot"),
#   tuneGrid = nnetGrid
# )
# 
# compare <- resamples(list("GradientBoosting"=gbm.nosample,
#                           "ExtremeGradientBoosting"=xgbtree.nosample,
#                           "GB.smote"=gbm.smote,
#                           "XGB.smote"=xgbtree.smote,
#                           "NN.downsampling"=nnet))
#  
# summary(compare)
# bwplot(compare)	
# 
#  predictions <- predict(nnet, testing)
# confusionMatrix(predictions, testing$TARGET,mode = "everything",positive = "pos")
# saveRDS(nnet, "nn-downsampling.rds")
# # saveRDS(mod1, "lsvm.rds")
# # saveRDS(mod3, "logreg.rds")
# # saveRDS(compare, "compare_models.rds")
# # 
# # nn <- readRDS(here("nn.rds"))
# # lsvm <- readRDS(here("lsvm.rds"))
# # logreg <- readRDS(here("logreg.rds"))
# # compare <- readRDS(here("compare_models.rds"))
#  densityplot(compare,metric = "ROC",auto.key = list(columns = 3))
# # 
# # scales <- list(x=list(relation="free"), y=list(relation="free"))
# # bwplot(compare, scales=scales)
# 
# 
# 
# 
# 
# 
# #valutazione con test set ####
# #preprocess del test set: il test set è una lista di bag. Ogni bag contiene
# # un dataframe di tante righe quanti sono gli scontrini in 5 giorni
# # più la variabile flag che indica se quella bag ha prodotto una
# # chiamata. Il test deve essere processato allo stesso modo fatto per
# # il training senza però trasformare le bag stesse. L'obiettivo
# # è quello di predire la variabile flag. Ogni riga del dataframe verrà predetta
# # la predizione complessiva sarà il valore della variabile flag.
# 
# #trasformo il test in un unico dataframe aggiungendo la variabile bag_flag
test_df <- lapply(test, function(bag){
  cbind(bag$INSTANCES,"BAG_FLAG"=bag$BAG_FLAG)
  }) %>% do.call("rbind",.)
 
 bag_index <- test_df$BAG
 
test_pp_pre <- test_df[,-which(names(test_df) %in% c("BAG","CHIAMATA", "GIORNO","flag"))]
 
test_pp_pre_1 <- test_pp_pre[, sapply(test_pp_pre, nlevels) > 1]
n <- length(test_pp_pre)

test_pp <- cbind(test_pp_pre[,(n-2):n],test_pp_pre_1)
 # df_meta_pp[,-which(names(df_meta_pp)%in%"TARGET")] <- factor(df_meta_pp[,-which(names(df_meta_pp)%in%"TARGET")])
 dummies <- dummyVars(~.,data = test_pp,fullRank = T)
 # head(predict(dummies, newdata = df_meta_pp))
 
 dummied <- as.data.frame(predict(dummies, newdata = test_pp))
 test_df<- dummied
 
 
 #scaling
 test_df_no_nzv <- preProcess(test_df[ , c(1:2)],
                            method = c("range","medianImpute"))
test_df <- predict(test_df_no_nzv, newdata = test_df)
 
 test_df$BAG_FLAG <- factor(test_df$BAG_FLAG)
 levels(test_df$BAG_FLAG) <- c("neg", "pos")

 test_predictions <- predict(mod1, newdata = test_df,type = "prob")
test_df_predicted <- test_df %>%
  mutate(.,
         # "prediction"=predict(gbm.smote, newdata = test_df),
         # "predictions_pos"=test_predictions[,1],
         #  "predictions_neg"=test_predictions[,2],
         "BAG"=bag_index,
         "bag_prediction_pos"=test_predictions[,2]) %>% 
  .[,which(names(.) %in% c("BAG_FLAG","bag_prediction_pos","BAG"))]
  


test_list <- as.list(split(test_df_predicted,f = test_df_predicted$BAG))


df <- lapply(test_list, function(element){
  if(nrow(element)>0){ 
  predicted <- factor(ifelse(max(element$bag_prediction_pos)>.92,"pos","neg"))
  actual <- element$BAG_FLAG[1]
  data.frame(predicted,actual)
  
  } })%>% do.call("rbind",.)

df$predicted <- fct_rev(df$predicted)



confusionMatrix(
  df$predicted,
  df$actual,
  mode = "everything",
  positive = "pos"
) 

plot(varImp(mod1))
summary(mod1)

plotnet(nnet$finalModel, y_names = "ScontrinoPredittivo")
title("Graphical Representation of our Neural Network")
