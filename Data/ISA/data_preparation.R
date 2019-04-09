library(tidyverse)
library(dplyr)
library(lubridate)
library(here)
library(ggplot2)
library(readxl)
library(caret)
#importa tabella degli scontrini

df <-
  read.csv2(file = "tabella_scontrini.csv",
            header = T,
            stringsAsFactors = T)

#conversione date e factors
df$INIZIO.CICLO <-
  parse_date_time(df$INIZIO.CICLO, orders = "dmy hms")
df$CICLO.REGOLARE <-
  factor(df$CICLO.REGOLARE)

#quanto tempo passa tra un ciclo irregolare e l'altro?
df_irregolari <- df[which(df$CICLO.REGOLARE == "-1"),]

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

#caricamento coswin
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
        format(date - days(0:x), format = "%Y-%m-%d"),
      simplify = T
    )
  
  col_name <<- paste0("CHIAMATA-", x)
  df_backed <-
    table %>% mutate(., !!col_name := factor(ifelse(.$GIORNO %in% as.Date(a), 1, 0)))
  table(df_backed$col_name)
  
  return(df_backed)
}

#predizione a 3 giorni
df_backed <- back_assign(df, 5)
str(df_backed)
table(df_backed$`CHIAMATA-5`)

train(
  x = sample(df_backed, 4000,replace = T),
  y = df_backed$`CHIAMATA-5`,
  method = "nnet",
  trControl=trainControl(methodverboseIter

)
