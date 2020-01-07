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
--\copy smultixcan from /mnt/tmp/output.tsv with delimiter as E'\t' csv header;
