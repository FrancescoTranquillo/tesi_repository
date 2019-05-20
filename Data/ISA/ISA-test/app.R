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

source(file = "morpher.r")
source(file = "estrazione_nomi_allarmi.r")

# HEADER ------------------------------------------------------------------


header <- dashboardHeader(title = "ISA-TEST")

# sidebar -----------------------------------------------------------------


sidebar <- dashboardSidebar(
    sidebarMenu(
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
            )
            
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
        )
)


# body --------------------------------------------------------------------


body<-dashboardBody(
    
    tabItems(
        ######WELCOME####
        tabItem(tabName="Welcomepage",
                fluidRow(valueBoxOutput("ib1"),
                         valueBoxOutput("ib2")
                ),
                box(title=strong("visualizza scontrino / TEST"),
                    DTOutput("scontrino_table"),
                    width = 100,height = 50
                )
                
        ),
        
        tabItem(tabName = "plot",
                tags$div( # needs to be in fixed height container
                  style = "position: fixed; top: 0; bottom: 0; right: 12; left: 12;", 
                  esquisserUI(id = "esq")))))
    
ui <- dashboardPage(header,
                    sidebar,
                    body,
                    skin = "green")


server <- function(input, output, session) {
    
    scontrino_txt <- reactive({
        
        path <- input$txt$datapath
        text <- lapply(path,readLines,encoding = "UTF8")
        return(text)
    })
    scontrino_df <- reactive({ 
        req(input$txt)
        df <- lapply(scontrino_txt(),morpher) %>% do.call("rbind",.)
        
        df$`INIZIO CICLO` <-  parse_date_time(df$`INIZIO CICLO`, orders = "dmy HMS")
        
        return(df)
    })
    
    valori_infobox <- reactive({
      df_ib <- scontrino_df()
      df_ib %<>% mutate("GIORNO"=factor(cut.Date(as.Date(.$`INIZIO CICLO`), breaks = "1 day",labels = F)))
      df_giorni <- as.list(split(df_ib,f = df_ib$GIORNO))
      ngiorni <- length(df_giorni)
      return(ngiorni)
    })
    
    output$scontrino_table <- DT::renderDT({
        datatable(scontrino_df(),
                  options = list(scrollX = TRUE,
                                 scrollY = "600px"
                                )
                  
                  )
        
        
                      
        })
    
    data_r <- reactiveValues(data = iris, name = "scontrini")
    
    observeEvent(scontrino_df(), {
      if (is_empty(scontrino_df())==F){
        data_r$data <- scontrino_df()
        data_r$name <- "scontrini"
      } else {
        data_r$data <- mtcars
        data_r$name <- "mtcars"
      }
    })
    
    
    callModule(module = esquisserServer, id = "esq",data=data_r)
    
    
    output$ib1 <- renderValueBox({
      valueBox(valori_infobox(),subtitle = "Giorni di attività",
              icon = icon("list"),
              color = "olive"
      )
    })
    output$ib2 <- renderValueBox({
      valueBox(as.numeric(table(grepl(pattern = "Nessun",
                                      ignore.case = T,
                                      x = scontrino_df()$ALLARMI))[1]
                          ),
               subtitle = "Allarmi rilevati",
               icon = icon("warning"),
               color = "orange"
      )
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
