import os
import sys
import argparse

import pandas as pd

from utils import simplify_string_for_hdf5


parser = argparse.ArgumentParser(description='S-PrediXcan results processor.')
parser.add_argument('--spredixcan-hdf5-folder', required=True, type=str)
parser.add_argument('--spredixcan-hdf5-file-template', required=False, type=str, default='spredixcan-{tissue}-{column}.h5')
parser.add_argument('--tissue-id', required=True, type=int)
parser.add_argument('--phenotype-id', required=True, type=int)
parser.add_argument('--phenotypes-info-file', required=True, type=str)
parser.add_argument('--tissues-info-file', required=True, type=str)
parser.add_argument('--genes-info-file', required=True, type=str)
parser.add_argument('--no-header', required=False, action='store_true')
args = parser.parse_args()

# pheno info
pheno_info = pd.read_csv(args.phenotypes_info_file, sep='\t', index_col='pheno_id')
pheno_full_code_to_source = pheno_info[['full_code', 'source']].set_index('full_code').to_dict()['source']

pheno_full_code = pheno_info.loc[args.phenotype_id, 'full_code']
pheno_desc = pheno_info.loc[args.phenotype_id, 'unique_description']
pheno_source = pheno_info.loc[args.phenotype_id, 'source']

# tissue info
tissue_info = pd.read_csv(args.tissues_info_file, sep='\t', index_col='tissue_id')
tissue_name = tissue_info.loc[args.tissue_id, 'tissue_name']

# gene info
gene_mappings = pd.read_csv(args.genes_info_file, sep='\t')

# read s-predixcan results
all_spredixcan_results = {}
for column in ('effect_size', 'pvalue', 'zscore'):
    spredixcan_results_filename = os.path.join(
        args.spredixcan_hdf5_folder,
        args.spredixcan_hdf5_file_template.format(tissue=tissue_name, column=column)
    )
    spredixcan_results = pd.read_hdf(spredixcan_results_filename, key=simplify_string_for_hdf5(pheno_full_code))

    all_spredixcan_results[column] = spredixcan_results

all_spredixcan_results = pd.DataFrame(all_spredixcan_results)
all_spredixcan_results = all_spredixcan_results.dropna(subset=['pvalue'])
all_spredixcan_results = all_spredixcan_results.assign(pheno_id=args.phenotype_id)
all_spredixcan_results = all_spredixcan_results.assign(tissue_id=args.tissue_id)

# add gene_id column
all_spredixcan_results = pd.merge(
    all_spredixcan_results,
    gene_mappings[['gene_id', 'gene_num_id']].set_index('gene_id'),
    left_index=True,
    right_index=True,
    how='left',
    validate='one_to_one',
)

all_spredixcan_results = all_spredixcan_results.set_index(['pheno_id', 'tissue_id', 'gene_num_id']).sort_index()

# write final file
try:
    all_spredixcan_results.to_csv(
        sys.stdout,
        sep='\t',
        float_format='%.4e',
        header=not args.no_header
    )
    sys.exit(0)
except BrokenPipeError:
    sys.exit(0)
