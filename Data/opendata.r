# script per open data sanità lombardia

library(here)
library(tidyverse)
library(ggplot2)
library(esquisse)
library(rayshader)

list.files("../")
df <- read.csv("../Prestazioni_Ambulatoriali.csv")

df_asstvim <- df %>% .[which(.$ENTE=="ASST DI VIMERCATE"),]

df_asstvim_endo <- df_asstvim %>% 
  .[grep("endoscop" ,df_asstvim$PREST_AMBLE,ignore.case = T,fixed = F),] %>% 
  .[which(.$TIPO_PREST=="AMB"),20:22] %>% 
  filter(N_PREST>100)

esquisser()
library(ggplot2)

gg <- ggplot(data = df_asstvim_endo) +
  aes(x = PREST_AMBLE, y = N_PREST) +
  geom_bar(fill = "#0c4c8a",stat = "sum") +
  theme_minimal() +
  coord_flip()

