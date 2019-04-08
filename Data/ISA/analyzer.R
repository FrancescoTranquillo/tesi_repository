library(tidyverse)
library(dplyr)
library(here)
library(pbapply)
library(forcats)

# funzione che dato in input uno scontrino lo trasforma in una tabella
morpher <- function(path_scontrino) {
  scontrino <- readLines(paste0(path, "\\", path_scontrino))
  scontrino_header <- scontrino[5:15]
  scontrino_footer <- scontrino[16:length(scontrino)]
  #trasformazione header
  df_header <- data.frame(do.call(rbind,
                                  strsplit(scontrino_header,
                                           "(?<=[A-Z]): ",
                                           perl = T)),
                          stringsAsFactors = F)
  tmydf_header = setNames(data.frame(t(df_header[,-1])), df_header[, 1])
  head(tmydf_header)
  df <- tmydf_header
  
  
  #trasformazione footer
  df <- df %>%
    mutate("CICLO REGOLARE" = ifelse(any(
      grepl("CICLO IRREGOLARE", scontrino_footer) == TRUE
    ),-1, 1))
  
  return(df)
}
#scontrino <- readLines(file.choose())


#path = "C:\\Users\\frtranquillo\\github\\tesi_repository\\Data\\ISA\\isareport16-19\\16-17-18"
path <- here("isareport16-19")
lista_scontrini <- as.list(list.files(path, pattern = "*.txt"))

# applico funzione morpher ad ogni elemento della lista di scontrini e poi unisco
message("Analisi degli scontrini in corso...")
tabella_scontrini <- pblapply(lista_scontrini, morpher) %>%
  bind_rows(.)

tabella_scontrini <- tabella_scontrini[, 2:12]
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

#scrittura tabella

write.csv2(test,
           file = here("tabella_scontrini.csv"),
           row.names = F)
