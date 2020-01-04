import os
import hashlib
import argparse

import settings as conf
from remote import download_raw_results


def _check_md5(expected_md5, filepath):
    with open(filepath, 'rb') as f:
        current_md5 = hashlib.md5(f.read()).hexdigest()
        assert expected_md5 == current_md5, f'md5 failed for "{filepath}"'
    print(f'md5 file ok for {filepath}')


def _create_directories():
    os.makedirs(conf.BASE_DIR, exist_ok=True)
    os.makedirs(conf.DATA_DIR, exist_ok=True)
    os.makedirs(conf.GTEX_DIR, exist_ok=True)
    os.makedirs(conf.TMP_DIR, exist_ok=True)
    os.makedirs(conf.SMULTIXCAN_RESULTS_BASE_DIR, exist_ok=True)


def download_mashr_models():
    output_file = os.path.join(conf.TMP_DIR, 'mashr_eqtl.tar')
    os.system(f'wget https://zenodo.org/record/3518299/files/mashr_eqtl.tar?download=1 -O {output_file}')
    _check_md5('87f3470bf2676043c748b684fb35fa7d', output_file)
    os.system(f'tar -xf {output_file} -C {conf.TMP_DIR}')
    os.system(f'mv {conf.TMP_DIR}/eqtl/mashr/ {conf.GTEX_MODELS_DIR}')


def download_rapid_gwas_pheno_info():
    final_output_file = conf.RAPID_GWAS_PHENO_INFO_FILE
    output_file = os.path.join(conf.TMP_DIR, os.path.basename(final_output_file))
    os.system(f'wget https://uchicago.box.com/shared/static/46gsi3lrrsw030uircn4fesjcrn4898q.gz -O {output_file}')
    _check_md5('cba910ee6f93eaed9d318edcd3f1ce18', output_file)
    os.system(f'mv {output_file} {final_output_file}')


def download_gtex_gwas_pheno_info():
    final_output_file = conf.GTEX_GWAS_PHENO_INFO_FILE
    output_file = os.path.join(conf.TMP_DIR, os.path.basename(final_output_file))
    os.system(f'wget https://uchicago.box.com/shared/static/hvuqanqclnj5wz8xap4xx9jpyrms7bqr.tsv -O {output_file}')
    _check_md5('982434335f07acb1abfb83e57532f2c0', output_file)
    os.system(f'mv {output_file} {final_output_file}')


def download_genes_information():
    final_output_file = conf.BIOMART_GENES_INFO_FILE
    output_file = os.path.join(conf.TMP_DIR, os.path.basename(final_output_file))
    os.system(f'wget https://uchicago.box.com/shared/static/qxgjh6kpa8543s99tlclhil74cd4536k.gz -O {output_file}')
    _check_md5('c4d74e156e968267278587d3ce30e5eb', output_file)
    os.system(f'mv {output_file} {final_output_file}')


def download_clinvar_data():
    final_output_file = conf.CLINVAR_DATA_FILE
    output_file = os.path.join(conf.TMP_DIR, os.path.basename(final_output_file))
    os.system(f'wget https://uchicago.box.com/shared/static/g83rtsctb3borlk5p815mcki27jrje0e -O {output_file}')
    _check_md5('ccfd90344cc59c9869bf6e012c0e5c77', output_file)
    os.system(f'mv {output_file} {final_output_file}')


def download_fastenloc_tissues():
    final_output_file = conf.FASTENLOC_GTEX_TISSUES_FILE
    output_file = os.path.join(conf.TMP_DIR, os.path.basename(final_output_file))
    os.system(f'wget https://uchicago.box.com/shared/static/t7866iiivxa2rdg8n8hx6w3p1rc0sq2t.txt -O {output_file}')
    os.system(f'echo "b31c47aa56ca9fdbac3bee5b3a38ba63 {output_file}" | md5sum -c')
    os.system(f'mv {output_file} {final_output_file}')


def download_smultixcan_results():
    download_raw_results(
        conf.SMULTIXCAN_RESULTS_DIR,
        'https://uchicago.box.com/shared/static/v72fmxm521dvtx238nsoghwadp89fmoa.xlsx',
    )


def download_spredixcan_results():
    download_raw_results(
        conf.SPREDIXCAN_RESULTS_DIR,
        'https://uchicago.box.com/shared/static/b7i2ovtqern07joh7b4481tl10x558i6.xlsx',
    )


def download_fastenloc_results():
    download_raw_results(
        conf.FASTENLOC_RESULTS_DIR,
        'https://uchicago.box.com/shared/static/enwnyinsgcgs48y70qggo8iyuo0gfhct.xlsx',
    )



available_actions = {'all': None, }
local_items = list(locals().items())
for key, value in local_items:
    if callable(value) and value.__module__ == __name__ and not key.startswith('_'):
        available_actions[key] = value


parser = argparse.ArgumentParser(description='PhenomeXcan data setup.')
parser.add_argument('actions', choices=available_actions, nargs="+")
args = parser.parse_args()

_create_directories()

actions_to_run = args.actions
if 'all' in args.actions:
    actions_to_run = list(available_actions.keys())

print(actions_to_run)
for k in actions_to_run:
    if k == 'all':
        continue

    print(f'Running {k}')
    available_actions[k]()

