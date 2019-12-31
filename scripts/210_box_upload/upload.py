import os
import argparse
from glob import glob
from getpass import getpass

import pandas as pd
from boxsdk import OAuth2, Client

from hashing import get_sha1

parser = argparse.ArgumentParser()
parser.add_argument('--source-directory', required=True, type=str)
parser.add_argument('--target-box-directory', required=True, type=str)
parser.add_argument('--output-file-info', required=True, type=str)
parser.add_argument('--credentials-file', required=False, type=str, help='File where to store credentials')
parser.add_argument('--file-pattern', required=False, type=str, default='*')
parser.add_argument('--redirect-url', required=False, type=str, default='http://localhost:9999')

args = parser.parse_args()

if args.credentials_file is not None and os.path.isfile(args.credentials_file):
    credentials = pd.read_pickle(args.credentials_file)
else:
    # ask for Box credentials
    client_id = getpass('Client ID: ')
    client_secret = getpass('Client secret: ')

    credentials = pd.Series({
        'client_id': client_id,
        'client_secret': client_secret,
    })

    if args.credentials_file is not None:
        credentials.to_pickle(args.credentials_file)

oauth = OAuth2(
    client_id=credentials.loc['client_id'],
    client_secret=credentials.loc['client_secret'],
)

auth_url, csrf_token = oauth.get_authorization_url(args.redirect_url)

print(f'Authorization URL: {auth_url}')

access_code = getpass('Access code (from redirect URL): ')

access_token, refresh_token = oauth.authenticate(access_code)
client = Client(oauth)

folder_files_path = os.path.join(args.source_directory, args.file_pattern)
folder_files = glob(folder_files_path)

file_info_df = pd.DataFrame(columns=['file_path', 'file_name', 'file_sha1', 'box_share_url', 'wget_command'])

# get current files in folder
box_items = list(client.folder(folder_id=args.target_box_directory).get_items())
box_items = {f.name: f for f in box_items}
n_items_in_folder = len(box_items)

for file_idx, file in enumerate(folder_files):
    file_name = os.path.basename(file)
    file_sha1 = get_sha1(file)

    if file_name in box_items:
        uploaded_file_info = box_items[file_name]
        print(f'Already uploaded: {file_name}')
    else:
        print(f'Uploading {file}')
        uploaded_file_info = client.folder(args.target_box_directory).upload(file)

    assert uploaded_file_info.sha1 == file_sha1, f'File uploaded BUT different: {file_name}'

    file_url = uploaded_file_info.get_shared_link_download_url(access='open')

    wget_command = f'wget {file_url} -O {file_name}'

    file_info_df.loc[file_idx] = [file, file_name, file_sha1, file_url, wget_command]
    file_info_df.set_index('file_path').to_csv(args.output_file_info, sep='\t')

# check all files were uploaded
box_items = set(client.folder(folder_id=args.target_box_directory).get_items())
n_items_in_folder = len(box_items)

if n_items_in_folder == len(folder_files):
    print(f'All files uploaded correctly: {len(folder_files)}')
else:
    n_missing = len(folder_files) - n_items_in_folder
    print(f'ERROR: there are {n_missing} files not uploaded:')

    folder_files = set([os.path.basename(f) for f in folder_files])

    missing_items = folder_files.difference(box_items)
    for miss_item in missing_items:
        print(f'  {miss_item}')
