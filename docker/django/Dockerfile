FROM baseimage

# EXPOSE 8000

WORKDIR /src

COPY ./django/stellarbot /src

COPY ./docker/django/initialize-webapp.sh /src/initialize-webapp.sh
RUN chmod 755 /src/initialize-webapp.sh