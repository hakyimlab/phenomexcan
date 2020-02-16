library(data.table)
options(datatable.fread.datatable = F)
library(dplyr)
source('rlib.R')

args <- commandArgs(trailingOnly = TRUE)
if (length(args)==0) {
  stop('You need to provide the path to the omim_silver_standard data')
}

base_dir = args[1]

mim2gene = fread(paste0('cat ', args[1], '/mim2gene.txt | tail -n +5'), header = T)
colnames(mim2gene) = c('mim', 'entry_type', 'entrez_gene_id', 'approved_gene_symbol','ensembl_gene_id')
# myfunc_mim2gene(trait2mim$mim[11], mim2gene$mim, mim2gene$ensembl_gene_id)
# mim2gene do NOT work since the extract MIM is phenotype but not gene
# should use genemap2 instead

genemap2 = fread(paste0('cat ', args[1], '/genemap2.txt | head -n 16943 | tail -n +4'), header = T)
trait2mim = read.delim2('efo-trait-to-hpo-and-mim.txt', header = T)

df_trait2mim = data.frame()
for(i in 1 : nrow(trait2mim)) {
  message(i)
  pheno_mim_str = trait2mim$mim[i]
  if(is.na(pheno_mim_str)) {
    next
  } else {
    pheno_mim_vec = strsplit(as.character(pheno_mim_str), ';')[[1]]
    for(p in pheno_mim_vec) {
      any_mim = myfunc_pheno_mim_to_any_mim(p, genemap2$Phenotypes, genemap2$`Mim Number`)
      if(length(any_mim) == 0) {
        next
      }
      df_trait2mim = rbind(df_trait2mim, data.frame(trait = trait2mim$trait[i], pheno_mim = p, mim = any_mim))
    }
  }
}

df_trait2mim = left_join(df_trait2mim, mim2gene, by = 'mim')
df_trait2gene = df_trait2mim %>% filter(entry_type == 'gene')
count_trait_ngene = df_trait2gene %>% group_by(trait, approved_gene_symbol) %>% summarize(n()) %>% ungroup() %>% group_by(trait) %>% summarise(ngene = n())
write.table(count_trait_ngene, 'efo-summary_ngene_by_trait.txt', quo = F, col = T, row = F, sep = '\t')
df_trait2gene[df_trait2gene == ''] = NA
write.table(df_trait2gene, 'omim_silver_standard.tsv', quo = F, col = T, row = F, sep = '\t')
#saveRDS(df_trait2mim, 'efo-trait-to-any-mim.rds')
