library(tidyverse)
library(dplyr)
library(lubridate)
library(here)
library(readxl)
library(magrittr)
library(DataExplorer)
library(caret)
library(rlist)
library(tm)
library(e1071)
library(nnet)
library(NeuralNetTools)

# library(pROC)

# Lo script unisce la tabella degli scontrini a quella di coswin, 
# aggiungendo le colonne chiamata e chiamata-x dove x sono i giorni precedenti
# all'effettiva chiamata

#importa tabella degli scontrini

df <-
  read.csv2(file = "tabella_scontrini_text.csv",
            header = T,
            stringsAsFactors = F)

#conversione date e factors
df$INIZIO.CICLO <-
  parse_date_time(df$INIZIO.CICLO, orders = "dmy hms")
df$CICLO.REGOLARE <-
  factor(df$CICLO.REGOLARE)
df$TIPO.CICLO <- factor(df$TIPO.CICLO)


#caricamento coswin####
# vengono eliminate le righe corrispondenti a chiamate relative all'inserimento
# nel db della macchina di un nuovo strumento.
coswin <- read.csv2(file = "coswin-isa/108841.csv",
                    header = T,
                    stringsAsFactors = F) %>% 
  .[-which(grepl("inseri", x = .$Descrizione,ignore.case = T)),24] %>% 
  as.character(.) %>%
  dmy_hm(.) %>%
  as_date(.) %>%
  .[which(complete.cases(.))] %>%
  unique(.)


#aggiunta colonna dei giorni nella tabella di scontrini
df <- df %>%
  mutate("GIORNO" = as_date(.$INIZIO.CICLO))

#aggiunta della bag-label
df <- df %>%
  mutate("CHIAMATA" = factor(ifelse(.$GIORNO %in% coswin, 1, 0)))

df$testo <- iconv(df$testo,"UTF-8", "UTF-8",sub='')
# "BAG"=factor(cut.Date(df$GIORNO, breaks = "5 days",labels = F)))

# ignore_columns <- c("TEST.DI.TENUTA","NUMERO.CICLO",
#                     "INIZIO.CICLO")
# df <- df[,-which(names(df) %in% ignore_columns)]

#trovo i giorni in cui ci sono state chiamate a coswin
giorni_guasti <- unique(df[which(df$CHIAMATA==1),which(colnames(df)=="GIORNO")])

#trovo le date dei 5 giorni precedenti ad ognuno dei giorni appena trovati
# attraverso la funzione backprop
backprop <- function(giorno){
  as.list(seq(from=giorno-1,to =giorno-6,by = -1))
}

giorni_predittivi <- sapply(giorni_guasti, backprop)

# assegno flag=1 in corrispondenza dei giorni predittivi
df%<>%mutate(flag=ifelse(as.Date(df$GIORNO)%in%giorni_predittivi,1,0))

trainIndex <- createDataPartition(df$flag, p = .75,
                                  list = FALSE,
                                  times = 1)
nlp_training <- df[ trainIndex,]
nlp_testing <-  df[-trainIndex,]

clean_corpus <- function(corpus) {
  corpus <- tm_map(corpus, stripWhitespace)
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, content_transformer(tolower))
  corpus <- tm_map(corpus, removeNumbers)
  # corpus <- tm_map(corpus, stemDocument)
  
  
}

#Data preparation – cleaning and standardizing text data####


descr_corpus_train <- VCorpus(VectorSource(nlp_training$testo))
descr_train_labels <- factor(nlp_training$flag)
descr_corpus_clean_train<-clean_corpus(descr_corpus_train)
descr_dtm_train <- DocumentTermMatrix(descr_corpus_clean_train,control = list(weighting = function(x) weightTfIdf(x)))

descr_corpus_test <- VCorpus(VectorSource(nlp_testing$testo))
descr_test_labels <- factor(nlp_testing$flag)
descr_corpus_clean_test<-clean_corpus(descr_corpus_test)


descr_dict <- findFreqTerms(descr_dtm_train, highfreq = 600)
descr_test <- as.data.frame(as.matrix(DocumentTermMatrix(descr_corpus_clean_test, list(dictionary=descr_dict,weighting=function(x) weightTfIdf(x)))))
descr_train <- as.data.frame(as.matrix(DocumentTermMatrix(descr_corpus_clean_train, list(dictionary=descr_dict,weighting=function(x) weightTfIdf(x)))))

# descr_dtm_freq_train <- descr_dtm_train[, descr_freq_words]
# descr_dtm_freq_test <- descr_dtm_test[, descr_freq_words]
# convert_counts <- function(x) {
#   x <- ifelse(x > 0, "Yes", "No")
# }
# 
# 
# descr_train <-as.data.frame(apply(descr_dtm_freq_train, MARGIN = 2, convert_counts))
# descr_test <- as.data.frame(apply(descr_dtm_freq_test, MARGIN = 2, convert_counts))


# descr_classifier2 <-
#   naiveBayes(descr_train, descr_train_labels, laplace = 1)
# 
# descr_test_pred2 <- predict(descr_classifier2, descr_test)
# # 
# levels(descr_test_pred2) <- c("neg", "pos")
# levels(descr_test_labels) <- c("neg", "pos")
# confusionMatrix(descr_test_pred2, descr_test_labels,positive = "1")

# 
# descr_train %<>%
#   mutate_each_(funs(factor(.)),c(1:61)) %>%
#   .[, sapply(descr_train, function(col) length(unique(col))) > 1]
# 
# descr_test %<>%
#   mutate_each_(funs(factor(.)),c(1:61)) %>%
#   .[, sapply(descr_test, function(col) length(unique(col))) > 1]
# 

descr_train$TARGET <- factor(nlp_training$flag)
levels(descr_train$TARGET) <- c("neg", "pos")
levels(descr_test_labels) <- c("neg", "pos")

# dummies <- dummyVars(~., data = descr_train, fullRank =F)
# dummied <- as.data.frame(predict(dummies, newdata = descr_train))
# test_df<- dummied
# train_pp_nozv <- preProcess(descr_train[ , -which(names(descr_train) %in% "TARGET")],
#            method = c("range","nzv"))
# 
# train_pp_nozv
# train_pp_nozv <- predict(train_pp_nozv, newdata = descr_train[,-which(names(descr_train) %in% "TARGET")])

grid <- expand.grid(size = c(1,3,5,10,15,20,15,50),
                    decay= seq(from=0, to=1, by=0.01))

# train_pp_nozv$TARGET <- factor(nlp_training$flag)
# levels(train_pp_nozv$TARGET) <- c("neg", "pos")

table(descr_train$TARGET
      )

fitControl <- trainControl(method = "repeatedcv", 
                           number = 10,
                           repeats = 5,
                           verboseIter=T,
                           # classProbs = TRUE,
                           allowParallel = T,
                           sampling = "down"
                            # summaryFunction = twoClassSummary,
                           )


nlp_classifier <-
  train(TARGET~.,
     data=descr_train,
    method = "bayesglm",
    trControl = fitControl,
    tuneLength = 2
  )
# tuneGrid=grid)

predictions <- predict(nlp_classifier,newdata = descr_test)
confusionMatrix(predictions, descr_test_labels, positive = "pos")
nlp_classifier

grid_gbm <- expand.grid( n.trees = c(1,5,10,15,20,50,100,200,400)
                         )

set.seed(825)
nlp_classifier2 <- train(TARGET ~ .,
                         data = descr_train,
                         method = "svmLinear3",
                         trControl = fitControl,
                         # tuneGrid = grid_gbm,
                         tuneLength=10,
                        )
                         
nlp_classifier2
plot(nlp_classifier2)
predictions <- predict(nlp_classifier2,newdata = descr_test)
confusionMatrix(predictions, descr_test_labels, positive = "pos")

plotnet(nlp_classifier$finalModel)
