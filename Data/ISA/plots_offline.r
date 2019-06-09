library(plyr)
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
library(dygraphs)
library(xts)
library(tidyquant)
library(pbapply)

# path <- here("isareport16-19")
# lista_scontrini <- as.list(list.files(path, pattern = "*.txt"))
# 
# scontrinol <- lapply(lista_scontrini, function(path_scontrino)
#   readLines(paste0(path, "\\", path_scontrino), encoding = "UTF-8"))
# 
# tabella_scontrini <- pblapply(scontrinol, morpher) %>%
#   bind_rows(.)
# # 
tabella_scontrini <- read.csv2(here("tabella_scontrini_multimacchina.csv"),header = T)
tabella_scontrini$`INIZIO CICLO` <-  parse_date_time(tabella_scontrini$`INIZIO CICLO`, orders = "dmy HMS")
tabella_scontrini$`TIPO CICLO` <- factor(tabella_scontrini$`TIPO CICLO`)
tabella_scontrini$STRUMENTO <- factor(tabella_scontrini$STRUMENTO)
tabella_scontrini$CATEGORIA <- factor(tabella_scontrini$CATEGORIA)
tabella_scontrini$MATRICOLA <- factor(tabella_scontrini$MATRICOLA)
tabella_scontrini$OPERATORE <- factor(tabella_scontrini$OPERATORE)
tabella_scontrini$ALLARMI <- factor(tabella_scontrini$ALLARMI)
tabella_scontrini$`ESITO CICLO` <- factor(tabella_scontrini$`ESITO CICLO`)

col <-  c(1:2637)
tabella_scontrini$NUMERO.SERIALE <- as.character(tabella_scontrini$NUMERO.SERIALE)
tabella_scontrini$NUMERO.SERIALE[col] <- "lava.2"
tabella_scontrini$NUMERO.SERIALE <- factor(tabella_scontrini$NUMERO.SERIALE)
colnames(tabella_scontrini)[which(names(tabella_scontrini) == "ESITO CICLO")] <- "ESITO.CICLO"

levels(tabella_scontrini$OPERATORE)
operatori_selezionati <- levels(tabella_scontrini$OPERATORE)[8:10]
t_selected <- tabella_scontrini[which(tabella_scontrini$OPERATORE%in%operatori_selezionati),]

# tabella_scontrini %<>% mutate("GIORNO" = factor(cut.Date(
#   as.Date(.$`INIZIO CICLO`),
#   breaks = "1 day",
#   labels = F
# )))
# df_giorni <- as.list(split(tabella_scontrini, f = tabella_scontrini$GIORNO))
# 
# 
# n_allarmi <- function(df_giorno){
#   nirreg <-  as.numeric(nrow(df_giorno[-which(df_giorno$ESITO.CICLO=="CICLO REGOLARE"),]))
#   nreg <- as.numeric(nrow(df_giorno[-which(df_giorno$ESITO.CICLO=="CICLO IRREGOLARE"),]))
# 
#   giorno <- unique(as.Date(df_giorno$`INIZIO CICLO`))
#   return(data.frame("giorno"=giorno,
#                     "numero di cicli irregolari"=nirreg,
#                     "numero di cicli regolari"=nreg))
#   
# }
# 
# andamento_allarmi <- lapply(df_giorni,n_allarmi) %>% do.call("rbind",.)
# 
# 
# ggplot(data = andamento_allarmi,aes(x=giorno,y=numero.di.cicli.irregolari))+
#   geom_line()+
#   geom_smooth()
# 
# library(dygraphs)
# library(xts)
# 
# cicli_irregolari <- as.xts(ts(start = c(first(andamento_allarmi$giorno)), 
#                     end=c(last(andamento_allarmi$giorno)),
#                     data = c(andamento_allarmi$numero.di.cicli.irregolari)))
# cicli_regolari <-  as.xts(ts(start = c(first(andamento_allarmi$giorno)), 
#                          end=c(last(andamento_allarmi$giorno)),
#                          data = c(andamento_allarmi$numero.di.cicli.regolari)))
# 
# giorni <- cbind(cicli_irregolari,cicli_regolari)
# HoltWinters(giorni$cicli_regolari)
# 
# library(v)
# dygraph(giorni) %>% dyRangeSelector() %>% dyRoller(rollPeriod = 14) %>% 
#   dyHighlight(highlightCircleSize = 5, 
#               highlightSeriesBackgroundAlpha = 0.4,
#               hideOnMouseOut = TRUE) %>% 
#   
#   dyOptions(colors = c("orange", "green"))


# numero di allarmi per tipo di strumento ---------------------------------

esquisser()

library(ggplot2)
library(viridis)

df <- tabella_scontrini[-which(tabella_scontrini$ALLARMI=="Nessun allarme rilevato"),]

levels(df$ALLARMI)
df_melted <- data.frame("strumenti"=levels(df$CATEGORIA),
                        "allarme"=c(levels(df$ALLARMI)))
ggplotly(
  ggplot(data = tabella_scontrini[-which(tabella_scontrini$ALLARMI=="Nessun allarme rilevato"),]) +
  aes(fill = ALLARMI, x = CATEGORIA) +
  geom_bar(color="black",width = 0.8,size=0.2)+
  scale_fill_viridis_d(option  = "viridis",direction = 1) +
  theme_minimal() +
  scale_x_discrete()+
  facet_wrap(vars(ESITO.CICLO)) +
  coord_flip()
            
)

glimpse(tabella_scontrini)
df <- tabella_scontrini %>%.[which(.$ALLARMI=="Allarme temperatura massima acqua"),]
esquisser()

totale_allarmi <- function(strumento){
  dff <- tabella_scontrini[which(tabella_scontrini$CATEGORIA==strumento),10]
  
}
tabella_scontrini <-sort(x = tabella_scontrini$CATEGORIA,by=count(tabella_scontrini$ALLARMI)) 






# sankey ------------------------------------------------------------------


# df <- tabella_scontrini[which(tabella_scontrini$ESITO.CICLO=="CICLO IRREGOLARE"),]
df <- tabella_scontrini
colnames(df)[which(names(df) == "MATRICOLA")] <- "NUMERO SERIALE STRUMENTO"
library(rlist)
sankey_table <- function(tab,nome){
  library(rlist)
  library(viridis)
  
  pairs <- cbind(nome[-length(nome)], nome[-1])
  dftot <- apply(pairs, MARGIN =1, function(j) plyr::count(tab,paste0("`",j,"`"))) %>% 
    lapply(.,setNames, nm=c("source","target", "value")) %>% 
    do.call("rbind",.)
      
  dftot$source <- as.character(dftot$source)
  dftot$target <- as.character(dftot$target)
  source <- dftot$source
  target <- dftot$target
  value <- dftot$value
  actors <- unique(c(dftot$source, dftot$target))
  l <- length(actors)
  actors_t <- data.frame("actors" = actors, "id" = 0:(l - 1))
  
  convert_name_id <- function(node_name) {
    actors_t$id[which(actors_t$actors %in% node_name)]
  }
  
  sankey_list <-
    list(
      nodes = data.frame("actors" = factor(actors_t$actors)),
      links = data.frame(
        "source" = sapply(source, convert_name_id, USE.NAMES = F),
        "target" = sapply(target, convert_name_id, USE.NAMES = F),
        "value" = value
      )
    )
  sankey_list$nodes <- mutate(sankey_list$nodes,"nodecolor" = viridis(nlevels(sankey_list$nodes$actors), alpha = 0.6, option ="viridis"))
  sankey_list$links <- mutate(sankey_list$links,"linkcolor" = viridis((nrow(sankey_list$links)*ncol(sankey_list$links)), alpha = 0.2, option ="viridis"))
  return(sankey_list)
}


stb <- sankey_table(df[which(df$ESITO.CICLO%in%"CICLO IRREGOLARE"&df$CATEGORIA%in%"BRONCOSCOPIO"&!df$ALLARMI%in%"Nessun allarme rilevato"),],
                    c("ALLARMI","NUMERO SERIALE STRUMENTO"))


  p <- plot_ly(
    type = "sankey",
    orientation = "h",
    arrangement = 'freeform',
    
    node = list(
      
      label=stb$nodes$actors,
      thickness = 15,
      pad=10,
      color=stb$nodes$nodecolor,
      line = list(color = "black",
                  width = 0.5)
    ),
    
    link = list(
      source = stb$links$source,
      target = stb$links$target,
      value = stb$links$value,
      color=stb$links$linkcolor
      
    )
  ) 

  ezsankey <- function(tab,nome){
    stb <- sankey_table(tab,nome)
    p <- plot_ly(
      type = "sankey",
      orientation = "h",
      arrangement = 'freeform',
      
      node = list(
        
        label=stb$nodes$actors,
        thickness = 15,
        pad=10,
        color=stb$nodes$nodecolor,
        line = list(color = "black",
                    width = 0.5)
      ),
      
      link = list(
        source = stb$links$source,
        target = stb$links$target,
        value = stb$links$value,
        color=stb$links$linkcolor
        
      )
    ) %>% 
      layout(font = list(size = 14))
    return(p)
    
  }

  ezsankey(df[which(!df$ALLARMI%in%"Nessun allarme rilevato"&df$CATEGORIA%in%c("BRONCOSCOPIO","DUODENOSCOPIO")),],
           c("ESITO.CICLO", "CATEGORIA","MATRICOLA", "ALLARMI"))

              