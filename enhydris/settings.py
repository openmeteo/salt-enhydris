DEBUG = False
TEMPLATE_DEBUG = False
ROOT_URLCONF = 'enhydris.urls'
ALLOWED_HOSTS = ['{{ instance.site_url }}']
ADMINS = (
{% for admin in instance.admins %}
    ('{{ admin.name }}', '{{ admin.email }}'),
{% endfor %}
)
MANAGERS = ADMINS
DATABASES =  {
    'default': {
        'ENGINE': 'django.contrib.gis.db.backends.postgis',
        'NAME': '{{ instance.name }}',
        'USER': '{{ instance.name }}',
        'PASSWORD': '{{ instance.secret_key }}',
        'HOST': 'localhost',
        'PORT': 5432,
    }
}

TIME_ZONE = '{{ instance.time_zone }}'
SITE_ID = {{ instance.site_id }}
SITE_URL = "{{ instance.site_url }}"

MEDIA_ROOT = '/var/local/lib/enhydris/{{ instance.name }}/media/'
MEDIA_URL = '/media/'
STATIC_ROOT = '/var/local/lib/enhydris/static'
STATIC_URL = '/static/'

# Make this unique, and don't share it with anybody.
SECRET_KEY = '{{ instance.secret_key }}'

# Options for django-registration
ACCOUNT_ACTIVATION_DAYS = {{ instance.account_activation_days }}
REGISTRATION_OPEN = {{ instance.registration_open }}
EMAIL_USE_TLS = {{ instance.email_use_tls }}
EMAIL_PORT = {{ instance.email_port }}
EMAIL_HOST = '{{ instance.email_host }}'
DEFAULT_FROM_EMAIL = '{{ instance.default_from_email }}'
SERVER_EMAIL = DEFAULT_FROM_EMAIL
EMAIL_HOST_USER = '{{ instance.email_host_user }}'
EMAIL_HOST_PASSWORD = '{{ instance.email_host_password }}'

INSTALLED_APPS = (
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.staticfiles',
    'django.contrib.markup',
    'django.contrib.admin',
    'django.contrib.sites',
    'django.contrib.humanize',
    'django.contrib.gis',

    'rest_framework',
    'south',
    'pagination',
    'enhydris.sorting',
    'registration',
    'ajax_select',
    'captcha',

    'enhydris.dbsync',
    'enhydris.hcore',
    'enhydris.hprocessor',
    'enhydris.hchartpages',
    'enhydris.api',
    'enhydris.permissions',
)

MIDDLEWARE_CLASSES = (
    'django.middleware.common.CommonMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.locale.LocaleMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.middleware.transaction.TransactionMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.middleware.gzip.GZipMiddleware',
    'django_notify.middleware.NotificationsMiddleware',
    'pagination.middleware.PaginationMiddleware',
    'enhydris.sorting.middleware.SortingMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
)

APPEND_SLASH = True

TEMPLATE_CONTEXT_PROCESSORS = (
    'django.core.context_processors.debug',
    'django.core.context_processors.i18n',
    'django.core.context_processors.media',
    'django.core.context_processors.static',
    'django.core.context_processors.request',
    'django.contrib.auth.context_processors.auth',
    'django.contrib.messages.context_processors.messages',
    'django_notify.context_processors.notifications',
)

TEMPLATE_DIRS = ('/usr/local/enhydris/enhydris/templates',)

AUTH_PROFILE_MODULE = 'hcore.UserProfile'

ENHYDRIS_USERS_CAN_ADD_CONTENT = {{ instance.get('enhydris_users_can_add_content', False }}
ENHYDRIS_TSDATA_AVAILABLE_FOR_ANONYMOUS_USERS = {{ instance.get('enhydris_tsdata_available_for_anonymous_users', False }}
ENHYDRIS_STORE_TSDATA_LOCALLY = {{ instance.get('enhydris_store_tsdata_locally', True) }}
ENHYDRIS_SITE_CONTENT_IS_FREE = {{ instance.get('enhydris_site_content_is_free', False) }}
ENHYDRIS_WGS84_NAME = "{{ instance.get('enhydris_wgs84_name', 'WGS84') }}"
