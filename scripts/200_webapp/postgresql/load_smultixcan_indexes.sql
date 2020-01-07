CREATE INDEX sm_pvalue_idx ON smultixcan (pvalue ASC);
CREATE INDEX sm_rcp_idx ON smultixcan (rcp ASC);
CREATE INDEX sm_pheno_id_pvalue_idx ON smultixcan (pheno_id, pvalue ASC);
CREATE INDEX sm_gene_num_id_pvalue_idx ON smultixcan (gene_num_id, pvalue ASC);
CREATE INDEX sm_gene_num_id_pheno_id_idx ON smultixcan (gene_num_id, pheno_id);
