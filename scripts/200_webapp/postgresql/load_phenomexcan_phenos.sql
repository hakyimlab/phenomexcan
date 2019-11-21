drop table if exists phenotype_info;

create table phenotype_info (
    full_code varchar(210) not null,
    short_code varchar(55) not null,
    description varchar(210) null,
    unique_description varchar(225) not null,
    type varchar(15) not null,
    n real not null,
    n_cases real null,
    n_controls real null,
    source varchar(20) not null,
    primary key(full_code)
);

\copy phenotype_info from /mnt/tmp/phenotypes_info.tsv with delimiter as E'\t' csv header;
