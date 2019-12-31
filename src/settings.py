import tempfile
from os.path import join

# General settings
N_JOBS = 4
N_JOBS_HIGH = 20 # for low-computational tasks

# Main folders
BASE_DIR = '/mnt/phenomexcan_base/'

TMP_DIR = join(tempfile.gettempdir(), 'phenomexcan')
DATA_DIR = join(BASE_DIR, 'data')
RESULTS_DIR = join(BASE_DIR, 'results')
GENE_ASSOC_DIR = join(BASE_DIR, 'gene_assoc')
DELIVERABLES_DIR = join(BASE_DIR, 'deliverables')
WEBAPP_DIR = join(BASE_DIR, 'webapp')

# GTEx
GTEX_DIR = join(DATA_DIR, 'gtex_v8')
GTEX_MODELS_DIR = join(GTEX_DIR, 'mashr')
GTEX_MODELS_N_EXPECTED_TISSUES = 49

# Gene info
BIOMART_GENES_INFO_FILE = join(DATA_DIR, 'biomart_genes_hg38.csv.gz')
GENES_METADATA_DIR = join(DATA_DIR, 'genes_metadata')

# GWAS info
RAPID_GWAS_PHENO_INFO_FILE = join(DATA_DIR, 'phenotypes.both_sexes.tsv.gz')
GTEX_GWAS_PHENO_INFO_FILE = join(DATA_DIR, 'gtex_gwas_phenotypes_metadata.tsv')

# Clinvar
CLINVAR_DATA_FILE = join(DATA_DIR, '2019-07-16-gene_condition_source_id')

# S-MultiXcan
SMULTIXCAN_RESULTS_BASE_DIR = join(RESULTS_DIR, 'smultixcan')
SMULTIXCAN_RESULTS_DIR = {
    'RapidGWASProject': join(SMULTIXCAN_RESULTS_BASE_DIR, 'rapid_gwas_project'),
    'GTEX_GWAS': join(SMULTIXCAN_RESULTS_BASE_DIR, 'gtex_gwas'),
}
SMULTIXCAN_EXPECTED_PHENOTYPES = {
    'RapidGWASProject': 4049,
    'GTEX_GWAS': 42,
}

# S-PrediXcan
SPREDIXCAN_RESULTS_BASE_DIR = join(RESULTS_DIR, 'spredixcan')
SPREDIXCAN_RESULTS_DIR = {
    'RapidGWASProject': join(SPREDIXCAN_RESULTS_BASE_DIR, 'rapid_gwas_project'),
    'GTEX_GWAS': join(SPREDIXCAN_RESULTS_BASE_DIR, 'gtex_gwas'),
}
SPREDIXCAN_EXPECTED_PHENOTYPES = {
    'RapidGWASProject': SMULTIXCAN_EXPECTED_PHENOTYPES['RapidGWASProject'],
    'GTEX_GWAS': SMULTIXCAN_EXPECTED_PHENOTYPES['GTEX_GWAS'],
}

# fastENLOC
FASTENLOC_GTEX_TISSUES_FILE = join(DATA_DIR, 'fastenloc_gtex_tissues.txt')

FASTENLOC_RESULTS_BASE_DIR = join(RESULTS_DIR, 'fastenloc')
FASTENLOC_RESULTS_DIR = {
    'RapidGWASProject': join(FASTENLOC_RESULTS_BASE_DIR, 'rapid_gwas_project'),
    'GTEX_GWAS': join(FASTENLOC_RESULTS_BASE_DIR, 'gtex_gwas'),
}
FASTENLOC_EXPECTED_PHENOTYPES = {
    'RapidGWASProject': SMULTIXCAN_EXPECTED_PHENOTYPES['RapidGWASProject'],
    'GTEX_GWAS': SMULTIXCAN_EXPECTED_PHENOTYPES['GTEX_GWAS'],
}

# TORUS
TORUS_RESULTS_BASE_DIR = join(RESULTS_DIR, 'torus')
TORUS_RESULTS_DIR = {
    'RapidGWASProject': join(TORUS_RESULTS_BASE_DIR, 'rapid_gwas_project'),
}
TORUS_EXPECTED_PHENOTYPES = {
    'RapidGWASProject': SMULTIXCAN_EXPECTED_PHENOTYPES['RapidGWASProject'],
}
