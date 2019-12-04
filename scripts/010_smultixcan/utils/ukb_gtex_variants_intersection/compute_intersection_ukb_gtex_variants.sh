#!/bin/bash

python compute_intersection_ukb_gtex_variants.py \
    --gtex-models-dir /scratch/mpividori/gtex_v8/mashr/models/ \
    --variants-file-with-gtex-id /gpfs/data/im-lab/nas40t2/miltondp/phenomexcan/misc/snps_matched.txt.gz \
    --output-file /gpfs/data/im-lab/nas40t2/miltondp/phenomexcan/misc/snps_intersection-varid-gtex_v8_mashr_and_ukb_neale2018.txt

