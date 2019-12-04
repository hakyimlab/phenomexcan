import os
from glob import glob
import json
import random
import argparse

import pandas as pd


def _read_tissues(args):
    import re

    # en_Brain_Hippocampus.db
    PATTERN = re.compile(args.gtex_models_regex)

    gtex_dir = args.gtex_models_dir
    all_model_files = [os.path.basename(f) for f in glob(os.path.join(gtex_dir, '*.db'))]
    return [re.search(PATTERN, f).group('tissue') for f in all_model_files]


def _write_file(args, out_dir, pheno, pheno_md, filename, file_pattern=None):
    with open(os.path.join(args.job_template_dir, filename), 'r') as f:
        file_content = f.read()

    job_dir = os.path.join(out_dir, 'logs')
    orig_file = pheno_md['File']
    new_file_uncompressed = pheno_md['File'][:-4]
    new_file = new_file_uncompressed + '.gz'

    wget_command = 'wget {} -O {}'.format(
        pheno_md['Dropbox File'],
        orig_file,
    )

    file_content = (
        file_content
            .replace('__JOB_DIR__', job_dir)
            .replace('__PHENO_ID__', pheno)
            .replace('__PHENO_ORIG_FILE__', orig_file)
            .replace('__PHENO_NEW_FILE__', new_file)
            .replace('__PHENO_NEW_FILE_UNCOMPRESSED__', new_file_uncompressed)
            .replace('__WGET_COMMAND__', wget_command)
            .replace('__TISSUES_SELECTED__', ' '.join(tissues_selected))
            .replace('__METAXCAN_RESULT_FILENAME_SUFFIX__', '-2018_10')
    )

    if file_pattern is not None:
        file_content = file_content.replace('__FILE_PATTERN__', file_pattern)

    if args.extra_variables is not None:
        for k, v in args.extra_variables.items():
            file_content = file_content.replace(k, str(v))

    file_path = os.path.join(out_dir, filename)
    with open(file_path, 'w') as f:
        f.write(file_content)


def _write_all_files(args, pheno, pheno_md, file_pattern=None):
    if file_pattern is not None:
        file_pattern = os.path.basename(file_pattern).split('.')[0]
        out_dir = os.path.join(args.output_dir, pheno, file_pattern)
    else:
        out_dir = os.path.join(args.output_dir, pheno)

    os.makedirs(out_dir, exist_ok=True)

    # header
    _write_file(args, out_dir, pheno, pheno_md, 'header', file_pattern=file_pattern)

    # resources
    _write_file(args, out_dir, pheno, pheno_md, 'resources', file_pattern=file_pattern)

    # main
    _write_file(args, out_dir, pheno, pheno_md, 'main', file_pattern=file_pattern)


def write_phenotypes_jobs(args, phenotypes, phenos, phenos_metadata):
    print('Working on phenotypes:')
    for pheno in phenotypes:
        if pheno not in phenos.index:
            raise ValueError(f'Phenotype "{pheno}" does not exist.')

        print(f'{pheno}', end=', ', flush=True)

        pheno_md = phenos_metadata.loc[pheno]
        if isinstance(pheno_md, pd.DataFrame):
            pheno_md = pheno_md.query('Sex == "both_sexes"').iloc[0]

        if args.extra_file_pattern_iterator is not None:
            from concurrent.futures import ProcessPoolExecutor, as_completed

            with ProcessPoolExecutor(max_workers=args.n_jobs) as executor:
                futures = {
                    executor.submit(_write_all_files, args, pheno, pheno_md, f): f
                    for f in glob(args.extra_file_pattern_iterator)
                }

            for future in as_completed(futures):
                try:
                    future.result()
                except Exception as e:
                    print(f'Exception: {e}')
        else:
            _write_all_files(args, pheno, pheno_md)

    print()


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--job-template-dir', required=True, type=str)
    parser.add_argument('--gtex-models-dir', required=True, type=str)
    parser.add_argument('--gtex-models-regex', required=True, type=str)
    parser.add_argument('--output-dir', required=True, type=str)
    parser.add_argument('--extra-variables', type=json.loads)
    parser.add_argument('--extra-file-pattern-iterator', type=str)
    parser.add_argument('--tissues', type=str, nargs='+')
    parser.add_argument('--phenotypes', type=str, nargs='+')
    parser.add_argument('--sources', type=str, nargs='+')
    parser.add_argument('--variable-type', type=str, nargs='+')
    parser.add_argument('--sample', type=int)
    parser.add_argument('--n-jobs', type=int)

    args = parser.parse_args()

    script_path = os.path.dirname(os.path.realpath(__file__))

    phenos_file = os.path.join(script_path, 'phenotypes.both_sexes.tsv')
    print(f'Reading {phenos_file}')
    phenos = pd.read_csv(phenos_file, sep='\t', index_col='phenotype')
    assert phenos.index.is_unique

    phenos_metadata_file = os.path.join(script_path, 'phenotypes-google_docs.tsv')
    print(f'Reading {phenos_metadata_file}')
    phenos_metadata = pd.read_csv(phenos_metadata_file, sep='\t', index_col='Phenotype Code')

    if args.tissues is None:
        print('All tissues will be selected')
        tissues_selected = _read_tissues(args)
    else:
        tissues_selected = args.tissues

    os.makedirs(args.output_dir, exist_ok=True)

    phenotypes = []
    if args.phenotypes is not None and len(args.phenotypes) > 0:
        phenotypes = args.phenotypes
    elif args.sources is not None and len(args.sources) > 0:
        conds = phenos['source'].isin(args.sources)

        if args.variable_type is not None:
            conds = (conds) & (phenos['variable_type'].isin(args.variable_type))

        phenotypes = phenos[conds].index.tolist()
    else:
        print('WARNING: creating jobs for all phenotypes')
        phenotypes = phenos.index.tolist()

    if args.sample is not None:
        phenotypes = random.sample(phenotypes, args.sample)

    write_phenotypes_jobs(args, phenotypes, phenos, phenos_metadata)

