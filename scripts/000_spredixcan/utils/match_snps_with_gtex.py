#!/usr/bin/env python

import argparse
import logging

import pandas as pd

parser = argparse.ArgumentParser()
parser.add_argument('--variants-file-with-gtex-id', type=str, required=True)
parser.add_argument('--variants-file-neale', type=str, required=True)
parser.add_argument('--output-file', type=str, required=True)
args = parser.parse_args()

LOG_FORMAT = "[%(filename)s - %(asctime)s] %(levelname)s: %(message)s"
logging.basicConfig(format=LOG_FORMAT, level=logging.INFO)
logger = logging.getLogger('root')

logger.info(f'Reading {args.variants_file_with_gtex_id}')
snp00 = pd.read_csv(args.variants_file_with_gtex_id, sep='\t', usecols=['variant', 'panel_variant_id']).dropna(subset=['panel_variant_id'])

logger.info(f'Reading {args.variants_file_neale}')
snp01 = pd.read_csv(args.variants_file_neale, sep='\t', usecols=['variant'])

logger.info(f'Merging')
snp_merge = pd.merge(snp01, snp00, how='left', on='variant', validate='one_to_one')

logger.info(f'Writing to {args.output_file}')
snp_merge[['panel_variant_id']].to_csv(args.output_file, sep='\t', index=False, na_rep='NaN')

