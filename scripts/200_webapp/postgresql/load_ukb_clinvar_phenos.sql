--
-- UKB phenotypes
--

drop table if exists ukb_clinvar_ukb_pheno_info;

create table ukb_clinvar_ukb_pheno_info (
    pheno_desc varchar(225) not null,
    primary key(pheno_desc)
);

\copy ukb_clinvar_ukb_pheno_info from /mnt/tmp/ukb_clinvar-ukb_traits.tsv with delimiter as E'\t' csv header;

--
-- ClinVar phenotypes
--

drop table if exists ukb_clinvar_clinvar_pheno_info;

create table ukb_clinvar_clinvar_pheno_info (
    pheno_desc varchar(150) not null,
    primary key(pheno_desc)
);

\copy ukb_clinvar_clinvar_pheno_info from /mnt/tmp/ukb_clinvar-clinvar_traits.tsv with delimiter as E'\t' csv header;
