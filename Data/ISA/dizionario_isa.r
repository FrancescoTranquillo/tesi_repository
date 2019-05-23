library(tidyverse)
library(dplyr)
library(lubridate)
# library(here)
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
  # corpus <- tm_map(corpus, stemDocument)
}

meta <- function(bag){
  bag_text <- bag$INSTANCES$testo
  bag_corpus <- VCorpus(VectorSource(bag_text)) %>% 
    clean_corpus(.)
  bag_dtm <- as.data.frame(as.matrix(DocumentTermMatrix(bag_corpus,
                                                        control=list(dictionary=testo_dict,
                                                                     weighting = function(x) weightTfIdf(x, normalize = FALSE)))))
  tfidf <- summarise_all(bag_dtm,sum,na.rm=T)
  cbind("TARGET"=bag$BAG_FLAG,tfidf)
  
}
testo_corpus <- VCorpus(VectorSource(df$testo))
testo_corpus_clean<-clean_corpus(testo_corpus)
testo_dtm<- DocumentTermMatrix(testo_corpus_clean)
testo_dict <- findFreqTerms(testo_dtm, lowfreq = 1)
