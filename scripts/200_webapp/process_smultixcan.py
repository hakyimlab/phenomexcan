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
parser.add_argument('--spredixcan-most_signif-dir-effect-h5-file', required=True, type=str)
parser.add_argument('--spredixcan-consensus-dir-effect-h5-file', required=True, type=str)
parser.add_argument('--phenotypes-info-file', required=True, type=str)
parser.add_argument('--genes-info-file', required=True, type=str)
parser.add_argument('--no-header', required=False, action='store_true')
args = parser.parse_args()


# pheno info
pheno_info = pd.read_csv(args.phenotypes_info_file, sep='\t')
pheno_code_to_id = pheno_info[['short_code', 'pheno_id']].set_index('short_code').to_dict()['pheno_id']
pheno_code_to_unique_desc = pheno_info[['short_code', 'unique_description']].set_index('short_code').to_dict()['unique_description']
pheno_code_to_full_code = pheno_info[['short_code', 'full_code']].set_index('short_code').to_dict()['full_code']
pheno_code_to_source = pheno_info[['short_code', 'source']].set_index('short_code').to_dict()['source']

# gene mappings
gene_mappings = pd.read_csv(args.genes_info_file, sep='\t')
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

pheno_id = pheno_code_to_id[pheno_code]
pheno_desc = pheno_code_to_unique_desc[pheno_code]
pheno_full_code = pheno_code_to_full_code[pheno_code]
pheno_source = pheno_code_to_source[pheno_code]

smultixcan_data = smultixcan_data.assign(pheno_id=pheno_id)
# smultixcan_data = smultixcan_data.assign(pheno_desc=pheno_desc)
# smultixcan_data = smultixcan_data.assign(pheno_full_code=pheno_full_code)
# smultixcan_data = smultixcan_data.assign(pheno_source=pheno_source)

# add gene_id column
smultixcan_data = pd.merge(
    smultixcan_data.set_index('gene'),
    gene_mappings[['gene', 'gene_id', 'gene_num_id']].set_index('gene'),
    left_index=True,
    right_index=True,
    how='left',
)

# add fastenloc
fastenloc_data = pd.read_hdf(args.fastenloc_h5_file, key=simplify_string_for_hdf5(pheno_full_code))
smultixcan_data = smultixcan_data.reset_index().set_index('gene_id', drop=False)
smultixcan_data = smultixcan_data.assign(rcp=fastenloc_data)

# add direction of effect
most_signif_direction_effect = pd.read_hdf(args.spredixcan_most_signif_dir_effect_h5_file, key=simplify_string_for_hdf5(pheno_full_code))
most_signif_direction_effect = most_signif_direction_effect.astype('category').cat.rename_categories({-1.0: '-1', 0.0: '0', 1.0: '1'})
smultixcan_data = smultixcan_data.assign(dir_effect_most_signif=most_signif_direction_effect)

consensus_direction_effect = pd.read_hdf(args.spredixcan_consensus_dir_effect_h5_file, key=simplify_string_for_hdf5(pheno_full_code))
consensus_direction_effect = consensus_direction_effect.astype('category').cat.rename_categories({-1.0: '-1', 0.0: '0', 1.0: '1'})
smultixcan_data = smultixcan_data.assign(dir_effect_consensus=consensus_direction_effect)

# reorder columns
smultixcan_data = smultixcan_data.set_index(['pheno_id', 'gene_num_id']).sort_index()
smultixcan_data = smultixcan_data[[
    'pvalue',
    'dir_effect_most_signif', 'dir_effect_consensus',
    'n', 'n_indep',
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
