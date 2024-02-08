import json
import os

from unipath import Path

from .base import *

DEV_SECRETS_PATH = SETTINGS_PATH.child("staging_secrets.json")
with open(os.path.join(DEV_SECRETS_PATH)) as f: secrets = json.loads(f.read())

INSTALLED_APPS = INSTALLED_APPS + ('mod_wsgi.server', )
PROPAGATE_EXCEPTIONS = True
DEBUG=True

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': 'blast_cache_db',
        'USER': get_secret("BC_USER", secrets),
        'PASSWORD': get_secret("BC_PASSWORD", secrets),
        'HOST': '1',
        'PORT': '5432',
    }
}

ALLOWED_HOSTS = [
    'localhost',
    '127.0.0.1',
    '',
    '',
    '',
]

CORS_ORIGIN_WHITELIST = (
        '127.0.0.1:4000',
        '',
        '',
        '',
        '',
    )

STATIC_URL = '/static_dev/'

SECRET_KEY = get_secret("BC_SECRET_KEY", secrets)

# TODO: Change this for staging and production
MEDIA_URL = '/submissions/'
MEDIA_ROOT = os.path.join(BASE_DIR, 'submissions')
#
# EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
# EMAIL_HOST = 'smtp.cs.ucl.ac.uk'
# # EMAIL_HOST_USER = 'psipred@cs.ucl.ac.uk'
# DEFAULT_FROM_EMAIL = 'psipred@cs.ucl.ac.uk'
