import sys
from os.path import join
from glob import glob
import argparse

import pandas as pd

import settings as conf

parser = argparse.ArgumentParser()
parser.add_argument('--pheno-info-file', type=str, required=False, default='pheno_info.xlsx')
parser.add_argument('--results-dir', type=str, required=False, default='results/fastenloc')
parser.add_argument('--jobs-dir', type=str, required=False, default='jobs_fastenloc')
parser.add_argument('--job-template', type=str, required=False, default='{pheno_code}_{tissue}_fastenloc.sh')
parser.add_argument('--tissue', type=str, required=True)
args = parser.parse_args()

all_files_path = join(args.results_dir, f'**/fastenloc-*-{args.tissue}.*.out')
all_files = glob(all_files_path)
if len(all_files) == int(3 * 4049):
    sys.exit(0)

all_ukb_phenos = pd.read_excel(args.pheno_info_file)
all_ukb_phenos = all_ukb_phenos[all_ukb_phenos['source'] == 'UK Biobank']
all_ukb_phenos = all_ukb_phenos['short_code'].unique()


#print('Getting all fastENLOC tissues')
#with open(conf.FASTENLOC_GTEX_TISSUES_FILE, 'r') as f:
#    all_fastenloc_tissues = set([x.strip() for x in f.readlines()])

expected_files_dict = {
        join(args.results_dir, f'{pheno_code}/fastenloc-{pheno_code}-{args.tissue}.enloc.{file_type}.out'): pheno_code
    for pheno_code in all_ukb_phenos
    for file_type in ('enrich', 'snp', 'sig')
}
assert len(expected_files_dict.keys()) == int(3 * 4049)

all_files_set = set(all_files)
expected_files_set = set(expected_files_dict.keys())
diffs = expected_files_set.difference(all_files_set)

phenos_pending = set([expected_files_dict[f] for f in diffs])

for f_pheno_code in phenos_pending:
    job_file = join(args.jobs_dir, args.job_template.format(pheno_code=f_pheno_code, tissue=args.tissue))
    print(job_file)

