#!/bin/bash

cd /av

export FLASK_APP=application.py

# Change root password only if ROOT_PASSWORD definde in OS
[ ! -z "$ROOT_PASSWORD" ] && usermod --password $(openssl passwd -1 $ROOT_PASSWORD) root

service ssh start -4 -v
#/etc/init.d/ssh start -4 -v

source venv/bin/activate
#python application.py runserver
#sleep infinity
#flask run

clamd &

echo ""
flask routes

echo ""
gunicorn application:application -b 0.0.0.0:5000
