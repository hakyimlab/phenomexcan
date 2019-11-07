# PhenomeXcan

[bioRxiv manuscript](https://doi.org/10.1101/833210): PhenomeXcan: Mapping the genome to the phenome through the transcriptome


## Summary

Large-scale genomic and transcriptomic initiatives offer unprecedented ability to study the biology of complex traits and identify target genes for precision prevention or therapy. Translation to clinical contexts, however, has been slow and challenging due to lack of biological context for identified variant-level associations. Moreover, many translational researchers lack the computational or analytic infrastructures required to fully use these resources. We integrate genome-wide association study (GWAS) summary statistics from multiple publicly available sources and data from Genotype-Tissue Expression (GTEx) v8 using PrediXcan and provide a user-friendly platform for translational researchers based on state-of-the-art algorithms. We develop a novel Bayesian colocalization method, fastENLOC, to prioritize the most likely causal gene-trait associations. Our resource, PhenomeXcan, synthesizes 8.87 million variants from GWAS on 4,091 traits with transcriptome regulation data from 49 tissues in GTEx v8 into an innovative, gene-based resource including 22,255 genes. Across the entire genome/phenome space, we find 65,603 significant associations (Bonferroni-corrected p-value of 5.5e-10), where 19,579 (29.8 percent) were colocalized (locus regional colocalization probability > 0.1). We successfully replicate associations from PheWAS Catalog (AUC=0.61) and OMIM (AUC=0.64). We provide examples of (a) finding novel and underreported genome-to-phenome associations, (b) exploring complex gene-trait clusters within PhenomeXcan, (c) studying phenome-to-phenome relationships between common and rare diseases via further integration of PhenomeXcan with ClinVar, and (d) evaluating potential therapeutic targets. PhenomeXcan (http://phenomexcan.org) broadens access to complex genomic and transcriptomic data and empowers translational researchers.


# Results access

PhenomeXcan can be accessed in several ways:

 * **phenomexcan.org**: the quickest one is going to http://phenomexcan.org, where you can query by trait or gene, specify thresholds for p-values or regional colocalizagion probability (RCP), etc.
 * **Results summary**: if you want a more direct access, you can download the processed result files in Zenodo: https://doi.org/10.5281/zenodo.3530669. Here you'll find three files:
   * `smultixcan-mashr-pvalues.tsv.gz`: this is a matrix of p-values of S-MultiXcan results for 4,091 traits and 22,515 genes.
   * `fastenloc-torus-rcp.tsv.gz`: this is a matrix of RCP of fastENLOC results for 4,091 traits and 37,967 genes. To obtain this matrix, for each cell (trait-gene pair), we summed the RCP across gene clusters, and then took the maximum RCP across tissues.
   * `smultixcan_and_clinvar-z2.tsv.gz`: this is a matrix with 4,091 general traits in the rows (from UK Biobank and other GWAS) and 5,106 diseases from ClinVar. Each cell has the mean squared z-score from S-MultiXcan using all the genes reported for the ClinVar trait. See the manuscript for more details.
 * **Full results set** (coming soon): if you need to access all the raw results (i.e all S-PrediXcan and fastENLOC results across all tissues, TORUS fine-mapping results, etc), you can download them from this [UChicago Box shared folder](https://uchicago.box.com/s/i6vocl9pq59gydzpefidexodyuhegmde).

The Supplementary Material of the bioRxiv manuscript contains a spreadsheet with all the gene associations across 4,091 traits that are Bonferroni significant (p < 5.5e-10) and have an RCP > 0.1. You also can obtain this result by combining the two matrices mentioned above: `smultixcan-mashr-pvalues.tsv.gz` and `fastenloc-torus-rcp.tsv.gz`.


# Code

Coming soon.

## Conda environment

Create a new Conda environment with this command:
```
$ conda env create -n YOUR_CONDA_ENV_NAME -p env/environment.yml
$ conda activate YOUR_CONDA_ENV_NAME
```

# Manuscript content

Coming soon.

## Figures
