#!/bin/bash
set -e

if [ -z "${1}" ]; then
  echo "Specify notebook to run"
  exit 1
fi

filename="${1%.*}.run.ipynb"

export PYTHONPATH=`pwd`/../src/
papermill \
  --log-output \
  --request-save-on-cell-execute \
  $1 \
  $filename

