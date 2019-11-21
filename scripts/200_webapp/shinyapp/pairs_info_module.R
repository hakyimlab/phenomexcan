library(shiny)

build_pair_ui <- function(entry) {
  tagList(
    fluidRow(
      column(8,p(HTML(paste0("<b>" ,entry$ukb_trait, "</b>"))))
    ),
    fluidRow(
      column(8,p(HTML(paste0("<b>" ,entry$clinvar_trait, "</b>"))))
    ),
    fluidRow(
      column(12,
             p("Genes:"),
             p(entry$gene_names)
      )
    )
  )
}

modal_pairs_content <- function(process_pairs_event){
  entry <- process_pairs_event()
  if (!is.null(entry) && nrow(entry)) {
    build_pair_ui(entry)
  } else {
    p("No information available")
  }
}

modal_pairs_title <- function(process_pairs_event) {
  p("UKB trait - Clinvar pair")
}