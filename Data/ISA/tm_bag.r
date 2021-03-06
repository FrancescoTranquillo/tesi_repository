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
library(tm)
library(pbapply)
# library(pROC)
rm(list=ls())
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
  .[-which(grepl("inseri|verifica|ordinaria", x = .$Descrizione,ignore.case = T)),c(22,24)] %>% 
  .[which(complete.cases(.)),] %>%
  unique(.)

coswin$Data.Richiesta <- dmy_hm(coswin$Data.Richiesta) %>% 
  as_date()

coswin$Data.Richiesta[2]

#aggiunta colonna dei giorni nella tabella di scontrini
df <- df %>%
  mutate("GIORNO" = as_date(.$INIZIO.CICLO))

#aggiunta della colonna CHIAMATA nella tabella degli scontrini
#l'istanza avrà CHIAMATA = 1 se il giorno corrisponde ad una delle date in coswin

#aggiunta della bag-label
df <- df %>%
  mutate("CHIAMATA" = factor(ifelse(.$GIORNO %in% coswin$Data.Richiesta, 1, 0)))
# "BAG"=factor(cut.Date(df$GIORNO, breaks = "5 days",labels = F)))
table(df$CHIAMATA)


ignore_columns <- c("TEST.DI.TENUTA","NUMERO.CICLO",
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
  as.list(seq(from=giorno,to =giorno-9,by = -1))
}

giorni_predittivi <- sapply(giorni_guasti, backprop)

# assegno flag=1 in corrispondenza dei giorni predittivi
df%<>%mutate(flag=ifelse(as.Date(df$GIORNO)%in%giorni_predittivi,1,0))

# trainIndex_pos <- sample(length(df_pos_bag)*0.75,replace = F)
# trainIndex_neg <- sample(length(df_neg_bag)*0.75,replace = F)


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

# # divido in train e test ####
# trainIndex_pos <- sample(length(df_pos_bag)*0.75,replace = F)
# trainIndex_neg <- sample(length(df_neg_bag)*0.75,replace = F)
# 
# train_pos <- df_pos_bag[trainIndex_pos]
# train_neg <- df_neg_bag[trainIndex_neg]
# train <- c(train_pos, train_neg)
# 
# test_pos <- df_pos_bag[-trainIndex_pos]
# test_neg <- df_neg_bag[-trainIndex_neg]
# test <- c(test_pos, test_neg)
# 
# #shuffling finale
# train <- sample(train, length(train), replace = T)
# test <- sample(test, length(test),replace=T)

bags <- c(df_pos_bag,df_neg_bag)


clean_corpus <- function(corpus) {
  corpus <- tm_map(corpus, stripWhitespace)
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, content_transformer(tolower))
  corpus <- tm_map(corpus, removeNumbers)
  # corpus <- tm_map(corpus, stemDocument)
}

testo_corpus <- VCorpus(VectorSource(df$testo))
testo_corpus_clean<-clean_corpus(testo_corpus)
testo_dtm<- DocumentTermMatrix(testo_corpus_clean)
testo_dict <- findFreqTerms(testo_dtm, lowfreq = 1)

# trasformo ogni bag 
meta <- function(bag){
  bag_text <- bag$INSTANCES$testo
  bag_corpus <- VCorpus(VectorSource(bag_text)) %>% 
    clean_corpus(.)
  bag_dtm <- as.data.frame(as.matrix(DocumentTermMatrix(bag_corpus,
                                          control=list(dictionary=testo_dict,
                                                       weighting = function(x) weightTfIdf(x, normalize = FALSE)))))
  tfidf <- summarise_all(bag_dtm,mean,na.rm=T)
    cbind("TARGET"=bag$BAG_FLAG,tfidf)
 
}


df_meta <- pblapply(bags,meta) %>% do.call("rbind",.)

# unify <- function(bag){
#   bag_text <- bag$INSTANCES$testo %>% 
#     paste(.,collapse="|")
#   data.frame("testo"=bag_text,
#                 "flag"=bag$BAG_FLAG)
# }
# 
# tm <- lapply(c(df_pos_bag,df_neg_bag), unify) %>% 
#   do.call("rbind",.) %>% 
#   .[sample(nrow(.)),]

trainIndex <- createDataPartition(df_meta$TARGET, p = .75,
                                  list = FALSE,
                                  times = 1)
tm_training <- df_meta[ trainIndex,]
tm_testing <-  df_meta[-trainIndex,]

# descr_corpus_train <- VCorpus(VectorSource(tm_training$testo))
# descr_train_labels <- factor(tm_training$flag)
# descr_corpus_clean_train<-clean_corpus(descr_corpus_train)
# descr_dtm_train <- as.matrix(DocumentTermMatrix(descr_corpus_clean_train,
#                                                 control=list(weighting = function(x) weightTfIdf(x, normalize = FALSE))))
# 
# descr_corpus_test <- VCorpus(VectorSource(tm_testing$testo))
# descr_test_labels <- factor(tm_testing$flag)
# descr_corpus_clean_test<-clean_corpus(descr_corpus_test)
# descr_dtm_test <- as.matrix(DocumentTermMatrix(descr_corpus_clean_test,
#                                                control=list(weighting = function(x) weightTfIdf(x, normalize = FALSE))))
# 
# train.df <- data.frame(descr_dtm_train[,intersect(colnames(descr_dtm_train), colnames(descr_dtm_test))])
# test.df <- data.frame(descr_dtm_test[,intersect(colnames(descr_dtm_test), colnames(descr_dtm_train))])

tm_training$TARGET<- factor(tm_training$TARGET)
tm_testing$TARGET <-factor( tm_testing$TARGET)

levels(tm_training$TARGET) <- c("neg", "pos")
levels(tm_testing$TARGET) <- c("neg", "pos")

table(tm_training$TARGET)

fitControl <- trainControl(method = "repeatedcv", 
                           number = 10,
                           repeats = 2,
                           verboseIter=T,
                           classProbs = TRUE,
                           allowParallel = T,
                           sampling = "down"
                           # summaryFunction = twoClassSummary
)

model_weights <- ifelse(tm_training$TARGET == "pos",
                        (1/table(tm_training$TARGET)[1]) * 0.5,
                        (1/table(tm_training$TARGET)[2]) * 0.5)



set.seed(1045)
nn <-
  train(TARGET~., 
        data=tm_training,
        method = 'naive_bayes',
        trControl = fitControl,
        tuneLength=5,
        # # maxit=200,
        preProcess=c("medianImpute","pca","nzv")
          # weights = model_weights
  )


#internal test, non conta
predictions <- predict(nn,newdata =tm_testing)
confusionMatrix(predictions, tm_testing$TARGET, positive = "pos",mode = "sens_spec")
nn

# saveRDS(nn, here("tm_bag_xgbTree.rds"))
# saveRDS(nn, here("tm_bag_svmLinear.rds"))
# saveRDS(nn, here("tm_bag_naivebayes.rds"))
# saveRDS(nn, here("tm_bag_ada.rds"))
# saveRDS(nn, here("tm_bag_adaboost.rds"))
# saveRDS(nn, here("tm_bag_gbm.rds"))
# 
# #trasformo il test in un unico dataframe aggiungendo la variabile bag_flag
# test_df <- pblapply(test,meta) %>% do.call("rbind",.)
# 
# bag_index <- test_df$BAG
# # 
# # 
# # test_pp <- cbind(test_pp_pre[,(n-2):n],test_pp_pre_1)
# # # df_meta_pp[,-which(names(df_meta_pp)%in%"TARGET")] <- factor(df_meta_pp[,-which(names(df_meta_pp)%in%"TARGET")])
# # dummies <- dummyVars(~.,data = test_pp,fullRank = T)
# # # head(predict(dummies, newdata = df_meta_pp))
# # 
# # dummied <- as.data.frame(predict(dummies, newdata = test_pp))
# # test_df<- dummied
# # 
# # 
# # #scaling
# # test_df_no_nzv <- preProcess(test_df[ , c(1:2)],
# #                              method = c("range","medianImpute"))
# # test_df <- predict(test_df_no_nzv, newdata = test_df)
# 
# test_df$TARGET <- factor(test_df$TARGET)
# levels(test_df$TARGET) <- c("neg", "pos")
# 
# test_predictions <- predict(nn, newdata = test_df,type = "prob")
# test_df_predicted <- test_df %>%
#   mutate(.,
#          # "prediction"=predict(gbm.smote, newdata = test_df),
#          # "predictions_pos"=test_predictions[,1],
#          #  "predictions_neg"=test_predictions[,2],
#          "BAG"=bag_index,
#          "bag_prediction_pos"=test_predictions[,2]) %>% 
#   .[,which(names(.) %in% c("BAG_FLAG","bag_prediction_pos","BAG"))]
# 
# 
# 
# test_list <- as.list(split(test_df_predicted,f = test_df_predicted$BAG))
# 
# 
# df <- lapply(test_list, function(element){
#   if(nrow(element)>0){ 
#     predicted <- factor(ifelse(max(element$bag_prediction_pos)>.65,"pos","neg"))
#     actual <- element$BAG_FLAG[1]
#     data.frame(predicted,actual)
#     
#   } })%>% do.call("rbind",.)
# 
# df$predicted <- fct_rev(df$predicted)
# levels(df$actual)
# 
# confusionMatrix(
#   df$predicted,
#   df$actual,
#   mode = "sens_spec",
#   positive = "pos"
# ) 
# 

