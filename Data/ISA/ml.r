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

#caricamento coswin####
# vengono eliminate le righe corrispondenti a:
# chiamate relative all'inserimento nel db della macchina di un nuovo strumento,
# verifiche di sicurezza elettrica
# manutenzione ordinaria
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



ignore_columns <- c("testo", "INIZIO.CICLO")
df <- df[,-which(names(df) %in% ignore_columns)]


#trovo i giorni in cui ci sono state chiamate a coswin
giorni_guasti <- unique(df[which(df$CHIAMATA==1),which(colnames(df)=="GIORNO")])

#trovo le date dei 5 giorni precedenti ad ognuno dei giorni appena trovati
# attraverso la funzione backprop
backprop <- function(giorno){
  as.list(seq(from=giorno-1,to =giorno-7,by = -1))
}

giorni_predittivi <- sapply(giorni_guasti, backprop)

# assegno flag=1 in corrispondenza dei giorni predittivi
df%<>%mutate(flag=ifelse(as.Date(df$GIORNO)%in%giorni_predittivi,1,0))