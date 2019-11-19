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

-- perform an explain analyze before creating indexes

--CREATE INDEX gene_name_idx ON smultixcan (gene_name);
--CREATE INDEX pheno_desc_idx ON smultixcan (pheno_desc);
--CREATE INDEX pvalue_idx ON smultixcan (pvalue);
--CREATE INDEX rcp_idx ON smultixcan (rcp);

--CREATE EXTENSION pg_trgm;
--CREATE INDEX smultixcan_ukb_trait_00 ON smultixcan USING gin (ukb_trait gin_trgm_ops);
--CREATE INDEX smultixcan_ukb_clinvar_00 ON smultixcan USING gin (clinvar_trait gin_trgm_ops);

