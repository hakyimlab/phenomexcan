#!/usr/bin/env python

import os
import argparse
import sqlite3
from glob import glob

import pandas as pd

parser = argparse.ArgumentParser()
parser.add_argument('--gtex-models-dir', type=str, required=True)
parser.add_argument('--variants-file-with-gtex-id', type=str, required=True)
parser.add_argument('--output-file', type=str, required=True)
args = parser.parse_args()

all_models = glob(os.path.join(args.gtex_models_dir, '*.db'))
assert len(all_models) == 49, len(all_models)

all_variants_ids = set()

for m in all_models:
    print(f'Processing {m}')

    with sqlite3.connect(m) as conn:
        df = pd.read_sql('select varID from weights', conn)['varID']
        all_variants_ids.update(set(df.values))

print(f'Read {len(all_variants_ids)} unique variants in GTEx models')

print(f'Reading {args.variants_file_with_gtex_id}')
variants_gtexid = pd.read_csv(args.variants_file_with_gtex_id, sep='\t', usecols=['panel_variant_id'], squeeze=True).dropna()
variants_gtexid = set(variants_gtexid.values)
print(f'  Read {len(variants_gtexid)} variants')

print('Merging GTEx and other variants')
merged_variants = variants_gtexid.intersection(all_variants_ids)
print(f'Final number of merged variants: {len(merged_variants)}')
print(f'Coverage of GTEx variants: {(len(merged_variants) / len(all_variants_ids)) * 100:.2f}%')

print(f'Writing to {args.output_file}')
pd.DataFrame({'rsid': list(merged_variants)}).to_csv(args.output_file, index=False)

