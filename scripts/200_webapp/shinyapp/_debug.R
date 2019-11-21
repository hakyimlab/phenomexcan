source("global.R")
source("helpers.R")

input = list(clinvar_trait=NULL,
             ukb_trait=NULL,
             ordered=TRUE,
             limit=100)

l <- get_pairs_from_data_db(input)


d <- (function(){
  "SELECT phenotype, count(*) as count
  FROM `gtex-awg-im.GTEx_V8_UKB_PhenomeXcan.smultixcan_mashr_eqtl_v2` 
  GROUP BY phenotype" %>% query_exec(project = phenomexcan_fastenloc_tbl_eqtl $project, use_legacy_sql = FALSE, max_pages = Inf)
})()