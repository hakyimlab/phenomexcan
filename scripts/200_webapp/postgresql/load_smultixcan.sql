drop table if exists smultixcan;

create table smultixcan (
    pheno_id smallint not null REFERENCES phenotypes,
    gene_num_id smallint not null REFERENCES genes,
    pvalue double precision not null,
    dir_effect_most_signif smallint not null,
    dir_effect_consensus smallint null,
    n smallint not null,
    n_indep smallint not null,
    rcp double precision null,
    primary key(pheno_id, gene_num_id)
);

-- the file loaded here is the one generated with the script combine_smultixcan_results.sh
\copy smultixcan from /mnt/tmp/output.tsv with delimiter as E'\t' csv header;

CREATE INDEX sm_pvalue_idx ON smultixcan (pvalue ASC);
CREATE INDEX sm_rcp_idx ON smultixcan (rcp ASC);

CREATE INDEX sm_pheno_id_pvalue_idx ON smultixcan (pheno_id, pvalue ASC);
CREATE INDEX sm_gene_num_id_pvalue_idx ON smultixcan (gene_num_id, pvalue ASC);
CREATE INDEX sm_gene_num_id_pheno_id_idx ON smultixcan (gene_num_id, pheno_id);
