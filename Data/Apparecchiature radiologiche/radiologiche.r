library(readxl)
library(tidyverse)
library(ggplot2)
rm(list = ls())

setwd("~/FRA/POLI/Tesi/Data/Apparecchiature radiologiche")
df <-
  read_excel("costi con benchmark.xls", col_types = c(rep("guess", 9), "date", rep("guess", 6)))
df <- df[, 1:10]
#estrazione dei master e singoli
df_master <- df[which(is.na(df$`SIC PADRE`)), ]

#fattorizzazione
df_master$`COMPOSIZIONE SIC` <-
  as.factor(df_master$`COMPOSIZIONE SIC`)
df_master$`DESCRIZIONE PRODUTTORE` <-
  as.factor(df_master$`DESCRIZIONE PRODUTTORE`)
df_master$`FORMA PRESENZA` <- as.factor(df_master$`FORMA PRESENZA`)
df_master$`DESCRIZIONE PRESIDIO` <-
  as.factor(df_master$`DESCRIZIONE PRESIDIO`)
df_master$`DESCRIZIONE TIPOLOGIA` <-
  as.factor(df_master$`DESCRIZIONE TIPOLOGIA`)

df_vimercate <-
  subset(df_master, subset = df_master$`DESCRIZIONE PRESIDIO` == "VIMERCATE NUOVO")

ggplot(
  df_vimercate,
  aes(
    x = `DESCRIZIONE TIPOLOGIA`
  )
) +
  geom_bar()+
  coord_flip()+
  theme_light()
