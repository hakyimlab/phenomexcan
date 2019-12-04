#!/bin/bash
set -e

if [ -z "${1}" ]; then
  echo "Specify job directory."
  exit 1
fi

RESOURCES="jobs/common/confs/basic"
if [ -f "${1}/resources" ]; then
    RESOURCES="${1}/resources"
fi

cat ${1}/header ${RESOURCES} jobs/common/vars ${1}/main

