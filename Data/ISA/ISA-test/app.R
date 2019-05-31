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
library(plotly)
library(readr)
library(arm)
library(caret)
library(naivebayes)
library(dygraphs)
library(xts)
rds <- as.list(list.files(here("ISA-test/"),"*7_*"))
modelli <- lapply(rds,function(x) readRDS(x))

 # modello_predizione <- readRDS(here("tm_bag_prediction7_glm.rds"))

source(file = here("ISA-test/morpher.r"))
# source(file = here("ISA-test","estrazione_nomi_allarmi.r"))
# 


# MODULI ------------------------------------------------------------------

modulo_upload <- fileInput(
  "txt",
  label = NULL,
  accept = c("text/csv", "text/comma-separated-values,text/plain", ".txt"),
  multiple = T
)
# UI ----------------------------------------------------------------------


ui <- tagList(dashboardPage( skin = "green",
            
  
  ## HEADER ------------------------------------------------------------------
  
  dashboardHeader(title = "SML"),
  ## SIDEBAR -----------------------------------------------------------------
  dashboardSidebar(sidebarMenu(
    menuItem(
      tags$strong("Caricamento scontrini"),
      tabName = "cs",
      icon = icon("upload"),
      selected = T,
      startExpanded = F
      
    ),
    modulo_upload,
    menuItem(
      startExpanded = T,
      tags$strong("Analisi"),
      menuSubItem(
        tags$strong("Overview"),
        tabName = "Welcomepage",
        icon = icon("drafting-compass"),
        selected = F
      ),
      menuSubItem(
        tags$strong("Allarmi"),
        tabName = "alarms",
        icon = icon("warning"),
        selected = F
      ),
      menuSubItem(
        tags$strong("Strumentazione"),
        tabName = "strum",
        icon = icon("stethoscope",lib = "font-awesome"),
        selected = F
      )
      

    )
   
  )),
  
  
  ## BODY --------------------------------------------------------------
  
  
  dashboardBody(
    useSweetAlert(),
    tabItems(
      tabItem(
        tabName="cs",
        h2("Per iniziare, carica gli scontrini nel menù a sinistra"),
        br(),
        h2("poi clicca sul sottomenù chiamato \"Overview\"" )
        ),
      tabItem(
        
        tabName = "Welcomepage",
        fluidPage(
          h2("Overview"),
            fluidRow(column(
            width = 11,
            div(id = 'clickdiv1',
                valueBoxOutput("ib1")),
            div(id = 'clickdiv2',
                valueBoxOutput("ib2")),
            valueBoxOutput("ib3"),
            valueBoxOutput("ib4")
          )),
          
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
          
          fluidRow(column(
            width = 12,
            tabBox(
              width = 12,
              title = "Grafici-test",
              
              tabPanel(title = "Numero di cicli per categoria di strumento",
                       plotlyOutput("plot2")),
              tabPanel(title = "Numero di cicli per operatore",
                       plotlyOutput("plot3")),
              tabPanel(title = "Cicli effettuati nel periodo selezionato",
                       dygraphOutput("dygraph"))
            )
          ))
        )
      ),

      
      tabItem(
        tabName = "alarms",
        fluidPage(
          h2("Analisi degli allarmi"),
          box(title = "Allarmi per categoria di strumento",
                   plotlyOutput("plot4"),width = 12)
          )
        ),
      tabItem(
        tabName = "strum",
        fluidPage(
          h2("Strumentazione riprocessata"),
          uiOutput("picker_str")
        )
        
      )

      )
    )
  )
  
  
 
)






# SERVER ------------------------------------------------------------------

server <- function(input, output, session) {
  session$onSessionEnded(stopApp)
  

# elaborazione dati in ingresso --------------------------------------------------------

  
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
    
    df$`ESITO CICLO` <- factor(df$`ESITO CICLO`)
    
    
    colnames(df)[which(names(df) == "ESITO CICLO")] <- "ESITO.CICLO"
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
  data_r <- reactiveValues(data = iris, name = "scontrini")
  cicli <- reactive({
    req(input$txt)
    df <- scontrino_df()
    
    df %<>% mutate("GIORNO" = factor(cut.Date(
      as.Date(.$`INIZIO CICLO`),
      breaks = "1 day",
      labels = F
    )))
    df_giorni <- as.list(split(df, f = df$GIORNO))
    
    
    n_allarmi <- function(df_giorno){
      nirreg <-  as.numeric(nrow(df_giorno[-which(df_giorno$ESITO.CICLO=="CICLO REGOLARE"),]))
      nreg <- as.numeric(nrow(df_giorno[-which(df_giorno$ESITO.CICLO=="CICLO IRREGOLARE"),]))
      
      giorno <- unique(as.Date(df_giorno$`INIZIO CICLO`))
      return(data.frame("giorno"=giorno,
                        "numero di cicli irregolari"=nirreg,
                        "numero di cicli regolari"=nreg))
      
    }
    
    andamento_allarmi <- lapply(df_giorni,n_allarmi) %>% do.call("rbind",.)
    cicli_irregolari <- as.xts(ts(start = c(first(andamento_allarmi$giorno)), 
                                  end=c(last(andamento_allarmi$giorno)),
                                  data = c(andamento_allarmi$numero.di.cicli.irregolari)))
    cicli_regolari <-  as.xts(ts(start = c(first(andamento_allarmi$giorno)), 
                                 end=c(last(andamento_allarmi$giorno)),
                                 data = c(andamento_allarmi$numero.di.cicli.regolari)))
    
    giorni <- cbind(cicli_irregolari,cicli_regolari)
    return(giorni)
    })
  
  observeEvent(scontrino_df(), {
    if (is_empty(scontrino_df()) == F) {
      data_r$data <- scontrino_df()
      data_r$name <- "scontrini"
    } else {
      data_r$data <- mtcars
      data_r$name <- "mtcars"
    }
  })
  

# tabelle -----------------------------------------------------------------
  output$scontrino_table <- DT::renderDT(server=FALSE,{
    df <- scontrino_df()[,-which(names(scontrino_df())%in% "testo")]
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
  output$table <- DT::renderDT(server=FALSE,{
    df <- scontrino_df()[,-which(names(scontrino_df())%in% "testo")]
    
    df$`INIZIO CICLO` <- as.character(df$`INIZIO CICLO`)
    info <- info_giorni()
    filename <- info[[4]]
    
    DT::datatable(df[which(df$ALLARMI != "Nessun allarme rilevato"), ],
                  
                  rownames = FALSE,
                  extensions = c('Buttons'),
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
                    scrollY = "600px"
                  )
    )
    
  })


  
  # 
  # callModule(module = esquisserServer,
  #            id = "esq",
  #            data = data_r)
  
  # vista_giorni <- valori_infobox()
  # giorno_inizio <- as.character.Date(as_date(vista_giorni[["lista"]][["1"]][["INIZIO CICLO"]][1]))
  # giorno_fine <- as.character.Date(as_date(vista_giorni[["lista"]][[ngiorni]][["INIZIO CICLO"]][1]))
  # periodo <- paste0("Dal ", giorno_inizio, " al ", giorno_fine)
  
  output$titletab <- renderText({
   info <- info_giorni()
   info[[4]]
  })

# infoboxes ---------------------------------------------------------------

  
  output$ib1 <- renderValueBox({
    info <- info_giorni()
    valueBox(
      info[[1]],
      subtitle = strong(paste0("Giorni di attività")),
      icon = icon("list"),
      color = "olive"
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
      nrow(scontrino_df()),
      subtitle = strong("Cicli effettuati"),
      icon = icon("recycle",lib = "font-awesome"),
      color = "light-blue"
    )
  })
  output$ib4 <- renderValueBox({
    valueBox(
      paste0(round((predizione()$pos)*100,digits = 2),"%"),
      subtitle = strong("Probabilità di guasto nei prossimi 7 giorni di utilizzo"),
      icon = icon("robot",lib = "font-awesome"),
      color = "teal"
    )
  })

# plot --------------------------------------------------------------------

  
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
    ggplot(data = scontrino_df()) +
      aes(x = `TIPO CICLO`, fill = CATEGORIA) +
      geom_bar(position = "dodge") +
        scale_fill_viridis_d(option  = "viridis")+
      labs(y = "Numero di cicli effettuati") +
      theme_classic() +
      theme(legend.position = "bottom")+
      coord_flip() 
  })
  output$plot3 <- renderPlotly({
    ggplot(data = scontrino_df()) +
      aes(fill = CATEGORIA, x = OPERATORE) +
      geom_bar() +
      theme_classic() +
      facet_wrap(vars(ESITO.CICLO))
  })
  output$plot4 <- renderPlotly({
    ggplot(data = scontrino_df()[-which(scontrino_df()$ALLARMI=="Nessun allarme rilevato"),]) +
        aes(fill = ALLARMI, x = CATEGORIA) +
        geom_bar()+
        scale_fill_viridis_d(option  = "viridis",direction = -1) +
        theme_minimal() +
        facet_wrap(vars(ESITO.CICLO)) +
        coord_flip()
    
  })
  output$dygraph <- renderDygraph({
    dygraph(cicli())%>%
      dyRangeSelector() %>%
      dyRoller(rollPeriod = 4) %>%
      dyHighlight(highlightCircleSize = 5, 
                  highlightSeriesBackgroundAlpha = 0.4,
                  hideOnMouseOut = TRUE,
                  highlightSeriesOpts = list(strokeWidth = 3)) %>%
      dyOptions(colors = c("red", "green"))
  })

# predizione --------------------------------------------------------------

  
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
  

# controlli ---------------------------------------------------------------
output$picker_str <- renderUI({
  req(input$txt)
  pickerInput(
    inputId = "picker_str",
    label = "Seleziona uno strumento", 
    choices = levels(scontrino_df()$CATEGORIA)
  )
})

# alerts ------------------------------------------------------------------

  observeEvent(input$txt, {
    sendSweetAlert(
      session = session,
      title = "File caricati",
      text = "Caricamento avvenuto con successo",
      type = "success"
    )
  })
  
  
}


# Run the application
shinyApp(ui = ui, server = server)
