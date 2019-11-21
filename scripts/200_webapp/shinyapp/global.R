source("helpers.R")

LOG("Initializing server data...")
#options(gargle_oauth_email = TRUE)

#bq_auth(path = "gtex-awg-im-ec004afad146.json")
phenotypes_ <- get_phenotypes()
clinvar_phenotypes_ <- get_clinvar_phenotypes()
ukb_phenotypes_ <- get_ukb_phenotypes()
genes_ <- get_genes()
LOG("Initialized server data.")