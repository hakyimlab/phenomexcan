#!/bin/bash
set -e

if [ -z "${1}" ]; then
  echo "Specify notebook to run"
  exit 1
fi

export PYTHONPATH=`pwd`/../src/
jupyter nbconvert \
  --ExecutePreprocessor.timeout=0 \
  --to notebook \
  --execute ${1}

