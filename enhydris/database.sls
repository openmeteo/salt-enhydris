postgresql:
  pkg:
    - installed

postgresql-9.1-postgis:
  pkg:
    - installed

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
