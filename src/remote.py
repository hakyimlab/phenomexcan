import os
import tempfile

import pandas as pd

from hashing import get_sha1
from utils import run_command

PHENO_MAIN_SOURCE_MAP = {
    'Rapid GWAS Project': 'RapidGWASProject',
    'GTEX GWAS': 'GTEX_GWAS',
}


def _download_pheno(pheno, output_file):
    print('downloading... ', end='', flush=True)

    wget_command = f'wget -q {pheno.box_share_url} -O {output_file}'
    run_command(wget_command)

    if not os.path.isfile(output_file):
        print('not downloaded')
        return False

    exp_hash = pheno.file_sha1
    curr_hash = get_sha1(output_file)

    if exp_hash == curr_hash:
        print('hash ok... ', end='', flush=True)
    else:
        print('hash do not match')
        return False

    return True


def download_raw_results(results_dir, pheno_info_url, extract=False, extract_and_delete=False):
    if 'RapidGWASProject' in results_dir:
        os.makedirs(results_dir['RapidGWASProject'], exist_ok=True)

    if 'GTEX_GWAS' in results_dir:
        os.makedirs(results_dir['GTEX_GWAS'], exist_ok=True)

    # download pheno info file
    pheno_info_file = os.path.join(tempfile.mkdtemp(), 'pheno_info.xlsx')
    wget_command = f'wget -q {pheno_info_url} -O {pheno_info_file}'
    run_command(wget_command)

    pheno_info = pd.read_excel(pheno_info_file)
    n_success = 0
    for pheno in pheno_info.itertuples():
        print(f'{pheno.file_name}: ', end='', flush=True)

        output_dir = results_dir[PHENO_MAIN_SOURCE_MAP[pheno.main_source]]
        output_file = os.path.join(output_dir, pheno.file_name)

        if os.path.isfile(output_file):
            if get_sha1(output_file) == pheno.file_sha1:
                print('already downloaded... ', end='', flush=True)
            else:
                print('hash do not match, downloading... ', end='', flush=True)
                # os.remove(output_file)
                if not _download_pheno(pheno, output_file):
                    continue
        else:
            if not _download_pheno(pheno, output_file):
                continue

        if extract or extract_and_delete:
            print('uncompressing... ', end='', flush=True)
            tar_command = f'tar -xf {output_file} -C {output_dir}'
            run_command(tar_command)

            if extract_and_delete:
                os.remove(output_file)

        n_success += 1

        print('done')

    if pheno_info.shape[0] == n_success:
        print(f'DONE: {n_success} files downloaded')
    else:
        print(f'WARNING: {n_success} downloaded, {pheno_info.shape[0] - n_success} failed.')
