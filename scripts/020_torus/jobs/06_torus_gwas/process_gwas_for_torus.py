import argparse
import logging

import pandas as pd

LOG_FORMAT = "[%(filename)s - %(asctime)s] %(levelname)s: %(message)s"
logging.basicConfig(format=LOG_FORMAT, level=logging.INFO)
logger = logging.getLogger('root')


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--gwas-file', required=True, type=str)
    parser.add_argument('--region-map-file', required=True, type=str)
    parser.add_argument('--output-file', required=True, type=str)
    args = parser.parse_args()

    logger.info(f'Reading GWAS file from {args.gwas_file}')
    data = pd.read_csv(args.gwas_file, sep='\t', usecols=['variant', 'tstat'], index_col='variant')

    logger.info(f'Reading region map file from {args.region_map_file}')
    region_map = pd.read_csv(args.region_map_file, sep='\t', index_col='var_hg19')

    logger.info('Processing GWAS')
    data = data.loc[region_map.index]
    assert data.shape[0] == region_map.shape[0], (data.shape[0], region_map.shape[0])

    data = data.assign(hg38_variant=region_map['var_hg38'])
    data = data.assign(location=region_map['location'])
    data = data.set_index('hg38_variant')[['location', 'tstat']]

    logger.info(f'Writing to {args.output_file}')
    data.to_csv(args.output_file, sep='\t', header=False)

