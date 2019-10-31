from os.path import join

###

BASE_DIR = '/mnt/phenomexcan_base/'

DATA_DIR = join(BASE_DIR, 'data')

# GTEx
GTEX_DIR = join(DATA_DIR, 'gtex_v8')
GTEX_MODELS_DIR = join(GTEX_DIR, 'mashr')

# Gene info
BIOMART_GENES_INFO_FILE = join(DATA_DIR, 'biomart_genes_hg38.csv')
GENES_METADATA_DIR = join(DATA_DIR, 'genes_metadata')
