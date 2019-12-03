
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(shinythemes)
source("ui_helpers.R")

build_ui <- function() {
  fluidPage(theme = shinytheme("cerulean"),
    shinyjs::useShinyjs(),
    tags$head(includeScript("google-analytics.js")),
    appTitle(), # uiHeader.R
    releaseDate(),
    alertMessage(),
    dataInfo(),
    HTML('<hr style="color: purple;">'),
    htmlTemplate("modal.html",
                 title = uiOutput("modal_title"),
                 content = uiOutput("modal_content")
    ),
    h3("Results:"),
    fluidRow(
      column(4, selectInput( "display", "Result set:",
                                    c(PhenomeXcan = 'results',
                                      PhenomeXcan_Clinvar = 'pairs'))),
      column(8, div(""))
    ),
    conditionalPanel(
      condition = "input.display == 'results'",
      fluidRow(
        column(1, checkboxInput("ordered", label = "Order by p-value", value = TRUE)),
        column(1, numericInput("pthreshold", "P-value thres.:", 0.05, width = 200), min = 0, max = 1, step = 0.001),
        column(1, numericInput("rthreshold", "rcp thres.:", 0, width = 200), min = 0, max = 1, step = 0.001),
        column(1, div()),
        column(1, numericInput("limit", "Record limit:", 100), min = 1),
        column(7, div(""))
      ),
      fluidRow(
        column(4, selectizeInput(inputId = "pheno",
                                 label = "Filter by phenotype(s):",
                                 choices = NULL,
                                 selected = NULL,
                                 multiple = TRUE,
                                 width = 650,
                                 # list of options for selectize.js available at: github.com/selectize/selectize.js/blob/master/docs/usage.md
                                 options = list(closeAfterSelect = FALSE, openOnFocus = TRUE, loadThrottle = NULL))),
        column(2, selectizeInput(inputId = "gene_name",
                                 label = "Filter by gene(s):",
                                 choices = NULL,
                                 selected = NULL,
                                 multiple = TRUE,
                                 # list of options for selectize.js available at: github.com/selectize/selectize.js/blob/master/docs/usage.md
                                 options = list(closeAfterSelect = FALSE, openOnFocus = TRUE, loadThrottle = NULL))),
        column(6, div(""))
      ),
      uiOutput("loading_results"),
      fluidRow(
        DT::dataTableOutput(outputId="sm_results")
      ) #,
    ),
    conditionalPanel(
      condition = "input.display == 'pairs'",
      fluidRow(
        column(4, checkboxInput("ordered", label = "Order by score", value = TRUE)),
        column(1, numericInput("limit", "Record limit:", 100), min = 1),
        column(8)
      ),
      fluidRow(
        column(4, selectizeInput(inputId = "ukb_trait",
                                 label = "Filter by UKB trait(s):",
                                 choices = NULL,
                                 selected = NULL,
                                 width = 650,
                                 multiple = TRUE,
                                 # list of options for selectize.js available at: github.com/selectize/selectize.js/blob/master/docs/usage.md
                                 options = list(closeAfterSelect = FALSE, openOnFocus = TRUE, loadThrottle = NULL))),
        column(4, selectizeInput(inputId = "clinvar_trait",
                                 label = "Filter by CLINVAR trait(s):",
                                 choices = NULL,
                                 selected = NULL,
                                 multiple = TRUE,
                                 width = 650,
                                 # list of options for selectize.js available at: github.com/selectize/selectize.js/blob/master/docs/usage.md
                                 options = list(closeAfterSelect = FALSE, openOnFocus = TRUE, loadThrottle = NULL))),
        column(4, div())
      ),
      uiOutput("loading_pairs"),
      fluidRow(
        DT::dataTableOutput(outputId="sm_pairs")
        #div("Hello there")
      )
    ),

    modelsInfo(),
    disclaimer(),
    cites()
  )
}

shinyUI(
  build_ui()
)
