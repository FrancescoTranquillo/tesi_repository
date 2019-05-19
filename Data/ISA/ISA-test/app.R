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
library(shinythemes)

source(file = "morpher.r")
source(file = "estrazione_nomi_allarmi.r")

# HEADER ------------------------------------------------------------------


header <- dashboardHeader(title = "ISA-TEST")

# sidebar -----------------------------------------------------------------


sidebar <- dashboardSidebar(
    sidebarMenu(
        menuItem(
            tags$strong("Welcome"),
            tabName = "Welcomepage",
            icon = icon("home"),
            selected = F
        ),
        menuItem(
            tags$strong("Analizza scontrini"),
            tabName = "cs",
            icon = icon("upload"),
            selected = T
        )))


# body --------------------------------------------------------------------


body<-dashboardBody(
    
    tabItems(
        ######WELCOME####
        tabItem(tabName="Welcomepage",
                fluidRow(
                    column(width=12,
                           box(width=12,
                                  title="Benvenuto in SMS/RMS",
                                status =  "success")
                           )
                    )),
        tabItem(tabName = "cs",
                fluidRow(
                    box(title = strong("Carica gli scontrini"),
                        solidHeader = TRUE, 
                        status = "success", 
                        background = "green",
                        fileInput(
                            "txt",
                            label = NULL,
                            accept = c("text/csv", "text/comma-separated-values,text/plain", ".txt"),
                            multiple = T)
                    )
                    ),
                
                    box(title=strong("visualizza scontrino / TEST"),
                        DTOutput("scontrino_table"),width = 100)
                
                    
                    )
                )
                )
    
ui <- dashboardPage(header,
                    sidebar,
                    body,
                    skin = "green")

# Define server logic required to draw a histogram
server <- function(input, output, session) {
    
    scontrino_txt <- reactive({
        
        path <- input$txt$datapath
        text <- lapply(path,readLines,encoding = "UTF8")
        return(text)
    })
    scontrino_df <- reactive({ 
        req(input$txt)
        df <- lapply(scontrino_txt(),morpher) %>% do.call("rbind",.)
        return(df)
    })
    
    output$scontrino_table <- DT::renderDT({
        datatable(scontrino_df(),
                  options = list(scrollX = TRUE,
                                 dom = 't', max
                                )
                  )
        
        
                      
        })
}

# Run the application 
shinyApp(ui = ui, server = server)
