from os.path import join

import pandas as pd

from utils import load_pickle
import settings as conf


class Gene:
    biomart_genes = pd.read_csv(conf.BIOMART_GENES_INFO_FILE, index_col='ensembl_gene_id')
    gene_id_to_name_map = load_pickle(join(conf.GENES_METADATA_DIR, 'genes_mapping_simplified-0.pkl'))
    gene_name_to_id_map = load_pickle(join(conf.GENES_METADATA_DIR, 'genes_mapping_simplified-1.pkl'))
    #understudied_genes = pd.read_excel('/mnt/phenomexcan/data/journal.pbio.2006643.s016.xlsx')

    def __init__(self, gene_id=None, gene_name=None):
        if gene_id is not None and gene_name is None:
            self.gene_id = gene_id
            self.gene_name = Gene.gene_id_to_name_map[self.gene_id]
        elif gene_id is None and gene_name is not None:
            self.gene_name = gene_name
            self.gene_id = Gene.gene_name_to_id_map[self.gene_name]
        else:
            self.gene_id = gene_id
            self.gene_name = gene_name
        
        self.gene_band = self._get_gene_band(self.gene_id)
    
#     def is_understudied(self):
#         return self.gene_id in Gene.understudied_genes['gene_ensembl'].values
    
    def _get_gene_band(self, gene_id):
        if gene_id not in Gene.biomart_genes.index:
            return ''
        
        gene_data = Gene.biomart_genes.loc[gene_id]
        chrom = gene_data['chromosome_name']
        band = gene_data['band']
        
        return f'{chrom}{band}'