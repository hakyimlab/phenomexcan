#!/bin/bash

GWAS_DIR="/scratch/mpividori/gwas2gene/data/gwas_omim_silver/"

# generate list of files with first extension
parallel --tmpdir /scratch/mpividori/tmp/ -j1 'echo {/.}' ::: ${GWAS_DIR}/*.txt.gz > list

# run Yanyu's script
parallel --tmpdir /scratch/mpividori/tmp/ -j4 'bash run_gwas2gene.sh {/.}' < list

