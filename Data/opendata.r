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
m

mapshot(m,file = "ASST.pdf")
#
# lat: 45.70186352230473   lon: 9.475879669189453
# lat: 45.597224374966075   lon: 9.737491607666016
m

df <- read.csv("../Geo_strutture.csv")

df
library(magrittr)
library(rayshader)
library(av)
localtif = raster::raster(file.choose())

#And convert it to a matrix:
elmat = matrix(raster::extract(localtif, raster::extent(localtif), buffer = 1000),
               nrow = ncol(localtif), ncol = nrow(localtif))
library(png)
foto <- png::readPNG(file.choose())
# define label
zscale <- 0.5
#We use another one of rayshader's built-in textures:
elmat %>%
  sphere_shade(texture = "imhof1") %>%
  add_overlay(foto,alphacolor = "white",alphalayer = 0.9) %>% 
  add_shadow(ray_shade(elmat,lambert=FALSE)) %>%
  # add_water(detect_water(elmat)) %>%
  add_shadow(lamb_shade(elmat)) %>%
  add_shadow(ambient_shade(elmat)) %>%
  plot_3d(elmat, solid = T,zscale = zscale, windowsize = c(1000, 800),
          theta = -16, phi = 40, zoom = 0.7, fov = 10
  
render_label(elmat, x = 250, y = 290, z = 350, 
             zscale = zscale, text = "Lago di Como", textsize = 3, linewidth = 5,color = "blue",
             textcolor = "blue")
render_movie("test",type = "orbit",fps = 60)
render_snapshot()
render_depth(focus = 0.4, focallength = 40)

montshadow = ray_shade(montereybay, zscale = 50, lambert = FALSE)
montamb = ambient_shade(montereybay, zscale = 50)
montereybay %>% 
  sphere_shade(zscale = 10, texture = "imhof1") %>% 
  add_shadow(montshadow, 0.5) %>%
  add_shadow(montamb) %>%
  plot_3d(montereybay, zscale = 50, fov = 0, theta = -45, phi = 45, windowsize = c(1000, 800), zoom = 0.75,
          water = TRUE, waterdepth = 0, wateralpha = 0.5, watercolor = "lightblue",
          waterlinecolor = "white", waterlinealpha = 0.5)
render_snapshot(clear = TRUE)









draw <- function(character,lun){
  
  shaft <- c(rep(" ",nchar(character)),character, character,"\n")
  balls <- c(character,rep(character,2),character)
  message(
    rep(shaft, lun),balls
    )
}

