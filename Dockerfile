# FROM directive instructing base image to build upon
FROM python:3.7.7-alpine3.11

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1


# COPY startup script into known file location in container
COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY . /usr/src/app
WORKDIR /usr/src/app
RUN apk update
RUN apk add --virtual build-deps gcc python-dev build-base postgresql-libs musl-dev postgresql-dev tiff-dev jpeg-dev zlib-dev freetype-dev lcms2-dev libwebp-dev tcl-dev tk-dev python2-tkinter libressl-dev py-gunicorn libffi-dev
RUN apk add --update openssl
RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing gdal-dev
RUN pip install --upgrade pip exit&& pip install --no-cache-dir -r /usr/src/app/requirements.txt
RUN apk add --no-cache --virtual .build-deps-edge --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing --repository http://dl-cdn.alpinelinux.org/alpine/edge/main geos-dev && sed -i.bak s/"ver = geos_version().decode()"/"ver = geos_version().decode().split(' ')[0]"/g /usr/local/lib/python3.7/site-packages/django/contrib/gis/geos/libgeos.py
# I excluded a bunch of libs that I don't want to sync
RUN echo "Collecting static" && python gvx/manage.py collectstatic -i  bootstrap -i  Cesium -i  facebox -i  img -i  jqGrid -i  jquery.validationEngine -i  leaflet -i  melon -i  tiny_mce -i  melon -i admin -i rest_framework --no-input || true

# EXPOSE port 8000 to allow communication to/from server
EXPOSE 8000

RUN chmod +x docker-entrypoint.sh

# CMD specifcies the command to execute to start the server running.
CMD ["sh", "/docker-entrypoint.sh"]
