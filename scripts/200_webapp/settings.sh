# Paths configuration
export PHENOTYPES_INFO_FILE="/mnt/phenomexcan_base/deliverables/phenotypes_info.tsv.gz"
export TISSUES_FILE="/mnt/phenomexcan_base/deliverables/tissues.tsv"
export GENES_INFO_FILE="/mnt/phenomexcan_base/deliverables/genes_info.tsv.gz"

export SMULTIXCAN_RESULTS_DIR_00="/mnt/phenomexcan_base/results/smultixcan/rapid_gwas_project"
export SMULTIXCAN_PATTERN_00='^smultixcan_(?P<code>.*)_ccn30\.tsv\.gz$'
export SMULTIXCAN_RESULTS_DIR_01="/mnt/phenomexcan_base/results/smultixcan/gtex_gwas"
export SMULTIXCAN_PATTERN_01='^(?P<code>.*)_smultixcan_imputed_gwas_gtexv8mashr_ccn30\.txt$'

export SPREDIXCAN_HDF5_FOLDER="/mnt/phenomexcan_base/gene_assoc/spredixcan"
export SPREDIXCAN_DIRECTION_EFFECT_MOST_SIGNIF_HDF5_FILE="/mnt/phenomexcan_base/gene_assoc/spredixcan-mashr-effect_direction-most_signif.h5"
export SPREDIXCAN_DIRECTION_EFFECT_CONSENSUS_HDF5_FILE="/mnt/phenomexcan_base/gene_assoc/spredixcan-mashr-effect_direction-consensus.h5"

export FASTENLOC_HDF5_FILE="/mnt/phenomexcan_base/gene_assoc/fastenloc-torus-rcp.h5"

# PostgreSQL configuration
export DBUSER="ukbrest"
export DBHOST='localhost'
export DBPORT=7432
export DBDATABASE_NAME='phenomexcan'
