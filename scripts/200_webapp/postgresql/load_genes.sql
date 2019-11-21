drop table if exists genes_info;

create table genes_info (
    gene_id varchar(15) not null,
    gene varchar(18) not null,
    gene_name varchar(20) not null,
    gene_type varchar(15) not null,
    band varchar(10) null,
    primary key(gene_id)
);

\copy genes_info from /mnt/tmp/genes_info.tsv with delimiter as E'\t' csv header;
