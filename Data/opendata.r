# script per open data sanità lombardia
library(here)
library(tidyverse)
library(ggplot2)
library(esquisse)

#ciao rosti

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

library(rgdal)
library(leaflet)
library(magrittr)
library(tidyverse)
library(maps)
library(maptools)
library(raster)

ss <- readOGR(dsn = "../shp",layer = "Strutture_sanitarie")
ss <- spTransform(ss, CRS( '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs'))

osp <- readOGR(dsn = "../shp",layer = "Ospedali")
osp <- spTransform(osp, CRS( '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs'))

distretti <- readOGR(dsn = "../shp",layer = "DISTRETTI")
distretti <- spTransform(distretti, CRS( '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs'))

#filtro per ats brianza
distretti <- distretti[distretti$CODICE_ATS=="030405",]

asst <- distretti[distretti$DISTRETTO%in%c("VIMERCATE","CARATE","SEREGNO"),]
brianza <- distretti[!distretti$DISTRETTO%in%c("VIMERCATE","CARATE","SEREGNO"),]
asst_ss <- ss[ss$DENOM_ENTE== "ASST DI VIMERCATE",] %>% 
  .[!.$DENOM_STRU=="ASST DI VIMERCATE",]
ats <- readOGR(dsn = "../shp",layer = "ATS")
ats <- spTransform(ats, CRS( '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs'))

seregno <- asst[asst$DISTRETTO%in%"SEREGNO",]

library("leaflet")

library(mapview)
library(here)
m <- leaflet() %>%
  setView(lat=45.7140697, lng=9.2622897,zoom=10.5) %>% 
  addTiles() %>%
  addProviderTiles(.,providers$Hydda) %>%
  # addPolygons(data = osp) %>%
  addPolygons(data =brianza, opacity = 0.1) %>%
  addPolygons(data =asst, opacity = 0.6,col="red") %>%
  addMarkers(data = asst_ss,lng = asst_ss@coords[,1],lat = asst_ss@coords[,2])

  # addMarkers(lng=as.numeric(df$COORDINATA.GEOGRAFICA.Y), lat=as.numeric(df$COORDINATA.GEOGRAFICA.X), popup=df$DESCRIZIONE.STRUTTURA.DI.RICOVERO)


names(df_asstvim)
head(df_asstvim)


library(here)
library(tidyverse)
library(ggplot2)
library(stringr)
library(esquisse)

#ciao rosti

list.files("../")
df <- read.csv("../Prestazioni_Ambulatoriali.csv")

df_prest_endo <- df %>% 
  filter(grepl("ENDOSCOPIA", BRANCA_REGLE),
         ENTE=="ASST DI VIMERCATE") %>% 
  group_by(TIPO_PREST) %>% 
  summarise(N_PREST_TOT = sum(N_PREST)) %>% 
  arrange(desc(N_PREST_TOT, TIPO_PREST)) 


df_prest_endo <- df %>%
  filter(grepl("ENDOSCOPIA", BRANCA_REGLE),
         ENTE=="ASST DI VIMERCATE") %>%
  group_by(PREST_AMBLE, TIPO_PREST) %>%
  summarise(N_PREST_TOT = sum(N_PREST)) %>%
  arrange(desc(N_PREST_TOT)) %>% 
  top_n(n = 10,wt = N_PREST_TOT)

df_prest_endo$TIPO_PREST<- c("Ambulatorio", "Screening", "Pronto Soccorso")

stringr::str_to_title(as.character(df_prest_endo$PREST_AMBLE))

df_prest_endo$PREST_AMBLE <- tolower(as.character(df_prest_endo$PREST_AMBLE))

library(kableExtra)
kable(x = df_prest_endo, "latex", align = "c", booktabs = T, caption = "Document Term Matrix")%>%
  kable_styling(latex_options = "HOLD_position")
