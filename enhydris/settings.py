DEBUG = False
TEMPLATE_DEBUG = False
ROOT_URLCONF = 'enhydris.urls'
ADMINS = (
{% for admin in instance.admins %}
    ('{{ admin.email }}', '{{ admin.name }}'),
{% endfor %}
)
MANAGERS = ADMINS
DATABASES =  {
    'default': {
        'ENGINE': 'django.contrib.gis.db.backends.postgis',
        'NAME': '{{ instance.database.name }}',
        'USER': '{{ instance.database.user }}',
        'PASSWORD': '{{ instance.database.password }}',
        'HOST': '{{ instance.database.host }}',
        'PORT': '{{ instance.database.port }}',
    }
}

TIME_ZONE = '{{ instance.time_zone }}'
SITE_ID = {{ instance.site_id }}
SITE_URL = "{{ instance.site_url }}"

MEDIA_ROOT = '/var/local/enhydris/{{ instance.name }}/media'
MEDIA_URL = '/media/'
STATIC_ROOT = '/var/local/enhydris/{{ instance.name }}/static'
STATIC_URL = '/static/'

# Make this unique, and don't share it with anybody.
SECRET_KEY = '{{ instance.secret_key }}'

# Options for django-registration
ACCOUNT_ACTIVATION_DAYS = 7
EMAIL_USE_TLS = True
EMAIL_PORT = 587
EMAIL_HOST = 'smtp.my.domain'
DEFAULT_FROM_EMAIL = 'user@host.domain'
SERVER_EMAIL = DEFAULT_FROM_EMAIL
EMAIL_HOST_USER = 'automaticsender@my.domain'
EMAIL_HOST_PASSWORD = 'mypassword'

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

TEMPLATE_DIRS = ('enhydris/templates',)
