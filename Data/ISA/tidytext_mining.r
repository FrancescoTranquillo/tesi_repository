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
library(tidytext)
library(splitstackshape)

clean_corpus <- function(corpus) {
  corpus <- tm_map(corpus, stripWhitespace)
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, content_transformer(tolower))
  corpus <- tm_map(corpus, removeNumbers)
  corpus <- tm_map(corpus, stemDocument)
  
  
}

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
# "BAG"=factor(cut.Date(df$GIORNO, breaks = "5 days",labels = F)))

# ignore_columns <- c("TEST.DI.TENUTA","NUMERO.CICLO",
#                     "INIZIO.CICLO")
# df <- df[,-which(names(df) %in% ignore_columns)]

#trovo i giorni in cui ci sono state chiamate a coswin
giorni_guasti <- unique(df[which(df$CHIAMATA==1),which(colnames(df)=="GIORNO")])

#trovo le date dei 5 giorni precedenti ad ognuno dei giorni appena trovati
# attraverso la funzione backprop
backprop <- function(giorno){
  as.list(seq(from=giorno-1,to =giorno-5,by = -1))
}

giorni_predittivi <- sapply(giorni_guasti, backprop)

# assegno flag=1 in corrispondenza dei giorni predittivi
df%<>%mutate(flag=ifelse(as.Date(df$GIORNO)%in%giorni_predittivi,1,0))

trainIndex <- createDataPartition(df$flag, p = .75,
                                  list = FALSE,
                                  times = 1)
nlp_training <- df[ trainIndex,]
nlp_testing <-  df[-trainIndex,]

descr_corpus_train <- VCorpus(VectorSource(nlp_training$testo))
descr_train_labels <- factor(nlp_training$flag)
descr_corpus_clean_train<-clean_corpus(descr_corpus_train)
descr_dtm_train <- as.matrix(DocumentTermMatrix(descr_corpus_clean_train))

descr_corpus_test <- VCorpus(VectorSource(nlp_testing$testo))
descr_test_labels <- factor(nlp_testing$flag)
descr_corpus_clean_test<-clean_corpus(descr_corpus_test)
descr_dtm_test <- as.matrix(DocumentTermMatrix(descr_corpus_clean_test))

train.df <- data.frame(descr_dtm_train[,intersect(colnames(descr_dtm_train), colnames(descr_dtm_test))])
test.df <- data.frame(descr_dtm_test[,intersect(colnames(descr_dtm_test), colnames(descr_dtm_train))])

train.df$TARGET<- factor(nlp_training$flag)
test.df_labels <-factor( nlp_testing$flag)

levels(train.df$TARGET) <- c("neg", "pos")
levels(test.df_labels) <- c("neg", "pos")

fitControl <- trainControl(method = "repeatedcv", 
                           number = 10,
                           repeats = 2,
                           verboseIter=T,
                             classProbs = TRUE,
                           allowParallel = T,
                            sampling = "down"
                           # summaryFunction = twoClassSummary
)

model_weights <- ifelse(train.df$TARGET == "pos",
                        (1/table(train.df$TARGET)[1]) * 0.5,
                        (1/table(train.df$TARGET)[2]) * 0.5)

grid <- expand.grid(size=3,
                    decay=0.1)

set.seed(1045)
nn <-
  train(TARGET~., 
        data=train.df,
    method = 'avNNet',
    trControl = fitControl
      # tuneGrid=grid
   # weights = model_weights
    # metric = "ROC"
  )

predictions <- predict(nlp_classifier,newdata =test.df)
confusionMatrix(predictions, test.df_labels, positive = "pos",mode = "everything")

plot(nn)
nlp_classifier


# saveRDS(nlp_classifier,file =here("nlp_classifier.rds") )
nlp_classifier <- read_rds(here("nlp_classifier.rds"))
