#!/bin/bash

set -e
set -x

# docker kill stacktester   # if it hangs and you don't want to wait

echo "Starting: `date`"

docker-compose -f docker/docker-compose-prod-stack-local.yaml down --remove-orphans
docker-compose -f docker/docker-compose-prod-stack-local.yaml up -d

sleep 30

# docker run --rm \
#     --name stacktester \
#     --network container:local_prod_webapp \
#     -e SERVICE="localhost:8000" \
#     -e TESTERUSER_PASSWORD=entendre-wist-surgeon \
#     stacktest ./integration-tests.sh

docker run --rm \
    --name stacktester \
    --network container:local_prod_api_gateway \
    -e SERVICE="localhost:9999/api/v0.1" \
    -e TESTERUSER_PASSWORD=entendre-wist-surgeon \
    stacktest ./integration-tests.sh

## ^^^ kill the tester container if you don't want to wait:
# docker kill stacktester

# leave the stack running for a few minutes for manual testing:
# sleep 300

docker-compose -f docker/docker-compose-prod-stack-local.yaml down --remove-orphans


# #####
# # same tests with development stack:
# docker-compose -f devflow/docker-compose-local-dev.yaml down --remove-orphans
# docker-compose -f devflow/docker-compose-local-dev.yaml up -d
# sleep 20
# docker run --rm \
#     --name stacktester \
#     --network container:local_dev_webapp \
#     -e SERVICE="localhost:8000" \
#     -e TESTERUSER_PASSWORD \
#     stacktest ./integration-tests.sh
# docker-compose -f devflow/docker-compose-local-dev.yaml down --remove-orphans

echo "Finished: `date`"