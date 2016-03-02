from __future__ import print_function

try:
    import httplib2
except ImportError:
    print("run pip3 install httplib2")

import os

try:
    from apiclient import discovery
except ImportError:
    print("run `pip3 install google-api-python-client`\n "
          "or manually on https://developers.google.com/api-client-library/python/start/installation")

import oauth2client
from oauth2client import client
from oauth2client import tools
import translations

try:
    import argparse

    parser = argparse.ArgumentParser(parents=[tools.argparser], description='Create localizable files')
    parser.add_argument('--id', help='provide file id to avoid prompt')
    parser.add_argument('--path', help='Path destination for *.lproj folders', default='./')
    parser.add_argument('--platform', choices=['ios', 'android'], help='Should be either ios or android', default='ios')
    parser.add_argument('--gid', help='Use the Google sheet ID from the end of the url link')
    parser.add_argument('--keep_csv', type=bool, help='Should keep the CSV file on the disk', default=False)
    args = parser.parse_args()
    flags = args
except ImportError:
    flags = None
    print("Cannot parse")

SCOPES = 'https://www.googleapis.com/auth/drive'
CLIENT_SECRET_FILE = 'client_secret.json'
APPLICATION_NAME = 'Drive API Python Quickstart'


def get_credentials():
    """Gets valid user credentials from storage.

    If nothing has been stored, or if the stored credentials are invalid,
    the OAuth2 flow is completed to obtain the new credentials.

    Returns:
        Credentials, the obtained credential.
    """
    home_dir = os.path.expanduser('~')
    credential_dir = os.path.join(home_dir, '.credentials')
    if not os.path.exists(credential_dir):
        os.makedirs(credential_dir)
    credential_path = os.path.join(credential_dir, 'drive-python-quickstart.json')

    store = oauth2client.file.Storage(credential_path)
    credentials = store.get()
    if not credentials or credentials.invalid:
        flow = client.flow_from_clientsecrets(CLIENT_SECRET_FILE, SCOPES)
        flow.user_agent = APPLICATION_NAME
        if flags:
            credentials = tools.run_flow(flow, store, flags)
        else:  # Needed only for compatibility with Python 2.6
            credentials = tools.run(flow, store)
        print('Storing credentials to ' + credential_path)
    return credentials


def getFiles(service):
    results = service.files().list(maxResults=10).execute()
    items = results.get('items', [])
    if not items:
        print('No files found.')
    else:
        return service, items


def main():
    """Shows basic usage of the Google Drive API.

    Creates a Google Drive API service object and outputs the names and IDs
    for up to 10 files.
    """
    credentials = get_credentials()
    http = credentials.authorize(httplib2.Http())
    service = discovery.build('drive', 'v2', http=http)
    service, files = getFiles(service)

    i = 0

    if (args.id):
        for item in files:
            if item['id'] == args.id:
                file = item
    else:
        for item in files:
            print("[" + str(i) + "] " + str(item['title']) + " - " + str(item['id']))
            i += 1
        isDigit = False
        while not isDigit:
            _file = input("Select a file index: \n")
            isDigit = _file.isdigit()
            if int(_file) > len(files) or int(_file) < 0:
                print("Invalid index supplied. Try again")
                isDigit = False
        file = files[int(_file)]
    content = download_file(service, file)
    filename = file['id'] + '.csv'
    csvf = open(filename, 'w')
    csvf.write(content.decode("utf-8"))
    csvf.close()
    if args.platform == 'ios':
        translations.translate(filename, args.path)
    elif args.platform == 'android':
        translations.translate_android(filename, args.path)
    else:
        print("Invalid platform. type --help for help")

    print(repr(args.keep_csv))
    if not args.keep_csv:
        os.remove(filename)


def download_file(service, drive_file):
    download_url = drive_file['exportLinks']['text/csv']
    if args.gid:
        download_url += "&gid=" + args.gid
    if download_url:
        resp, content = service._http.request(download_url)
        if resp.status == 200:
            return content
        else:
            print('An error occurred: %s' % resp)
            return None
    else:
        # The file doesn't have any content stored on Drive.
        return None


if __name__ == '__main__':
    main()
