CREATE INDEX sp_pvalue_idx ON spredixcan (pvalue ASC);
CREATE INDEX sp_pheno_id_pvalue_idx ON spredixcan (pheno_id, pvalue ASC); -- used
CREATE INDEX sp_pheno_id_tissue_id_gene_num_id_idx ON spredixcan (pheno_id, tissue_id, gene_num_id);
CREATE INDEX sp_tissue_id_gene_num_id_pvalue_idx ON spredixcan (tissue_id, gene_num_id, pvalue ASC); -- used
