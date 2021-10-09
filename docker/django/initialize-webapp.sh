#!/bin/bash
set -e

echo "------------------"

echo "Migrating databases..."
python manage.py migrate

echo "Collecting static files..."
python manage.py collectstatic --noinput

echo "Create admin user..."
python manage.py create_admin_user

echo "Queueing data-update celery task"
python manage.py shell -c "from api.tasks import load_data; load_data.apply_async(countdown=60)"

echo "Start uWSGI..."
uwsgi --module stellarbot.wsgi:application --http 0.0.0.0:8000 --static-map /static=/src/_static
