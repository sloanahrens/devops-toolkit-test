#!/bin/bash

set -e
set -x


# setup
source ${ROOT_PATH}/bash-scripts/devops-functions.sh
source ${ROOT_PATH}/docker/repo.sh
validate_ecr_config

export POSTGRES_HOST=postgres_tagged
export POSTGRES_PORT=5432
export POSTGRES_USER=docker_compose_user
export POSTGRES_DB=docker_compose_db

export RABBITMQ_HOST=rabbitmq_tagged
export RABBITMQ_PORT=5672
export RABBITMQ_DEFAULT_USER=docker_compose_user
export RABBITMQ_DEFAULT_VHOST=docker_compose_host

export REDIS_HOST=redis_tagged
export REDIS_PORT=6379
export REDIS_NAMESPACE=0

export SUPERUSER_PASSWORD=${SUPERUSER_PASSWORD-'veal-paranoid-cognomen'}
export TESTERUSER_PASSWORD=${TESTERUSER_PASSWORD-'edible-sled-synoptic'}
export VIEWERUSER_PASSWORD=${VIEWERUSER_PASSWORD-'avatar-booklist-and'}
export POSTGRES_PASSWORD=${POSTGRES_PASSWORD-'duffel-yearling-palmer'}
export RABBITMQ_DEFAULT_PASS=${RABBITMQ_DEFAULT_PASS-'ewer-whomso-reserved'}


echo "POSTGRES_HOST=${POSTGRES_HOST}" > container_environments/prod_stack_vars.env
echo "POSTGRES_PORT=${POSTGRES_PORT}" >> container_environments/prod_stack_vars.env
echo "POSTGRES_USER=${POSTGRES_USER}" >> container_environments/prod_stack_vars.env
echo "POSTGRES_PASSWORD=${POSTGRES_PASSWORD}" >> container_environments/prod_stack_vars.env
echo "POSTGRES_DB=${POSTGRES_DB}" >> container_environments/prod_stack_vars.env
echo "RABBITMQ_HOST=${RABBITMQ_HOST}" >> container_environments/prod_stack_vars.env
echo "RABBITMQ_PORT=${RABBITMQ_PORT}" >> container_environments/prod_stack_vars.env
echo "RABBITMQ_DEFAULT_USER=${RABBITMQ_DEFAULT_USER}" >> container_environments/prod_stack_vars.env
echo "RABBITMQ_DEFAULT_PASS=${RABBITMQ_DEFAULT_PASS}" >> container_environments/prod_stack_vars.env
echo "RABBITMQ_DEFAULT_VHOST=${POSTGRES_USER}" >> container_environments/prod_stack_vars.env
echo "REDIS_HOST=${REDIS_HOST}" >> container_environments/prod_stack_vars.env
echo "REDIS_PORT=${REDIS_PORT}" >> container_environments/prod_stack_vars.env
echo "REDIS_NAMESPACE=${REDIS_NAMESPACE}" >> container_environments/prod_stack_vars.env
echo "SUPERUSER_PASSWORD=${SUPERUSER_PASSWORD}" >> container_environments/prod_stack_vars.env
echo "TESTERUSER_PASSWORD=${TESTERUSER_PASSWORD}" >> container_environments/prod_stack_vars.env
echo "VIEWERUSER_PASSWORD=${VIEWERUSER_PASSWORD}" >> container_environments/prod_stack_vars.env


docker-compose -f docker/docker-compose-stack-tagged.yaml down --remove-orphans

# # remove local tagged images so we can test pulling the images from ECR
# docker rmi ${ECR_ID}.dkr.ecr.${ECR_REGION}.amazonaws.com/${PROJECT_NAME}/ui:${IMAGE_TAG}
# docker rmi ${ECR_ID}.dkr.ecr.${ECR_REGION}.amazonaws.com/${PROJECT_NAME}/django:${IMAGE_TAG}
# docker rmi ${ECR_ID}.dkr.ecr.${ECR_REGION}.amazonaws.com/${PROJECT_NAME}/api-gateway:${IMAGE_TAG}

$(aws ecr get-login --no-include-email --region ${ECR_REGION})

echo "Pulling images from ECR..."
docker pull ${ECR_ID}.dkr.ecr.${ECR_REGION}.amazonaws.com/${PROJECT_NAME}/ui:${IMAGE_TAG}
docker pull ${ECR_ID}.dkr.ecr.${ECR_REGION}.amazonaws.com/${PROJECT_NAME}/django:${IMAGE_TAG}
docker pull ${ECR_ID}.dkr.ecr.${ECR_REGION}.amazonaws.com/${PROJECT_NAME}/api-gateway:${IMAGE_TAG}

docker-compose -f docker/docker-compose-stack-tagged.yaml up -d

sleep 30

docker run --rm \
    --name stacktester \
    --network container:api_gateway \
    -e SERVICE="localhost:9999/api/v0.1" \
    -e TESTERUSER_PASSWORD \
    stacktest ./integration-tests.sh

docker-compose -f docker/docker-compose-stack-tagged.yaml down --remove-orphans

echo "Finished: `date`"