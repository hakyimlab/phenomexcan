# PhenomeXcan

[bioRxiv manuscript](https://doi.org/10.1101/833210): PhenomeXcan: Mapping the genome to the phenome through the transcriptome


## Summary

Large-scale genomic and transcriptomic initiatives offer unprecedented insight into complex traits, but clinical translation remains limited by variant-level associations without biological context and lack of analytic resources. Our resource, PhenomeXcan, synthesizes 8.87 million variants from genome-wide association study (GWAS) summary statistics on 4,091 traits with transcriptomic data from 49 tissues in Genotype-Tissue Expression (GTEx) v8 into a gene-based, queryable platform including 22,515 genes. We developed a novel Bayesian colocalization method, fastENLOC, to prioritize likely causal gene-trait associations. We successfully replicate associations from PheWAS Catalog (AUC=0.62), OMIM (AUC=0.64), and an evidence-based curated gene list (AUC=0.67). Using PhenomeXcan results, we provide examples of novel and underreported genome-to-phenome associations, complex gene-trait clusters, shared causal genes between common and rare diseases via further integration of PhenomeXcan with ClinVar, and potential therapeutic targets. PhenomeXcan (http://phenomexcan.org/) provides broad, user-friendly access to complex data for translational researchers.

# News
- **2020/06/27**: S-PrediXcan results for each tissue are available in the Zenodo dataset (https://doi.org/10.5281/zenodo.3530669).
- **2020/02/25**: We have updated the fastENLOC results, so if you are using them, please, download them again!
Basically, we fixed a problem with the estimation of the alpha1 enrichment values, which are used in the colocalization
probability. The old and the current results mostly match, although we highly recommend using the new ones.

# Results access

PhenomeXcan can be accessed in several ways:

 * **phenomexcan.org**: the quickest one is going to http://phenomexcan.org, where you can query by trait or gene,specify thresholds for p-values or regional colocalization probability (RCP), etc.
 * **Results summary**: if you want a more direct access, you can download the processed result files in Zenodo: https://doi.org/10.5281/zenodo.3530669. Here you'll find three files:
   * `smultixcan-mashr-pvalues.tsv.gz`: this is a matrix of p-values of S-MultiXcan results for 4,091 traits and 22,515 genes.
   * `spredixcan-mashr-zscores.tar`: contains one compressed file per tissue with the S-PrediXcan z-scores for 4,091 traits.
   * `fastenloc-torus-rcp.tsv.gz`: this is a matrix of RCP of fastENLOC results for 4,091 traits and 37,967 genes. To obtain this matrix, for each cell (trait-gene pair), we summed the RCP across gene clusters, and then took the maximum RCP across tissues.
   * `smultixcan_and_clinvar-z2.tsv.gz`: this is a matrix with 4,091 general traits in the rows (from UK Biobank and other GWAS) and 5,106 diseases from ClinVar. Each cell has the mean squared z-score from S-MultiXcan using all the genes reported for the ClinVar trait. See the manuscript for more details.
 * **Full results set**: if you need to access all the raw results (i.e S-MultiXcan, all S-PrediXcan and fastENLOC results across all tissues, and TORUS fine-mapping results), you can download them from this [UChicago Box shared folder](https://uchicago.box.com/s/i6vocl9pq59gydzpefidexodyuhegmde). [The shared Google Drive Spreadsheet](https://docs.google.com/spreadsheets/d/15KEYR_G2AOkPiLi9H68Kv8HcC0PJA5B-0LX_aIlx1x0/edit?usp=sharing) contains the list of all phenotypes as well as the download links for each one.

The Supplementary Material of the bioRxiv manuscript contains a spreadsheet with all the gene associations across 4,091 traits that are Bonferroni significant (p < 5.5e-10) and have an RCP > 0.1. You can also obtain this result by combining the two matrices mentioned above: `smultixcan-mashr-pvalues.tsv.gz` and `fastenloc-torus-rcp.tsv.gz`.


# Setup and manuscript content

Check the [wiki](https://github.com/hakyimlab/phenomexcan/wiki) for instructions to run everything from scratch, postprocessing steps and manuscript content generation.
