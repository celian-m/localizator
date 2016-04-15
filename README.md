# localizator
Download and format your Drive sheet to iOS or Android localized file

## Google Drive API KEY
If you don't have already an API key ( and you certainly don't ) visit https://developers.google.com/drive/v3/web/quickstart/python
Follow the Step 1 and 2.
You now have to move the *client_secret.json file into the localizator folder*.


##Dependencies
Python3 is required. If you don't have python3, go on https://www.python.org/downloads/


You may need to install several packages too

```shell
pip3 install httplib2
pip3 install google-api-python-client
```

##Usage
```shell
python3 localizator.py --help
```

##Nice to Have

I recommend you to create a `localizator.sh` file containing your command line

Exemple :
```shell
python3 localizator/localyzator.py --id=MY_SHEET_ID --path=PATH_TO_RESSOURCE
```

Then in your `bash_profile` add the `Localize` alias as following :

```shell
echo "alias Localize='sh localizator.sh'" >> ~/.bash_profile
```

Now, simply run `Localize` from your workspace!
