# LD Computation on UK Biobank

This folder contains a set of Jupyter notebooks to compute LD on UK Biobank using Hail 0.2.

You need to copy these notebooks to a bucket in Google Cloud Storage. Then start a Spark cluster with Hail 0.2 using `hailctl`
(or whatever tool is available). Then run the notebook in order:

1. `000_genotype_setup.ipynb`: it will index BGEN files.
1. `005_samples_table.ipynb`: it creates a table in Hail with the samples ID used to compute LD. Currently,
it randomly takes a sample of 50k individuals from those used by the Rapid GWAS project to compute their GWAS.
You'll notice that it points to a file named `samples_neale_eids.csv`, which
can be generated using the script `utils/compute_neale_samples.py` (it reads the file `samples.both_sexes.tsv.bgz` that you
can download from the [Rapid GWAS project](https://docs.google.com/spreadsheets/d/1kvPoupSzsSFBNSztMzl04xMoSC3Kcx3CrjVf4yBmESU/edit?ts=5b5f17db#gid=227859291)).
1. `010_ld_computation.ipynb`: it computes LD among those variants preselected. The notebook points to files named like
`chr1_region0_variants.tsv`. These ones have a special format to make them more easily readable from Hail, and were generated
with the script `utils/create_region_files.py` (the coordinates mapping file, which is one of the arguments of this script,
can be downloaded from [here](https://uchicago.box.com/s/od6cs3ki9c2usikdc721sjese4ktdo8d)). To compute LD, change the
variable `SELECTED_CHR` in the Run section of this notebook.
