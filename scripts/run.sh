#!/bin/bash
set -e

if [ -z "${1}" ]; then
  echo "Specify notebook to run"
  exit 1
fi

filename=$(basename -- "$1")
filename="${filename%.*}"

export PYTHONPATH=`pwd`/../src/
jupyter nbconvert \
  --to python \
  --output "$filename" \
  ${1}

ipython "${1%.*}".py

rm "${1%.*}".py

