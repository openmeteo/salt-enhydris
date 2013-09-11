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

# Download enhydris
enhydris.tar.gz:
  file.managed:
    - name: /usr/local/enhydris.tar.gz
    - source: https://github.com/openmeteo/enhydris/archive/5f742d4175.tar.gz
    - source_hash: md5=b95ce3d143afd3dd328129ed31e1e3d7

# Unpack enhydris
enhydris:
  cmd.run:
    - cwd: /usr/local
    - name: >
        tar xzf enhydris.tar.gz &&
        ln -sf enhydris-5f742d4175e0d561290511bd2b53a0602e071e82 enhydris
    - unless:
        test -e /usr/local/enhydris-5f742d4175e0d561290511bd2b53a0602e071e82
    - require:
        - file.managed: enhydris.tar.gz

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
  file.managed:
    - template: jinja
    - source: salt://enhydris/settings.py
    - context:
        instance: {{ instance }}
{% endfor %}
