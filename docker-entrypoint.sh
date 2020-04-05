#!/bin/sh

# Start Gunicorn processes
echo Starting Gunicorn.

cd appfolder/

# Prepare log files and start outputting logs to stdout
mkdir /usr/src/app/logs
touch /usr/src/app/logs/gunicorn.log
touch /usr/src/app/logs/access.log
tail -n 0 -f /usr/src/app/logs/*.log & exec gunicorn wsgi:application --bind 0.0.0.0:8000 --workers 3 --timeout 120 \
    --log-level=DEBUG \
    --log-file=/usr/src/app/logs/gunicorn.log \
    --access-logfile=/usr/src/app/logs/access.log \
    "$@"