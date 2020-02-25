# Box upload of raw results

See `main_upload.sh` (at the top of the file, the "Notes" section) on how to run the `upload.py` script to upload every result set (S-PrediXcan, S-MultiXcan, etc) to Box.
The script will create, for each result set, a phenotype info file with the SHA1 hash and the public URL for direct download, along with the
`wget` command to download it. Please, make sure to change the `--target-box-directory` with the right folder ID, otherwise
you could **override previous results by mistake**.

The previous script will call `upload.py`, which will ask you for your Client ID, Client Secret, and then you will need
to open an URL with your browser, grant access, and copy the last part of the redirection URL with the code and provide it
to the script. You can find the Client ID and Client Secret by going to your Dev Console
in Box and click on the application you have created, and then go the Configuration section, OAuth 2.0 Credentials.
See the Box documentation on how to create an application. For PhenomeXcan we have created one with these settings:

 * Name: PhenomeXcan
 * Authentication method: Standard OAuth 2.0 (User Authentication)

After running `main_upload.sh`, you have to run `generate_phenotype_info.py` to create a unified phenotype file
for each result set to upload to Google Drive as a reference for the users.
