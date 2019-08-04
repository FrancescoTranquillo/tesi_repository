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
library(mltools)
# library(pROC)
rm(list=ls())
# Lo script unisce la tabella degli scontrini a quella di coswin, 
# aggiungendo le colonne chiamata e chiamata-x dove x sono i giorni precedenti
# all'effettiva chiamata

#importa tabella degli scontrinia

df <-
  read.csv2(file = "tabella_scontrini_allarmi.csv",
            header = T,
            stringsAsFactors = F,encoding = "UTF-8")

#conversione date e factors

n <- ncol(df)
df[,c(2,4:(n-2))] %<>% lapply(function(x) factor(x))

df$INIZIO.CICLO <-
  parse_date_time(df$INIZIO.CICLO, orders = "dmy HMS")

coswin <- read.csv2(file = "coswin-isa/108841.csv",
                    header = T,
                    stringsAsFactors = F) %>% 
  .[-which(grepl("inseri|verifica|ordinaria", x = .$Descrizione,ignore.case = T)),c(22,24)] %>% 
  .[which(complete.cases(.)),] %>%
  unique(.)

coswin$Data.Richiesta <- dmy_hm(coswin$Data.Richiesta) %>% 
  as_date()

#aggiunta colonna dei giorni nella tabella di scontrini
df <- df %>%
  mutate("GIORNO" = as_date(.$INIZIO.CICLO))

#aggiunta della colonna CHIAMATA nella tabella degli scontrini
#l'istanza avrà CHIAMATA = 1 se il giorno corrisponde ad una delle date in coswin

#aggiunta della bag-label
df <- df %>%
  mutate("CHIAMATA" = factor(ifelse(.$GIORNO %in% coswin$Data.Richiesta, 1, 0)))
table(df$CHIAMATA)


ignore_columns <- c("TEST.DI.TENUTA","NUMERO.CICLO",
                    "INIZIO.CICLO")
df <- df[,-which(names(df) %in% ignore_columns)]

#trovo i giorni in cui ci sono state chiamate a coswin
giorni_guasti <- unique(df[which(df$CHIAMATA==1),which(colnames(df)=="GIORNO")])

#trovo le date dei 5 giorni precedenti ad ognuno dei giorni appena trovati
# attraverso la funzione backprop

# BACKPRO -----------------------------------------------------------------


backprop <- function(giorno){
  as.list(seq(from=giorno,to =giorno-6,by = -1))
}
# ------------------------------------------------------------------------
giorni_predittivi <- sapply(giorni_guasti, backprop)

# assegno flag=1 in corrispondenza dei giorni predittivi
df%<>%mutate(flag=ifelse(as.Date(df$GIORNO)%in%giorni_predittivi,1,0))

DF <- data.frame(testo=df$testo, giorno=df$GIORNO,flag=df$flag)

table(DF$flag)

clean_corpus <- function(corpus) {
  corpus <- tm_map(corpus, stripWhitespace)
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, content_transformer(tolower))
  corpus <- tm_map(corpus, removeNumbers)
  corpus <- tm_map(corpus, stemDocument)
}

meta_train <- function(bag) {
  
    bag_text <- bag$INSTANCES$testo
    bag_corpus <- VCorpus(VectorSource(bag_text)) %>%
      clean_corpus(.)
    bag_dtm <- as.data.frame(as.matrix(DocumentTermMatrix(
      bag_corpus,
      control = list(dictionary = DF_testo_dict,
                     weighting = function(x) weightTf(x)))))
    if(bag$INSTANCES$BAG_FLAG==1){
      tfidf <- summarise_all(bag_dtm, mean, na.rm = T)
      cbind("TARGET" = bag$BAG_FLAG, tfidf)
    } else{
      cbind("TARGET" = bag$BAG_FLAG, bag_dtm)
    }
  
  
}
meta_test <- function(bag) {
  
  bag_text <- bag$INSTANCES$testo
  bag_corpus <- VCorpus(VectorSource(bag_text)) %>%
    clean_corpus(.)
  bag_dtm <- as.data.frame(as.matrix(DocumentTermMatrix(
    bag_corpus,
    control = list(dictionary = DF_testo_dict,
                   weighting = function(x) weightTfIdf(x)))))
  
    tfidf <- summarise_all(bag_dtm, mean, na.rm = T)
    cbind("TARGET" = bag$BAG_FLAG, tfidf)
}

DF$testo <- iconv(DF$testo,"UTF-8", "UTF-8",sub='')
DF_testo_corpus <- VCorpus(VectorSource(DF$testo))
DF_testo_corpus_clean<-clean_corpus(DF_testo_corpus)

DF_testo_dict <- findFreqTerms(DocumentTermMatrix(DF_testo_corpus_clean))
# DF_testo_dtm<- as.data.frame(as.matrix(DocumentTermMatrix(DF_testo_corpus_clean,
                                                          # control = list(dictionary=DF_testo_dict,
                                                                           # weighting = function(x) weightTfIdf(x,normalize = T)))))
write.table(DF_testo_dict, file="DF_dizionario_scontrini.txt",row.names = F)
trainIndex <- createDataPartition(DF$flag, p = .97,
                                  list = FALSE,
                                  times = 1)

# DF <- cbind(DF,DF_testo_dtm)

DF_training <- DF[trainIndex,]
DF_test <- DF[-trainIndex,]

table(DF_test$flag)

DF_training %<>% mutate("BAG"=factor(cut.Date(.$giorno, breaks = "8 days",labels = F)))
DF_test%<>% mutate("BAG"=factor(cut.Date(.$giorno, breaks = "1 days",labels = F)))


#se una bag contiene almeno un flag=1, allora la sua etichetta sarà positiva
DF_train_bag_flag <- DF_training %>% 
  group_by(BAG) %>% 
  mutate("BAG_FLAG"=ifelse(1%in%flag,yes = 1,no = 0)) %>% 
  ungroup()

DF_test_bag_flag <- DF_test %>% 
  group_by(BAG) %>% 
  mutate("BAG_FLAG"=ifelse(1%in%flag, 1,0)) %>% 
  ungroup()


#divisione in lista per applicarci il meta
BAGS_training<-split(DF_train_bag_flag, f = DF_training$BAG) %>% 
  pblapply(.,function(list){
    list("INSTANCES"=list,
         "BAG_FLAG"=list[names(list)]$BAG_FLAG[1])})

BAGS_test <- split(DF_test_bag_flag, f=DF_test$BAG) %>% 
  pblapply(.,function(list){
    list("INSTANCES"=list,
         "BAG_FLAG"=list[names(list)]$BAG_FLAG[1])
  })


#eseguo meta
DF_train<- pblapply(BAGS_training,meta_train) %>% 
  do.call("rbind",.) %>% 
  .[sample(nrow(.)),]

DF_test <- pblapply(BAGS_test,meta_test) %>% 
  do.call("rbind",.) %>% 
  .[sample(nrow(.)),]


DF_train$TARGET <-  factor(DF_train$TARGET)
levels(DF_training$TARGET) <- c("neg", "pos")

DF_test$TARGET <-  factor(DF_test$TARGET)
levels(DF_test$TARGET) <- c("neg", "pos")

trainIndex <- createDataPartition(DF_train$TARGET, p = 1,
                                  list = FALSE,
                                  times = 1)
tm_training <- DF_train[ trainIndex,]
tm_testing <-  DF_train[-trainIndex,]

tm_training$TARGET<- factor(tm_training$TARGET)
tm_testing$TARGET <-factor( tm_testing$TARGET)

levels(tm_training$TARGET) <- c("neg", "pos")
levels(tm_testing$TARGET) <- c("neg", "pos")

table(tm_training$TARGET)
table(DF_test$TARGET)


set.seed(1045)
# library(doParallel)
# cl <- makeCluster(16)
# registerDoParallel(cl)
fitControl <- trainControl(method = "repeatedcv", 
                           number = 10,
                           repeats = 3,
                           verboseIter=T,
                           classProbs = TRUE,
                           allowParallel = T,
                           sampling = "down"
)

model_maker <- function(nome_modello, nome_algoritmo, nome_file){
  
  model_object<-
    train(TARGET~., 
          data=tm_training,
          method = nome_algoritmo,
          trControl = fitControl,
          tuneLength=3,
          preProcess=c("range","nzv")
    )
  nome_modello <- model_object
  filename <- paste0(nome_file,"_",nome_algoritmo, ".rds")
  saveRDS(model_object, here::here(filename))
  message("model saved!")
  return(nome_modello)
}

modelli <- mapply(model_maker,
                  c("Neural Network","Bayesian Generalized Linear Model", "Naive Bayes", "Logistic Regression", "Support Vector Machine Linear" ), 
                  c("nnet","bayesglm","naive_bayes","glm","svmLinear3"),
                  c("mm2", "mm2", "mm2", "mm2", "mm2"),
                  SIMPLIFY=FALSE)


modelli <- lapply(as.list(list.files(here::here(),"mm2_*")),read_rds)


l_predictions <- lapply(modelli, function(modello) predict(modello, DF_test))


matrici <- lapply(l_predictions, function(predizioni) confusionMatrix(predizioni, DF_test$TARGET, "pos", mode = "everything"))

nomi_modelli <- lapply(modelli,
                       function(modello) data.frame("Model name"=modello[["modelInfo"]][["label"]])) %>% 
  
  do.call("rbind", .)

performance <- lapply(l_predictions,
                      function(predizioni) {
                        cm <- confusionMatrix(predizioni,
                                              DF_test$TARGET,
                                              "pos",
                                              mode = "everything")
                        performance <-
                          tibble(
                            "Accuracy" = round(cm[["overall"]][["Accuracy"]], 2),
                            "Sensitivity" = round(cm$byClass[1], 2),
                            "Specificity" = round(cm$byClass[2], 2),
                            "Precision" = round(cm$byClass[5], 2),
                            "MCC" = round(mcc(preds = predizioni,DF_test$TARGET),2)
                          )
                        
                        return(performance)
                      }) %>%
  do.call("rbind", .)


tabella_performance <- cbind(nomi_modelli,performance)
tabella_performance
results <- resamples(modelli)
summary(results)
# boxplots of results
bwplot(results)
# # dot plots of results
dotplot(results)
# parallelplot(results)
# splom(results)
densityplot(results,pch = "|",auto.key = list(columns = 2))
# 
# 
# predictions <- predict(nn,newdata =DF_test)
# confusionMatrix(predictions,DF_test$TARGET, positive = "pos",mode = "everything") 
# 
# library(mltools)
# mcc(preds = predictions, df_meta_test$TARGET)
# 
# #linux
# # modelli <- lapply(as.list(list.files(here(),"linux")),read_rds)
# modelli <- lapply(as.list(list.files(here(),"mm_*")),read_rds)
# l_predictions <- lapply(modelli, function(modello) predict(modello, DF_test))
# 
# round(mcc(l_predictions[[1]],df_meta_test$TARGET),2)
# 
a <- confusionMatrix(l_predictions[[1]], DF_test$TARGET, "pos",mode="everything")
a
# 
# nomi_modelli <- lapply(modelli,
#                        function(modello) data.frame("Model name"=modello[["modelInfo"]][["label"]])) %>% 
#   
#   do.call("rbind",.)
# 
# performance <- lapply(l_predictions, 
#                       function(predizioni){
#                         cm <- confusionMatrix(predizioni, 
#                                               DF_test$TARGET,
#                                               "pos",
#                                               mode="everything")
#                         performance <-
#                           tibble(
#                             "Accuracy" = round(cm[["overall"]][["Accuracy"]], 2),
#                             "Sensitivity" = round(cm$byClass[1], 2),
#                             "Specificity" = round(cm$byClass[2], 2),
#                             "Precision" = round(cm$byClass[5], 2),
#                             "Recall" = round(cm$byClass[6], 2))
#                         return(performance)}) %>% 
#   do.call("rbind",.)
# 
# 
# tabella_performance <- cbind(nomi_modelli,performance)
# tabella_performance
# # write.csv(tabella_performance, here("reduced_tabella_performance_modelli.csv"),fileEncoding = "UTF8",row.names = F)
# 
# #linux
# # write.csv(tabella_performance, here("linux_tabella_performance_modelli.csv"),fileEncoding = "UTF8",row.names = F)

