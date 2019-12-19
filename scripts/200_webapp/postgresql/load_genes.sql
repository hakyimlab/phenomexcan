drop table if exists genes;

create table genes (
    id smallint not null,
    gene_id varchar(15) not null,
    gene_id_version varchar(20) not null,
    gene_name varchar(20) not null,
    gene_type varchar(15) not null,
    band varchar(10) null,
    primary key(id)
);

-- the file here is the uncompressed version of the file generated by the jupyter
-- notebook 100_postprocessing/20_traits_and_genes_info_files.ipynb
\copy genes from /mnt/phenomexcan_base/deliverables/genes_info.tsv with delimiter as E'\t' csv header;

CREATE INDEX g_gene_name_idx ON genes (gene_name);
