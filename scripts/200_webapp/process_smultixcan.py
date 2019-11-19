import os
import sys
import re
import argparse

import pandas as pd

from utils import simplify_string_for_hdf5

parser = argparse.ArgumentParser(description='S-MultiXcan results processor.')
parser.add_argument('--smultixcan-file', required=True, type=str)
parser.add_argument('--smultixcan-file-pattern', required=True, type=str, help='Must contain a named grouped called "code"')
parser.add_argument('--fastenloc-h5-file', required=True, type=str)
parser.add_argument('--phenotypes-info-file', required=True, type=str)
parser.add_argument('--gene-mappings-file', required=True, type=str)
parser.add_argument('--no-header', required=False, action='store_true')
args = parser.parse_args()


# pheno info
pheno_info = pd.read_csv(args.phenotypes_info_file, sep='\t')
pheno_id_to_unique_desc = pheno_info[['short_code', 'unique_description']].set_index('short_code').to_dict()['unique_description']
pheno_id_to_full_code = pheno_info[['short_code', 'full_code']].set_index('short_code').to_dict()['full_code']
pheno_id_to_source = pheno_info[['short_code', 'source']].set_index('short_code').to_dict()['source']

# gene mappings
gene_mappings = pd.read_csv(args.gene_mappings_file, sep='\t')
gene_to_band = gene_mappings[['gene', 'band']].set_index('gene').to_dict()['band']
gene_to_gene_id = gene_mappings[['gene', 'gene_id']].set_index('gene').to_dict()['gene_id']

# read smultixcan
smultixcan_data = pd.read_csv(
    args.smultixcan_file,
    sep='\t',
    usecols=['gene', 'gene_name', 'pvalue', 'n', 'n_indep', 't_i_best', 'p_i_best']
)
smultixcan_data = smultixcan_data.dropna(subset=['pvalue'])

smultixcan_data['n'] = smultixcan_data['n'].astype(int)
smultixcan_data['n_indep'] = smultixcan_data['n_indep'].astype(int)

# add pheno info columns
smultixcan_filename = os.path.basename(args.smultixcan_file)

match = re.search(args.smultixcan_file_pattern, smultixcan_filename)
if match is not None and 'code' in match.groupdict().keys():
    pheno_code = match.group('code')
else:
    raise ValueError('Regex did not match or no "code" named group found.')

pheno_desc = pheno_id_to_unique_desc[pheno_code]
pheno_full_code = pheno_id_to_full_code[pheno_code]
pheno_source = pheno_id_to_source[pheno_code]

smultixcan_data = smultixcan_data.assign(pheno_desc=pheno_desc)
smultixcan_data = smultixcan_data.assign(pheno_full_code=pheno_full_code)
smultixcan_data = smultixcan_data.assign(pheno_source=pheno_source)

# add gene_id column
smultixcan_data = pd.merge(
    smultixcan_data.set_index('gene'),
    gene_mappings[['gene_id', 'gene', 'band']].set_index('gene'),
    left_index=True,
    right_index=True,
    how='left',
)

# add fastenloc
fastenloc_data = pd.read_hdf(args.fastenloc_h5_file, key=simplify_string_for_hdf5(pheno_full_code))
smultixcan_data = smultixcan_data.reset_index().set_index('gene_id', drop=False)
smultixcan_data = smultixcan_data.assign(rcp=fastenloc_data)

# reorder columns
smultixcan_data = smultixcan_data.set_index('gene')
smultixcan_data = smultixcan_data[[
    'gene_name', 'band',
    'pheno_desc', 'pheno_source', # 'pheno_full_code'
    'pvalue',
    'n', 'n_indep',
    'p_i_best', 't_i_best',
    'rcp',
]]

# write final file
try:
    smultixcan_data.to_csv(
        sys.stdout,
        sep='\t',
        float_format='%.4e',
        header=not args.no_header
    )
    sys.exit(0)
except BrokenPipeError:
    sys.exit(0)
