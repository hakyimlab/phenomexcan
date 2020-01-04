#!/bin/bash

GWAS_DIR="/scratch/mpividori/gwas2gene/data/gwas_omim_silver/"
PHENO=$1

mkdir -p _results

# optional argument: list of genes to consider
#  --gene_list_filter /scratch/mpividori/gwas2gene/data/clinvar_genes.txt \
Rscript ldblock2gene.R \
  --gwas ${GWAS_DIR}/${PHENO}.txt.gz \
  --gene_list /gpfs/data/im-lab/nas40t2/miltondp/phenomexcan/gwas2gene/annotations_gencode_v26.tsv \
  --ldblock /gpfs/data/im-lab/nas40t2/miltondp/phenomexcan/gwas2gene/ld_independent_regions.txt \
  --output _results/${PHENO}.rds \
  --gwas_pval_lt 5e-8 \
  --source_path rlib.R

# Step 2
#Rscript annotate_random_precision.R \
#  --gwas gwas_in_LDblock-GLGC_Mc_LDL.rds \
#  --output gwas_in_LDblock-GLGC_Mc_LDL.by_locus.rds \
#  --gene_list /gpfs/data/im-lab/nas40t2/yanyul/mv_from_scratch/repo_new/rotation-at-imlab/data/annotations_gencode_v26.tsv \
#  --region_based 1 \
#  --source_path rlib.R
