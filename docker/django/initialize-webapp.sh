#!/bin/bash
set -e

echo "------------------"

echo "Migrating databases..."
python manage.py migrate

echo "Collecting static files..."
python manage.py collectstatic --noinput

echo "Create admin user..."
python manage.py create_admin_user

echo "Start uWSGI..."
uwsgi --module stellarbot.wsgi:application --http 0.0.0.0:8000 --static-map /static=/src/_static
