#!/bin/bash

echo "Place this script in the directory where phenotype folders (with results) are located"
sleep 10

parallel -j8 'tar -cjf fastenloc-v2-{}.tar.bz2 {}/' ::: *

