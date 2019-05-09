library(tidyverse)
library(dplyr)
library(lubridate)
library(here)
library(pbapply)
library(forcats)
library(readr)
library(tm)
library(magrittr)
library(tabulizer)
#estrazione nomi allarmi dal manuale di istruzioni della macchina
source(file = "estrazione_nomi_allarmi.r")

#### funzione che pulisce il nome di un processo
# presente in uno scontrino, standardizzandolo
trimmer <- function(nome_processo) {
  processo <- as.character(nome_processo) %>%
    gsub(
      pattern =  " \\(.*\\)|:(?<=:).*",
      replacement = "",
      x = .,
      perl = T
    )
  return(processo)
  
}
#### funzione che filtra e da la lista solamente degli scontrini "validi", ovvero contenenti
### la dicitura "regolare" o "irregolare
bouncer <- function(path_scontrino) {
  n <- str_extract(path_scontrino, "(\\d*)(?= [Strumento])")
  scontrino <-
    readLines(paste0(path, "\\", path_scontrino), encoding = "UTF-8")
  if (last(grepl("REGOLARE|IRREGOLARE", scontrino, perl = T)) == F) {
    return(as.numeric(n))
  }
}

#### funzione che dato in input uno scontrino lo trasforma in una tabella####
morpher <- function(path_scontrino) {
  scontrino <-
    readLines(paste0(path, "\\", path_scontrino), encoding = "UTF-8")
  
  n <- str_extract(path_scontrino,"(\\d*)(?= [Strumento])")
  if (last(grepl("REGOLARE|IRREGOLARE", scontrino, perl = T)) == T) {
   # print(n)
    
    scontrino_header <-
      na.omit(gsub(scontrino, 
                   pattern = "\\d\\d:\\d\\d:\\d\\d .*", 
                   replacement = NA)) %>%
      .[5:(length(.) - 1)]
    
    sclean_header <- scontrino_header[length(scontrino_header) - 1]
    
    scontrino_regolare <-
      na.omit(str_extract(scontrino, 
                          pattern = "\\d\\d:\\d\\d:\\d\\d .*")) %>%
      gsub("(\\d\\d:){2,}\\d\\d ", "", .) %>%
      last(.)
    
    scontrino_footer <-
      na.omit(str_extract(scontrino, 
                          pattern = "\\d\\d:\\d\\d:\\d\\d .*")) %>%
      .[1:(length(.) - 1)]
    
    sclean_footer <-
      gsub(scontrino_footer,
           pattern = "\\d\\d:\\d\\d:\\d\\d ",
           replacement = "")
    
    if (any(grepl("PRELEVATO", sclean_footer))) {
      sclean_footer %<>% .[-which(grepl("PRELEVATO", sclean_footer))]
    }
    
    sclean <- paste(sclean_header,
                    paste(sclean_footer, collapse = " "),
                    scontrino_regolare)
    
    righe_allarmi <- which(grepl("allarme|alarm", sclean_footer,perl = T,ignore.case = T))
    
    if (!is_empty(righe_allarmi)) {
      nome_allarmi_rilevati <-
        nomi_allarmi[which(grepl(
          sclean_footer[righe_allarmi],
          nomi_allarmi,
          perl = F,
          ignore.case = T,
          fixed = F
        ))]
      if (is_empty(nome_allarmi_rilevati)) {
        nome_allarmi_rilevati <- "ALTRO"
      }
      allarmi_rilevati <- ifelse(nome_allarmi_rilevati == nomi_allarmi, 1, 0) %>%
          t() %>%
          data.frame() %>%
          set_colnames(nomi_allarmi)
      } else {
        allarmi_rilevati <- rep(0, length(nomi_allarmi)) %>%
          t() %>%
          data.frame()%>%
          set_colnames(nomi_allarmi)
      }
      
      #trasformazione header:
    #estrazione di inizio ciclo, tipo ciclo e numero ciclo
    
    dati_header <-
      na.omit(
        str_extract(
          scontrino_header,
          "(?<=INIZIO CICLO: ).*|(?<=TIPO CICLO: ).*"
        )
      )
    label_dati_header <-
      c("INIZIO CICLO", "TIPO CICLO")
    df_header <-
      data.frame(cbind(label_dati_header, dati_header), stringsAsFactors = F)
    tmydf_header = setNames(data.frame(t(df_header[,-1])), df_header[, 1])
    head(tmydf_header)
    df_header <- tmydf_header
    
    #trasformazione footer
    # tempi <-
    #   parse_time(substr(scontrino_footer, 1, 8), format = "%H:%M:%S")
    # 
    # dt <- difftime(tempi, lag(tempi, default = first(tempi)))

    processi <- gsub("(\\d\\d:){2,}\\d\\d ", "", scontrino_footer)
    temperature <- as.numeric(na.omit(str_extract(processi, "(\\d*)(?=°)")))
    if (length(temperature) != 0) {
      temp_flag <- 1
      temperature_labels <-
        paste0("temp.", seq(1, length(temperature), 1))
      temperature_table <-
        data.frame(t(temperature[1:2])) %>% 
        set_colnames(temperature_labels[1:2])
      } else
      temp_flag <- 0
    
    #### tabelle footer ####
    # processi <- sapply(processi,
    #                    trimmer,
    #                    USE.NAMES = F,
    #                    simplify = T)
    # processi_table <-
    #   data.frame(cbind(unique(processi), "1"), stringsAsFactors = F)
    # processi_table_header <-
    #   setNames(data.frame(t(processi_table[,-1])), processi_table[, 1])
    # 
    # t.labels <- paste0("t.", seq(1, length(dt), 1))
    # 
    # dt_table <-
    #   data.frame(cbind(t.labels, as.numeric(dt)), stringsAsFactors = F)
    # 
    # dt_table_header = setNames(data.frame(t(dt_table[,-1])), dt_table[, 1])
    # 
    #unione delle tabelle del footer
    if (temp_flag == 1) {
      df_footer <-
        data.frame(
          # processi_table_header,
          # dt_table_header,
          temperature_table
        )
      df <- cbind(df_header, df_footer, testo = sclean, allarmi_rilevati)
      
    } else

    df <- cbind(df_header, testo = sclean, allarmi_rilevati)
    
    
    #trasformazione footer
    # df_footer <- df_footer %>%
    #   mutate("CICLO REGOLARE" = ifelse(any(
    #     grepl("CICLO IRREGOLARE", scontrino_regolare) == TRUE
    #   ), 0, 1))
    # 
       # df <- cbind(df_header, testo = sclean, allarmi_rilevati)
    
    return(df)
  }
  else
    data.frame()
}

#scontrino <- readLines(file.choose())


#path = "C:\\Users\\frtranquillo\\github\\tesi_repository\\Data\\ISA\\isareport16-19\\16-17-18"
path <- here("isareport16-19")
lista_scontrini <- as.list(list.files(path, pattern = "*.txt"))

# applico funzione morpher agli scontrini validi e poi unisco
message("Analisi degli scontrini in corso...");
tabella_scontrini <- pblapply(lista_scontrini, morpher) %>%
  bind_rows(.)

# tabella_scontrini <-
#   tabella_scontrini[, order(colnames(tabella_scontrini), decreasing = TRUE)]
#tabella_scontrini <- tabella_scontrini[, 2:12]
head(tabella_scontrini)

tabella_scontrini$`TIPO CICLO` <-
  factor(tabella_scontrini$`TIPO CICLO`)

test <- tabella_scontrini
test$`TIPO CICLO` <-
  test$`TIPO CICLO` %>% fct_collapse(
    CALIBRAZIONE = c("CALIBRATION", "CALIBRAZIONE"),
    "DISINFEZIONE COMPLETA" = c("COMPLETE DISINFECTION", "DISINFEZIONE COMPLETA"),
    "DISINFEZIONE VELOCE" = c("DISINFEZIONE VELOCE", "FAST DISINFECTION"),
    "STERILIZZAZIONE COMPLETA" = c("COMPLETE STERILIZATION", "STERILIZZAZIONE COMPLETA"),
    "STERILIZZAZIONE VELOCE" = c(
      " STERILIZAZIONE VELOCE" ,
      "FAST STERILIZATION",
      "ster velo1",
      " STERILIZZAZIONE VELOCE"
    )
  )
table(test$`TIPO CICLO`)

test%<>%.[,-ncol(.)]
#scrittura tabella
write.csv2(test,
           file = "tabella_scontrini_allarmi.csv",
           row.names = F)

write.csv2(test,
           file = "tabella_scontrini_text.csv",
           row.names = F)
