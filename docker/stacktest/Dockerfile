FROM alpine

WORKDIR /usr/src

RUN apk add --no-cache \
        bash \
        curl \
        jq \
    && rm -rf /var/cache/apk/*

COPY ./docker/stacktest/integration-tests.sh .
RUN chmod 755 /usr/src/integration-tests.sh