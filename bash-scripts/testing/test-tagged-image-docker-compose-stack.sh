#!/bin/bash

set -e
set -x


# setup
source ${ROOT_PATH}/bash-scripts/devops-functions.sh
source ${ROOT_PATH}/docker/repo.sh
validate_ecr_config


echo "Starting: `date`"

docker-compose -f docker/docker-compose-prod-stack-tagged.yaml down --remove-orphans

# # remove local tagged images so we can test pulling the images from ECR
# docker rmi ${ECR_ID}.dkr.ecr.${ECR_REGION}.amazonaws.com/${PROJECT_NAME}/ui:${IMAGE_TAG}
# docker rmi ${ECR_ID}.dkr.ecr.${ECR_REGION}.amazonaws.com/${PROJECT_NAME}/django:${IMAGE_TAG}
# docker rmi ${ECR_ID}.dkr.ecr.${ECR_REGION}.amazonaws.com/${PROJECT_NAME}/api-gateway:${IMAGE_TAG}

$(aws ecr get-login --no-include-email --region ${ECR_REGION})

echo "Pulling images from ECR..."
docker pull ${ECR_ID}.dkr.ecr.${ECR_REGION}.amazonaws.com/${PROJECT_NAME}/ui:${IMAGE_TAG}
docker pull ${ECR_ID}.dkr.ecr.${ECR_REGION}.amazonaws.com/${PROJECT_NAME}/django:${IMAGE_TAG}
docker pull ${ECR_ID}.dkr.ecr.${ECR_REGION}.amazonaws.com/${PROJECT_NAME}/api-gateway:${IMAGE_TAG}

docker-compose -f docker/docker-compose-prod-stack-tagged.yaml up -d

sleep 30

docker run --rm \
    --name stacktester \
    --network container:tagged_prod_api_gateway \
    -e SERVICE="localhost:9999/api/v0.1" \
    -e TESTERUSER_PASSWORD=entendre-wist-surgeon \
    stacktest ./integration-tests.sh

docker-compose -f docker/docker-compose-prod-stack-tagged.yaml down --remove-orphans

echo "Finished: `date`"