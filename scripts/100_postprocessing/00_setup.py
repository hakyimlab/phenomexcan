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
    os.makedirs(conf.OMIM_SILVER_STANDARD_BASE_DIR, exist_ok=True)
    os.makedirs(conf.MISC_RESULTS_BASE_DIR, exist_ok=True)


def download_mashr_models(**kwargs):
    output_file = os.path.join(conf.TMP_DIR, 'mashr_eqtl.tar')
    os.system(f'wget https://zenodo.org/record/3518299/files/mashr_eqtl.tar?download=1 -O {output_file}')
    _check_md5('87f3470bf2676043c748b684fb35fa7d', output_file)
    os.system(f'tar -xf {output_file} -C {conf.TMP_DIR}')
    os.system(f'mv {conf.TMP_DIR}/eqtl/mashr/ {conf.GTEX_MODELS_DIR}')


def download_rapid_gwas_pheno_info(**kwargs):
    final_output_file = conf.RAPID_GWAS_PHENO_INFO_FILE
    output_file = os.path.join(conf.TMP_DIR, os.path.basename(final_output_file))
    os.system(f'wget https://uchicago.box.com/shared/static/46gsi3lrrsw030uircn4fesjcrn4898q.gz -O {output_file}')
    _check_md5('cba910ee6f93eaed9d318edcd3f1ce18', output_file)
    os.system(f'mv {output_file} {final_output_file}')


def download_hpo_to_omim_and_phecode(**kwargs):
    final_output_file = os.path.join(conf.DATA_DIR, 'hpo-to-omim-and-phecode.csv.gz')
    output_file = os.path.join(conf.TMP_DIR, os.path.basename(final_output_file))
    os.system(f'wget https://uchicago.box.com/shared/static/31u8dcmokowzddf98n6f98d8yg86yhdx.gz -O {output_file}')
    _check_md5('85b25a9707897ef3cd16ab3bc8718398', output_file)
    os.system(f'mv {output_file} {final_output_file}')


def download_phewas_catalog(**kwargs):
    final_output_file = os.path.join(conf.DATA_DIR, 'phewas-catalog.csv.gz')
    output_file = os.path.join(conf.TMP_DIR, os.path.basename(final_output_file))
    os.system(f'wget https://uchicago.box.com/shared/static/nde83340q6qxjtwlbidz5rzdp67o8c8u.gz -O {output_file}')
    _check_md5('da863d9df86e95e624bcfe5683ee3ead', output_file)
    os.system(f'mv {output_file} {final_output_file}')


def download_omim_standard(**kwargs):
    final_output_file = os.path.join(conf.DATA_DIR, 'omim_silver_standard.tsv')
    output_file = os.path.join(conf.TMP_DIR, os.path.basename(final_output_file))
    os.system(f'wget https://uchicago.box.com/shared/static/1urk2apf8w1nq1qu6v4nmk152aad5qfe.tsv -O {output_file}')
    _check_md5('5b2b4744359a46ec1453f07ed56d180f', output_file)
    os.system(f'mv {output_file} {final_output_file}')


def download_omim_standard_gwas2gene(**kwargs):
    final_output_file = os.path.join(conf.RESULTS_DIR, 'gwas2gene.tar.gz')
    output_file = os.path.join(conf.TMP_DIR, os.path.basename(final_output_file))
    os.system(f'wget https://uchicago.box.com/shared/static/1s2i05u2um4idfnbkpx3qjbt2f35oky6.gz -O {output_file}')
    _check_md5('ceeb0e72407afaf95409971b4721bf7e', output_file)
    os.system(f'tar -C {conf.OMIM_SILVER_STANDARD_BASE_DIR} -xf {output_file}')


def download_gtex_gwas_pheno_info(**kwargs):
    final_output_file = conf.GTEX_GWAS_PHENO_INFO_FILE
    output_file = os.path.join(conf.TMP_DIR, os.path.basename(final_output_file))
    os.system(f'wget https://uchicago.box.com/shared/static/hvuqanqclnj5wz8xap4xx9jpyrms7bqr.tsv -O {output_file}')
    _check_md5('982434335f07acb1abfb83e57532f2c0', output_file)
    os.system(f'mv {output_file} {final_output_file}')


def download_genes_information(**kwargs):
    final_output_file = conf.BIOMART_GENES_INFO_FILE
    output_file = os.path.join(conf.TMP_DIR, os.path.basename(final_output_file))
    os.system(f'wget https://uchicago.box.com/shared/static/qxgjh6kpa8543s99tlclhil74cd4536k.gz -O {output_file}')
    _check_md5('c4d74e156e968267278587d3ce30e5eb', output_file)
    os.system(f'mv {output_file} {final_output_file}')


def download_gwas2gene_files(**kwargs):
    os.makedirs(conf.GWAS2GENE_DIR, exist_ok=True)

    # annotations_gencode_v26.tsv
    final_output_file = os.path.join(conf.GWAS2GENE_DIR, 'annotations_gencode_v26.tsv')
    output_file = os.path.join(conf.TMP_DIR, os.path.basename(final_output_file))
    os.system(f'wget https://uchicago.box.com/shared/static/d5v1450dzdhk80fxecil1jlio8cbxf16.tsv -O {output_file}')
    _check_md5('74b29e90ff96cccbf9fe1b3308796a84', output_file)
    os.system(f'mv {output_file} {final_output_file}')

    # ld_independent_regions.txt
    final_output_file = os.path.join(conf.GWAS2GENE_DIR, 'ld_independent_regions.txt')
    output_file = os.path.join(conf.TMP_DIR, os.path.basename(final_output_file))
    os.system(f'wget https://uchicago.box.com/shared/static/3qhph7cg9kz5uy20osfy9j05jnvh6jgq.txt -O {output_file}')
    _check_md5('2ec973243aa87bdb8daa36f4d2f54f20', output_file)
    os.system(f'mv {output_file} {final_output_file}')


def download_clinvar_data(**kwargs):
    final_output_file = conf.CLINVAR_DATA_FILE
    output_file = os.path.join(conf.TMP_DIR, os.path.basename(final_output_file))
    os.system(f'wget https://uchicago.box.com/shared/static/g83rtsctb3borlk5p815mcki27jrje0e -O {output_file}')
    _check_md5('ccfd90344cc59c9869bf6e012c0e5c77', output_file)
    os.system(f'mv {output_file} {final_output_file}')


def download_fastenloc_tissues(**kwargs):
    final_output_file = conf.FASTENLOC_GTEX_TISSUES_FILE
    output_file = os.path.join(conf.TMP_DIR, os.path.basename(final_output_file))
    os.system(f'wget https://uchicago.box.com/shared/static/t7866iiivxa2rdg8n8hx6w3p1rc0sq2t.txt -O {output_file}')
    os.system(f'echo "f969ea9a442cd8a347824627a5ac12df {output_file}" | md5sum -c')
    os.system(f'mv {output_file} {final_output_file}')


def download_smultixcan_results(**kwargs):
    download_raw_results(
        conf.SMULTIXCAN_RESULTS_DIR,
        'https://uchicago.box.com/shared/static/v72fmxm521dvtx238nsoghwadp89fmoa.xlsx',
    )


def download_spredixcan_results(extract=False, extract_and_delete=False, **kwargs):
    download_raw_results(
        conf.SPREDIXCAN_RESULTS_DIR,
        'https://uchicago.box.com/shared/static/b7i2ovtqern07joh7b4481tl10x558i6.xlsx',
        extract=extract, extract_and_delete=extract_and_delete
    )


def download_fastenloc_results(extract=False, extract_and_delete=False, **kwargs):
    download_raw_results(
        conf.FASTENLOC_RESULTS_DIR,
        'https://uchicago.box.com/shared/static/enwnyinsgcgs48y70qggo8iyuo0gfhct.xlsx',
        extract=extract, extract_and_delete=extract_and_delete
    )


def download_torus_results(extract=False, extract_and_delete=False, **kwargs):
    download_raw_results(
        conf.TORUS_RESULTS_DIR,
        'https://uchicago.box.com/shared/static/1i0slligiy93rn4ui1c8tfwwpch64w5t.xlsx',
        extract=extract, extract_and_delete=extract_and_delete
    )


def download_enloc_selected_traits(**kwargs):
    final_output_file = os.path.join(conf.MISC_RESULTS_BASE_DIR, 'enloc-selected_traits.tar.gz')
    output_file = os.path.join(conf.TMP_DIR, os.path.basename(final_output_file))
    os.system(f'wget https://uchicago.box.com/shared/static/i9ox9xeb0ajczssy275e311hmeu0xkhg.gz -O {output_file}')
    os.system(f'echo "8909da0618eab99355b203a075c0c952 {output_file}" | md5sum -c')
    os.system(f'mv {output_file} {final_output_file}')
    os.system(f'tar -xf {final_output_file} -C {conf.MISC_RESULTS_BASE_DIR}')



available_actions = {'all': None, }
local_items = list(locals().items())
for key, value in local_items:
    if callable(value) and value.__module__ == __name__ and not key.startswith('_'):
        available_actions[key] = value


parser = argparse.ArgumentParser(description='PhenomeXcan data setup.')
parser.add_argument('actions', choices=available_actions, nargs="+")
parser.add_argument('--extract', action='store_true', help='Whether to extract .tar files or not')
parser.add_argument('--extract-and-delete', action='store_true',
                    help='Whether to delete or not .tar files after correct extraction.')
args = parser.parse_args()

_create_directories()

actions_to_run = args.actions
if 'all' in args.actions:
    actions_to_run = list(available_actions.keys())

global_args = vars(args)

print('Running these actions: ' + f' '.join(actions_to_run))
for k in actions_to_run:
    if k == 'all':
        continue

    print(f'Running {k}')
    available_actions[k](**global_args)
