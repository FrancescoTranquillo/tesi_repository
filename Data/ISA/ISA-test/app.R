#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)
library(shinyalert)
library(shinyWidgets)
library(DT)
library(esquisse)
library(lubridate)
library(here)
library(shinyBS)
library(shinytest)
library(plotly)
library(readr)

# modelli <- lapply(as.list(list.files(here(),"*7_*")),readRDS)

# modello_predizione <- readRDS(here("tm_bag_prediction7_glm.rds"))

source(file = here("ISA-test","morpher.r"))
# source(file = here("ISA-test","estrazione_nomi_allarmi.r"))
# 


ui <- tagList(dashboardPage(
  
  # HEADER ------------------------------------------------------------------
  dashboardHeader(title = "SML"),
  # sidebar -----------------------------------------------------------------
  dashboardSidebar(sidebarMenu(
    menuItem(
      tags$strong("Caricamento scontrini"),
      tabName = "cs",
      icon = icon("upload"),
      selected = F,
      fileInput(
        "txt",
        label = NULL,
        accept = c("text/csv", "text/comma-separated-values,text/plain", ".txt"),
        multiple = T
      ),
      startExpanded = T
      
    ),
    menuItem(
      tags$strong("Analisi"),
      tabName = "Welcomepage",
      icon = icon("drafting-compass"),
      selected = F
    ),
    menuItem(
      tags$strong("Grafici"),
      tabName = "plot",
      icon = icon("chart-bar"),
      selected = F
    )
  )),
  
  
  # body --------------------------------------------------------------------
  
  
  dashboardBody(

    
    tabItems(
      tabItem(
        tabName = "Welcomepage",
        fluidPage(
          style = "max-height: 100vh; overflow-y: auto;" ,
          
          fluidRow(
            div(id = 'clickdiv1',
                valueBoxOutput("ib1")),
            div(id = 'clickdiv2',
                valueBoxOutput("ib2")),
            column(infoBox("BOX",value = "test"),width = 4)
            
            ),
          
          fluidRow(
            valueBoxOutput("ib3"),
            valueBoxOutput("ib4")
          ),
          bsTooltip(
            "ib2",
            "Clicca per visualizzare gli allarmi",
            placement = "bottom",
            trigger = "hover",
            options = NULL
          ),
          bsModal(
            "modalExample1",
            "Allarmi rilevati",
            "clickdiv2",
            size = "large",
            dataTableOutput("table")
          ),
          bsTooltip(
            "ib1",
            "Clicca per visualizzare il resoconto dei cicli",
            placement = "bottom",
            trigger = "hover",
            options = NULL
          ),
          bsModal(
            "modalExample2",
            "Scontrini analizzati",
            "clickdiv1",
            size = "large",
            dataTableOutput("scontrino_table")
          ),
          fluidRow(
            box(title = "Numero di allarmi rilevati nel periodo di attività analizzato",
                plotlyOutput("plot1")
            ),
            box(title = "Numero di cicli per categoria di strumento",
                plotlyOutput("plot2")
            )
            
          )
          
          
        )
          
        ),

      
      tabItem(
        tabName = "plot",
        tags$div(# needs to be in fixed height container
          style = "position: fixed; top: 0; bottom: 0; right: 12; left: 12;",
          esquisserUI(id = "esq"))
      )
    )
  ),
  
  
  skin = "green"
))






server <- function(input, output, session) {
  scontrino_txt <- reactive({
    path <- input$txt$datapath
    text <- lapply(path, readLines, encoding = "UTF8")
    return(text)
  })
  scontrino_df <- reactive({
    req(input$txt)
    df <- lapply(scontrino_txt(), morpher) %>% do.call("rbind", .)
    
    df$`INIZIO CICLO` <-
      parse_date_time(df$`INIZIO CICLO`, orders = "dmy HMS")
    
    colnames(df)[which(names(df) == "MATRICOLA")] <- "NUMERO SERIALE STRUMENTO"
    colnames(df)[which(names(df) =="STRUMENTO")] <- "MODELLO DELLO STRUMENTO"
    colnames(df)[which(names(df) =="NUMERO SERIALE")] <- "NUMERO SERIALE LAVAENDOSCOPI"
  
    
    return(df)
  })
  info_giorni <- reactive({
    
    vista_giorni <- valori_infobox()
    ngiorni <- vista_giorni$n
    giorno_inizio <- as.character.Date(as_date(vista_giorni[["lista"]][["1"]][["INIZIO CICLO"]][1]))
    giorno_fine <- as.character.Date(as_date(vista_giorni[["lista"]][[ngiorni]][["INIZIO CICLO"]][1]))
    periodo <- paste0("Dal ", giorno_inizio, " al ", giorno_fine)
    
    info_list <- list(
      ngiorni,
      giorno_inizio,
      giorno_fine,
      periodo
    )
    return(info_list)
    
  })
  valori_infobox <- reactive({
    df_ib <- scontrino_df()
    df_ib %<>% mutate("GIORNO" = factor(cut.Date(
      as.Date(.$`INIZIO CICLO`),
      breaks = "1 day",
      labels = F
    )))
    df_giorni <- as.list(split(df_ib, f = df_ib$GIORNO))
    ngiorni <- length(df_giorni)
    vista_giorni <- list(lista=df_giorni, n=ngiorni)
    return(vista_giorni)
  })
  
  output$scontrino_table <- DT::renderDT(server=FALSE,{
    df <- scontrino_df()[,-ncol(scontrino_df())]
    df$`INIZIO CICLO` <- as.character(df$`INIZIO CICLO`)
    info <- info_giorni()
    filename <- info[[4]]
    DT::datatable(df,
                 
              rownames = FALSE,
              extensions = 'Buttons',
              options = list(
                dom = 'Bfrtipl',
                buttons = list('copy', 'csv', 'excel',
                                         list(
                                           extend = 'pdf',
                                           pageSize = 'A4',
                                           orientation = 'landscape',
                                           filename=paste0("Resoconto cicli_",filename),
                                           title = paste("ISA Monitoring System",
                                                         paste0("Resoconto cicli effettuati"),
                                                         filename,
                                                         sep = "\n"))),
                scrollX = TRUE
              )
    )

  })
  
  data_r <- reactiveValues(data = iris, name = "scontrini")
  
  observeEvent(scontrino_df(), {
    if (is_empty(scontrino_df()) == F) {
      data_r$data <- scontrino_df()
      data_r$name <- "scontrini"
    } else {
      data_r$data <- mtcars
      data_r$name <- "mtcars"
    }
  })
  
  
  callModule(module = esquisserServer,
             id = "esq",
             data = data_r)
  
  # vista_giorni <- valori_infobox()
  # giorno_inizio <- as.character.Date(as_date(vista_giorni[["lista"]][["1"]][["INIZIO CICLO"]][1]))
  # giorno_fine <- as.character.Date(as_date(vista_giorni[["lista"]][[ngiorni]][["INIZIO CICLO"]][1]))
  # periodo <- paste0("Dal ", giorno_inizio, " al ", giorno_fine)
  
  output$titletab <- renderText({
   info <- info_giorni()
   info[[4]]
  })
  
  output$ib1 <- renderValueBox({
    info <- info_giorni()
    valueBox(
      info[[1]],
      subtitle = strong(paste0("Giorni di attività")),
      icon = icon("list"),
      color = "olive"
    )
  })
  
  output$table <- DT::renderDT(server=FALSE,{
    df <- scontrino_df()[,-ncol(scontrino_df())]
    
    df$`INIZIO CICLO` <- as.character(df$`INIZIO CICLO`)
    info <- info_giorni()
    filename <- info[[4]]

    DT::datatable(df[which(df$ALLARMI != "Nessun allarme rilevato"), ],
              
              rownames = FALSE,
              extensions = c('Buttons','FixedColumns'),
              options = list(
                dom = 'Bfrtipl',
                orientation ='landscape',
                buttons = list('copy', 'csv', 'excel',
                            list(
                              extend = 'pdf',
                              pageSize = 'A4',
                              orientation = 'landscape',
                              filename=paste0("Resoconto allarmi_",filename),
                              title = paste("ISA Monitoring System",
                                            paste0("Resoconto allarmi rilevati"),
                                            filename,
                                            sep = "\n"))),
                scrollX = TRUE, 
                fixedColumns = list(leftColumns = 2, rightColumns = 1),
                scrollY = "600px"
                )
    )
              
  })
  output$ib2 <- renderValueBox({
    icona <- ifelse(nrow(scontrino_df()[which(scontrino_df()$ALLARMI != "Nessun allarme rilevato"), ]) >
             0, "warning", "check-circle")
    valueBox(
      nrow(scontrino_df()[which(scontrino_df()$ALLARMI != "Nessun allarme rilevato"),]),
      subtitle = strong("Allarmi rilevati"),
      
      icon = icon(icona),
      
      color = ifelse(nrow(scontrino_df()[which(scontrino_df()$ALLARMI != "Nessun allarme rilevato"), ]) >
                       0, "orange", "green")
    )

  })
  
  output$ib3 <- renderValueBox({
    valueBox(
      nrow(scontrino_df()[which(scontrino_df()$`TIPO CICLO`!="AUTOSANIFICAZIONE"),]),
      subtitle = strong("Riprocessazioni effettuate"),
      icon = icon("recycle",lib = "font-awesome"),
      color = "light-blue"
    )
  })
  
  output$plot1 <- renderPlotly({
    
      ggplotly(ggplot(data = scontrino_df()[which(scontrino_df()$ALLARMI!="Nessun allarme rilevato"),]) +
                 aes(x = ALLARMI) +
                 geom_bar(fill = "#ff7f00") +
                 theme_classic() +
                 labs(y = "Numero di allarmi rilevati")+
                 coord_flip()
      )
  })
  output$plot2 <- renderPlotly({
    ggplotly(ggplot(data = scontrino_df()) +
      aes(x = `TIPO CICLO`, fill = CATEGORIA) +
      geom_bar(position = "dodge") +
        scale_fill_viridis_d(option  = "viridis")+
      labs(y = "Numero di cicli effettuati") +
      theme_classic() +
      coord_flip())
  })
  
  predizione <- reactive({
    
    df_ib <- scontrino_df()
    df_ib %<>% mutate("GIORNO" = factor(cut.Date(
      as.Date(.$`INIZIO CICLO`),
      breaks = "1 day",
      labels = F
    )))
    
    df_giorni <- as.list(split(df_ib, f = df_ib$GIORNO))
    df <- last(df_giorni)

    df_predizione <- meta(df)
    risultati <- lapply(modelli, function(modello) predict(modello,df_predizione,type = "prob")) %>% 
      do.call("rbind",.) %>% 
      summarise_all(.,median,na.rm=T)
    return(risultati)
  })
  
  output$ib4 <- renderValueBox({
    valueBox(
      paste0(round((predizione()$pos)*100,digits = 2),"%"),
      subtitle = strong("Probabilità di guasto nei prossimi 7 giorni di utilizzo"),
      icon = icon("robot",lib = "font-awesome"),
      color = "teal"
    )
  })
}


# Run the application
shinyApp(ui = ui, server = server)
