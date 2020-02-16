# Overview

1. Map keyword to GWAS catalog trait
2. Map GWAS catalog trait to phecode 
3. Map phecode to MIM trait
4. Map MIM trait to MIM gene

# Step 1,2,3: run

input: 

* `ukbiobank_efo_mappings.tsv`: trait list to start with. The script treated the `efo_name` as keyword column
* `gwas-catalog-to-phecode.csv`: the magic file shared by Lisa mapping GWAS catalog trait to phecode
* `hpo-to-omim-and-phecode.csv`: the magic file shared by Lisa mapping phecode to MIM

output:

* `efo-trait-to-hpo-and-mim.txt`: each row is a UKBB trait with mapped HPO/MIM if there is any


```
$ Rscript map_trait_to_hpo_and_mim.R
``` 


# Step 4: run

input:

* `mim2gene.txt`: from OMIM database telling the meta information of each MIM ID 
* `genemap2.txt`: from OMIM database telling how MIM trait is mapped to MIM gene 
* `efo-trait-to-hpo-and-mim.txt`: output above

output:

* `efo-trait-to-gene.txt`: each row is a UKBB trait with mapped MIM gene pair
* `efo-summary_ngene_by_trait.txt`: each row is a UKBB trait with number of MIM genes being mapped to
* `efo-trait-to-any-mim.rds`: almost identical to `efo-trait-to-gene.txt` but in RDS format ...

```
$ Rscript mim-to-gene.R
```