from __future__ import print_function
import datetime
import json
import os
import hashlib
import getpass
from multiprocessing.dummy import Pool
from synapseutils.monitor import with_progress_bar

import requests
import pandas as pd
from collections import Counter as c

try:
    from urllib.parse import urlparse
    from urllib.parse import urlunparse
    import configparser
except ImportError:
    from urlparse import urlparse
    from urlparse import urlunparse
    import ConfigParser as configparser


BASE_URL='https://webservices.sagebridge.org'
CONFIG_FILE = os.path.join(os.path.expanduser('~'), '.bridgeConfig')


def _is_json(content_type):
    """detect if a content-type is JSON"""
    ## The value of Content-Type defined here:
    ## http://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html#sec3.7
    return content_type.lower().strip().startswith('application/json') if content_type else False


class bridgeConnector:
    def __init__(self, email=None, password=None, study='parkinson', type="researcher", rememberMe=False):
        if email is None:
            config_auth_dict = bridgeConfig()
            config_auth_dict = config_auth_dict.getDict('authentication')
            email = config_auth_dict.get('email', None)
            password = config_auth_dict.get('password', None)
        if email is None:
             email = raw_input('Username:')
             password = getpass.getpass('Password:' )
        print(email, password)
        response = self.restPOST('/v3/auth/signIn', headers={},
                                 json={"study": study, "email": email, "password": password, 'type': type})
        #TODO add caching of username/password
        print('Welcome %s' % response['firstName'])
        self.auth = response


    def getParticipants(self, startDate=None, endDate=None):
        """Given an optional date range of enrollment get all Participants in
        a study that enrolled between dates.

        Return a dataframe with participant information including:
            createdOn, email, firstName, id, lastName, status, studyIdentifier, type
        """
        total=100
        n=0
        params={'startDate':startDate, 'endDate':  endDate, 'offsetBy': 0}
        dfs=[]
        while n<total:
            response = self.restGET('/v3/participants', params=params)
            total = response['total']
            dfs.append(pd.DataFrame(response['items']))
            n += len(dfs[-1])
            params['offsetBy'] +=len(dfs[-1])
            print(n)
        return pd.concat(dfs)


    def getParticipantMetaData(self, userId):
        """Gets consentHistory, healthCode and other metadata for on individual."""
        return self.restGET('/v3/participants/%s' %userId)


    def getParticipantInfo(self, userId):
        """Get information about last requests (uploads and signOn etc for specific users)"""
        return  self.restGET('/v3/participants/%s/requestInfo' %userId)


    def _build_uri_and_headers(self, uri, headers):
        parsedURL = urlparse(uri)
        if parsedURL.netloc == '':
            uri = BASE_URL + uri
        if headers is None:
            headers = {'Bridge-Session':self.auth['sessionToken']}
        return uri, headers


    def restGET(self, uri, headers=None, **kwargs):
        """
        Performs a REST GET operation to the Bridge server.
        :param uri:      URI on which get is performed
        :param headers:  Dictionary of headers to use rather than the API-key-signed default set of headers
        :param kwargs:   Any other arguments taken by a
                       `requests <http://docs.python-requests.org/en/latest/>`_ method
        :returns: JSON encoding of response
        """
        uri, headers = self._build_uri_and_headers(uri, headers)
        response = requests.get(uri, headers=headers, **kwargs)
        response.raise_for_status()
        if _is_json(response.headers.get('content-type', None)):
            return response.json()
        return response.text


    def restPOST(self, uri, json, headers=None, **kwargs):
        """Performs a REST POST operation to the Bridge server.

        :param uri:      URI on which get is performed
        :param json:     The payload to be delivered
        :param headers:  Dictionary of headers to use rather than the API-key-signed default set of headers
        :param kwargs:   Any other arguments taken by a `requests <http://docs.python-requests.org/en/latest/>`_ method

        :returns: JSON encoding of response
        """
        uri, headers = self._build_uri_and_headers(uri, headers)
        response = requests.post(uri, json=json, headers=headers, **kwargs)
        response.raise_for_status()
        if _is_json(response.headers.get('content-type', None)):
            return response.json()
        return response.text


    def restPUT(self, uri, body=None, headers=None, **kwargs):
        """
        Performs a REST PUT operation to the Synapse server.

        :param uri:      URI on which get is performed
        :param body:     The payload to be delivered
        :param headers:  Dictionary of headers to use rather than the API-key-signed default set of headers
        :param kwargs:   Any other arguments taken by a `requests <http://docs.python-requests.org/en/latest/>`_ method

        :returns: JSON encoding of response
        """

        uri, headers = self._build_uri_and_headers(uri, endpoint, headers)
        response = requests.put(uri, data=body, headers=headers, **kwargs)
        response.raise_for_status()
        if _is_json(response.headers.get('content-type', None)):
            return response.json()
        return response.text


    def restDELETE(self, uri, endpoint=None, headers=None, retryPolicy={}, **kwargs):
        """
        Performs a REST DELETE operation to the Synapse server.

        :param uri:      URI of resource to be deleted
        :param endpoint: Server endpoint, defaults to self.repoEndpoint
        :param headers:  Dictionary of headers to use rather than the API-key-signed default set of headers
        :param kwargs:   Any other arguments taken by a `requests <http://docs.python-requests.org/en/latest/>`_ method
        """

        uri, headers = self._build_uri_and_headers(uri, endpoint, headers)
        response = requests.delete(uri, headers=headers, **kwargs)
        response.raise_for_status()



class bridgeConfig():
    #TODO finish this method

    def __init__(self, configPath=CONFIG_FILE):
        self.configPath=configPath


    def getConfigFile(self):
        """Returns a ConfigParser populated with properties from the user's configuration file."""
        try:
            config = configparser.ConfigParser()
            config.read(self.configPath) # Does not fail if the file does not exist
            return config
        except configparser.Error:
            sys.stderr.write('Error parsing Synapse config file: %s' % configPath)
            raise

    def getDict(self,section='authentication'):
        """Returns """
        config = self.getConfigFile()
        try:
            return dict(config.items(section))
        except configparser.NoSectionError:
            return {}
