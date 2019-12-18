#!/bin/bash

export SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export PYTHONPATH="${SCRIPT_DIR}/../../src/"

export SMULTIXCAN_RESULTS_DIR_00="/mnt/phenomexcan_base/results/smultixcan/rapid_gwas_project"
export SMULTIXCAN_PATTERN_00='^smultixcan_(?P<code>.*)_ccn30\.tsv\.gz$'

export SMULTIXCAN_RESULTS_DIR_01="/mnt/phenomexcan_base/results/smultixcan/gtex_gwas"
export SMULTIXCAN_PATTERN_01='^(?P<code>.*)_smultixcan_imputed_gwas_gtexv8mashr_ccn30\.txt$'

OUTPUT_FOLDER="${1}"
if [ -z "${OUTPUT_FOLDER}" ]; then
  echo "Wrong arguments"
  exit 1
fi
mkdir -p ${OUTPUT_FOLDER}
echo "Output folder: ${OUTPUT_FOLDER}"

N_JOBS=1
if [ ! -z "${2}" ]; then
  N_JOBS="${2}"
fi
echo "Using n jobs: ${N_JOBS}"

{
  # skip first line
  read
  while IFS=$'\t' read -r TISSUE_ID TISSUE_NAME; do
    echo "${TISSUE_NAME} - ${TISSUE_ID}"

read -r -d '' COMMAND << EOM
python ${SCRIPT_DIR}/process_spredixcan.py \
  --phenotype-id "{}" \
  --tissue-id ${TISSUE_ID} \
  --spredixcan-hdf5-folder /mnt/phenomexcan_base/gene_assoc/spredixcan \
  --phenotypes-info-file /mnt/phenomexcan_base/deliverables/phenotypes_info.tsv.gz \
  --tissues-info-file /mnt/phenomexcan_base/deliverables/tissues.tsv \
  --genes-info-file /mnt/phenomexcan_base/deliverables/genes_info.tsv.gz
EOM

    OUTPUT_FILE="${OUTPUT_FOLDER}/${TISSUE_NAME}.tsv"

    # add header
    zcat /mnt/phenomexcan_base/deliverables/phenotypes_info.tsv.gz | tail -n +2 | head -1 | cut -f1 | \
      parallel -j1 "${COMMAND} | head -1 > ${OUTPUT_FILE}"

    # add data
    zcat /mnt/phenomexcan_base/deliverables/phenotypes_info.tsv.gz | tail -n +2 | cut -f1 | \
      parallel -j${N_JOBS} "${COMMAND} --no-header" >> ${OUTPUT_FILE}
  done
} < /mnt/phenomexcan_base/deliverables/tissues.tsv
