import os
import re
from glob import glob


class GTEXModel:
    MODEL_FILE_PATTERN = re.compile(r'^mashr_(?P<tissue>.+)\.db$')

    ALL_TISSUES = None

    @classmethod
    def get_tissues(cls, models_dir):
        if cls.ALL_TISSUES is not None:
            return cls.ALL_TISSUES

        model_files = glob(os.path.join(models_dir, '*.db'))

        all_tissues = []
        for f in model_files:
            filename = os.path.basename(f)
            m = re.search(cls.MODEL_FILE_PATTERN, filename)
            if m is None:
                raise ValueError(f'Model file did not match file pattern: {filename}')

            all_tissues.append(m.group('tissue'))

        cls.ALL_TISSUES = all_tissues

        return cls.ALL_TISSUES
