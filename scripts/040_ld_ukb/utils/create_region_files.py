import os
import argparse

import pandas as pd
from pyliftover import LiftOver

from utils.log import get_logger


def _map_coords(map_dict, row, logger):
    source = f'{row["chr_thin"]}:{row["pos"]}'
    if source not in map_dict:
        logger.warning(f'Source coord not found: {source}')
        return None
    return map_dict[source]


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--sliced-gwas-file', type=str, required=True)
    parser.add_argument('--chromosome', type=str, required=True)
    parser.add_argument('--output-folder', type=str, required=True)
    parser.add_argument('--coordinates-mapping-file', type=str, required=True)
    parser.add_argument('--only-regions', type=str, nargs='+', required=False, default=None)
    parser.add_argument('--force', action='store_true', required=False)
    args = parser.parse_args()

    os.makedirs(args.output_folder, exist_ok=True)

    # get logger
    logger = get_logger(filename=os.path.join(args.output_folder, f'logs_chr{args.chromosome}.txt'))

    logger.info(f'Reading sliced GWAS: {args.sliced_gwas_file}')
    data = pd.read_csv(args.sliced_gwas_file, sep='\t', header=None)
    data = data.rename(columns={0: 'varid', 1: 'region', 2: 'zscore'})
    data = data.assign(chromosome=data['varid'].apply(lambda x: x.split('_')[0].split('chr')[1]))
    logger.info(f'Read {data.shape[0]} variants')

    selected_chr = data[(data['chromosome'] == args.chromosome)]
    logger.info(f'Number of variants in chromosome {args.chromosome}: {selected_chr.shape[0]}')

    selected_regions = selected_chr['region'].unique()
    logger.info(f'Number of regions in chromosome {args.chromosome}: {selected_regions.shape[0]}')

    #logger.info('Creating LiftOver instance')
    #lo = LiftOver(os.path.join(args.liftover_chains_folder, 'hg38ToHg19.over.chain.gz'))
    logger.info(f'Reading coordinates map file: {args.coordinates_mapping_file}')
    coords_df = pd.read_csv(args.coordinates_mapping_file, sep='\t')
    map_to_hg19 = coords_df[['hg38_variant', 'hg19_variant']].set_index('hg38_variant').squeeze().to_dict()

    for region in selected_regions:
        if args.only_regions is not None and region not in args.only_regions:
            continue

        logger.info(f'Working on region {region}')

        variants_file = os.path.join(args.output_folder, f'chr{args.chromosome}_{region}_variants.tsv')
        if os.path.isfile(variants_file) and not args.force:
            logger.warning(f'Output file exists, quitting')
            continue

        region_variants = selected_chr[selected_chr['region'] == region].reset_index()
        logger.info(f'Number of variants in region: {region_variants.shape[0]}')

        varid_split = (
            region_variants['varid']
                .str.split('_', expand=True)
                .rename(columns={0: 'chr', 1: 'pos', 2: 'ref', 3: 'alt', 4: 'build'})
        )
        varid_split = varid_split.assign(chr_thin=varid_split['chr'].apply(lambda x: x[3:]))
        varid_split['pos'] = varid_split['pos'].astype(int)

        logger.info('Re-mapping back to hg19')
        mapped_region_data = varid_split.apply(lambda x: _map_coords(map_to_hg19, x, logger), axis=1)
        mapped_region_data = mapped_region_data.rename('variant')

        mapped_region_data_no_nan = mapped_region_data.dropna()
        if mapped_region_data.shape != mapped_region_data_no_nan.shape:
            logger.warning(f'Variants lost in mapping: {mapped_region_data.shape[0] - mapped_region_data_no_nan.shape[0]}')
            mapped_region_data = mapped_region_data_no_nan

        # add ref and alt alleles to liftOver mapped file
        logger.info(f'Saving variants file to: {variants_file}')

        mapped_region_data.to_csv(variants_file, header=True, index=False)
        logger.info(f'Finished. Saved {mapped_region_data.shape[0]} variants')

