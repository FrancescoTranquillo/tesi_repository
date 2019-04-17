library(tidyverse)
library(dplyr)
library(lubridate)
library(here)
library(readxl)
library(magrittr)
library(DataExplorer)
library(caret)
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

#caricamento coswin ####
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

#aggiunta della colonna CHIAMATA nella tabella degli scontrini
#l'istanza avrà CHIAMATA = 1 se il giorno corrisponde ad una delle date in coswin

#aggiunta della bag-label
df <- df %>%
  mutate("CHIAMATA" = factor(ifelse(.$GIORNO %in% coswin, 1, 0)),
         "BAG"=factor(cut.Date(df$GIORNO, breaks = "3 days",labels = F)))



ignore_columns <- c("testo","TEST.DI.TENUTA","NUMERO.CICLO",
                    "INIZIO.CICLO", "GIORNO")
df_bagged <- df[,-which(names(df) %in% ignore_columns)]

#conversione multipla delle feature da int a fattori
cols = c(38:88, 2)
df_bagged[,cols] %<>% lapply(function(x) fct_explicit_na(as.character(x)))
df_bagged <- df_bagged[,-c(3,6:37)]


#divisione in lista di bags
bags <- as.list(split(df_bagged,f = df_bagged$BAG))

#assegnazione label bag positiva o negativa a seconda della presenza, nelle singole
#bags, di chiamata = 1

bags_label <- lapply(bags,function(bag){
  if(1%in%bag$CHIAMATA){
    bags <- list("INSTANCES"=bag, "FLAG"=1)
  } else{
    bags <- list("INSTANCES"=bag, "FLAG"=0)
  }
})

table(factor(lapply(bags_label,function(bag){
  s <- bag$FLAG
}) %>% do.call("rbind",.)))


#Trasformazione delle bag nel dataframe di ESEMPI
#ciclando sulle bags, se il flag è 0, tutte le istances diventano esempi,
#se il flag è 1, viene creato un metaesempio tramite la funzione meta


#la funzione meta prende in ingresso un dataframe e riporta in uscita
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
  alarms <- summarise_all(df_instances[,alarm_columns], funs(unify_alarms(.)))
  return(cbind(fct,temps,alarms))
}

df_meta <- lapply(bags_label,FUN = function(bag){
  if(bag$FLAG==1){
    meta_example <- meta(bag$INSTANCES)
  } else{
    examples <- bag$INSTANCES
  }
}) %>% do.call("rbind",.)

names(df_meta)[names(df_meta) == "CHIAMATA"] <- "TARGET"
df_meta_pp <- df_meta[,-which(names(df_meta) %in% "BAG")]
df_meta_pp$TARGET <- as.numeric(df_meta_pp$TARGET)
# pre processing

#one-hot encoding
dummies <- dummyVars(~.,data = df_meta_pp,fullRank = T)
head(predict(dummies, newdata = df_meta_pp))

dummied <- as.data.frame(predict(dummies, newdata = df_meta_pp))
df_meta_pp <- dummied


#scaling
pp_df_no_nzv <- preProcess(df_meta_pp[ , -which(names(df_meta_pp) %in% "TARGET")],
                           method = c("range","medianImpute"))

pp_df_no_nzv
data <- predict(pp_df_no_nzv, newdata = df_meta_pp[,-which(names(df_meta_pp) %in% "TARGET")])


data$TARGET <- factor(df_meta_pp$TARGET)
levels(data$TARGET) <- c("neg", "pos")
df_meta_pp$TARGET <- factor(df_meta_pp$TARGET)
levels(df_meta_pp$TARGET) <- c("neg", "pos")
#data splitting
trainIndex <- createDataPartition(data$TARGET, p = .8,
                                  list = FALSE,
                                  times = 1)
training <- data[ trainIndex,]
testing <-  data[-trainIndex,]

# set.seed(9560)
# down_train <- downSample(x = data[, -which(names(df_meta_pp) %in% "TARGET")],
#                          y = data$TARGET)
# down_train <- down_train[,-63]
# table(down_train$TARGET)



mod0 <- train(TARGET ~ ., data = training,
              method = "gbm",
              trControl = trainControl( verboseIter = T,
                                        sampling = "up",
                                        method = "repeatedcv",
                                        number = 5,
                                        repeats = 5))
# saveRDS(mod0, "model0.rds")
# my_model <- readRDS(here("model.rds"))
predictions <- predict(mod0, testing)
confusionMatrix(predictions, testing$TARGET,mode = "everything",positive = "pos")
plot(mod0)
