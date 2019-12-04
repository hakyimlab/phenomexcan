# S-MultiXcan scripts for CRI

These scripts are intended to be run on the CRI cluster at the University of
Chicago. They should be adapted if used in another cluster.

# Dependencies

For miniconda installation (required), download this file:
```
https://repo.anaconda.com/miniconda/Miniconda3-4.5.11-Linux-x86_64.sh
```
which is the one that works on CRI.

You also need to use [Badger](https://github.com/hakyimlab/badger) to generate and run
these jobs.

# Execution

Before running these scripts, you need to open `smultixcan.yaml` and configure the
paths to fit your environment.

To generate the job files:

```bash
$ python3 badger/src/badger.py -yaml_configuration_file smultixcan.yaml -parsimony 9
```