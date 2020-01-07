drop table if exists ukb_clinvar;

create table ukb_clinvar (
    ukb_pheno_id smallint not null REFERENCES phenotypes,
    clinvar_pheno_id smallint not null REFERENCES clinvar_phenotypes,
    sqrt_z2_avg real not null,
    primary key(ukb_pheno_id, clinvar_pheno_id)
);
