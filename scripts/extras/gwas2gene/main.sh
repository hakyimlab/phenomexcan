#!/bin/bash

GWAS_DIR="/home/miltondp/projects/labs/hakyimlab/phenomexcan/base/results/misc/gwas_parsing/full"

# generate list of files with first extension
#parallel --tmpdir /scratch/mpividori/tmp/ -j1 'echo {/.}' ::: ${GWAS_DIR}/*.txt.gz > list

# run gwas2gene
cat selected_ukb_traits_omim.txt | parallel -j2 "bash run_gwas2gene.sh ${GWAS_DIR}/{}.txt.gz"
