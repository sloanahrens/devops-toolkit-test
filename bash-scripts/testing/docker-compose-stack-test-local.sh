#!/bin/bash

set -x

# docker kill stacktester   # if it hangs and you don't want to wait

echo "Starting: `date`"

docker-compose -f devflow/docker-compose-prod-stack.yaml down --remove-orphans
docker-compose -f devflow/docker-compose-prod-stack.yaml up -d

sleep 20

docker run --rm \
    --name stacktester \
    --network container:local_prod_webapp \
    -e SERVICE="localhost:8000" \
    stacktest ./integration-tests.sh
docker-compose -f devflow/docker-compose-prod-stack.yaml down --remove-orphans


# docker-compose -f devflow/docker-compose-local-dev.yaml down --remove-orphans
# docker-compose -f devflow/docker-compose-local-dev.yaml up -d

# sleep 20

# docker run --rm \
#     --name stacktester \
#     --network container:local_dev_webapp \
#     -e SERVICE="localhost:8000" \
#     stacktest ./integration-tests.sh
# docker-compose -f devflow/docker-compose-local-dev.yaml down --remove-orphans

echo "Finished: `date`"