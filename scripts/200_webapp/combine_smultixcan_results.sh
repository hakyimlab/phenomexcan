#!/bin/bash

if [ -z "${1}" ]; then
  echo "Wrong arguments"
  exit 1
fi
echo "Using directory: ${1}"


if [ -z "${2}" ]; then
  echo "Wrong arguments"
  exit 1
fi
echo "Using output file: ${2}"


COMMAND="cat"
if [ ! -z "${3}" ]; then
  COMMAND="${3}"
fi
echo "Using command: ${COMMAND}"


if [ "${4}" = "--add-header" ]; then
  echo "Adding header"
  parallel "${COMMAND} {} | cut -d$'\t' -f1-7,18 | head -1 | sed 's/$/\tfile/' > ${2}" ::: `ls ${1}/* | head -1`
fi


N_JOBS=1
if [ ! -z "${5}" ]; then
  N_JOBS="${5}"
fi
echo "Using n jobs: ${N_JOBS}"


echo "Concatenating S-MultiXcan results"
parallel -j${N_JOBS} "${COMMAND} {} | cut -d$'\t' -f1-7,18 | tail -n +2 | sed 's/$/\t{/}/' | sem --fg -j1 --id l "cat"  >> ${2}" ::: ${1}/*

