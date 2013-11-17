python:
  pkg:
    - installed

python-psycopg2:
  pkg:
    - installed

python-setuptools:
  pkg:
    - installed

python-virtualenv:
  pkg:
    - installed

python-pip:
  pkg:
    - installed

python-imaging:
  pkg:
    - installed

python-gdal:
  pkg:
    - installed

python-docutils:
  pkg:
    - installed

# Git is used to install Enhydris.
git:
  pkg:
    - installed

# Mercurial is needed to install some Enhydris prerequisites from bitbucket.
mercurial:
  pkg:
    - installed

# Dickinson
build-essential:
  pkg:
    - installed
dickinson:
  cmd.run:
    - cwd: /tmp
    - unless: test -e /usr/local/lib/libdickinson.so
    - name: >
        wget https://github.com/openmeteo/dickinson/archive/0.1.0.tar.gz &&
        tar xzf 0.1.0.tar.gz &&
        cd dickinson-0.1.0 &&
        ./configure &&
        make &&
        make install &&
        ldconfig
    - require:
      - pkg: build-essential

# Enhydris
enhydris:
  cmd.run:
    - cwd: /usr/local
    - name: git clone https://github.com/openmeteo/enhydris.git
    - unless: test -e /usr/local/enhydris
    - require:
      - pkg: git

# Enhydris_stats
enhydris_stats:
  cmd.run:
    - cwd: /usr/local
    - name: git clone https://github.com/openmeteo/enhydris_stats.git
    - unless: test -e /usr/local/enhydris_stats
    - require:
      - pkg: git

# Virtualenv with requirements for enhydris
requirements.txt:
  cmd.run:
    - cwd: /usr/local/enhydris
    - name: cp requirements.txt /var/tmp/enhydris.virtualenv.requirements.txt
    - unless: test -e /var/tmp/enhydris.virtualenv.requirements.txt
    - require:
      - cmd.run: enhydris
requirements-gunicorn: # Add gunicorn to the requirements
  file.append:
    - name: /var/tmp/enhydris.virtualenv.requirements.txt
    - text: gunicorn>=18,<19
    - require:
      - cmd.run: requirements.txt
/usr/local/enhydris.virtualenv:
  virtualenv.managed:
    - system_site_packages: True
    - requirements: /var/tmp/enhydris.virtualenv.requirements.txt
    - require:
        - file.append: requirements-gunicorn
        - pkg: python-pip
        - pkg: python-virtualenv
        - pkg: python-psycopg2
        - pkg: python-imaging
        - pkg: mercurial
        - cmd.run: dickinson

supervisor:
  pkg:
    - installed

# System user and group
enhydris-group:
  group.present:
    - name: enhydris
    - system: True
enhydris-user:
  user.present:
    - name: enhydris
    - system: True
    - gid_from_name: enhydris
    - fullname: System user for running Enhydris
    - require:
      - group.present: enhydris-group

/var/log/enhydris:
  file.directory:
    - user: enhydris
    - group: enhydris
    - dir_mode: 755
    - require:
      - user.present: enhydris-user

/var/log/gunicorn:
  file.directory:
    - user: enhydris
    - group: enhydris
    - dir_mode: 755
    - require:
      - user.present: enhydris-user

{% for instance in pillar.get('enhydris_instances', {}) %}
/etc/enhydris/{{ instance.name }}/run-gunicorn:
  file.managed:
    - template: jinja
    - source: salt://enhydris/run-gunicorn
    - makedirs: True
    - mode: 755
    - context:
        instance: {{ instance }}
/etc/supervisor/conf.d/enhydris_{{ instance.name }}.conf:
  file.managed:
    - template: jinja
    - source: salt://enhydris/supervisor.conf
    - context:
        instance: {{ instance }}
/etc/enhydris/{{ instance.name }}/settings.py:
  {% set use_db_of = instance.get('use_db_of', instance.name) %}
  file.managed:
    - template: jinja
    - source: salt://enhydris/settings.py
    - context:
        instance: {{ instance }}
        admins: {{ instance.admins }}  # Workaround salt issue #7846
        db_instance: {% for i in pillar.enhydris_instances -%}
                       {% if i.name == use_db_of %}{{ i }}{% endif -%}
                     {% endfor %}
/etc/enhydris/{{ instance.name }}/urls.py:
  file.managed:
    - template: jinja
    - source: salt://enhydris/urls.py
    - context:
        instance: {{ instance }}
/etc/enhydris/{{ instance.name }}/templates/base.html:
  file.managed:
    - makedirs: True
    - contents: |
        {{ instance.get("base_template", "{% extends 'base-sample.html' %}").replace("\n", "\n        ") }}
enhydris_{{ instance.name }}:
  supervisord:
    - running
    - require:
      - pkg: supervisor
    - watch:
      - file.managed: /etc/supervisor/conf.d/enhydris_{{ instance.name }}.conf
      - file.managed: /etc/enhydris/{{ instance.name }}/run-gunicorn
      - file.managed: /etc/enhydris/{{ instance.name }}/settings.py
{% if instance.dbsync_remote_dbs is defined %}
/etc/cron.daily/enhydris_{{ instance.name }}_dbsync:
  file.managed:
    - template: jinja
    - source: salt://enhydris/dbsync_cron
    - mode: 755
    - context:
        instance: {{ instance }}
{% else %}
/etc/cron.daily/enhydris_{{ instance.name }}_dbsync:
  file.absent
{% endif %}
{% endfor %}


### PostgreSQL ###

postgresql:
  pkg:
    - installed

postgresql-9.1-postgis:
  pkg:
    - installed

# PostGIS template database
template_postgis:
  postgres_database.present:
    - lc_collate: en_US.UTF-8
    - lc_ctype: en_US.UTF-8
    - require:
        - pkg: postgresql

template_postgis1:
  cmd.run:
    - user: postgres
    - name: >
        createlang plpgsql -d template_postgis;
        psql template_postgis -f /usr/share/postgresql/9.1/contrib/postgis-1.5/postgis.sql;
        psql template_postgis -f /usr/share/postgresql/9.1/contrib/postgis-1.5/spatial_ref_sys.sql;
        psql -c
        "UPDATE pg_database SET datistemplate='true'
        WHERE datname='template_postgis'" template_postgis;
        psql -c
        "GRANT SELECT ON spatial_ref_sys TO PUBLIC;" template_postgis;
        psql -c
        "GRANT ALL ON geometry_columns TO PUBLIC;" template_postgis;
    - unless: psql -c "SELECT * FROM spatial_ref_sys LIMIT 1" template_postgis
    - require:
        - postgres_database.present: template_postgis
        - pkg: postgresql-9.1-postgis

# PostgreSQL users
{% for instance in pillar.get('enhydris_instances', {})
   if not instance.get('use_db_of', '') %}
{{ instance.name }}-postgresql-user:
  postgres_user.present:
    - name: {{ instance.name }}
    - password: {{ instance.secret_key }}
    - encrypted: True
    - require:
        - pkg: postgresql
{% endfor %}


### Firewall ###
iptables-persistent:
  pkg:
    - installed
drop_invalid:
  iptables.append:
    - table: filter
    - chain: INPUT
    - match: state
    - connstate: INVALID
    - jump: DROP
    - watch_in:
      - cmd.wait: make-persistent
accept_established:
  iptables.append:
    - table: filter
    - chain: INPUT
    - match: state
    - connstate: ESTABLISHED,RELATED
    - jump: ACCEPT
    - watch_in:
      - cmd.wait: make-persistent
accept_local:
  iptables.append:
    - table: filter
    - chain: INPUT
    - in-interface: lo
    - jump: ACCEPT
    - watch_in:
      - cmd.wait: make-persistent
accept_icmp:
  iptables.append:
    - table: filter
    - chain: INPUT
    - proto: icmp
    - icmp-type: any
    - jump: ACCEPT
    - watch_in:
      - cmd.wait: make-persistent
accept_ssh:
  iptables.append:
    - table: filter
    - chain: INPUT
    - proto: tcp
    - dport: 22
    - jump: ACCEPT
    - watch_in:
      - cmd.wait: make-persistent
policy_deny:
  iptables.set_policy:
    - table: filter
    - chain: INPUT
    - policy: DROP
    - watch_in:
      - cmd.wait: make-persistent
make-persistent:
  # This should be cmd.wait, not cmd.run. However, in the current salt version,
  # all watch_in seem to be ignored. Therefore we settle with always running
  # the thing below.
  cmd.run:
    - name: /etc/init.d/iptables-persistent save


### Nginx ###

nginx:
  pkg:
    - installed
  service:
    - running
    - watch:
        - pkg: nginx

accept_http:
  iptables.append:
    - table: filter
    - chain: INPUT
    - proto: tcp
    - dport: 80
    - jump: ACCEPT
    - watch_in:
      - cmd.wait: make-persistent

{% if 'nginx' in pillar %}
/etc/nginx/enhydris-cert.pem:
  file.managed:
    - contents: |
        {{ pillar.nginx.ssl_certificate.replace("\n", "\n        ") }}
    - require:
        - pkg: nginx
/etc/ssl/private/enhydris.key:
  file.managed:
    - contents: |
        {{ pillar.nginx.ssl_private_key.replace("\n", "\n        ") }}
    - mode: 600
    - require:
        - pkg: nginx
accept_https:
  iptables.append:
    - table: filter
    - chain: INPUT
    - proto: tcp
    - dport: 443
    - jump: ACCEPT
    - watch_in:
      - cmd.wait: make-persistent
{% endif %}

{% for instance in pillar.get('enhydris_instances', {}) %}
/var/local/lib/enhydris/{{ instance.site_url }}/media:
  file.directory:
    - makedirs: True
    - user: enhydris
    - group: enhydris
    - dir_mode: 755
/etc/nginx/sites-available/{{ instance.site_url }}:
  file.managed:
    - template: jinja
    - source: salt://enhydris/nginx-vhost.conf
    - context:
        instance: {{ instance }}
        ssl: {{ 'nginx' in pillar }}
    - require:
        - pkg: nginx
/etc/nginx/sites-enabled/{{ instance.site_url }}:
  file.symlink:
    - target: /etc/nginx/sites-available/{{ instance.site_url }}
    - require:
        - file.managed: /etc/nginx/sites-available/{{ instance.site_url }}
extend:
  nginx:
    service:
      - watch:
          - file.managed: /etc/nginx/sites-enabled/{{ instance.site_url }}
          - file.managed: /etc/nginx/sites-available/{{ instance.site_url }}
{% endfor %}
