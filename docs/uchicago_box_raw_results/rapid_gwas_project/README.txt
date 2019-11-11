PhenomeXcan - Rapid GWaS Project
================================

If you use this resource, please cite these two manuscripts:

 - PhenomeXcan: Mapping the genome to the phenome through the transcriptome.
   bioRxiv, doi: https://doi.org/10.1101/833210

 - Widespread dose-dependent effects of RNA expression and splicing on complex
   diseases and traits. bioRxiv, doi: https://doi.org/10.1101/814350


This folder contains the full set of raw results for 4,049 traits from the
Rapid GWAS Project: S-MultiXcan, S-PrediXcan, fastENLOC and TORUS.

For S-PrediXcan, fastENLOC ant TORUS the size is around 200G each; for this
reason the results were splitted in each subfolder (spredixcan, fastenloc and
torus). To obtain any of these results, follow these steps:

 1. Download all files in the subfolder (including the MD5SUM.txt and all
    *_part_* files). If you want to automate download using the command line, you
    can get the download list file (for S-PrediXcan for instance, this is the file
    spredixcan_download_list) and then run this command:

    $ parallel -j2 --colsep ' ' 'wget {1} -O {2}' < spredixcan_download_list

    where -j2 indicates the number of concurrent downloads.

 2. Check the integrity of all parts to make sure they were correctly
    downloaded by running:

    $ md5sum -c MD5SUM.txt

 3. Combine all parts to get the final archive. For instance, for S-PrediXcan:

    $ cat spredixcan_part_* > spredixcan_mashr.tar

    The final archive names for fastENLOC and TORUS are fastenloc.tar and
    torus.tar, respectively.

 4. Check the integrity of the final archive (S-PrediXcan in this example):

    $ cat MD5SUM.txt | grep spredixcan_mashr.tar | md5sum -c

