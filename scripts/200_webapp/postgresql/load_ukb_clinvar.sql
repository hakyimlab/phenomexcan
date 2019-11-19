drop table if exists ukb_clinvar;

create table ukb_clinvar (
    ukb_trait varchar(225) not null,
    clinvar_trait varchar(150) not null,
    sqrt_z2_avg real not null,
    gene_names varchar(450) not null,
    primary key(ukb_trait, clinvar_trait)
);

\copy ukb_clinvar from /mnt/tmp/ukb_clinvar.tsv with delimiter as E'\t' csv header;

-- check which indexes are worth creating