import os
import re

import pandas as pd

from utils import simplify_string
from metadata import RAPID_GWAS_PHENO_INFO
import settings as conf


class MXPhenoInfo:
    DEFAULT_FILE_PATTERN = re.compile('smultixcan_(?P<code>[^/]+)_ccn30\.tsv\.gz$')

    def __init__(self, file_path, file_pattern=None):
        if not os.path.isfile(file_path):
            raise ValueError(f'File does not exist: {file_path}')

        self.pheno_path = file_path

        if file_pattern is None:
            file_pattern = MXPhenoInfo.DEFAULT_FILE_PATTERN
        else:
            file_pattern = re.compile(file_pattern)

        tmp = re.search(file_pattern, self.pheno_path)
        if tmp is None:
            raise ValueError(f'Invalid file path: {self.pheno_path}')
        self.pheno_code = tmp.group('code')

        self.pheno_description = None

        if self.pheno_code in RAPID_GWAS_PHENO_INFO.index:
            pheno_info = RAPID_GWAS_PHENO_INFO.loc[self.pheno_code]
            self.pheno_description = pheno_info.description
            self.pheno_type = pheno_info.variable_type
            self.pheno_source = pheno_info.source
            self.n_non_missing = pheno_info.n_non_missing
            self.n_missing = pheno_info.n_missing
            self.notes = pheno_info.notes

            # add number of cases and controls
            if self.pheno_source in ('icd10', 'finngen') or self.pheno_type == 'binary':
                self.n_cases = pheno_info.n_cases
                self.n_controls = pheno_info.n_controls

            # add uk biobank data field code
            if self.pheno_source == 'phesant':
                if '_' in self.pheno_code:
                    pheno_code_split = self.pheno_code.split('_')
                    assert len(pheno_code_split) == 2
                    self.ukb_code = int(pheno_code_split[0])
                    self.pheno_extra_info = pheno_code_split[1]
                else:
                    self.ukb_code = int(self.pheno_code)

    def get_plain_name(self):
        if not pd.isnull(self.pheno_description):
            return f'{self.pheno_code}-{simplify_string(self.pheno_description)}'
        else:
            return self.pheno_code

    def __str__(self):
        if not pd.isnull(self.pheno_description):
            return f'{self.pheno_code} - {self.pheno_description}'
        else:
            return self.pheno_code

    def __repr__(self):
        return self.__str__()


class MXPhenoResults:
    def __init__(self, pheno_info, file_pattern=None):
        if isinstance(pheno_info, MXPhenoInfo):
            self.pheno_info = pheno_info
        else:
            # assumed to be a file path
            self.pheno_info = MXPhenoInfo(pheno_info, file_pattern)

    def get_data(self, cols=['pvalue'], index_col='gene'):
        if not isinstance(cols, (tuple, list)):
            cols = [cols]

        #         tissue_file_path = self.file_by_tissue[tissue]
        squeeze = len(cols) == 1

        df = pd.read_csv(self.pheno_info.pheno_path, sep='\t', usecols=['gene'] + cols)

        if index_col == 'gene_simple':
            df = df.assign(gene_simple=df['gene'].apply(lambda x: x.split('.')[0]))

        df = df.set_index(index_col)
        if squeeze:
            df = df.squeeze()

        if isinstance(df, pd.Series):
            df = df.rename(self.pheno_info.get_plain_name())

        assert df.index.is_unique

        return df

    def __str__(self):
        return 'Results for ' + self.pheno_info.__str__()

    def __repr__(self):
        return self.__str__()
