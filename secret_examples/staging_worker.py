import json
import os

from unipath import Path

from .base import *

DEV_SECRETS_PATH = SETTINGS_PATH.child("staging_worker_secrets.json")
with open(os.path.join(DEV_SECRETS_PATH)) as f: secrets = json.loads(f.read())

INSTALLED_APPS = INSTALLED_APPS + ('mod_wsgi.server', )
PROPAGATE_EXCEPTIONS = True
DEBUG=True
# Celery Settings
# BROKER_URL = 'amqp://external_worker:4SJtN3tVqR8p8vm3@128.16.14.77//'
# Uncomment to allow celery tests to run
ADMIN_EMAIL = ""
CELERY_BROKER_URL = ""
# CELERY_RESULT_BACKEND = 'amqp'
# CELERY_TIMEZONE = 'Europe/London'
# CELERY_ACCEPT_CONTENT = ['json']
# CELERY_TASK_SERIALIZER = 'json'
# CELERY_RESULT_SERIALIZER = 'json'
# CELERY_ENABLE_UTC = True
# CELERYD_MAX_TASKS_PER_CHILD = 30
# CELERYD_PREFETCH_MULTIPLIER = 1
CELERY_RESULT_BACKEND = ''
# BACKEND SHOULD BE SENT TO STAGING SETTINGS
timezone = 'Europe/London'
accept_content = ['json']
task_serializer = 'json'
result_serializer = 'json'
enable_utc = True
worker_max_tasks_per_child = 30
worker_prefetch_multiplier = 1

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': 'analytics_automated_db',
        'USER': get_secret("USER", secrets),
        'PASSWORD': get_secret("PASSWORD", secrets),
        'HOST': '',
        'PORT': '',
    }
}

ALLOWED_HOSTS = [
    'localhost',
    '127.0.0.1',
    '',
    '',
]

CORS_ORIGIN_WHITELIST = (
        '127.0.0.1:4000',
        '',
        ',
        '',
    )

STATIC_URL = '/static_dev/'

SECRET_KEY = get_secret("SECRET_KEY", secrets)

# TODO: Change this for staging and production
MEDIA_URL = '/analytics_automated/submissions/'
MEDIA_ROOT = os.path.join(BASE_DIR, 'submissions')

EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
EMAIL_HOST = 'smtp.cs.ucl.ac.uk'
# EMAIL_HOST_USER = 'psipred@cs.ucl.ac.uk'
DEFAULT_FROM_EMAIL = ''
EMAIL_MESSAGE_STRING = 'Your analysis is complete.\nYou can retrieve the ' \
                       'results from http://bioinf.cs.ucl.ac.uk/psipred_beta/&uuid='
