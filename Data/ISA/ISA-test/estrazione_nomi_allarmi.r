# library(tidyverse)
# # library(here)
# library(tabulizer)
# library(pdftools)
# library(dplyr)
# library(magrittr)
# file <- here("isa-manuale.pdf")
# areas<- pdf_data(pdf = file)[[103]]
# 
# areas
nomi_allarmi <- extract_text("isa-manuale.pdf",
                    pages = seq(94,104,by = 1),
                    # pages=98,
                    area= list(c(183, 73, 670, 201))) %>% 
  gsub("\\r",replacement = "",.) %>% 
  gsub("Tipo di allarme","|",.) %>% 
  gsub("\\n",replacement = "",.) %>% 
  gsub("CHIUSURACOPERCHIO",replacement="CHIUSURA COPERCHIO",.) %>% 
  paste0(.,collapse = "|") %>% 
  strsplit(.,split = "\\|") %>% 
  unlist()

nomi_allarmi <- append(nomi_allarmi,values = "ALTRO")
