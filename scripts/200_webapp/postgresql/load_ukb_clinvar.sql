drop table if exists ukb_clinvar;

create table ukb_clinvar (
    ukb_trait varchar(225) not null,
    clinvar_trait varchar(150) not null,
    sqrt_z2_avg real not null,
    gene_names varchar(450) not null,
    primary key(ukb_trait, clinvar_trait)
);

\copy ukb_clinvar from /mnt/tmp/ukb_clinvar.tsv with delimiter as E'\t' csv header;

CREATE INDEX sqrt_z2_avg_idx ON ukb_clinvar (sqrt_z2_avg);
CREATE INDEX ukb_trait_z2_idx ON ukb_clinvar (ukb_trait, sqrt_z2_avg);
CREATE INDEX clinvar_trait_z2_idx ON ukb_clinvar (clinvar_trait, sqrt_z2_avg);
CREATE INDEX ukb_trait_clinvar_trait_z2_idx ON ukb_clinvar (ukb_trait, clinvar_trait, sqrt_z2_avg);
