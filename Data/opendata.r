# script per open data sanità lombardia

library(here)
library(tidyverse)
library(ggplot2)
library(esquisse)
library(rayshader)

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
s <- shapefile("../Strutture_sanitarie.shx")
shape <- shapefile("../Strutture_sanitarie.shp")

library("rgdal")
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
asst_ss <- ss[ss$DENOM_ENTE== "ASST DI VIMERCATE",]
ats <- readOGR(dsn = "../shp",layer = "ATS")
ats <- spTransform(ats, CRS( '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs'))

seregno <- asst[asst$DISTRETTO%in%"SEREGNO",]

library("leaflet")
leaflet() %>%
  addTiles() %>%
  addProviderTiles(.,providers$Stamen.Terrain) %>%
  # addPolygons(data = osp) %>%
  # addPolygons(data =brianza, opacity = 0.2, label= "ATS BRIANZA") %>%
  addPolygons(data =asst, opacity = 0.7,col="green",label= "ASST VIMERCATE") %>%
  addMarkers(data = asst_ss,lng = asst_ss@coords[,1],lat = asst_ss@coords[,2], label  = asst_ss$DENOM_STRU,
             labelOptions = labelOptions(noHide = T,))

  # addMarkers(lng=as.numeric(df$COORDINATA.GEOGRAFICA.Y), lat=as.numeric(df$COORDINATA.GEOGRAFICA.X), popup=df$DESCRIZIONE.STRUTTURA.DI.RICOVERO)


#
# lat: 45.70186352230473   lon: 9.475879669189453
# lat: 45.597224374966075   lon: 9.737491607666016
m

df <- read.csv("../Geo_strutture.csv")

df
