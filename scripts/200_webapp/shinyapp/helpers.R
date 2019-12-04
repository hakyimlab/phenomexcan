library(tidyr)
library(readr)

source('postgresql_config.r')

library(RPostgreSQL)

get_db <- function() {
  drv <- dbDriver("PostgreSQL")
  con <- dbConnect(drv,
                   host = POSTGRESQL_HOST,
                   port = POSTGRESQL_PORT,
                   user = POSTGRESQL_USER,
                   dbname = POSTGRESQL_DB,
                   password = POSTGRESQL_PASS
                   )
  return(con)
}

LOG_LEVEL=0

log_ <- function(s, min_level) {
  if(is.null(s))
    return
  if (LOG_LEVEL >= min_level) {
    message(s)
  }
}

CRIT <- function(s) { log_(s,0) }
LOG <- function(s) { log_(s, 2) }

###############################################################################

get_distinct_ <- function(table, field) {
  sql_query = glue::glue("SELECT DISTINCT {field} FROM {table}")
  con = get_db()
  d=dbGetQuery(con, sql_query)
  dbDisconnect(con)
  return(d)
}

get_phenotypes <- function() { get_distinct_('phenotype_info', "unique_description") }
get_genes <- function() { get_distinct_('genes_info', "gene_name") }
get_clinvar_phenotypes <- function() { get_distinct_('ukb_clinvar_clinvar_pheno_info', "pheno_desc") }
get_ukb_phenotypes <- function() { get_distinct_('ukb_clinvar_ukb_pheno_info', "pheno_desc") }

to_sql_list <- function(s) { sprintf("(values %s)", toString(sprintf("('%s')", s))) }

###############################################################################

get_results_from_data_db_ <- function(input, table_sme, table_g) {
  CLAUSE <- "
SELECT 
  pheno_desc as phenotype, pheno_source as phenotype_source, gene_name, gene as gene_id, band as gene_band,
  rcp, pvalue,
  (case when dir_effect_most_signif = 1 then '+'
        when dir_effect_most_signif = -1 then '-'
        else '' end) as best_sign,
  (case when dir_effect_consensus = 1 then '+'
        when dir_effect_consensus = -1 then '-'
        else '' end) as consensus_sign,
  n as n_tissues, n_indep,
  t_i_best as best_tissue, p_i_best as best_tissue_p
FROM smultixcan
WHERE 1=1 
" %>% glue::glue()
  
  if (length(input$gene_name) != 0) {
    CLAUSE <- CLAUSE %>% glue::glue("
AND gene_name IN {gene_name_list}", gene_name_list=to_sql_list(input$gene_name))
  }
  
  if (length(input$pheno) != 0) {
    CLAUSE <- CLAUSE %>% glue::glue("
AND pheno_desc IN {pheno_list}", pheno_list=to_sql_list(input$pheno))
  }
  
  if (length(input$pthreshold) != 0 && input$pthreshold > 0) {
    CLAUSE <- CLAUSE %>% glue::glue("
AND pvalue < {input$pthreshold}")
  }
  
  if (length(input$rthreshold) != 0 && input$rthreshold > 0) {
    CLAUSE <- CLAUSE %>% glue::glue("
AND rcp > {input$rthreshold}")
  }
  
  if (input$ordered){
    CLAUSE <- CLAUSE %>% glue::glue("
ORDER BY pvalue");
  }
  
  l = 100
  if (input$limit > 1) {
    l = input$limit
  }
  CLAUSE <- paste0(CLAUSE, "\n 
LIMIT {l}" %>% glue::glue())
  LOG(paste0("results:\n", CLAUSE))
  
  con = get_db()
  d = dbGetQuery(con, CLAUSE)
  dbDisconnect(con)
  LOG("Query completed")
  d
}

get_results_from_data_db <- function(input) { get_results_from_data_db_(input, phenomexcan_sme_tbl_eqtl, phenomexcan_genes_tbl) }

###############################################################################

get_pairs_from_data_db_ <- function(input, table_sm) {
  CLAUSE <- "
SELECT ukb_trait, clinvar_trait, sqrt_z2_avg as zscore, gene_names
FROM ukb_clinvar
WHERE 1=1 
" %>% glue::glue()
  
  
  if (length(input$ukb_trait) != 0) {
    CLAUSE <- paste0(CLAUSE, "\n
AND ukb_trait IN {trait_list}" %>% glue::glue(trait_list=to_sql_list(input$ukb_trait)))
  }
  
  if (length(input$clinvar_trait) != 0) {
    CLAUSE <- paste0(CLAUSE, "\n
AND clinvar_trait IN {trait_list}" %>% glue::glue(trait_list=to_sql_list(input$clinvar_trait)))
  }
  
  if (input$ordered){
    CLAUSE <- paste0(CLAUSE, "\n
ORDER BY sqrt_z2_avg DESC");
  }
  
  l = 100
  if (input$limit > 1) {
    l = input$limit
  }
  CLAUSE <- paste0(CLAUSE, "\n 
LIMIT {l}" %>% glue::glue())
  LOG(paste0("pairs:\n", CLAUSE))
  
  con = get_db()
  d = dbGetQuery(con, CLAUSE)
  dbDisconnect(con)
  LOG("Query completed")
  d
}

get_pairs_from_data_db <- function(input) { get_pairs_from_data_db_(input, phenomexcan_pairs_mashr_tbl_eqtl) }