drop table if exists spredixcan;

create table spredixcan (
    pheno_id smallint not null REFERENCES phenotypes,
    tissue_id smallint not null REFERENCES tissues,
    gene_num_id smallint not null REFERENCES genes,
    effect_size double precision null,
    pvalue double precision not null,
    zscore double precision not null,
    primary key(pheno_id, tissue_id, gene_num_id)
);

-- the file loaded here is the one generated with the script combine_spredixcan_results.sh
--\copy spredixcan from /mnt/tmp/spredixcan_results/Thyroid.csv with delimiter as E'\t' csv header;

-- TODO: add other tissues

CREATE INDEX sp_pvalue_idx ON spredixcan (pvalue ASC) where pvalue < 0.05;

CREATE INDEX sp_pheno_id_pvalue_idx ON spredixcan (pheno_id, pvalue ASC) where pvalue < 0.05;
CREATE INDEX sp_tissue_id_pvalue_idx ON spredixcan (tissue_id, pvalue ASC) where pvalue < 0.05;
CREATE INDEX sp_gene_num_id_pvalue_idx ON spredixcan (gene_num_id, pvalue ASC) where pvalue < 0.05;

CREATE INDEX sp_pheno_id_tissue_id_gene_num_id_idx ON spredixcan (pheno_id, tissue_id, gene_num_id, pvalue ASC) where pvalue < 0.05;
CREATE INDEX sp_tissue_id_gene_num_id_idx ON spredixcan (tissue_id, gene_num_id, pvalue ASC) where pvalue < 0.05;
