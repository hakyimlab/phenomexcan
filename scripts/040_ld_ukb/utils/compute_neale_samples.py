import os
import pandas as pd

samples_neale = pd.read_csv('samples.both_sexes.tsv.bgz', compression='gzip', delim_whitespace=True).drop_duplicates()
samples_qc = pd.read_csv('samplesqc.txt', sep=' ', usecols=['eid', 'Plate.Name', 'Well']).rename(columns={'Plate.Name': 'plate_name', 'Well': 'well'})
samples_merge = pd.merge(samples_neale, samples_qc, on=['plate_name', 'well'])
assert samples_merge['eid'].is_unique

samples_merge['eid'].to_csv('samples_neale_eids.csv', index=False, header=True)

