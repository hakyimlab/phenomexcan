#!/bin/bash

export SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export PYTHONPATH="${SCRIPT_DIR}/../../src/"

. settings.sh

read -r -d '' COMMAND << EOM
python ${SCRIPT_DIR}/process_smultixcan.py \
  --smultixcan-file {} \
  --fastenloc-h5-file ${FASTENLOC_HDF5_FILE} \
  --spredixcan-most_signif-dir-effect-h5-file ${SPREDIXCAN_DIRECTION_EFFECT_MOST_SIGNIF_HDF5_FILE} \
  --spredixcan-consensus-dir-effect-h5-file ${SPREDIXCAN_DIRECTION_EFFECT_CONSENSUS_HDF5_FILE} \
  --phenotypes-info-file ${PHENOTYPES_INFO_FILE} \
  --genes-info-file ${GENES_INFO_FILE}
EOM

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
parallel -j${N_JOBS} "${COMMAND} --no-header --smultixcan-file-pattern '${SMULTIXCAN_PATTERN_00}'" >> ${OUTPUT_FILE} ::: ${SMULTIXCAN_RESULTS_DIR_00}/*
parallel -j${N_JOBS} "${COMMAND} --no-header --smultixcan-file-pattern '${SMULTIXCAN_PATTERN_01}'" >> ${OUTPUT_FILE} ::: ${SMULTIXCAN_RESULTS_DIR_01}/*
