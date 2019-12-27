import os
import hashlib
import argparse

import pandas as pd

import settings as conf


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


def download_smultixcan_results_for_rapid_gwas_project():
    output_file = os.path.join(conf.TMP_DIR, 'smultixcan_mashr.tar')
    os.system(f'wget https://uchicago.box.com/shared/static/prq9o1vuwtba4ktfi1tm1hjqfiy8qvar.tar -O {output_file}')
    _check_md5('6900f6da03d6b430f942a32ec41124ba', output_file)
    os.system(f'tar -xf {output_file} -C {conf.TMP_DIR}')
    os.system(f'mv {conf.TMP_DIR}/smultixcan/ {conf.SMULTIXCAN_RESULTS_DIR["RapidGWASProject"]}')


def download_smultixcan_results_for_gtex_gwas():
    output_file = os.path.join(conf.TMP_DIR, 'gtex_gwas-42_traits-smultixcan.tar.gz')
    os.system(f'wget https://uchicago.box.com/shared/static/qi8m6mdxdyss42ui6dsukpuemh107yfv.gz -O {output_file}')
    _check_md5('2b1ade011506f87fe632ad56c6c99357', output_file)
    os.system(f'tar -xf {output_file} -C {conf.TMP_DIR}')
    os.system(f'mv {conf.TMP_DIR}/smultixcan/ {conf.SMULTIXCAN_RESULTS_DIR["GTEX_GWAS"]}')


def download_fastenloc_results_for_rapid_gwas_project():
    base_dir = os.path.join(conf.TMP_DIR, 'fastenloc')
    os.makedirs(base_dir, exist_ok=True)

    file_list = os.path.join(base_dir, 'fastenloc_download_list')
    os.system(f'wget https://uchicago.box.com/shared/static/vyk414lg2jzo00szehhxxyqwi6dxxsjz -O {file_list}')

    md5_file = os.path.join(base_dir, 'MD5SUM.txt')
    os.system(f'wget https://uchicago.box.com/shared/static/0ny0u72q5ir3nyw8sk84iwgkho8ak8qk.txt -O {md5_file}')
    md5info = pd.read_csv(md5_file, header=None, sep='\s+', index_col=1, squeeze=True)

    for row in pd.read_csv(file_list, header=None, sep='\s+').itertuples(index=False):
        file_url = row[0]
        file_name = row[1]

        if 'MD5SUM' in file_name:
            continue

        file_name_path = os.path.join(base_dir, file_name)

        print(f'Downloading: {file_name}')
        os.system(f'wget {file_url} -O {file_name_path}')
        _check_md5(md5info.loc[file_name], file_name_path)
        print(f'  md5 checking ok')


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

