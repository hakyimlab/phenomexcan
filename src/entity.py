import pandas as pd

from utils import simplify_string
from metadata import \
    BIOMART_GENES, GENE_ID_TO_NAME_MAP, GENE_NAME_TO_ID_MAP, \
    RAPID_GWAS_PHENO_INFO, GTEX_GWAS_PHENO_INFO


class Trait:
    def _init_ukb_metadata(self):
        pheno_data = RAPID_GWAS_PHENO_INFO.loc[self.code]
        self.description = pheno_data['description']
        self.type = pheno_data['variable_type']
        self.source = pheno_data['source']
        self.sample_size = pheno_data['n_non_missing']
        self.n_cases = pheno_data['n_cases']
        self.n_controls = pheno_data['n_controls']

    def _init_gtex_gwas_metadata(self, is_tag):
        if is_tag:
            pheno_data = GTEX_GWAS_PHENO_INFO[GTEX_GWAS_PHENO_INFO['Tag'] == 0]
        else:
            pheno_data = GTEX_GWAS_PHENO_INFO.loc[self.code]

        self.description = pheno_data['Phenotype']
        self.type = None
        if pheno_data['Binary'] == 1:
            self.type = 'binary'
        self.source = pheno_data['source']
        self.sample_size = pheno_data['Sample_Size']
        self.n_cases = pheno_data['Cases']
        self.n_controls = self.sample_size - self.n_cases

    def __init__(self, code):
        self.code = code

        if self.code in RAPID_GWAS_PHENO_INFO.index:
            self._init_ukb_metadata()
        elif self.code in GTEX_GWAS_PHENO_INFO.index:
            self._init_gtex_gwas_metadata(is_tag=False)
        elif self.code in GTEX_GWAS_PHENO_INFO['Tag']:
            self._init_gtex_gwas_metadata(is_tag=True)
        else:
            raise ValueError(f'Invalid phenotype code: {self.code}')

    def get_plain_name(self):
        if not pd.isnull(self.description):
            return f'{self.code}-{simplify_string(self.description)}'
        else:
            return self.code

    def __repr__(self):
        return self.get_plain_name()


class Gene:
    def __init__(self, gene_id=None, gene_name=None):
        if gene_id is not None and gene_name is None:
            self.gene_id = gene_id
            self.gene_name = GENE_ID_TO_NAME_MAP[self.gene_id]
        elif gene_id is None and gene_name is not None:
            self.gene_name = gene_name
            self.gene_id = GENE_NAME_TO_ID_MAP[self.gene_name]
        else:
            self.gene_id = gene_id
            self.gene_name = gene_name
        
        self.gene_band = self._get_gene_band(self.gene_id)
    
    def _get_gene_band(self, gene_id):
        if gene_id not in BIOMART_GENES.index:
            return ''
        
        gene_data = BIOMART_GENES.loc[gene_id]
        chrom = gene_data['chromosome_name']
        band = gene_data['band']
        
        return f'{chrom}{band}'
