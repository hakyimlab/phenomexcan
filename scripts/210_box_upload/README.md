# Box upload of raw results

See `main_upload.sh` on how to run the `upload.py` script to upload every result set (S-PrediXcan, S-MultiXcan, etc) to Box.
The script will create, for each result set, a phenotype info file with the SHA1 hash and the public URL for direct download, along with the
`wget` command to download it.

After running `main_upload.sh`, you have to run `generate_phenotype_info.py` to create a unified phenotype file
for each result set to upload to Google Drive as a reference for the users.
