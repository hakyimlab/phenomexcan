# S-PrediXcan scripts for CRI

These scripts are intended to be run on the CRI cluster at the University of
Chicago. They should be adapted if used in another cluster.

All paths should be adjusted in file `jobs/common/vars`

# Dependencies

For miniconda installation (required), download this file:
```
https://repo.anaconda.com/miniconda/Miniconda3-4.5.11-Linux-x86_64.sh
```
which is the one that works on CRI.

# Execution

The script `setup.sh` will run the jobs needed to prepare the environment (you have
to run it only once). After those jobs finish successfully, you can run the `main.sh`
script to generate the jobs for each trait.

To run for a single trait (over all tissues):

```bash
$ bash utils/run.sh _tmp/spredixcan/phesant/1180/ | qsub
```

To run all jobs (all traits and tissues):
```bash
$ parallel -j4 'bash utils/run.sh {} | qsub' ::: _tmp/spredixcan/phesant/*
```
