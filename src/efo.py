import pandas as pd
import numpy as np

from utils import is_number
import settings as conf


class EFO:
    UKB_MAP = pd.read_csv(conf.OMIM_SILVER_STANDARD_UKB_EFO_MAP_FILE, sep='\t')
    
    def __init__(self, efo_file):
        """
        efo_file in CSV format downloaded from: https://bioportal.bioontology.org/ontologies/EFO
        
        Example:
        
        efo_file = '/mnt/data/EFO.csv.gz'
        efo = EFO(efo_file)
        efo.efo_data.head()
        clinvar_with_efo = efo.assign_efo_term(clinvar_data)
        """
        self.efo_data_full = pd.read_csv(efo_file, low_memory=False)[['Class ID', 'database_cross_reference', 'Preferred Label']]
        self.efo_data_full = self.efo_data_full.rename(columns={
            'Class ID': 'class_id',
            'database_cross_reference': 'omim_codes',
            'Preferred Label': 'preferred_label',
        })
        self.efo_data_full = self.efo_data_full.dropna(subset=['class_id', 'preferred_label'])

        self.efo_data_omim = self.efo_data_full.drop_duplicates(subset='omim_codes').dropna()
        self.efo_data_omim = self.efo_data_omim.assign(omim_codes_num=self.efo_data_omim['omim_codes'].apply(self._convert_to_mim_number)).drop(columns='omim_codes')
        self.efo_data_omim = self.efo_data_omim.rename(columns={'omim_codes_num': 'omim_codes'})
        
        # unnest omim_codes column
        newvalues = np.dstack((np.repeat(self.efo_data_omim['preferred_label'].values, list(map(len, self.efo_data_omim['omim_codes'].values))), np.concatenate(self.efo_data_omim['omim_codes'].values)))
        self.efo_data = pd.DataFrame(data=newvalues[0], columns=['preferred_label', 'omim'])
        self.efo_data['omim'] = self.efo_data['omim'].astype(int)
    
    def _convert_to_mim_number(self, x):
        tmp = [i for i in x.split('|') if i.startswith('OMIM:')]
        tmp = [t.split(':')[1] for t in tmp]
        tmp = [int(t) for t in tmp if is_number(t)]
        return tmp
    
    def assign_mim_from_efo(self, df, efo_column='efo_name', copy=True):
        """
        Adds a new column to df with the MIM code for the EFO code.
        mim_column is the name of the column containing the MIMI code.
        """
        if copy:
            df2 = df.copy()
        else:
            df2 = df
        
        efo_to_mim = self.efo_data.set_index('preferred_label')
        
        def _assign_mim_from_efo(efo):
            if not isinstance(efo, list):
                efo = [efo]
            
            mim_terms = []
            
            for x in efo:
                if x not in efo_to_mim.index:
                    continue

                mim_values = efo_to_mim.loc[[x]]['omim'].tolist()
                mim_terms.extend(mim_values)
            
            if len(mim_terms) == 0:
                return None
            
            # in mim mapped to several EFO terms, then take the first one
            mim_term_df = pd.Series(mim_terms).value_counts()
            
            return mim_term_df.index[0]
        
        return df2.assign(mim_code=df2[efo_column].apply(_assign_mim_from_efo))
    
    def assign_efo_from_mim(self, df, mim_column='DiseaseMIM', copy=True):
        """
        Adds a new column to df with the EFO term name for the MIM code.
        mim_column is the name of the column containing the MIMI code.
        """
        if copy:
            df2 = df.copy()
        else:
            df2 = df
        
        mim_to_efo = self.efo_data.set_index('omim')
        
        def _assign_efo_from_mim(mim):
            if not isinstance(mim, list):
                mim = [mim]
            
            efo_terms = []
            
            for x in mim:
                if x not in mim_to_efo.index:
                    continue

                efo_values = mim_to_efo.loc[[x]]['preferred_label'].tolist()
                efo_terms.extend(efo_values)
            
            if len(efo_terms) == 0:
                return None
            
            # in mim mapped to several EFO terms, then take the first one
            efo_term_df = pd.Series(efo_terms).value_counts()
            
            return efo_term_df.index[0]
        
        return df2.assign(efo_name=df2[mim_column].apply(_assign_efo_from_mim))

    def assign_efo_from_ukb(self, df, ukb_code_column='ukb_code', map_types=None, copy=True):
        if copy:
            df2 = df.copy()
        else:
            df2 = df
        
        ukb_to_efo = EFO.UKB_MAP.set_index('ICD10_CODE/SELF_REPORTED_TRAIT_FIELD_CODE')[['MAPPED_TERM_URI', 'MAPPING_TYPE']]
        if map_types is not None:
            ukb_to_efo = ukb_to_efo[ukb_to_efo['MAPPING_TYPE'].isin(map_types)]
        
        efo_to_label = self.efo_data_full[['class_id', 'preferred_label']].dropna(subset=['class_id'])
        efo_to_label['class_id'] = efo_to_label['class_id'].apply(lambda x: x.split('/')[-1])
        efo_to_label = efo_to_label.set_index('class_id')
        
        def _assign_efo_from_ukb(ukb):
            if not isinstance(ukb, list):
                ukb = [ukb]
            
            efo_terms = []
            
            for x in ukb:
                if x not in ukb_to_efo.index:
                    continue

                # FIXME: taking the first row, and the first EFO term
#                 print(ukb_to_efo)
                efo_code = ukb_to_efo.loc[[x]].iloc[0]['MAPPED_TERM_URI'].split(', ')[0]
                if efo_code not in efo_to_label.index:
                    return None
            
                efo_label = efo_to_label.loc[efo_code]['preferred_label']
                
                efo_terms.append(efo_label)
            
            if len(efo_terms) == 0:
                return None
            
            # in mim mapped to several EFO terms, then take the first one
            efo_term_df = pd.Series(efo_terms).value_counts()
                
            return efo_term_df.index[0]
        
        return df2.assign(efo_name=df2[ukb_code_column].apply(_assign_efo_from_ukb))

    def assign_efo_label_from_efo_code(self, df, efo_code_column='efo_code', copy=True):
        if copy:
            df2 = df.copy()
        else:
            df2 = df

        efo_to_label = self.efo_data_full[['class_id', 'preferred_label']].dropna(subset=['class_id'])
        efo_to_label['class_id'] = efo_to_label['class_id'].apply(lambda x: x.split('/')[-1])
        efo_to_label = efo_to_label.set_index('class_id')

        def _assign_efo_from_efo(efo_code):
            if not isinstance(efo_code, list):
                efo_code = [efo_code]

            efo_terms = []

            for x in efo_code:
                if x not in efo_to_label.index:
                    return None

                efo_label = efo_to_label.loc[x]['preferred_label']
                efo_terms.append(efo_label)

            if len(efo_terms) == 0:
                return None

            # if mapped to several EFO terms, then take the first one
            efo_term_df = pd.Series(efo_terms).value_counts()
            return efo_term_df.index[0]

        return df2.assign(efo_name=df2[efo_code_column].apply(_assign_efo_from_efo))
