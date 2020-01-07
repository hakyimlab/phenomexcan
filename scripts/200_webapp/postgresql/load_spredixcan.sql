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
