FROM python:3.10-buster

ENV PYTHONUNBUFFERED 1

WORKDIR /src

RUN apt-get update && apt-get install -y postgresql

COPY ./django/requirements.txt /src/requirements.txt

RUN pip install --upgrade pip

RUN pip install -r requirements.txt