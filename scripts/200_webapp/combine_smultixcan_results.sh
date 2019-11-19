#!/bin/bash

export SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export PYTHONPATH="${SCRIPT_DIR}/../../src/"

read -r -d '' COMMAND << EOM
python ${SCRIPT_DIR}/process_smultixcan.py \
  --smultixcan-file {} \
  --fastenloc-h5-file /mnt/phenomexcan_base/gene_assoc/fastenloc-torus-rcp.h5 \
  --phenotypes-info-file /mnt/phenomexcan_base/deliverables/phenotypes_info.tsv.gz \
  --gene-mappings-file /mnt/phenomexcan_base/deliverables/genes_info.tsv.gz
EOM

export SMULTIXCAN_RESULTS_DIR_00="/mnt/phenomexcan_base/results/smultixcan/rapid_gwas_project"
export SMULTIXCAN_PATTERN_00='^smultixcan_(?P<code>.*)_ccn30\.tsv\.gz$'

export SMULTIXCAN_RESULTS_DIR_01="/mnt/phenomexcan_base/results/smultixcan/gtex_gwas"
export SMULTIXCAN_PATTERN_01='^(?P<code>.*)_smultixcan_imputed_gwas_gtexv8mashr_ccn30\.txt$'

OUTPUT_FILE="${1}"
if [ -z "${OUTPUT_FILE}" ]; then
  echo "Wrong arguments"
  exit 1
fi
echo "Output file: ${OUTPUT_FILE}"

N_JOBS=1
if [ ! -z "${2}" ]; then
  N_JOBS="${2}"
fi
echo "Using n jobs: ${N_JOBS}"

echo "Adding header"
parallel -j1 "${COMMAND} --smultixcan-file-pattern '${SMULTIXCAN_PATTERN_00}' | head -1 > ${OUTPUT_FILE}" ::: `ls ${SMULTIXCAN_RESULTS_DIR_00}/* | head -1`

echo "Adding data"
parallel -j${N_JOBS} "${COMMAND} --no-header --smultixcan-file-pattern '${SMULTIXCAN_PATTERN_00}' | sem --fg --id l 'cat'  >> ${OUTPUT_FILE}" ::: ${SMULTIXCAN_RESULTS_DIR_00}/*

parallel -j${N_JOBS} "${COMMAND} --no-header --smultixcan-file-pattern '${SMULTIXCAN_PATTERN_01}' | sem --fg --id l 'cat'  >> ${OUTPUT_FILE}" ::: ${SMULTIXCAN_RESULTS_DIR_01}/*

