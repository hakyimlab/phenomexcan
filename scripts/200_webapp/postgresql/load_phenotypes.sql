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

-- check which indexes are important

--CREATE INDEX short_code_idx ON smultixcan (short_code);
--CREATE INDEX description_idx ON smultixcan (description);
--CREATE INDEX unique_description_idx ON smultixcan (unique_description);

--CREATE EXTENSION pg_trgm;
--CREATE INDEX smultixcan_ukb_trait_00 ON smultixcan USING gin (ukb_trait gin_trgm_ops);
--CREATE INDEX smultixcan_ukb_clinvar_00 ON smultixcan USING gin (clinvar_trait gin_trgm_ops);

