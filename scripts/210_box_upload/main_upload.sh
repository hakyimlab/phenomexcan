#!/bin/bash

# Some notes
# - Keep in mind that the content of the folders given as the --source-directory parameter must be the final files
#   you want to upload, for example, compressed archives (like *.tar.bz2).
# - IMPORTANT: you have to change the --target-box-directory with the ID of the Box folder: it's the final part of the URL for
#   that folder.

export BASE_RESULTS_DIR="/home/miltondp/projects/labs/hakyimlab/phenomexcan/base/results/"

. "/Users/ukbrest/software/miniconda3/etc/profile.d/conda.sh"
conda activate phenomexcan
export PYTHONPATH="/Users/ukbrest/phenomexcan/phenomexcan-master/src/"

cd /Users/ukbrest/phenomexcan/phenomexcan-master/scripts/210_box_upload/

###############

# S-MultiXcan - gtex_gwas
python upload.py --credentials-file .box_secrets \
  --source-directory ${BASE_RESULTS_DIR}/smultixcan/gtex_gwas/ \
  --target-box-directory 98106099870 \
  --output-file-info ${BASE_RESULTS_DIR}/smultixcan/gtex_gwas_file_info.tsv

# S-MultiXcan - rapid_gwas_project
python upload.py --credentials-file .box_secrets \
  --source-directory ${BASE_RESULTS_DIR}/smultixcan/rapid_gwas_project/ \
  --target-box-directory 98106715870 \
  --output-file-info ${BASE_RESULTS_DIR}/smultixcan/rapid_gwas_project_file_info.tsv

###############

# S-PrediXcan - gtex_gwas
python upload.py --credentials-file .box_secrets \
  --source-directory ${BASE_RESULTS_DIR}/spredixcan/gtex_gwas/ \
  --target-box-directory 98146535604 \
  --output-file-info ${BASE_RESULTS_DIR}/spredixcan/gtex_gwas_file_info.tsv

# S-PrediXcan - rapid_gwas_project
python upload.py --credentials-file .box_secrets \
  --source-directory ${BASE_RESULTS_DIR}/spredixcan/rapid_gwas_project/ \
  --target-box-directory 98146381851 \
  --output-file-info ${BASE_RESULTS_DIR}/spredixcan/rapid_gwas_project_file_info.tsv

###############

# fastENLOC - gtex_gwas
python upload.py --credentials-file .box_secrets \
  --source-directory ${BASE_RESULTS_DIR}/fastenloc/gtex_gwas/ \
  --target-box-directory 98147013367 \
  --output-file-info ${BASE_RESULTS_DIR}/fastenloc/gtex_gwas_file_info.tsv

# fastENLOC - rapid_gwas_project
# the folder ID for the first set of results was 98147000659
python upload.py --credentials-file .box_secrets \
  --source-directory ${BASE_RESULTS_DIR}/fastenloc/rapid_gwas_project/ \
  --target-box-directory 104557978057 \
  --output-file-info ${BASE_RESULTS_DIR}/fastenloc/rapid_gwas_project_file_info.tsv

###############

# TORUS - rapid_gwas_project
python upload.py --credentials-file .box_secrets \
  --source-directory ${BASE_RESULTS_DIR}/torus/rapid_gwas_project/ \
  --target-box-directory 98147245546 \
  --output-file-info ${BASE_RESULTS_DIR}/torus/rapid_gwas_project_file_info.tsv
