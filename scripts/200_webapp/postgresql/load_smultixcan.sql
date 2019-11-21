drop table if exists smultixcan;

create table smultixcan (
    gene varchar(20) not null,
    gene_name varchar(20) not null,
    band varchar(10) null,
    pheno_desc varchar(225) not null,
    pheno_source varchar(20) not null,
    pvalue double precision not null,
    n smallint not null,
    n_indep smallint not null,
    p_i_best double precision not null,
    t_i_best varchar(40) not null,
    rcp double precision null,
    primary key(pheno_desc, gene)
);

\copy smultixcan from /mnt/tmp/output_full.tsv with delimiter as E'\t' csv header;

CREATE INDEX pvalue_idx ON smultixcan (pvalue);
CREATE INDEX pheno_desc_pvalue_idx ON smultixcan (pheno_desc, pvalue);
CREATE INDEX gene_name_pvalue_idx ON smultixcan (gene_name, pvalue);
CREATE INDEX pheno_desc_gene_name_pvalue_idx ON smultixcan(pheno_desc, gene_name, pvalue);
