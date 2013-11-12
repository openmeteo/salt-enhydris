from enhydris.settings.base import *
DEBUG = False
TEMPLATE_DEBUG = False
ALLOWED_HOSTS = ['{{ instance.site_url }}']
ADMINS = (
{% for admin in admins %}
    ('{{ admin.name }}', '{{ admin.email }}'),
{% endfor %}
)
MANAGERS = ADMINS
DATABASES =  {
    'default': {
        'ENGINE': 'django.contrib.gis.db.backends.postgis',
        'NAME': '{{ db_instance.name }}',
        'USER': '{{ db_instance.name }}',
        'PASSWORD': '{{ db_instance.secret_key }}',
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

SECRET_KEY = '{{ instance.secret_key }}'

# Options for django-registration
ACCOUNT_ACTIVATION_DAYS = {{ instance.account_activation_days }}
REGISTRATION_OPEN = {{ instance.registration_open }}
EMAIL_USE_TLS = {{ instance.email_use_tls }}
EMAIL_PORT = {{ instance.email_port }}
EMAIL_HOST = '{{ instance.email_host }}'
DEFAULT_FROM_EMAIL = '{{ instance.default_from_email }}'
SERVER_EMAIL = DEFAULT_FROM_EMAIL
{% if 'email_host_user' in instance -%}
EMAIL_HOST_USER = '{{ instance.email_host_user }}'
{% endif -%}
{% if 'email_host_user' in instance -%}
EMAIL_HOST_PASSWORD = '{{ instance.email_host_password }}'
{% endif %}

ENHYDRIS_USERS_CAN_ADD_CONTENT = {{ instance.get('enhydris_users_can_add_content', False) }}
ENHYDRIS_TSDATA_AVAILABLE_FOR_ANONYMOUS_USERS = {{ instance.get('enhydris_tsdata_available_for_anonymous_users', False) }}
ENHYDRIS_STORE_TSDATA_LOCALLY = {{ instance.get('enhydris_store_tsdata_locally', True) }}
ENHYDRIS_SITE_CONTENT_IS_FREE = {{ instance.get('enhydris_site_content_is_free', False) }}
ENHYDRIS_WGS84_NAME = "{{ instance.get('enhydris_wgs84_name', 'WGS84') }}"
ENHYDRIS_SITE_STATION_FILTER = {{ instance.get('enhydris_site_station_filter', {}) }}

TEMPLATE_DIRS = ('/etc/enhydris/{{ instance.name }}/templates',) + TEMPLATE_DIRS
