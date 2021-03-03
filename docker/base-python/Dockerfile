FROM python:3.6-buster

ENV PYTHONUNBUFFERED 1

WORKDIR /src

RUN apt-get update && apt-get install -y postgresql

COPY ./django/requirements.txt /src/requirements.txt

RUN pip --no-cache-dir install --progress-bar pretty -r requirements.txt