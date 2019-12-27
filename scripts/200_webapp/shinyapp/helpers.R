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

LOG_LEVEL=2

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

get_phenotypes <- function() { get_distinct_('phenotypes', "unique_description") }
get_genes <- function() { get_distinct_('genes', "gene_name") }
get_tissues <- function() { get_distinct_('tissues', "name") }
get_clinvar_phenotypes <- function() { get_distinct_('clinvar_phenotypes', "description") }

to_sql_list <- function(s) { sprintf("(values %s)", toString(sprintf("('%s')", s))) }

###############################################################################

get_results_from_data_db_ <- function(input, table_sme, table_g) {
  CLAUSE <- "
SELECT 
  p.unique_description as phenotype, p.source as phenotype_source, g.gene_name, g.band as gene_band,
  sm.pvalue, sm.rcp,
  (case when sm.dir_effect_most_signif = 1 then '+'
        when sm.dir_effect_most_signif = -1 then '-'
        else '' end) as best_sign,
  (case when sm.dir_effect_consensus = 1 then '+'
        when sm.dir_effect_consensus = -1 then '-'
        else '' end) as consensus_sign,
  sm.n as n_tissues, sm.n_indep
FROM smultixcan sm inner join phenotypes p on (sm.pheno_id = p.id) inner join genes g on (sm.gene_num_id = g.id)
WHERE 1=1 
" %>% glue::glue()
  
  if (length(input$gene_name) != 0) {
    CLAUSE <- CLAUSE %>% glue::glue("
AND g.gene_name IN {gene_name_list}", gene_name_list=to_sql_list(input$gene_name))
  }
  
  if (length(input$pheno) != 0) {
    CLAUSE <- CLAUSE %>% glue::glue("
AND p.unique_description IN {pheno_list}", pheno_list=to_sql_list(input$pheno))
  }
  
  if (length(input$pthreshold) != 0 && input$pthreshold > 0) {
    CLAUSE <- CLAUSE %>% glue::glue("
AND sm.pvalue < {input$pthreshold}")
  }
  
  if (length(input$rthreshold) != 0 && input$rthreshold > 0) {
    CLAUSE <- CLAUSE %>% glue::glue("
AND sm.rcp > {input$rthreshold}")
  }
  
#  if (input$ordered){
    CLAUSE <- CLAUSE %>% glue::glue("
ORDER BY sm.pvalue");
#  }
  
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

get_sp_results_from_data_db_ <- function(input, table_sme, table_g) {
  CLAUSE <- "
SELECT
  p.unique_description as phenotype, p.source as phenotype_source, t.name as tissue_name, g.gene_name, g.band as gene_band,
  sp.pvalue, sp.zscore, sp.effect_size
FROM spredixcan sp inner join phenotypes p on (sp.pheno_id = p.id)
  inner join tissues t on (sp.tissue_id = t.id)
  inner join genes g on (sp.gene_num_id = g.id)
WHERE 1=1
" %>% glue::glue()

  if (length(input$sp_pheno) != 0) {
    CLAUSE <- CLAUSE %>% glue::glue("
AND p.unique_description IN {pheno_list}", pheno_list=to_sql_list(input$sp_pheno))
  }

  if (length(input$sp_tissue) != 0) {
    CLAUSE <- CLAUSE %>% glue::glue("
AND t.name IN {tissue_list}", tissue_list=to_sql_list(input$sp_tissue))
  }

  if (length(input$sp_gene_name) != 0) {
    CLAUSE <- CLAUSE %>% glue::glue("
AND g.gene_name IN {gene_name_list}", gene_name_list=to_sql_list(input$sp_gene_name))
  }

  if (length(input$sp_pthreshold) != 0 && input$sp_pthreshold > 0) {
    CLAUSE <- CLAUSE %>% glue::glue("
AND sp.pvalue < {input$sp_pthreshold}")
  }

#  if (input$sp_ordered){
    CLAUSE <- CLAUSE %>% glue::glue("
ORDER BY sp.pvalue");
#  }

  l = 100
  if (input$sp_limit > 1) {
    l = input$sp_limit
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

get_sp_results_from_data_db <- function(input) { get_sp_results_from_data_db_(input, phenomexcan_sme_tbl_eqtl, phenomexcan_genes_tbl) }

###############################################################################

get_pairs_from_data_db_ <- function(input, table_sm) {
  CLAUSE <- "
SELECT p.unique_description, cp.description, uc.sqrt_z2_avg as zscore, cp.genes_info
FROM ukb_clinvar uc inner join phenotypes p on (uc.ukb_pheno_id = p.id) inner join clinvar_phenotypes cp on (uc.clinvar_pheno_id = cp.id)
WHERE 1=1 
" %>% glue::glue()
  
  
  if (length(input$uc_ukb_trait) != 0) {
    CLAUSE <- paste0(CLAUSE, "\n
AND p.unique_description IN {trait_list}" %>% glue::glue(trait_list=to_sql_list(input$uc_ukb_trait)))
  }
  
  if (length(input$uc_clinvar_trait) != 0) {
    CLAUSE <- paste0(CLAUSE, "\n
AND cp.description IN {trait_list}" %>% glue::glue(trait_list=to_sql_list(input$uc_clinvar_trait)))
  }
  
#  if (input$uc_ordered){
    CLAUSE <- paste0(CLAUSE, "\n
ORDER BY uc.sqrt_z2_avg DESC");
#  }
  
  l = 100
  if (input$uc_limit > 1) {
    l = input$uc_limit
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
