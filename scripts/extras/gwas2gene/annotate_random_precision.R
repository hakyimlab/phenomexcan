library(optparse)
option_list = list(
  make_option(c("-g", "--gwas"), type="character", default=NULL,
              help="gwas leading variant and extracted gene list", metavar="character"),
  make_option(c("-o", "--output"), type="character", default="test",
              help="output", metavar="character"),
  make_option(c("-e", "--gene_list"), type="character", default="test",
              help="gene model", metavar="character"),
  make_option(c("-r", "--region_based"), type="numeric", default=0,
              help="if use region based method to assign a gene to a leading variant set to 1", metavar="character"),
  make_option(c("-u", "--source_path"), type="character", default='rlib.R',
              help="path to sourced files (default rlib.R)", metavar="character")
);

args_parser = OptionParser(option_list=option_list);
opt = parse_args(args_parser)

# source(paste0(path, '/../../scripts/mylib_doc.R'))
# source(paste0(path, '/../../scripts/mylib_generic.R'))
source(opt$source_path)
library(dplyr)

gene_map = read.table(opt$gene_list, header = T, stringsAsFactors = F) %>% filter(gene_type == 'protein_coding') %>% rename(gene = gene_id)

gwas = readRDS(opt$gwas)
gwas_lead = gwas$gwas_leading_variant
candidate_genes = gwas$extracted_genes
if(nrow(gwas_lead) == 0) {
  saveRDS(gwas_lead, opt$output)
  quit()
}
candidate_genes = left_join(candidate_genes, gene_map, by = 'gene')

if(opt$region_based != 1) {
  variant_with_genes = assign_gene_to_variant(gwas_lead, candidate_genes$gene, candidate_genes$chromosome, candidate_genes$start, candidate_genes$end, candidate_genes$strand)
} else {
  variant_with_genes = assign_gene_to_variant_by_region(gwas_lead, candidate_genes$gene, candidate_genes$chromosome, candidate_genes$start, candidate_genes$end, candidate_genes$strand)
}



saveRDS(variant_with_genes, opt$output)
