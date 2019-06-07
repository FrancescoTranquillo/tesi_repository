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
rds <- as.list(list.files(here(),"*7_*"))
modelli <- lapply(rds,function(x) readRDS(x))

 # modello_predizione <- readRDS(here("tm_bag_prediction7_glm.rds"))

#editing offline
source(file = here("ISA-TEST/morpher.r"))

#per pubblicare
# source(file = here("morpher.r"))


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

  dashboardHeader(title = "INSIGHT"),
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
      uiOutput("picker_isa"),
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
      ),
      menuSubItem(
        tags$strong("Operatori"),
        tabName = "operatori",
        icon = icon("user",lib = "font-awesome"),
        selected = F
      )


    )

  )),


  ## BODY --------------------------------------------------------------


  dashboardBody(
    tags$head(tags$style(HTML('

                              .modal-lg {
                              width: 88%;
                              
                              }
                              '))),
    useSweetAlert(),
    tabItems(
      tabItem(
        tabName = "operatori",
        h2("Vista Operatori"),
        fluidPage(
          
          box(title = "Controlli",status = "success",solidHeader = T,collapsible = T,
            width = 3,
            uiOutput("picker_op"),
            uiOutput("picker_op_strum"),
            checkboxGroupButtons(
              inputId = "opzioni",
              label = "Opzioni",
              choices = c("CICLI REGOLARI", 
                          "CICLI IRREGOLARI"),
              status = "success",
              checkIcon = list(
                yes = icon("ok", 
                           lib = "glyphicon")),
              justified = T,
              size = "normal",
              direction = "vertical"
            )
          ),
          column(
            width=9,
            plotlyOutput("plot3")
          )
          
        )
      ),
      tabItem(
        tabName="cs",
        h2("Per iniziare, carica gli scontrini nel menù a sinistra"),
        br(),
        h2("poi clicca sul sotto menù chiamato \"Overview\"" ),
        br(),
        br(),
        h4("Alcuni scontrini sono disponibili al seguente ",a("link", href="https://drive.google.com/drive/folders/1HVTU2cPdoGsUC9x6dBFchgi8hIMTWxHT"),", scaricabili ed utilizzabili per testare le funzionalità di INSIGHT"),
        h4("I file sono situati all'interno dell'archivio.")
        
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
            div(id='clickdiv3',
                valueBoxOutput("ib3")),
            
            valueBoxOutput("ib4"),
            valueBoxOutput("cicli_reg_overview"),
            valueBoxOutput("cicli_irreg_overview")
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
            fluidRow(
              column(width = 9,
                     dataTableOutput("scontrino_table")
                     ),
              column(width = 3,
                     box(title="Print-out",
                        status="success",
                        solidHeader = T,
                        uiOutput("selected"),width = NULL)
                     )
              )
            ),
          bsTooltip(
            "ib3",
            "Clicca per visualizzare il dettaglio sulle riprocessazioni effettuate",
            placement = "bottom",
            trigger = "hover",
            options = NULL
            ),
          bsModal(
            "Modal3",
            "Riprocessazioni effettuate",
            "clickdiv3",
            size="large",
            plotlyOutput("plot2")
          ),

          fluidRow(column(
            width = 12,
            dygraphOutput("dygraph")
            
          ))
        )
      ),


      tabItem(
        tabName = "alarms",
        fluidPage(
          h2("Analisi degli allarmi"),
          box(title = "Allarmi per categoria di strumento",status = "success",solidHeader = T,
                   plotlyOutput("plot4"),width = 12),
          column(width = 3,
                 box(title="Controlli",
                     uiOutput("picker_str2"),
                     uiOutput("picker_alarms"),
                     solidHeader = T,
                     status = "success",
                     width = NULL)
                 ),
          column(width = 9,
                 plotlyOutput("plot_alarm_distr"))
          )
        ),
      
      tabItem(
        tabName = "strum",
        fluidPage(
          h2("Strumentazione riprocessata"),
          box(width = 12,title = "Cicli eseguiti",status = "success",solidHeader = T,collapsible = T,
            plotlyOutput("plot1")
          ),
          fluidRow(
            column(width = 3,
                   uiOutput("picker_str")),
            column(width=9,
                   valueBoxOutput("ib5"),
                   valueBoxOutput("ib6"),
                   valueBoxOutput("ib7")
            )
            ),
          fluidRow(
            tabBox(width = 12,
              tabPanel("CICLI REGOLARI",
                       dataTableOutput("table_strumentazione_reg")
                       ),
              tabPanel("CICLI IRREGOLARI",
                       dataTableOutput("table_strumentazione_irreg")
                       )
            )
            
          )
        )

      )

      )
    )
  )



)






# SERVER ------------------------------------------------------------------

server <- function(input, output, session) {
  session$onSessionEnded(stopApp)


# elaborazione dati in ingresso --------------------------------------------


  scontrino_txt <- reactive({
    path <- input$txt$datapath
    text <- lapply(path, readLines, encoding = "UTF8")
    return(text)
  })
  creazione_df <- reactive({
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
  scontrino_df <- reactive({
    req(input$txt)
    df <- creazione_df()
    df <- df[which(df$`NUMERO SERIALE LAVAENDOSCOPI` %in% input$picker_isa),]
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
    df <- scontrino_df()[,-which(names(scontrino_df())%in% c("testo","print"))]
    df$`INIZIO CICLO` <- as.character(df$`INIZIO CICLO`)
    info <- info_giorni()
    filename <- info[[4]]
    DT::datatable(df,
                  selection="single",
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
    df <- scontrino_df()[,-which(names(scontrino_df())%in% c("testo","print"))]

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
  

# rendering_tabelle_strumentazione ----------------------------------------

  output$table_strumentazione_reg <- DT::renderDT(server=FALSE,{
    df <- scontrino_df()[which(scontrino_df()$CATEGORIA==input$picker_str & scontrino_df()$ESITO.CICLO%in%"CICLO REGOLARE"),
                         -which(names(scontrino_df())%in% c("testo","print"))]
    df$`INIZIO CICLO` <- as.character(df$`INIZIO CICLO`)
    info <- info_giorni()
    filename <- info[[4]]
    DT::datatable(df,
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
  output$table_strumentazione_irreg <- DT::renderDT(server=FALSE,{
    df <- scontrino_df()[which(scontrino_df()$CATEGORIA==input$picker_str & scontrino_df()$ESITO.CICLO%in%"CICLO IRREGOLARE"),
                         -which(names(scontrino_df())%in% c("testo","print"))]
    df$`INIZIO CICLO` <- as.character(df$`INIZIO CICLO`)
    info <- info_giorni()
    filename <- info[[4]]
    DT::datatable(df,
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
             0, "exclamation-circle", "check-circle")
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
  output$cicli_reg_overview <- renderValueBox({
    req(input$txt)
    df <- scontrino_df()
    df_filtered <- df[which(df$ESITO.CICLO=="CICLO REGOLARE"),]
    valueBox(nrow(df_filtered),
             subtitle = strong("Cicli regolari"),
             icon = icon("check",lib = "font-awesome"),
             color = "green")
  })
  output$cicli_irreg_overview <- renderValueBox({
    req(input$txt)
    df <- scontrino_df()
    df_filtered <- df[which(df$ESITO.CICLO=="CICLO IRREGOLARE"),]
    valueBox(nrow(df_filtered),
             subtitle = strong("Cicli irregolari"),
             icon = icon("warning",lib = "font-awesome"),
             color = "red")
    
  })

  # INFOBOX DELLA PREDIZIONE
  output$ib4 <- renderValueBox({
    valueBox(
      paste0(round((predizione()$pos)*100,digits = 2),"%"),
      subtitle = strong("Probabilità di guasto nei prossimi 7 giorni di utilizzo"),
      icon = icon("robot",lib = "font-awesome"),
      color = "teal"
    )
  })

  # INFOBOX visuale "strumentazione": uno per cicli regolari e uno per gli irregolari
  output$ib5 <- renderValueBox({
    req(input$txt)
    df <- scontrino_df()
    df_filtered <- df[which(df$CATEGORIA==input$picker_str & df$ESITO.CICLO=="CICLO REGOLARE"),]
    box5 <- valueBox(nrow(df_filtered),
             subtitle = strong("Cicli regolari"),
             icon = icon("check",lib = "font-awesome"),
             color = "green"
             )
    return(box5)
  })
  output$ib6 <- renderValueBox({
    req(input$txt)
    df <- scontrino_df()
    df_filtered <- df[which(df$CATEGORIA==input$picker_str & df$ESITO.CICLO=="CICLO IRREGOLARE"),]
    box6 <- valueBox(nrow(df_filtered),
             subtitle = strong("Cicli irregolari"),
             icon = icon("warning",lib = "font-awesome"),
             color = "red"
            )
    
    return(box6)
  })
  output$ib7 <- renderValueBox({
    req(input$txt)
    df <- scontrino_df()
    df_filtered <- df[which(df$CATEGORIA==input$picker_str),]
    valueBox(nrow(df_filtered[-which(df_filtered$ALLARMI=="Nessun allarme rilevato"),]),
             subtitle = strong("Allarmi"),
             icon = icon("exclamation-circle",lib = "font-awesome"),
             color = "orange")
  })
# plot --------------------------------------------------------------------


  output$plot1 <- renderPlotly({
    ggplotly(
      ggplot(data = scontrino_df()) +
        aes(x = CATEGORIA,fill = ESITO.CICLO) +
        geom_bar(position = position_dodge(),
                 color="black",
                 width = 0.8,
                 size=0.2,alpha=0.6)+
        scale_fill_manual(values = c("CICLO REGOLARE" = "#4286f4", "CICLO IRREGOLARE" = "#f44141"))+
        
        theme_minimal() +
        theme(axis.text.x=element_text(angle = 35, hjust = 0))+
        labs(y = "Numero di cicli effettuati",x="Categoria strumento")+
        facet_wrap(vars(`NUMERO SERIALE LAVAENDOSCOPI`))
      
    )
  })
  output$plot2 <- renderPlotly({
    ggplot(data = scontrino_df()) +
      aes(fill = `TIPO CICLO`, x = CATEGORIA) +
      geom_bar(position = "dodge",color="black",
               width = 0.8,size=0.2) +
      scale_fill_viridis_d(option  = "viridis")+
      geom_text(stat="count",
                aes(label=..count..),
                nudge_x=0.10,nudge_y=0.50)+
      labs(y = "Numero di cicli effettuati") +
      theme_minimal() +
      coord_flip()
  })
  

# vista op_selezione cicli regolari/irregolari/entrambi -------------------
  
  sceltacicli <- reactive({
    req(length(input$opzioni)>0)
    if(input$opzioni=="CICLI REGOLARI"){
      return("CICLO REGOLARE")
    } else
      return("CICLO IRREGOLARE")
  })
  sceltaplot <- reactive({
    req(length(input$opzioni)>0)
    if(length(input$opzioni)==1){
      filtro <- scontrino_df()[which(scontrino_df()$OPERATORE%in%input$picker_op & scontrino_df()$ESITO.CICLO%in%sceltacicli()),]
      req(nrow(filtro) > 0)
      g <- ggplot(data = filtro) +
        aes(x = OPERATORE) +
        geom_bar(aes(fill=CATEGORIA),color="black",
                 width = 0.8,size=0.2,alpha=0.8) +
        geom_text(stat="count",
                  aes(label=..count..),
                  nudge_x=0,nudge_y=0.30)+
        scale_fill_viridis_d(option  = "viridis",direction = -1)+
        theme_minimal()
    } else
      filtro <- scontrino_df()[which(scontrino_df()$OPERATORE%in%input$picker_op),]
      req(nrow(filtro) > 0)
      g <- ggplot(data = filtro) +
        aes(x = OPERATORE) +
        geom_bar(aes(fill=CATEGORIA),color="black",
                 width = 0.8,size=0.2,alpha=0.8) +
        geom_text(stat="count",
                  aes(label=..count..),
                  nudge_x=0,nudge_y=0.30)+
        scale_fill_viridis_d(option  = "viridis",direction = -1)+
        theme_minimal()+
        facet_wrap(vars(ESITO.CICLO, `NUMERO SERIALE LAVAENDOSCOPI`))
      
    return(g)
      }) 
  output$plot3 <- renderPlotly({
    sceltaplot()
  })
  output$plot4 <- renderPlotly({
    ggplot(data = scontrino_df()[-which(scontrino_df()$ALLARMI=="Nessun allarme rilevato"),]) +
        aes(fill = ALLARMI, x = CATEGORIA) +
        geom_bar(color="black",
                 width = 0.8,size=0.2,alpha=0.8)+
        scale_fill_viridis_d(option  = "viridis",direction = -1) +
        theme_minimal() +
        facet_wrap(vars(`NUMERO SERIALE LAVAENDOSCOPI`)) +
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
      dyOptions(colors = c("red", "green"),
                stepPlot = TRUE)
  })
  output$plot_alarm_distr <- renderPlotly({
    ggplot(data = scontrino_df()[which(scontrino_df()$ALLARMI %in%input$picker_alarms &scontrino_df()$CATEGORIA %in%input$picker_str2 ),]) +
      aes(x = `NUMERO SERIALE LAVAENDOSCOPI`) +
      geom_bar(color="black",aes(fill=ALLARMI),
               width = 0.8,size=0.2,alpha=0.8)+
      geom_text(stat="count",
                aes(label=..count..),
                nudge_x=0,nudge_y=0.30)+
      scale_fill_viridis_d(option  = "viridis",direction = -1) +
      theme_minimal() 
    
    
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
  output$picker_str2 <- renderUI({
    req(input$txt)
    pickerInput(
      inputId = "picker_str2",
      label = "Seleziona uno strumento",
      choices = levels(scontrino_df()$CATEGORIA)
    )
  })
output$picker_op <- renderUI({
    req(input$txt)
    pickerInput(
      inputId = "picker_op",
      label = "Seleziona un operatore",
      choices = levels(factor(as.character(scontrino_df()$OPERATORE))),
      multiple = TRUE,
      options = list(
        title = "Per iniziare, carica i file nel menù a sinistra",
        `live-search` = TRUE,
        `actions-box`= TRUE
        )
    )
  })
output$picker_isa <- renderUI({
  req(input$txt)
  pickerInput(
    inputId = "picker_isa",
    label = "Seleziona una macchina",
    choices = levels(factor(as.character(creazione_df()$`NUMERO SERIALE LAVAENDOSCOPI`))),
    multiple = T,
    options = list(
      `live-search` = F,
      `actions-box`= T
    )
  )
  
})
output$picker_alarms <- renderUI({
  req(input$txt)
  pickerInput(
    inputId = "picker_alarms",
    label = "Seleziona un allarme",
    choices = levels(factor(as.character(creazione_df()$ALLARMI))),
    multiple = T,
    options = list(
      `live-search` = F,
      `actions-box`= T
    )
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
  
# printaggio scontrino txt ------------------------------------------------

  
  selectedRow <- eventReactive(input$scontrino_table_rows_selected,{
    nciclo <- scontrino_df()$print[input$scontrino_table_rows_selected]
    return(nciclo)
  })
  # output$selected <- renderText({
  #   rawText <- paste(scontrino_txt()[[selectedRow()]],collapse = "\\n")
  # })
  # 
  output$selected <- renderUI({
    # rawText <- paste(scontrino_txt()[[selectedRow()]],sep = "\\n")


    # split the text into a list of character vectors
    #   Each element in the list contains one line
    splitText <- stringi::stri_split(str = selectedRow(), regex = '\n')
    
    splitText <- as.list(splitText[[1]])
    # wrap a paragraph tag around each element in the list
    replacedText <- lapply(splitText, p)

    return(replacedText)
  })

}


# Run the application
shinyApp(ui = ui, server = server)
