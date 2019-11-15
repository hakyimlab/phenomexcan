from os.path import join

import pandas as pd

import settings as conf
from utils import load_pickle


# Phenotypes metadata
RAPID_GWAS_PHENO_INFO = pd.read_csv(conf.RAPID_GWAS_PHENO_INFO_FILE, sep='\t', index_col='phenotype')
GTEX_GWAS_PHENO_INFO = pd.read_csv(conf.GTEX_GWAS_PHENO_INFO_FILE, sep='\t', index_col='Tag')

# Genes metadata
BIOMART_GENES = pd.read_csv(conf.BIOMART_GENES_INFO_FILE, index_col='ensembl_gene_id')
GENES_MAPPINGS = load_pickle(join(conf.GENES_METADATA_DIR, 'genes_mappings.pkl'))
GENE_ID_TO_NAME_MAP = load_pickle(join(conf.GENES_METADATA_DIR, 'genes_mapping_simplified-0.pkl'))
GENE_NAME_TO_ID_MAP = load_pickle(join(conf.GENES_METADATA_DIR, 'genes_mapping_simplified-1.pkl'))
