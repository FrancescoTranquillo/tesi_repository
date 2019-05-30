library(shiny)
library(shinydashboard)
library(shinyalert)
library(shinyWidgets)
library(DT)
library(esquisse)
library(lubridate)
library(here)
library(shinyBS)
library(plotly)
library(readr)
library(arm)

path <- here("isareport16-19")
lista_scontrini <- as.list(list.files(path, pattern = "*.txt"))

scontrino <- lapply(lista_scontrini, function(path_scontrino)
  readLines(paste0(path, "\\", path_scontrino), encoding = "UTF-8"))

tabella_scontrini <- pblapply(scontrino[1:1900], morpher) %>%
  bind_rows(.)

tabella_scontrini$`INIZIO CICLO` <-  parse_date_time(tabella_scontrini$`INIZIO CICLO`, orders = "dmy HMS")
tabella_scontrini$`TIPO CICLO` <- factor(tabella_scontrini$`TIPO CICLO`)
tabella_scontrini$STRUMENTO <- factor(tabella_scontrini$STRUMENTO)
tabella_scontrini$CATEGORIA <- factor(tabella_scontrini$CATEGORIA)
tabella_scontrini$MATRICOLA <- factor(tabella_scontrini$MATRICOLA)
tabella_scontrini$OPERATORE <- factor(tabella_scontrini$OPERATORE)
tabella_scontrini$ALLARMI <- factor(tabella_scontrini$ALLARMI)
tabella_scontrini$`ESITO CICLO` <- factor(tabella_scontrini$`ESITO CICLO`)

colnames(tabella_scontrini)[which(names(tabella_scontrini) == "ESITO CICLO")] <- "ESITO.CICLO"


tabella_scontrini %<>% mutate("GIORNO" = factor(cut.Date(
  as.Date(.$`INIZIO CICLO`),
  breaks = "1 days",
  labels = F
)))
df_giorni <- as.list(split(tabella_scontrini, f = tabella_scontrini$GIORNO))


n_allarmi <- function(df_giorno){
  n <-  nrow(df_giorno[-which(df_giorno$ESITO.CICLO=="CICLO REGOLARE"),])
  giorno <- df_giorno$`INIZIO CICLO`
  return(data.frame("giorno"=giorno,
                    "numero di cicli irregolari"=n))
  
}

andamento_allarmi <- lapply(df_giorni,n_allarmi) %>% do.call("rbind",.)


ggplot(data = andamento_allarmi,aes(x=giorno,y=numero.di.cicli.irregolari))+
  geom_line()+
  geom_smooth()


