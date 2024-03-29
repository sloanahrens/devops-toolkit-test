import os
"""
Django settings for stellarbot project.

Generated by 'django-admin startproject' using Django 3.1.7.

For more information on this file, see
https://docs.djangoproject.com/en/3.1/topics/settings/

For the full list of settings and their values, see
https://docs.djangoproject.com/en/3.1/ref/settings/
"""

from pathlib import Path

# Build paths inside the project like this: BASE_DIR / 'subdir'.
BASE_DIR = Path(__file__).resolve().parent.parent


# Quick-start development settings - unsuitable for production
# See https://docs.djangoproject.com/en/3.1/howto/deployment/checklist/

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = '+*ll0!%&$(uco$wl4d@7esvw123k@1cs^psp!@xvlle+88c@fv'

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = True

# SECURITY WARNING: lock this down if possible
ALLOWED_HOSTS = ['*']


# Application definition

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',

    'rest_framework',

    'stellarbot',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'stellarbot.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'stellarbot.wsgi.application'


# Database
# https://docs.djangoproject.com/en/3.1/ref/settings/#databases

# DATABASES = {
#     'default': {
#         'ENGINE': 'django.db.backends.sqlite3',
#         'NAME': BASE_DIR / 'db.sqlite3',
#     }
# }

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': os.getenv('POSTGRES_DB', 'local_db'),
        'USER': os.getenv('POSTGRES_USER', 'local_user'),
        'PASSWORD': os.getenv('POSTGRES_PASSWORD', 'postgres-password'),
        'HOST': os.getenv('POSTGRES_HOST', 'localhost'),
        'PORT': os.getenv('POSTGRES_PORT', 5432),
    }
}


# Password validation
# https://docs.djangoproject.com/en/3.1/ref/settings/#auth-password-validators

AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]


# Internationalization
# https://docs.djangoproject.com/en/3.1/topics/i18n/

LANGUAGE_CODE = 'en-us'

TIME_ZONE = 'America/Chicago'

USE_I18N = True

USE_L10N = True

USE_TZ = True


# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/3.1/howto/static-files/

STATIC_URL = '/static/'

STATICFILES_STORAGE = 'django.contrib.staticfiles.storage.StaticFilesStorage'

STATIC_ROOT = "/src/_static"


APPEND_SLASH=False

REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
    ]
}

from datetime import timedelta

SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(hours=6),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=1),
    'ROTATE_REFRESH_TOKENS': False,
    'BLACKLIST_AFTER_ROTATION': True,
    'UPDATE_LAST_LOGIN': False,

    'ALGORITHM': 'HS256',
    'SIGNING_KEY': SECRET_KEY,
    'VERIFYING_KEY': None,
    'AUDIENCE': None,
    'ISSUER': None,

    'AUTH_HEADER_TYPES': ('Bearer',),
    'AUTH_HEADER_NAME': 'HTTP_AUTHORIZATION',
    'USER_ID_FIELD': 'id',
    'USER_ID_CLAIM': 'user_id',

    'AUTH_TOKEN_CLASSES': ('rest_framework_simplejwt.tokens.AccessToken',),
    'TOKEN_TYPE_CLAIM': 'token_type',

    'JTI_CLAIM': 'jti',

    'SLIDING_TOKEN_REFRESH_EXP_CLAIM': 'refresh_exp',
    'SLIDING_TOKEN_LIFETIME': timedelta(minutes=5),
    'SLIDING_TOKEN_REFRESH_LIFETIME': timedelta(days=1),
}

# # TODO: does this matter?
# CSRF_TRUSTED_ORIGINS = ['https://*.the-evolutionist.com']

#####
# Celery settings

CELERY_BROKER_URL = 'amqp://{rabbitmq_user}:{rabbitmq_password}@{rabbitmq_host}:{rabbitmq_port}/{rabbitmq_namespace}'.format(
    rabbitmq_user=os.getenv('RABBITMQ_DEFAULT_USER', 'local_user'),
    rabbitmq_password=os.getenv('RABBITMQ_DEFAULT_PASS', 'rabbitmq_password'),
    rabbitmq_host=os.getenv('RABBITMQ_HOST', 'localhost'),
    rabbitmq_port=os.getenv('RABBITMQ_PORT', 5672),
    rabbitmq_namespace=os.getenv('RABBITMQ_DEFAULT_VHOST', 'local_vhost')
)

CELERY_RESULT_BACKEND = 'redis://{redis_host}:{redis_port}/{redis_namespace}'.format(
    redis_host=os.getenv('REDIS_HOST', 'localhost'),
    redis_port=os.getenv('REDIS_PORT', 6379),
    redis_namespace=0
)

CELERY_ALWAYS_EAGER = False
CELERYD_PREFETCH_MULTIPLIER = 1
CELERY_ACKS_LATE = True
CELERYD_MAX_TASKS_PER_CHILD = 1

CELERY_TIMEZONE = 'America/Chicago'

from celery.schedules import crontab

CELERY_BEAT_SCHEDULE = {
    # 'clean_database': {
    #     'task': 'stellarbot.tasks.clean_database',
    #     'schedule': 90 # 90 * 60,  # every ninety minutes
    # },
    'chained_asset_api_sync': {
        'task': 'stellarbot.tasks.chained_asset_api_sync',
        'schedule': 6 * 60 * 60,  # every six hours
    },
    'random_asset_tuplet_scan': {
        'task': 'stellarbot.tasks.random_asset_tuplet_scan',
        'schedule': 90,  # every ninety seconds
    }
}


# App settings:
#####

# how many seconds to wait before firing next task in the chain
API_ASSET_TASK_REQUEST_DELAY = 15
API_TUPLE_TASK_REQUEST_DELAY = 20

NUM_ASSETS_IN_TUPLE = 4

# how many hours back to query
AGG_HISTORY_HOURS = 7 * 24

# minimum qualifications to consider an asset (?)
# ASSET_AMOUNT_THRESHOLD = 1e9
# ASSET_NUM_ACCOUNTS_THRESHOLD = 1000

ASSET_AMOUNT_THRESHOLD = 1e8
ASSET_NUM_ACCOUNTS_THRESHOLD = 500

ASSET_VOLUME_THRESHOLD = 1
ASSET_TRADE_THRESHOLD = 1

# start and end trade-cycle with this much XLM
TARGET_TX_AMT_IN_XLM = 100

# transaction fee is currently a max of 100 stroops (0.00001 XLM) 
TX_FEE = 0.00001

# # which positive-cycle pairs to notice
# XLM_VAL_ERROR_THRESHOLD = 1e-5

# how often to update asset pairs
TICK_SECONDS = 150

OBJECTS_RETURN_LIMIT = 50
LOGS_RETURN_LIMIT = 100

TABLE_ROW_LIMIT = 100000
ASSET_TUPLE_KEEP_DAYS=90

VIEWERUSERS = [
    'sloan',
]
