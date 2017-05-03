from __future__ import print_function

try:
    import httplib2
    from apiclient import errors
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
    """
    Retrieve a list of File resources.
    Args:
    service: Drive API service instance.
    Returns:
    List of File resources.
    """
    result = []
    page_token = None
    while True:
        try:
            param = {}
            if page_token:
                param['pageToken'] = page_token
                param['maxResults'] = '1000'
            files = service.files().list(**param).execute()

            result.extend(files['items'])
            page_token = files.get('nextPageToken')
            if not page_token:
                break
        except errors.HttpError as error:
            print('An error occurred: %s' % error )
            break
    return service, result


def download__file_metadata(service, file_id):
    file_id = file_id
    request = service.files().export_media(fileId=file_id, mimeType='text/csv').execute()
    print(request)
    return request

def main():
    """Shows basic usage of the Google Drive API.

    Creates a Google Drive API service object and outputs the names and IDs
    for up to 10 files.
    """
    credentials = get_credentials()
    http = credentials.authorize(httplib2.Http())
    service = discovery.build('drive', 'v2', http=http)


    i = 0
    if args.id:
        file = download__file_metadata(service, args.id)
    else:
        service, files = getFiles(service)
        for item in files:
            print(str(item['title']) + " - " + str(item['id']))
            i += 1
        exit(1)

    content = file
    filename = "tmp" + '.csv'
    csvf = open(filename, 'w')
    csvf.write(content.decode("utf-8"))
    csvf.close()
    if args.platform == 'ios':
        translations.translate(filename, args.path)
    elif args.platform == 'android':
        translations.translate_android(filename, args.path)
    else:
        print("Invalid platform. type --help for help")
    if not args.keep_csv:
        os.remove(filename)
    print("Your files have been generated under '"+args.path+"'")


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
