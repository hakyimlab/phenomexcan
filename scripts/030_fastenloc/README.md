# fastENLOC scripts for CRI

These scripts are intended to be run on the CRI cluster at the University of
Chicago. They should be adapted if used in another cluster.

# Compilation of fastENLOC

In CRI, it's necessary to run this command to load some necessary modules for
compilation:

```bash
$ module load gcc/6.2.0 gsl/1.16 boost/1.70.0 zlib/1.2.11 bzip2
```

# Dependencies

For miniconda installation (required), download this file:
```
https://repo.anaconda.com/miniconda/Miniconda3-4.5.11-Linux-x86_64.sh
```
which is the one that works on CRI.

You also need to use [Badger](https://github.com/hakyimlab/badger) to generate and run
these jobs.

For the snp_list argument in the yaml file, use the scripts in
`../010_smultixcan/utils/ukb_gtex_variants_intersection/`

# Execution

Before running these scripts, you need to open `fastenloc.yaml` and configure the
paths to fit your environment.

To generate the job files:

```bash
$ python3 badger/src/badger.py -yaml_configuration_file fastenloc.yaml -parsimony 9
```
