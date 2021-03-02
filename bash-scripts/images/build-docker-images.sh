#!/bin/bash

set -e
set -x


# build Python base-image:
docker build -t baseimage -f docker/base-python/Dockerfile .
# build django image:
docker build -t django -f docker/django/Dockerfile .

# build vue.js images:
docker build -t ui -f docker/ui/Dockerfile .
docker build -t ui:dev -f docker/ui/Dockerfile.dev .

# api-gateway microservice image
docker build -t api-gateway -f docker/api-gateway/Dockerfile docker/api-gateway

# build stack-tester image
docker build -t stacktest -f docker/stacktest/Dockerfile .

# build ci-executor image
docker build -t ci-exec -f docker/ci-executor/Dockerfile .

# build devops docker image:
docker build -t devops -f docker/devops-env/Dockerfile .
