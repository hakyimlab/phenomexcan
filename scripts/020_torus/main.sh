#!/bin/bash

which python

. jobs/common/vars

PARAM0="${1}"
N_JOBS=1

SOURCES="finngen phesant icd10"

echo "Generating job files"
for SOURCE in ${SOURCES}; do
    echo "Working on source ${SOURCE}"

    TMP_DIR="_tmp/torus_gwas/${SOURCE}"
    mkdir -p ${TMP_DIR}

    python3 utils/generate_jobs.py \
        --gtex-models-dir ${METAXCAN_GTEX_V8_MODELS_DIR} \
        --gtex-models-regex "${METAXCAN_GTEX_V8_REGEX}" \
        --job-template-dir jobs/06_torus_gwas/ \
        --output-dir ${TMP_DIR} \
        --variable-type categorical ordinal binary continuous_raw \
        --extra-variables '{"__N_JOBS__": "'"${N_JOBS}"'"}' \
        --sources ${SOURCE}
done
