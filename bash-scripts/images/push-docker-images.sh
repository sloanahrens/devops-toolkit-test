#!/bin/bash

set -e

source /src/bash-scripts/devops-functions.sh
validate_aws_config
source_cluster_env

$(aws ecr get-login --no-include-email --region ${ECR_REGION})

docker tag ui ${ECR_ID}.dkr.ecr.${ECR_REGION}.amazonaws.com/stellarbot/ui:${IMAGE_TAG}
docker tag django ${ECR_ID}.dkr.ecr.${ECR_REGION}.amazonaws.com/stellarbot/django:${IMAGE_TAG}
docker tag api-gateway ${ECR_ID}.dkr.ecr.${ECR_REGION}.amazonaws.com/stellarbot/api-gateway:${IMAGE_TAG}

docker push ${ECR_ID}.dkr.ecr.${ECR_REGION}.amazonaws.com/stellarbot/ui:${IMAGE_TAG}
docker push ${ECR_ID}.dkr.ecr.${ECR_REGION}.amazonaws.com/stellarbot/django:${IMAGE_TAG}
docker push ${ECR_ID}.dkr.ecr.${ECR_REGION}.amazonaws.com/stellarbot/api-gateway:${IMAGE_TAG}