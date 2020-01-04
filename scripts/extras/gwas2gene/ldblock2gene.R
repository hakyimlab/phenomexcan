library(optparse)
option_list = list(
  make_option(c("-a", "--gwas"), type="character", default="test",
              help="GWAS sumstat", metavar="character"),
  make_option(c("-g", "--gene_list"), type="character", default="test",
              help="gene model", metavar="character"),
  make_option(c("-d", "--ldblock"), type="character", default="test",
              help="ldblock file", metavar="character"),
  make_option(c("-o", "--output"), type="character", default="test",
              help="output", metavar="character"),
  make_option(c("-l", "--gene_list_filter"), type="character", default=NULL,
              help="a list of gene", metavar="character"),
  make_option(c("-w", "--gwas_pval_gt"), type="numeric", default=NULL,
              help="if only want to use large p-value (to mimic GWAS with low sample size)", metavar="character"),
  make_option(c("-s", "--gwas_pval_lt"), type="numeric", default=5e-8,
              help="conventional genome-wide cutoff on p-value", metavar="character"),
  make_option(c("-u", "--source_path"), type="character", default='rlib.R',
              help="path to sourced files (default rlib.R)", metavar="character")
);

args_parser = OptionParser(option_list=option_list);
opt = parse_args(args_parser);

# do region-based operation instead of variant-based with window

library(data.table)
options(datatable.fread.datatable = F)
library(dplyr)

# source(paste0(path, '/../../scripts/mylib_doc.R'))
# source(paste0(path, '/../../scripts/mylib_generic.R'))
source(opt$source_path)

get_gwas_lead_for_ldblock = function(filename, ldblock, cutoff_p_gt, cutoff_p_lt) {
  df = fread(paste0('zcat ', filename, ' | cut -f 2,3,4,8'), header = T, sep = '\t')
  if(nrow(df) == 0) {
    return(data.frame())
  }
  if(!is.null(cutoff_p_gt)) {
    df = df %>% filter(pvalue > cutoff_p_gt)
  }
  if(!is.null(cutoff_p_lt)) {
    df = df %>% filter(pvalue < cutoff_p_lt)
  }
  ldblock = read.table(ldblock, header = T, stringsAsFactors = F)
  df_all = data.frame()
  for(i in 1 : nrow(ldblock)) {
    # message(i)
    sub = df %>% filter(chromosome == ldblock$chromosome[i]) %>% filter(position >= ldblock$start[i], position < ldblock$end[i])
    if(nrow(sub) == 0) {
      next
    }
    min_p = min(sub$pvalue)
    sub = sub[sub$pvalue == min_p, ]
    if(nrow(sub) > 1) {
      sub = sub[sample(1: nrow(sub), size = 1), ]
    }
    sub$cs_idx = ldblock$region_name[i]
    sub$start = ldblock$start[i]
    sub$end = ldblock$end[i]
    df_all = rbind(df_all, sub)
  }
  colnames(df_all) = c('lead_var', 'chr', 'pos', 'pval', 'cs_idx', 'region_start', 'region_end')
  df_all[, c('cs_idx', 'lead_var', 'chr', 'pos', 'region_start', 'region_end')]
}


gene_map = read.table(opt$gene_list, header = T) %>% filter(gene_type == 'protein_coding')
gene_map$tss = get_tss(gene_map$start, gene_map$end, gene_map$strand)

gwas_lead = get_gwas_lead_for_ldblock(opt$gwas, opt$ldblock, opt$gwas_pval_gt, opt$gwas_pval_lt)
if(nrow(gwas_lead) == 0) {
  saveRDS(list(gwas_leading_variant = gwas_lead, extracted_genes = data.frame()), opt$output)
  quit()
}


if(!is.null(opt$gene_list_filter)) {
  gene_list = read.table(opt$gene_list_filter, header = F, stringsAsFactors = F)$V1
  gene_map_this = gene_map %>% filter(gene_id %in% gene_list)
  gwas_lead = post_filter_region_by_causal_gene_position(gwas_lead, gene_map_this$chromosome, gene_map_this$start, gene_map_this$end)
}

region_pos = gwas_lead[, c('chr', 'region_start', 'region_end', 'cs_idx', 'pos')]
df_extracted_genes_tmp = data.frame()
if(nrow(gwas_lead) == 0) {
  saveRDS(list(gwas_leading_variant = gwas_lead, extracted_genes = df_extracted_genes_tmp), opt$output)
  quit()
}
for(i in 1 : nrow(gwas_lead)) {
  sub = gene_map %>% filter(chromosome == region_pos$chr[i])
  sub = sub %>% mutate(dist_to_gene_body = get_distance(start, end, region_pos$pos[i]), dist_to_tss = abs(tss - region_pos$pos[i])) %>% filter(check_two_region_overlap(region_pos$region_start[i], region_pos$region_end[i], start, end))
  if(nrow(sub) == 0) {
    next
  }
  sub$variant = gwas_lead$lead_var[i]
  sub$cs_idx = gwas_lead$cs_idx[i]
  df_extracted_genes_tmp = rbind(df_extracted_genes_tmp, sub)
}
df_extracted_genes_tmp = df_extracted_genes_tmp %>% rename(gene = gene_id) %>% group_by(gene) %>% summarize(dist_to_tss = min(dist_to_tss), dist_to_gene_body = min(dist_to_gene_body)) %>% ungroup()

saveRDS(list(gwas_leading_variant = gwas_lead, extracted_genes = df_extracted_genes_tmp), opt$output)
