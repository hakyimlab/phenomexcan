#!/bin/bash

module load gcc/6.2.0 parallel/20170122

parallel -j1 'bash utils/run.sh {} | qsub' ::: jobs/00_*

