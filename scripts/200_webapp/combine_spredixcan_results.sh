#!/bin/bash

. settings.sh

export SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export PYTHONPATH="${SCRIPT_DIR}/../../src/"

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
  --spredixcan-hdf5-folder ${SPREDIXCAN_HDF5_FOLDER} \
  --phenotypes-info-file ${PHENOTYPES_INFO_FILE} \
  --tissues-info-file ${TISSUES_FILE} \
  --genes-info-file ${GENES_INFO_FILE}
EOM

    OUTPUT_FILE="${OUTPUT_FOLDER}/${TISSUE_NAME}.tsv"

    # add header
    zcat ${PHENOTYPES_INFO_FILE} | tail -n +2 | head -1 | cut -f1 | \
      parallel -j1 "${COMMAND} | head -1 > ${OUTPUT_FILE}"

    # add data
    zcat ${PHENOTYPES_INFO_FILE} | tail -n +2 | cut -f1 | \
      parallel -j${N_JOBS} "${COMMAND} --no-header" >> ${OUTPUT_FILE}
  done
} < ${TISSUES_FILE}
