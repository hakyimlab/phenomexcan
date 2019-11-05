import os
import time

import settings as conf


os.makedirs(conf.BASE_DIR, exist_ok=True)
os.makedirs(conf.DATA_DIR, exist_ok=True)
os.makedirs(conf.TMP_DIR, exist_ok=True)

# Download mashr models
print(f'Downloading mashr models')
models_file = os.path.join(conf.TMP_DIR, mashr_eqtl.tar)
os.system(f'wget https://zenodo.org/record/3518299/files/mashr_eqtl.tar?download=1 -O {models_file}')
os.system(f'echo "87f3470bf2676043c748b684fb35fa7d {models_file}" | md5sum -c')
os.system(f'tar -xf {models_file} -C {conf.TMP_DIR}')
os.system(f'mv {conf.TMP_DIR}/eqtl/mashr/ {conf.GTEX_MODELS_DIR}')

