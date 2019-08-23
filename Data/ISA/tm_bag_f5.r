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

# BACKPRO -----------------------------------------------------------------


backprop <- function(giorno){
  as.list(seq(from=giorno,to =giorno-6,by = -1))
}
# ------------------------------------------------------------------------
giorni_predittivi <- sapply(giorni_guasti, backprop)

# assegno flag=1 in corrispondenza dei giorni predittivi
df%<>%mutate(flag=ifelse(as.Date(df$GIORNO)%in%giorni_predittivi,1,0))

clean_corpus <- function(corpus) {
  corpus <- tm_map(corpus, stripWhitespace)
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, content_transformer(tolower))
  corpus <- tm_map(corpus, removeNumbers)
  corpus <- tm_map(corpus, stemDocument)
}

meta <- function(bag) {
  bag_text <- bag$INSTANCES$testo
  bag_corpus <- VCorpus(VectorSource(bag_text)) %>%
    clean_corpus(.)
  bag_dtm <- as.data.frame(as.matrix(DocumentTermMatrix(
    bag_corpus,
    control = list(dictionary = testo_dict,
                     weighting = function(x) weightTfIdf(x))
  )))
  tfidf <- summarise_all(bag_dtm, max, na.rm = T)
  cbind("TARGET" = bag$BAG_FLAG, tfidf)
  
}
df$testo <- iconv(df$testo,"UTF-8", "UTF-8",sub='')
testo_corpus <- VCorpus(VectorSource(df$testo))
testo_corpus_clean<-clean_corpus(testo_corpus)
testo_dtm<- DocumentTermMatrix(testo_corpus_clean)
testo_dict <- findFreqTerms(testo_dtm)
write.table(testo_dict, file="dizionario_scontrini.txt",row.names = F)
trainIndex <- createDataPartition(df$flag, p = .95,
                                  list = FALSE,
                                  times = 1)

df_training <- df[trainIndex,]
df_test <- df[-trainIndex,]


df <- df_training


df_pos_test <- df[which(df_test$flag==1),] %>% 
  mutate("BAG"=factor(cut.Date(.$GIORNO, breaks = "1 days",labels = F)))
df_pos_test_bag <- as.list(split(df_pos_test,f = df_pos_test$BAG))
#le righe con flag=1 sono le bag positive

#bag "negative", separate in bags da 5 giorni
df_neg_test <- df[-which(df_test$flag==1),] %>% 
  mutate("BAG"=factor(cut.Date(.$GIORNO, breaks = "1 days",labels = F)))
df_neg_test_bag <- as.list(split(df_neg_test,f = df_neg_test$BAG))

# assegno ad ogni elemento delle bag create il flag 1 o 0
df_pos_test_bag <- lapply(df_pos_test_bag,function(x) list("INSTANCES"=x,
                                                           "BAG_FLAG"=1))

df_neg_test_bag <- lapply(df_neg_test_bag,function(x) list("INSTANCES"=x,
                                                           "BAG_FLAG"=0))

bags_test <- c(df_pos_test_bag,df_neg_test_bag)

df_meta_test <- pblapply(bags_test,meta) %>% 
  do.call("rbind",.) %>% 
  .[sample(nrow(.)),]

df_meta_test$TARGET <-  factor(df_meta_test$TARGET)
levels(df_meta_test$TARGET) <- c("neg", "pos")
# La predizione viene fatta ogni giorno. Si predice se il pacchetto di scontrini della giornata appartiene
# al gruppo flag = 1 (scontrini 5 giorni prima di un guasto)

df_pos <- df[which(df$flag==1),] %>% 
  mutate("BAG"=factor(cut.Date(.$GIORNO, breaks = "1 days",labels = F)))
df_pos_bag <- as.list(split(df_pos,f = df_pos$BAG))
#le righe con flag=1 sono le bag positive

#bag "negative", separate in bags da 5 giorni
df_neg <- df[-which(df$flag==1),] %>% 
  mutate("BAG"=factor(cut.Date(.$GIORNO, breaks = "1 days",labels = F)))
df_neg_bag <- as.list(split(df_neg,f = df_neg$BAG))

# assegno ad ogni elemento delle bag create il flag 1 o 0
df_pos_bag <- lapply(df_pos_bag,function(x) list("INSTANCES"=x,
                                                 "BAG_FLAG"=1))

df_neg_bag <- lapply(df_neg_bag,function(x) list("INSTANCES"=x,
                                                 "BAG_FLAG"=0))

bags <- c(df_pos_bag,df_neg_bag)




# trasformo ogni bag 




df_meta <- pblapply(bags,meta) %>% 
  do.call("rbind",.) %>% 
  .[sample(nrow(.)),]

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

trainIndex <- createDataPartition(df_meta$TARGET, p = 1,
                                  list = FALSE,
                                  times = 1)
tm_training <- df_meta[ trainIndex,]
tm_testing <-  df_meta[-trainIndex,]

tm_training$TARGET<- factor(tm_training$TARGET)
tm_testing$TARGET <-factor( tm_testing$TARGET)

levels(tm_training$TARGET) <- c("neg", "pos")
levels(tm_testing$TARGET) <- c("neg", "pos")

table(tm_training$TARGET)
table(df_meta_test$TARGET)

Index <- createDataPartition(tm_training$TARGET, p = .5,
                                  list = FALSE,
                                  times = 1)
tm_training_50 <- tm_training[Index,]
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
                           # summaryFunction = twoClassSummary
)

model_maker <- function(nome_modello, nome_algoritmo, nome_file){
  
  model_object<-
    train(TARGET~., 
          data=tm_training_50,
          method = nome_algoritmo,
          trControl = fitControl,
          tuneLength=3,
          # ntree = 5,
          # maxit=200,
          preProcess=c("range","nzv")
          # metric="Kappa"
          # weights = model_weights
    )
  nome_modello <- model_object
  filename <- paste0(nome_file,"_",nome_algoritmo, ".rds")
  saveRDS(model_object, here::here(filename))
  return(nome_modello)
  }

modelli <- mapply(model_maker,
                  c("Neural Network","Bayesian Generalized Linear Model", "Naive Bayes", "Logistic Regression", "Support Vector Machine Linear" ), 
                  c("nnet","bayesglm","naive_bayes","glm","svmLinear3"),
                  c("wa", "wa", "wa", "wa", "wa"),
                  SIMPLIFY=FALSE)

results <- resamples(modelli)
summary(results)
# boxplots of results
bwplot(results)
# dot plots of results
dotplot(results)
parallelplot(results,auto.key = list(columns = 2))
splom(results,auto.key = list(columns = 2))
densityplot(results,pch = "|",auto.key = list(columns = 2),metrics=c("Sens", "Spec"))


predictions <- predict(nn,newdata =df_meta_test)
confusionMatrix(predictions,df_meta_test$TARGET, positive = "pos",mode = "everything") 

library(mltools)
mcc(preds = predictions, df_meta_test$TARGET)
# saveRDS(nn, here("tm_bag_prediction7_neuralnet.rds"))
# saveRDS(nn, here("tm_bag_prediction7_naivebayes.rds"))
# saveRDS(nn, here("tm_bag_prediction7_glm.rds"))
# saveRDS(nn, here("tm_bag_prediction7_bayesglm.rds"))
# saveRDS(nn, here("tm_bag_prediction7_pcannet.rds"))

#linux
# saveRDS(nn, here("linux_tm_bag_prediction7_neuralnet.rds"))
# saveRDS(nn, here("linux_tm_bag_prediction7_naivebayes.rds"))
# saveRDS(nn, here("linux_tm_bag_prediction7_glm.rds"))
# saveRDS(nn, here("linux_tm_bag_prediction7_bayesglm.rds"))
# saveRDS(nn, here("linux_tm_bag_prediction7_pcannet.rds"))

#18 words dictionary
# saveRDS(nn, here("18_neuralnet.rds"))
# saveRDS(nn, here("18_naivebayes.rds"))
# saveRDS(nn, here("18_glm.rds"))
# saveRDS(nn, here("18_bayesglm.rds"))
# saveRDS(nn, here("18_pcannet.rds"))
# saveRDS(nn, here("18_svmlinear3.rds"))
# plot(nn)

#linux
# modelli <- lapply(as.list(list.files(here(),"linux")),read_rds)
modelli <- lapply(as.list(list.files(here(),"wa*")),read_rds)
l_predictions <- lapply(modelli, function(modello) predict(modello, df_meta_test))
matrici <- lapply(l_predictions, function(predizioni) confusionMatrix(predizioni, df_meta_test$TARGET, "pos", mode = "everything"))

nomi_modelli <- lapply(modelli,
                       function(modello) data.frame("Model name"=modello[["modelInfo"]][["label"]])) %>% 
  
  do.call("rbind",.)

performance <- lapply(l_predictions, 
                              function(predizioni){
                                cm <- confusionMatrix(predizioni, 
                                                      df_meta_test$TARGET,
                                                      "pos",
                                                      mode="everything")
                                performance <-
                                  tibble(
                                    "Accuracy" = round(cm[["overall"]][["Accuracy"]], 2),
                                    "Sensitivity" = round(cm$byClass[1], 2),
                                    "Specificity" = round(cm$byClass[2], 2),
                                    "Precision" = round(cm$byClass[5], 2),
                                    "MCC" = round(mcc(preds = predizioni,df_meta_test$TARGET),2)
                                  )
                                return(performance)}) %>% 
  do.call("rbind",.)


tabella_performance <- cbind(nomi_modelli,performance)
tabella_performance
# write.csv(tabella_performance, here("reduced_tabella_performance_modelli.csv"),fileEncoding = "UTF8",row.names = F)

#linux
# write.csv(tabella_performance, here("linux_tabella_performance_modelli.csv"),fileEncoding = "UTF8",row.names = F)


