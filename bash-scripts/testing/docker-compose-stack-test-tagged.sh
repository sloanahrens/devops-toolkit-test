#!/bin/bash

set -x

# docker kill stacktester   # if it hangs and you don't want to wait

echo "Starting: `date`"

docker-compose -f docker/docker-compose-prod-stack-tagged.yaml down --remove-orphans

docker rmi ${ECR_ID}.dkr.ecr.${ECR_REGION}.amazonaws.com/stellarbot/ui:${IMAGE_TAG}

$(aws ecr get-login --no-include-email --region ${ECR_REGION})

docker-compose -f docker/docker-compose-prod-stack-tagged.yaml up -d

sleep 20
 
docker run --rm \
    --name stacktester \
    --network container:local_prod_webapp \
    -e SERVICE="localhost:8000" \
    stacktest ./integration-tests.sh
docker-compose -f docker/docker-compose-prod-stack-tagged.yaml down --remove-orphans

echo "Finished: `date`"