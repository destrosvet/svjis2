#!/bin/bash
set -e

cd /app

# Migrate database
python svjis/manage.py migrate --noinput

if [ "${SVJIS_DEV_MODE:-false}" = "true" ]; then
    # Local development convenience only - never enabled in production.
    python svjis/manage.py svjis_setup --password "${SVJIS_ADMIN_PASSWORD:-admin123}" 2>/dev/null || echo "Setup already done, skipping..."

    if [ "${SVJIS_LOAD_DEMO_DATA:-false}" = "true" ]; then
        python svjis/manage.py svjis_demo_data
    fi

    python svjis/manage.py collectstatic --noinput --clear
    cd svjis && exec python manage.py runserver 0.0.0.0:8000
else
    python svjis/manage.py collectstatic --noinput --clear
    cd svjis && exec gunicorn svjis.wsgi:application
fi
