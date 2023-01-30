#!/bin/bash

set -e

# setup
source ${ROOT_PATH}/bash-scripts/devops-functions.sh
source ${ROOT_PATH}/docker/repo.sh
validate_ecr_config

$(aws ecr get-login --no-include-email --region ${ECR_REGION})

# TODO: fix UI build
# docker tag ui ${ECR_ID}.dkr.ecr.${ECR_REGION}.amazonaws.com/${PROJECT_NAME}/ui:${IMAGE_TAG}
# docker push ${ECR_ID}.dkr.ecr.${ECR_REGION}.amazonaws.com/${PROJECT_NAME}/ui:${IMAGE_TAG}

docker tag django ${ECR_ID}.dkr.ecr.${ECR_REGION}.amazonaws.com/${PROJECT_NAME}/django:${IMAGE_TAG}
docker push ${ECR_ID}.dkr.ecr.${ECR_REGION}.amazonaws.com/${PROJECT_NAME}/django:${IMAGE_TAG}

docker tag api-gateway ${ECR_ID}.dkr.ecr.${ECR_REGION}.amazonaws.com/${PROJECT_NAME}/api-gateway:${IMAGE_TAG}
docker push ${ECR_ID}.dkr.ecr.${ECR_REGION}.amazonaws.com/${PROJECT_NAME}/api-gateway:${IMAGE_TAG}