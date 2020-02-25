import os

import pandas as pd

import settings as conf

### load phenotypes info
pheno_info = pd.read_csv(os.path.join(conf.DELIVERABLES_DIR, 'phenotypes_info.tsv.gz'), sep='\t')
assert pheno_info.shape[0] == conf.SMULTIXCAN_EXPECTED_PHENOTYPES['GTEX_GWAS'] + conf.SMULTIXCAN_EXPECTED_PHENOTYPES['RapidGWASProject']

pheno_info = pheno_info.drop(columns=['description'])
pheno_info = pheno_info.rename(columns={'unique_description': 'description'})

pheno_info = pheno_info.assign(main_source=pheno_info['source'].apply(lambda x: 'Rapid GWAS Project' if x == 'UK Biobank' else 'GTEX GWAS'))


def save_info_file(base_dir, n_expected_rows, output_file, gtex_gwas_code_func, rapid_gwas_project_code_func):
    dfs = []

    if gtex_gwas_code_func is not None:
        gtex_gwas = pd.read_csv(os.path.join(base_dir, 'gtex_gwas_file_info.tsv'), sep='\t')
        assert gtex_gwas.shape[0] == n_expected_rows['GTEX_GWAS']
        gtex_gwas = gtex_gwas.assign(
            short_code=gtex_gwas['file_name'].apply(gtex_gwas_code_func)
        )

        dfs.append(gtex_gwas)

    if rapid_gwas_project_code_func is not None:
        rapid_gwas_project = pd.read_csv(os.path.join(base_dir, 'rapid_gwas_project_file_info.tsv'), sep='\t')
        assert rapid_gwas_project.shape[0] == n_expected_rows['RapidGWASProject']
        rapid_gwas_project = rapid_gwas_project.assign(
            short_code=rapid_gwas_project['file_name'].apply(rapid_gwas_project_code_func)
        )

        dfs.append(rapid_gwas_project)

    smultixcan_box_info = pd.concat(dfs, ignore_index=True)
    smultixcan_box_info = smultixcan_box_info.drop(columns=['file_path'])
    smultixcan_box_info = pd.merge(pheno_info, smultixcan_box_info, on='short_code', validate='one_to_one')
    smultixcan_box_info = smultixcan_box_info.set_index('full_code')
    assert smultixcan_box_info.index.is_unique

    smultixcan_box_info = smultixcan_box_info.sort_values('pheno_id')
    smultixcan_box_info = smultixcan_box_info.drop(columns=['pheno_id'])

    print(f'Writing to {output_file}')

    smultixcan_box_info.to_excel(output_file)


OUTPUT_DIR = os.path.join(conf.DELIVERABLES_DIR, 'box_pheno_info')
os.makedirs(OUTPUT_DIR, exist_ok=True)

### S-Multixcan
save_info_file(
    conf.SMULTIXCAN_RESULTS_BASE_DIR,
    conf.SMULTIXCAN_EXPECTED_PHENOTYPES,
    os.path.join(OUTPUT_DIR, 'smultixcan_box_pheno_info.xlsx'),
    lambda x: x.split('_smultixcan_imputed_gwas_')[0],
    lambda x: x.split('_ccn30.tsv.gz')[0].split('smultixcan_')[1],
)

### S-PrediXcan
save_info_file(
    conf.SPREDIXCAN_RESULTS_BASE_DIR,
    conf.SPREDIXCAN_EXPECTED_PHENOTYPES,
    os.path.join(OUTPUT_DIR, 'spredixcan_box_pheno_info.xlsx'),
    lambda x: x.split('.tar.bz2')[0].split('spredixcan-')[1],
    lambda x: x.split('.tar.bz2')[0].split('spredixcan-')[1],
)

### fastENLOC
save_info_file(
    conf.FASTENLOC_RESULTS_BASE_DIR,
    conf.FASTENLOC_EXPECTED_PHENOTYPES,
    os.path.join(OUTPUT_DIR, 'fastenloc_box_pheno_info.xlsx'),
    lambda x: x.split('.tar.gz')[0].split('enloc-')[1],
    lambda x: x.split('.tar.bz2')[0].split('fastenloc-v2-')[1],
)

### TORUS
save_info_file(
    conf.TORUS_RESULTS_BASE_DIR,
    conf.TORUS_EXPECTED_PHENOTYPES,
    os.path.join(OUTPUT_DIR, 'torus_box_pheno_info.xlsx'),
    None,
    lambda x: x.split('.pip.gz')[0].split('torus-')[1],
)
