import tempfile
from os import makedirs
from os.path import join, exists

# Main folders
BASE_DIR = '/mnt/phenomexcan_base/'

TMP_DIR = join(tempfile.gettempdir(), 'phenomexcan')

DATA_DIR = join(BASE_DIR, 'data')

# GTEx
GTEX_DIR = join(DATA_DIR, 'gtex_v8')
GTEX_MODELS_DIR = join(GTEX_DIR, 'mashr')

# Gene info
BIOMART_GENES_INFO_FILE = join(DATA_DIR, 'biomart_genes_hg38.csv')
GENES_METADATA_DIR = join(DATA_DIR, 'genes_metadata')

# GWAS info
GWAS_PHENOTYPES_INFO_FILE = join(DATA_DIR, 'phenotypes.both_sexes.tsv.gz')
