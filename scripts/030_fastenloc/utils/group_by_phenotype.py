import os
import re
from glob import glob

import pandas as pd

# enloc
#FILE_SUFFIX = '*.enloc.rst'
#FILE_PATTERN = '(?P<pheno>.+)__PM__(?P<tissue>.+)\.enloc\.rst'

# fastenloc
ALL_TISSUES = pd.read_csv('/mnt/phenomexcan/fastenloc/fastenloc_gtex_tissues.txt', header=None, squeeze=True).tolist()
FILE_PREFIX = 'fastenloc-'
FILE_SUFFIX = '*.sig.out'
all_tissues_regex = '|'.join([re.escape(t) for t in ALL_TISSUES])
FILE_PATTERN = f'fastenloc-(?P<pheno>.+)-(?P<tissue>{all_tissues_regex})\.enloc\.sig\.out'

assert len(ALL_TISSUES) == 49

all_files = glob(FILE_SUFFIX)
print(len(all_files))

file_pattern = re.compile(FILE_PATTERN)
all_phenos = [re.search(file_pattern, f).group('pheno') for f in all_files]

assert len(all_files) == len(all_phenos)
assert not any([x is None for x in all_phenos])

all_phenos = list(set(all_phenos))
print(len(all_phenos))

assert len(all_phenos) * len(ALL_TISSUES) == len(all_files)

for pheno in all_phenos:
    os.makedirs(pheno, exist_ok=True)
    s = os.system(f'mv {FILE_PREFIX}{pheno}-* {pheno}/')
    assert s == 0

