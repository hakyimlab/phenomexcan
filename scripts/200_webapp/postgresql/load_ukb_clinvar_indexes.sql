CREATE INDEX uc_sqrt_z2_avg_idx ON ukb_clinvar (sqrt_z2_avg DESC);
CREATE INDEX uc_clinvar_pheno_id_idx ON ukb_clinvar (clinvar_pheno_id);
CREATE INDEX uc_ukb_pheno_id_clinvar_pheno_id_sqrt_z2_avg_idx ON ukb_clinvar (ukb_pheno_id, clinvar_pheno_id, sqrt_z2_avg DESC);
