library(tidyverse)
library(dplyr)
library(lubridate)
library(here)
library(readxl)
library(magrittr)
library(DataExplorer)
library(caret)
library(rlist)
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
  mutate("CHIAMATA" = factor(ifelse(.$GIORNO %in% coswin, 1, 0)))
# "BAG"=factor(cut.Date(df$GIORNO, breaks = "5 days",labels = F)))

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

df_pos <- df[which(df$flag==1),] %>% 
  mutate("BAG"=factor(cut.Date(.$GIORNO, breaks = "5 days",labels = F)))
df_pos_bag <- as.list(split(df_pos,f = df_pos$BAG))
#le righe con flag=1 sono le bag positive

ignore_columns <- c("testo","TEST.DI.TENUTA","NUMERO.CICLO",
                    "INIZIO.CICLO", "GIORNO")
df_bagged <- df[,-which(names(df) %in% ignore_columns)]

#conversione multipla delle feature da int a fattori
cols = c(38:88, 2)
df_bagged[,cols] %<>% lapply(function(x) fct_explicit_na(as.character(x)))
df_bagged <- df_bagged[,-c(3,6:37)]

#divisione in training e test set
df_train_index <- createDataPartition(df_bagged$CHIAMATA, p=0.75,list=F,times = 1)
df_train <- df_bagged[df_train_index,]
df_test <- df_bagged[-df_train_index,]


#divisione in lista di bags
df_bagged <- df_train
bags <- as.list(split(df_bagged,f = df_bagged$BAG))

df_test_bag <- as.list(split(df_test,f = df_test$BAG))

#assegnazione label bag positiva o negativa a seconda della presenza, nelle singole
#bags, di chiamata = 1

bags_label <- lapply(bags,function(bag){
  if(1%in%bag$CHIAMATA){
    
    bags <- list("INSTANCES"=bag, "FLAG"=1)
  } else{
    bags <- list("INSTANCES"=bag, "FLAG"=0)
  }
})

df_test_label <- lapply(df_test_bag,function(bag){
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
  TARGET <- 1
  return(cbind(fct,temps,alarms,TARGET))
}

df_meta <- lapply(bags_label,FUN = function(bag){
  if(bag$FLAG==1){
    meta_example <- meta(bag$INSTANCES)
  } else{
    examples <- cbind(bag$INSTANCES, TARGET=0)
  }
}) %>% do.call("rbind",.)

df_meta_pp <- df_meta[,-which(names(df_meta) %in% c("BAG","CHIAMATA"))]
df_meta_pp$TARGET <- as.numeric(df_meta_pp$TARGET)
# pre processing ####

#one-hot encoding
dummies <- dummyVars(~.,data = df_meta_pp,fullRank = T)
# head(predict(dummies, newdata = df_meta_pp))

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

#preprocess del test set: il test set è una lista di bag. Ogni bag contiene
# un dataframe di tante righe quanti sono gli scontrini in 5 giorni
# più la variabile flag che indica se quella bag ha prodotto una
# chiamata. Il test deve essere processato allo stesso modo fatto per
# il training senza però trasformare le bag stesse. L'obiettivo
# è quello di predire la variabile flag. Ogni riga del dataframe verrà predetta
# la predizione complessiva sarà il valore della variabile flag.

preprocessing <- function(bag){
  df <- bag$INSTANCES %>% .[,-which(names(.) %in% c("BAG","CHIAMATA"))]
  #one-hot encoding
  dummies <- dummyVars(~., data = df, fullRank = T)
  dummied <- as.data.frame(predict(dummies, newdata = df))
  df<- dummied
  
  #scaling e medianImpute
  df_no_nzv <- preProcess(df,method = c("range","medianImpute"))
  df <- predict(df_no_nzv, newdata = df)
  
  list("INSTANCES"=df, "FLAG"=bag$FLAG)
}

df_test_label <- lapply(df_test_label,preprocessing)
#data splitting
# trainIndex <- createDataPartition(data$TARGET, p = .75,
#                                   list = FALSE,
#                                   times = 1)
# training <- data[ trainIndex,]
# testing <-  data[-trainIndex,]

fitControl <- trainControl(method = "repeatedcv", 
                           number = 10, 
                           repeats = 3, 
                           classProbs = TRUE,
                           verboseIter=T,allowParallel = T,
                            summaryFunction = twoClassSummary)

#training ####
mod0 <- train(TARGET ~ ., data = data,
              metric = "ROC",
              maximize = TRUE,
              method = "nnet",
              trControl = fitControl)


mod1 <- train(TARGET ~ ., data = data,
              metric = "ROC",
              maximize = TRUE,
                  method = "svmLinear",
                  trControl = fitControl)

 
mod3 <- train(TARGET ~ ., data = data,
              metric = "ROC",
              maximize = TRUE,
                  method = "glm",
                  trControl = fitControl)

 compare <- resamples(list(NN=mod0,
                          SVM.Linear=mod1,
                          LogReg=mod3))
 
 bwplot(compare)	
 summary(compare)
 splom(compare)



 predictions <- predict(lsvm, testing)
confusionMatrix(predictions, testing$TARGET,mode = "sens_spec",positive = "pos")
saveRDS(mod0, "nn.rds")
saveRDS(mod1, "lsvm.rds")
saveRDS(mod3, "logreg.rds")
saveRDS(compare, "compare_models.rds")

nn <- readRDS(here("nn.rds"))
lsvm <- readRDS(here("lsvm.rds"))
logreg <- readRDS(here("logreg.rds"))
compare <- readRDS(here("compare_models.rds"))




densityplot(compare,metric = "ROC",auto.key = list(columns = 3))

scales <- list(x=list(relation="free"), y=list(relation="free"))
bwplot(compare, scales=scales)


#valutazione con test set ####
evaluate <- function(bag){
  predictions <- predict(mod1, bag$INSTANCES,type = "prob")
  list("INSTANCES"=bag$INSTANCES, "FLAG"=bag$FLAG, "PREDICTIONS"=predictions)
}

test <- lapply(df_test_label, evaluate)
