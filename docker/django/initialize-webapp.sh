#!/bin/bash

set -e
set -x


echo "------------------"

echo "Migrating databases..."
python manage.py migrate

echo "Collecting static files..."
python manage.py collectstatic --noinput

echo "Create admin user..."
python manage.py create_users

echo "Start Chained Asset Sync task..."
python manage.py shell -c "from stellarbot.tasks import chained_asset_api_sync; chained_asset_api_sync.apply_async(countdown=60)"

echo "Start uWSGI..."
uwsgi --module stellarbot.wsgi:application --http 0.0.0.0:8000 --static-map /static=/src/_static
