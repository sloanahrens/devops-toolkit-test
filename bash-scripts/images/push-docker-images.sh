#!/bin/bash

set -e

# setup
source ${ROOT_PATH}/bash-scripts/devops-functions.sh
source ${ROOT_PATH}/docker/repo.sh
validate_ecr_config


$(aws ecr get-login --no-include-email --region ${ECR_REGION})

docker tag ui ${ECR_ID}.dkr.ecr.${ECR_REGION}.amazonaws.com/stellarbot/ui:${IMAGE_TAG}
docker tag django ${ECR_ID}.dkr.ecr.${ECR_REGION}.amazonaws.com/stellarbot/django:${IMAGE_TAG}
docker tag api-gateway ${ECR_ID}.dkr.ecr.${ECR_REGION}.amazonaws.com/stellarbot/api-gateway:${IMAGE_TAG}

docker push ${ECR_ID}.dkr.ecr.${ECR_REGION}.amazonaws.com/stellarbot/ui:${IMAGE_TAG}
docker push ${ECR_ID}.dkr.ecr.${ECR_REGION}.amazonaws.com/stellarbot/django:${IMAGE_TAG}
docker push ${ECR_ID}.dkr.ecr.${ECR_REGION}.amazonaws.com/stellarbot/api-gateway:${IMAGE_TAG}