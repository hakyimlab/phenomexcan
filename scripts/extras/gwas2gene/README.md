# Dependency

```
> sessionInfo()
R version 3.3.2 (2016-10-31)
Platform: x86_64-pc-linux-gnu (64-bit)
Running under: Red Hat Enterprise Linux Server release 6.7 (Santiago)

locale:
[1] C

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base

other attached packages:
[1] dplyr_0.8.0.1     data.table_1.11.8

loaded via a namespace (and not attached):
 [1] tidyselect_0.2.5 magrittr_1.5     assertthat_0.2.0 R6_2.3.0
 [5] pillar_1.3.1     glue_1.3.0       tibble_2.1.1     crayon_1.3.4
 [9] Rcpp_1.0.0       pkgconfig_2.0.2  rlang_0.3.4      purrr_0.2.5
```


# Minimal test

```
$ bash run_gwas2gene.sh
```

# Workflow, input files, and output files

## Step 1

Take GWAS sumstat, LD blocks, and a list of gold standard gene:

1. Only keep LD blocks with at least one GWAS signal (passing a threshold parameter `--gwas_pval_lt`). Set the top GWAS variant as leading variant (randomly pick one if tie).
2. Filter out LD blocks which do not overlap with gold standard gene
3. Extract all genes overlapping the LD block after filtering

* GWAS summary statistics: `/gpfs/data/im-lab/nas40t2/Data/SummaryResults/imputed_gwas_hg38_1.1/imputed_GLGC_Mc_LDL.txt.gz` as example
* Gene model: `/gpfs/data/im-lab/nas40t2/yanyul/mv_from_scratch/repo_new/rotation-at-imlab/data/annotations_gencode_v26.tsv` as example
* LD block definition: `/gpfs/data/im-lab/nas40t2/yanyul/mv_from_scratch/repo_new/rotation-at-imlab/analysis/allelic_heterogeneity/data/ld_independent_regions.txt` as example
* Set threshold to to call GWAS signal: `5e-8` in this case
* Path to some sourced files inside the script: `--source_path rlib.R`

In output `gwas_in_LDblock-GLGC_Mc_LDL.rds`, you can find the list of LD blocks (along with GWAS leading variants) selected by the procedure and the list of selected genes. As shown in below

```
$ R
> out = readRDS('gwas_in_LDblock-GLGC_Mc_LDL.rds')
> head(out$gwas_leading_variant)
    cs_idx                lead_var   chr       pos region_start region_end
1  chr1_18   chr1_25442446_A_G_b38  chr1  25442446     25190354   27075376
2  chr1_34   chr1_55039974_G_T_b38  chr1  55039974     53760589   55947444
3  chr2_13   chr2_21041028_G_A_b38  chr2  21041028     20850730   23118512
4  chr2_27   chr2_43846742_T_C_b38  chr2  43846742     43082452   44086664
5  chr8_94  chr8_143948489_G_T_b38  chr8 143948489    143155464  145078481
6 chr11_70 chr11_116778201_G_C_b38 chr11 116778201    116512631  117876395
> head(out$extracted_genes)
             gene dist_to_tss dist_to_gene_body
1 ENSG00000006555      238707            238707
2 ENSG00000014164      407036            407036
3 ENSG00000058799     1150140           1150140
4 ENSG00000058804     1201114           1201114
5 ENSG00000060642     1345026           1345026
6 ENSG00000065989      674857            621999
```

Region means LD block. The distance computed is relative to GWAS leading variant.  

## Step 2 (it is not necessary for plotting ROC)

Post process the output in step 1 to link each LD block with gene (for locus-based analysis). See input details in `run_gwas2gene.sh`. The output file is `gwas_in_LDblock-GLGC_Mc_LDL.by_locus.rds`.

```
$ R
> out = readRDS('gwas_in_LDblock-GLGC_Mc_LDL.by_locus.rds')
> head(out)
             gene  chr    start      end strand      tss              lead_var
1 ENSG00000060642 chr1 26787472 26798398      + 26787472 chr1_25442446_A_G_b38
2 ENSG00000090273 chr1 26900238 26946862      + 26900238 chr1_25442446_A_G_b38
3 ENSG00000117614 chr1 25222679 25232502      - 25232502 chr1_25442446_A_G_b38
4 ENSG00000117616 chr1 25242237 25338213      - 25338213 chr1_25442446_A_G_b38
5 ENSG00000117632 chr1 25884181 25906991      - 25906991 chr1_25442446_A_G_b38
6 ENSG00000117640 chr1 25818640 25832942      + 25818640 chr1_25442446_A_G_b38
   cs_idx dist_to_gene_body dist_to_tss
1 chr1_18           1345026     1345026
2 chr1_18           1457792     1457792
3 chr1_18            209944      209944
4 chr1_18            104233      104233
5 chr1_18            441735      464545
6 chr1_18            376194      376194
```

Each row is a locus/gene pair. In some cases, two LD blocks can have the same gene because one gene can overlap with two nearby LD blocks.


