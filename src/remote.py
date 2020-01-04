import os
import subprocess
import tempfile

import pandas as pd

import settings as conf
from hashing import get_sha1


PHENO_MAIN_SOURCE_MAP = {
    'Rapid GWAS Project': 'RapidGWASProject',
    'GTEX GWAS': 'GTEX_GWAS',
}


def download_raw_results(results_dir, pheno_info_url):
    if 'RapidGWASProject' in results_dir:
        os.makedirs(results_dir['RapidGWASProject'], exist_ok=True)

    if 'GTEX_GWAS' in results_dir:
        os.makedirs(results_dir['GTEX_GWAS'], exist_ok=True)

    # download pheno info file
    pheno_info_file = os.path.join(tempfile.mkdtemp(), 'pheno_info.xlsx')
    subprocess.call(f'wget -q {pheno_info_url} -O {pheno_info_file}', shell=True)

    pheno_info = pd.read_excel(pheno_info_file)
    n_success = 0
    for pheno in pheno_info.itertuples():
        print(f'{pheno.file_name}: ', end='', flush=True)

        output_dir = results_dir[PHENO_MAIN_SOURCE_MAP[pheno.main_source]]
        output_file = os.path.join(output_dir, pheno.file_name)

        exp_hash = pheno.file_sha1

        if os.path.isfile(output_file):
            if get_sha1(output_file) == exp_hash:
                print('already downloaded', flush=True)
                n_success += 1
                continue
            else:
                print('hash do not match, downloading... ', end='', flush=True)
                os.remove(output_file)
        else:
            print('downloading... ', end='', flush=True)

        wget_command = f'wget -q {pheno.box_share_url} -O {output_file}'
        subprocess.call(wget_command, shell=True)

        if os.path.isfile(output_file):
            curr_hash = get_sha1(output_file)
            if exp_hash == curr_hash:
                n_success += 1
                print('done')
            else:
                print('hash do not match')
        else:
            print('not downloaded')

    if pheno_info.shape[0] == n_success:
        print(f'DONE: {n_success} files downloaded')
    else:
        print(f'WARNING: {n_success} downloaded, {pheno_info.shape[0] - n_success} failed.')
