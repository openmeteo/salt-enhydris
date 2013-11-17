from django.conf urls import include, patterns

from enhydris.urls import *

{% if instance.get('use_enhydris_stats', False) %}
urlpatterns += patterns(
    '',
    (r'^stats/', include('enhydris_stats.urls')),
)
{% endif %}
