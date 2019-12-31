#!/bin/bash

. "/Users/ukbrest/software/miniconda3/etc/profile.d/conda.sh"
conda activate phenomexcan
export PYTHONPATH="/Users/ukbrest/phenomexcan/phenomexcan-master/src/"

cd /Users/ukbrest/phenomexcan/phenomexcan-master/scripts/210_box_upload/

###############

# S-MultiXcan - gtex_gwas
python upload.py --credentials-file .box_secrets \
  --source-directory /Users/ukbrest/phenomexcan/base/results_raw_final/smultixcan/gtex_gwas/ \
  --target-box-directory 98106099870 \
  --output-file-info /Users/ukbrest/phenomexcan/base/results_raw_final/smultixcan/gtex_gwas_file_info.tsv

# S-MultiXcan - rapid_gwas_project
python upload.py --credentials-file .box_secrets \
  --source-directory /Users/ukbrest/phenomexcan/base/results_raw_final/smultixcan/rapid_gwas_project/ \
  --target-box-directory 98106715870 \
  --output-file-info /Users/ukbrest/phenomexcan/base/results_raw_final/smultixcan/rapid_gwas_project_file_info.tsv

###############

# S-PrediXcan - gtex_gwas
python upload.py --credentials-file .box_secrets \
  --source-directory /Users/ukbrest/phenomexcan/base/results_raw_final/spredixcan/gtex_gwas/ \
  --target-box-directory 98146535604 \
  --output-file-info /Users/ukbrest/phenomexcan/base/results_raw_final/spredixcan/gtex_gwas_file_info.tsv

# S-PrediXcan - rapid_gwas_project
python upload.py --credentials-file .box_secrets \
  --source-directory /Users/ukbrest/phenomexcan/base/results_raw_final/spredixcan/rapid_gwas_project/ \
  --target-box-directory 98146381851 \
  --output-file-info /Users/ukbrest/phenomexcan/base/results_raw_final/spredixcan/rapid_gwas_project_file_info.tsv

###############

# fastENLOC - gtex_gwas
python upload.py --credentials-file .box_secrets \
  --source-directory /Users/ukbrest/phenomexcan/base/results_raw_final/fastenloc/gtex_gwas/ \
  --target-box-directory 98147013367 \
  --output-file-info /Users/ukbrest/phenomexcan/base/results_raw_final/fastenloc/gtex_gwas_file_info.tsv

# fastENLOC - rapid_gwas_project
python upload.py --credentials-file .box_secrets \
  --source-directory /Users/ukbrest/phenomexcan/base/results_raw_final/fastenloc/rapid_gwas_project/ \
  --target-box-directory 98147000659 \
  --output-file-info /Users/ukbrest/phenomexcan/base/results_raw_final/fastenloc/rapid_gwas_project_file_info.tsv

###############

# TORUS - rapid_gwas_project
python upload.py --credentials-file .box_secrets \
  --source-directory /Users/ukbrest/phenomexcan/base/results_raw_final/torus/rapid_gwas_project/ \
  --target-box-directory 98147245546 \
  --output-file-info /Users/ukbrest/phenomexcan/base/results_raw_final/torus/rapid_gwas_project_file_info.tsv
