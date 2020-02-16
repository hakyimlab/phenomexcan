# process gwas-catalog -> phecode -> hpo and omim
library(dplyr)
library(stringr)

source('rlib.R')

args <- commandArgs(trailingOnly = TRUE)
if (length(args)==0) {
  stop('You need to provide the path to the omim_silver_standard data')
}

base_dir = args[1]

gwas_meta = read.delim2('ukbiobank_efo_mappings.tsv', stringsAsFactors = F, header = T, sep = '\t')
trait2phecode = read.csv(paste0(base_dir, '/gwas-catalog-to-phecode.csv'), stringsAsFactors = F) %>% select(trait, phecode) %>% unique
phecode2hpoomim = read.csv(paste0(base_dir, '/hpo-to-omim-and-phecode.csv'), stringsAsFactors = F) %>% filter(!phecode %in% c('', '-')) %>% select(phecode, dID, term_id) %>% unique

omim = c()
hpo = c()
nhpo = c()
nomim = c()
mapped_traits = c()
for(i in 1 : nrow(gwas_meta)) {
  kw = strsplit(gwas_meta$efo_name[i], ';')[[1]]
  # rm = gwas_meta$remove[i]
  # if(rm == '') {
  #   rm = NA
  # } 
  idx = c()
  for(kwi in kw) {
    idxi = extract_by_keyword(trait2phecode$trait, kwi, rm = NA)
    idx = union(idx, idxi)
  }
  sub = trait2phecode[idx, ]
  sub = sub[sub$phecode != '-', ]
  phecode = sub$phecode
  extracted_traits = sub$trait
  contribute_traits = extracted_traits[phecode %in% phecode2hpoomim$phecode]
  hpo_omim = phecode2hpoomim[phecode2hpoomim$phecode %in% phecode, ]
  hpo_merge = paste0(unique(hpo_omim$term_id), collapse = ';')
  omim_merge = paste0(unique(hpo_omim$dID), collapse = ';')
  trait_merge = paste0(unique(contribute_traits), collapse = ';')
  n_hpo = length(unique(hpo_omim$term_id))
  n_omim = length(unique(hpo_omim$dID))
  nhpo = c(nhpo, n_hpo)
  nomim = c(nomim, n_omim)
  hpo = c(hpo, hpo_merge)
  omim = c(omim, omim_merge)
  mapped_traits = c(mapped_traits, trait_merge)
}
o = data.frame(trait = gwas_meta$ukb_fullcode, mapped_trait = mapped_traits, mim = omim, hpo = hpo, num_mim = nomim, num_hpo = nhpo)
o[o == ''] = NA
write.table(o, 'efo-trait-to-hpo-and-mim.txt', sep = '\t', quo = F, row = F, col = T)
