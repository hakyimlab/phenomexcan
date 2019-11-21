# Shinyapp steps

## PostgreSQL data loading
1. Open file `combine_smultixcan_results.sh` and configure the paths where you stored the
S-MultiXcan results for the Rapid GWAS project and the GTEx GWAS traits.

1. Generate a file with all results:
```bash
$ combine_smultixcan_results.sh /mnt/tmp/output_full.tsv 4
Output file: /mnt/tmp/output_full.tsv
Using n jobs: 4
Adding header
Adding data
```
where `/mnt/tmp/output_full.tsv` is the output file and `4` the number of jobs.

1. Make sure the output file was correctly created:
```bash
$ cat /mnt/tmp/output.tsv | awk -F'\t' '{print NF-1}' | sort | uniq -c
91055811 10
```
A correct output must show 10 tabs per line, as shown above.

1. Load the data into a local PostgreSQL database (preferably version 11):
```bash
$ export DBUSER="your_postgresql_user"
$ export DBPORT="5432"
$ psql -h localhost -U $DBUSER -p $DBPORT -d postgres -f postgresql/load_phenomexcan_phenos.sql
DROP TABLE
CREATE TABLE
COPY 4091

$ psql -h localhost -U $DBUSER -p $DBPORT -d postgres -f postgresql/load_genes.sql


$ psql -h localhost -U $DBUSER -p $DBPORT -d postgres -f postgresql/load_smultixcan.sql
DROP TABLE
CREATE TABLE
COPY 91055810

$ psql -h localhost -U $DBUSER -p $DBPORT -d postgres -f postgresql/load_ukb_clinvar_phenos.sql

$ psql -h localhost -U $DBUSER -p $DBPORT -d postgres -f postgresql/load_ukb_clinvar.sql
DROP TABLE
CREATE TABLE
COPY 20888646
```

1. Dump the local PostgreSQL database:
```bash
$ pg_dump -h localhost -U $DBUSER -p $DBPORT -d postgres \
  --format=plain --no-owner --no-acl \
  | sed -E 's/(DROP|CREATE|COMMENT ON) EXTENSION/-- \1 EXTENSION/g' \
  | gzip > phenomexcan_db.sql.gz
```

1. Create a Cloud SQL instance:
```bash
$ export INSTANCE_NAME="phenomexcan-prod-v01"
$ gcloud sql instances create $INSTANCE_NAME \
    --database-version=POSTGRES_11 \
    --tier db-f1-micro \
    --region="us-central1" \
    --storage-auto-increase \
    --availability-type=ZONAL \
    --authorized-networks=[IP_ADDR1],[IP_ADDR2] \
    --storage-size=40
```

Replace `[IP_ADDR1],[IP_ADDR2]` with the public IPs from where you will access
the PostgreSQL database. For instance, Shinyapp, you need to specify (from
[here](https://docs.rstudio.com/shinyapps.io/applications.html#firewalls)):

```
...
--authorized-networks=54.204.34.9,54.204.36.75,54.204.37.78,34.203.76.245,3.217.214.132,34.197.152.155
```

```bash
$ read -s PASSWORD # enter your password here
$ gcloud sql users set-password postgres no-host --instance=$INSTANCE_NAME \
       --password=$PASSWORD
```

```bash
$ gcloud sql instances patch $INSTANCE_NAME --database-flags temp_file_limit=5048576
```

1. Upload the dump file to a Google Cloud bucket (these steps were taken from the
user guide of Cloud SQL):
```bash
# upload file to google cloud
gsutil cp phenomexcan_db.sql.gz gs://phenomexcan/

# get Cloud SQL instance info (serviceAccountEmailAddress)
gcloud sql instances describe $INSTANCE_NAME | grep serviceAccountEmailAddress

# add the service account to the bucket ACL as a writer
gsutil acl ch -u [SERVICE_ACCOUNT_ADDRESS]:W gs://phenomexcan

# add the service account to the import file as a reader
gsutil acl ch -u [SERVICE_ACCOUNT_ADDRESS]:R gs://phenomexcan/phenomexcan_db.sql.gz

# import the data
gcloud sql import sql $INSTANCE_NAME \
    gs://phenomexcan/phenomexcan_db.sql.gz \
    --database=postgres \
    --user=postgres
```

TODO: indexes, vacuum, etc


## Shinyapp deploy
TODO
