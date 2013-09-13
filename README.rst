=============
Salt-enhydris
=============

Overview
========

This is a Salt_ formula for installing and managing an Enhydris_
server on Debian Wheezy.  It is very simple, allowing little
configuration and having much hardwired stuff. Specifically:

* It sets up Enhydris (run with gunicorn and controlled by
  supervisor), PostgreSQL, and nginx, assuming that all these go to
  the same server.
* There can be many Enhydris instances, each one of them running as a
  different nginx virtual host. These instances are installed at the
  root url of each domain.
* The file locations for Enhydris, its static files, its media files,
  and the various system configuration files are hardwired.

See ``pillar.example`` for the full list of configuration options.

.. _salt: http://saltstack.org/
.. _enhydris: http://github.com/openmeteo/enhydris/

Database creation
=================

Although this formula installs PostgreSQL and creates one database
user for each Enhydris instance and a spatially enabled template
database, it does not create databases for the enhydris instances, and
it does not run ``syncdb``, ``migrate``, and ``collectstatic`` (this
is intended; it's a one-time operation, and often we don't want at all
to create, but instead to restore a database).

This is how to create a database and run ``syncdb``, ``migrate``, and
``collectstatic``::

    sudo -u postgres \
        createdb --template=template_postgis $INSTANCE --owner=$INSTANCE
    export PYTHONPATH=/etc/enhydris/$INSTANCE:/usr/local/enhydris
    export DJANGO_SETTINGS_MODULE=settings
    cd /usr/local/enhydris
    source /usr/local/enhydris.virtualenv/bin/activate
    ./manage.py syncdb --noinput
    ./manage.py migrate
    sudo ./manage.py collectstatic

Meta
====

Copyright (C) 2013 Antonis Christofides

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see http://www.gnu.org/licenses/.
