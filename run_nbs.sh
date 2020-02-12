#!/bin/bash

IP="127.0.0.1"
if [ ! -z "${1}" ]; then
  IP="${1}"
  echo "Using IP: ${1}"
fi

PYTHONPATH=`pwd`/src jupyter lab --ip ${IP} --port 8888 --no-browser

