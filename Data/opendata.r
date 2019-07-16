# script per open data sanità lombardia



 #ciao rosti


 
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
  addPolygons(data =brianza, opacity = 0.1, label= "ATS BRIANZA") %>%
  addPolygons(data =asst, opacity = 0.7,col="red",label= "ASST VIMERCATE") %>%
  addMarkers(data = asst_ss,lng = asst_ss@coords[,1],lat = asst_ss@coords[,2], label  = asst_ss$DENOM_STRU,
             labelOptions = labelOptions(noHide = T,))

  # addMarkers(lng=as.numeric(df$COORDINATA.GEOGRAFICA.Y), lat=as.numeric(df$COORDINATA.GEOGRAFICA.X), popup=df$DESCRIZIONE.STRUTTURA.DI.RICOVERO)


#
# lat: 45.70186352230473   lon: 9.475879669189453
# lat: 45.597224374966075   lon: 9.737491607666016
m

df <- read.csv("../Geo_strutture.csv")

df

library(rayshader)
loadzip = tempfile() 
download.file("https://tylermw.com/data/dem_01.tif.zip", loadzip)
localtif = raster::raster(file.choose())
unlink(loadzip)

#And convert it to a matrix:
elmat = matrix(raster::extract(localtif, raster::extent(localtif), buffer = 1000),
               nrow = ncol(localtif), ncol = nrow(localtif))

zscale <- 1
#We use another one of rayshader's built-in textures:
elmat %>%
  sphere_shade(texture = "imhof1") %>%
  add_shadow(ray_shade(elmat, maxsearch = 300), 0.5) %>%
  
  add_water(detect_water(elmat), color = "desert") %>%
  # add_shadow(ambmat, 0.5) %>%
  plot_3d(elmat, solid = T,zscale = zscale, windowsize = c(1000, 800),
          theta = 15, phi = 60, zoom = 0.65, fov = 30,  water = TRUE)
render_snapshot()
render_depth(focus = 0.6, focallength = 200, clear = TRUE)

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
