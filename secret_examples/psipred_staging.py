import json
import os

from unipath import Path

from .base import *

DEV_SECRETS_PATH = SETTINGS_PATH.child("psipred_staging_secrets.json")
with open(os.path.join(DEV_SECRETS_PATH)) as f: secrets = json.loads(f.read())

INSTALLED_APPS = INSTALLED_APPS + ('mod_wsgi.server', )
PROPAGATE_EXCEPTIONS = True
DEBUG = True
STAGING = True
# Celery Settings
# amqp://UID:PASSWORD@AMPQ_HOST//'
BROKER_URL = 'COMPLETE_BY_USER'

# Uncomment to allow celery tests to run

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': 'web_db',
        'USER': get_secret("USER", secrets),
        'PASSWORD': get_secret("PASSWORD", secrets),
        'HOST': 'COMPLETE_BY_USER',
        'PORT': '5432',
    }
}

ALLOWED_HOSTS = [
    'localhost',
    '127.0.0.1',
    'COMPLETE_BY_USER',
]

SECRET_KEY = get_secret("SECRET_KEY", secrets)

# TODO: Change this for staging and production
MEDIA_URL = '/submissions/'
MEDIA_ROOT = os.path.join(BASE_DIR, 'submissions')

EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
# example smtp.cs.ucl.ac.uk
EMAIL_HOST = 'COMPLETE_BY_USER'
# EMAIL_HOST_USER = 'psipred@cs.ucl.ac.uk'
DEFAULT_FROM_EMAIL = 'COMPLETE_BY_USER'
