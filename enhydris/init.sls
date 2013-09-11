python:
  pkg:
    - installed

postgresql:
  pkg:
    - installed

postgresql-9.1-postgis:
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
    - source: https://github.com/openmeteo/enhydris/archive/afc5224c91.tar.gz
    - source_hash: md5=0a9fc7d77839c04db18325eea184a1b7

# Unpack enhydris
enhydris:
  cmd.run:
    - cwd: /usr/local
    - name: >
        tar xzf enhydris.tar.gz &&
        ln -s enhydris-afc5224c9188ed3039971acde8391b5c2aaac16b enhydris
    - unless:
        test -e /usr/local/enhydris-afc5224c9188ed3039971acde8391b5c2aaac16b
    - require:
        - file.managed: enhydris.tar.gz

# Virtualenv with requirements for enhydris
/usr/local/enhydris.virtualenv:
  virtualenv.managed:
    - system_site_packages: True
    - requirements: /usr/local/enhydris/requirements.txt
    - require:
        - cmd.run: enhydris
        - pkg: python-pip
        - pkg: python-virtualenv
        - pkg: python-psycopg2
        - pkg: python-imaging
        - cmd.run: dickinson

# PostGIS template database
template_postgis:
  postgres_database.present:
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
        WHERE datname='template_postgis'" template_postgis
    - unless: psql -c "SELECT * FROM spatial_ref_sys LIMIT 1" template_postgis
    - require:
        - postgres_database.present: template_postgis
        - pkg: postgresql-9.1-postgis
