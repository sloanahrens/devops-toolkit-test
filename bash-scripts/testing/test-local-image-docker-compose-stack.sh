#!/bin/bash


set -e
set -x


docker-compose -f docker/docker-compose-stack-local.yaml down --remove-orphans
docker-compose -f docker/docker-compose-stack-local.yaml up -d

sleep 30

docker run --rm \
    --name stacktester \
    --network container:api_gateway \
    -e SERVICE="localhost:9999/api/v0.1" \
    -e TESTERUSER_PASSWORD=entendre-wist-surgeon \
    stacktest ./integration-tests.sh

docker-compose -f docker/docker-compose-stack-local.yaml down --remove-orphans

echo "Finished: `date`"