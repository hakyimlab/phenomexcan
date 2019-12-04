
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#
library(shiny)
source("helpers.R")
source("pairs_info_module.R")

###############################################################################

render_results <- function(data) {
  render <- DT::datatable(data,
    class = 'compact display',
    options = list(
      pageLength = 20,
      lengthMenu = c(10, 20, 40, 100),
      columnDefs = list(
        list(className = "dt-center", targets = c(8, 9))
      )
    ),
    selection = 'single')

  if (nrow(data)>0) {
    render <- render %>%
      DT::formatSignif('pvalue', 3) %>%
      DT::formatSignif('rcp', 3) %>%
      DT::formatSignif('best_tissue_p', 3)
  }
  render
}

render_pairs <- function(data) {
  render <- DT::datatable(data,
    class = 'compact display',
    options = list(
      pageLength = 20,
      lengthMenu = c(10, 20, 40, 100)
    ),
    selection = 'single')
  
  if (nrow(data)>0) {
    render <- render %>%
      DT::formatSignif('zscore', 4) %>%
      DT::formatStyle("gene_names",
                whiteSpace="nowrap",
                overflow="hidden",
                textOverflow= "ellipsis",
                maxWidth= "20ch")
  }
  render
}

###############################################################################

loading_indicator <- function(debug_message=NULL) {
  LOG(debug_message)
  fluidPage(
    tags$head(tags$style(type="text/css", "
             #loadmessage {
               position: relative;
               top: 300px;
               box-shadow: 6px 6px 18px #808080;
               border: 2px;
               border-radius: 5px;
               left: 0px;
               width: 100%;
               padding: 25px 0px 25px 0px;
               text-align: center;
               font-weight: bold;
               font-size: 100%;
               color: #000000;
               background-color: #CCFF66;
               z-index: 105;
               opacity: 0.7;
             }
        ")),
    conditionalPanel(
      condition="($('html').hasClass('shiny-busy'))",
      tags$div("Loading...", id="loadmessage")
    )
  )
  
}

#Gets the underlying data for the row clicked in the html table
selected_data_from_table <- function(event, data) {
  LOG("selecting data")
  info <- NULL
  if (length(event) && nrow(data)) {
    i <- as.numeric(tail(event, 1))
    info <- data[i,]
  }
  info
}

###############################################################################

server <- function(input, output, session) {
    updateSelectizeInput(session = session, inputId = 'gene_name', choices = c(genes_), server = TRUE)
    updateSelectizeInput(session = session, inputId = 'pheno', choices = c(phenotypes_), server = TRUE)
    updateSelectizeInput(session = session, inputId = 'ukb_trait', choices = c(ukb_phenotypes_), server = TRUE)
    updateSelectizeInput(session = session, inputId = 'clinvar_trait', choices = c(clinvar_phenotypes_), server = TRUE)
  
    sm_data <- data.frame()
    
    #cache pairs data, and return the data for selected row
    pairs_data <- data.frame()
    modal_dialog_pairs_helper <- reactive({
      v <- selected_data_from_table(input$sm_pairs_rows_selected, pairs_data)
      v
    })
    
    output$sm_results = DT::renderDataTable({
      l <- get_results_from_data_db(input)
      sm_data <<- l
      render_results(l)
    })

    output$sm_pairs = DT::renderDataTable({
      l <- get_pairs_from_data_db(input)
      pairs_data <<- l
      render_pairs(l)
    })
    
    ###########################################################################
    #Loading indicators
    output$loading_results <- renderUI(loading_indicator("sm_results_loading"))
    
    output$loading_pairs <- renderUI(loading_indicator("sm_pairs_loading"))
    
    ############################################################################
    # row clicking
    # this sets values for a template modal.html, only used for PAIRS at the moment,
    # but multiplexing left in place for the future
    output$modal_title   <- renderUI({
      if (input$display== "pairs") {
        modal_pairs_title(modal_dialog_pairs_helper)  
      }
    })
    output$modal_content <- renderUI({
      if (input$display== "pairs") {
        modal_pairs_content(modal_dialog_pairs_helper)
      }
    })
    
    #LOG(input$results_rows_selected)
    #event name is conventional from table name
    observeEvent(
      input$sm_results_rows_selected,{
        LOG("selected results rows")
        #shinyjs::runjs("$('#myModal').modal()")
      })
    
    observeEvent(
      input$sm_pairs_rows_selected,{
        LOG("selected pairs row")
        shinyjs::runjs("$('#myModal').modal()")
    })
}

shinyServer(server)
