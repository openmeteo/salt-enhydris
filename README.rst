Salt-enhydris
=============

This will eventually become a salt formula/module/whatever for
installing and managing Enhydris. However, right now it's half-finished and
probably broken. Initially it will work for Debian Wheezy only.

Among other things, it installs postgresql and creates a spatially
enabled template database and database users, but it does not create
databases for the enhydris instances, and it does not run syncdb,
migrate, and collectstatic. To do these, do this::

    sudo -u postgres \
        createdb --template=template_postgis $INSTANCE --owner=$INSTANCE
    export PYTHONPATH=/etc/enhydris/$INSTANCE:/usr/local/enhydris
    export DJANGO_SETTINGS_MODULE=settings
    cd /usr/local/enhydris
    source /usr/local/enhydris.virtualenv/bin/activate
    ./manage.py syncdb --noinput
    ./manage.py migrate
    sudo ./manage.py collectstatic

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
