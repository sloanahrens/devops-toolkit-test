FROM alpine

WORKDIR /src

RUN apk add --no-cache \
        bash \
        docker \
        docker-compose \
        python3 \
        py3-pip \
    && pip3 install --upgrade pip \
    && pip3 install \
        awscli \
    && rm -rf /var/cache/apk/*

RUN aws --version

RUN docker --version

RUN docker-compose --version