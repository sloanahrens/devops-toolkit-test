#!/bin/bash

set -e

# default to one replica for each microservice
UI_REPLICAS=${UI_REPLICAS-'1'}
WEBAPP_REPLICAS=${WEBAPP_REPLICAS-'1'}
WORKER_REPLICAS=${WORKER_REPLICAS-'3'}
API_GATEWAY_REPLICAS=${API_GATEWAY_REPLICAS-'1'}

echo "Deploying k8s stack:"
echo "SOURCE_PATH: ${SOURCE_PATH}"
echo "STACK_NAME: ${STACK_NAME}"
echo "IMAGE_TAG: ${IMAGE_TAG}"

echo "UI_REPLICAS: ${UI_REPLICAS}"
echo "WEBAPP_REPLICAS: ${WEBAPP_REPLICAS}"
echo "WORKER_REPLICAS: ${WORKER_REPLICAS}"
echo "API_GATEWAY_REPLICAS: ${API_GATEWAY_REPLICAS}"

# setup
echo "Running a few config tests..."
source "${ROOT_PATH}/bash-scripts/devops-functions.sh"
validate_source_path

source_cluster_env_rds

validate_aws_config
pull_kube_config
test_for_kube_config

source ${ROOT_PATH}/docker/repo.sh
validate_ecr_config

echo "POSTGRES_HOST@${POSTGRES_HOST}"
echo "POSTGRES_PORT@${POSTGRES_PORT}"
echo "POSTGRES_USER@${POSTGRES_USER}"
echo "POSTGRES_PASSWORD@${POSTGRES_PASSWORD}"
echo "POSTGRES_DB@${POSTGRES_DB}"
echo "RABBITMQ_HOST@${RABBITMQ_HOST}"
echo "RABBITMQ_PORT@${RABBITMQ_PORT}"
echo "RABBITMQ_DEFAULT_USER@${RABBITMQ_DEFAULT_USER}"
echo "RABBITMQ_DEFAULT_PASS@${RABBITMQ_DEFAULT_PASS}"
echo "RABBITMQ_DEFAULT_VHOST@${RABBITMQ_DEFAULT_VHOST}"
echo "REDIS_HOST@${REDIS_HOST}"
echo "REDIS_PORT@${REDIS_PORT}"
echo "REDIS_NAMESPACE@${REDIS_NAMESPACE}"
echo "SUPERUSER_EMAIL@${SUPERUSER_EMAIL}"
echo "SUPERUSER_PASSWORD@${SUPERUSER_PASSWORD}"
echo "TESTERUSER_PASSWORD@${TESTERUSER_PASSWORD}"

SPEC_TEMPLATES_PATH=${ROOT_PATH}/kubernetes/templates/specs


# deploy namespace
cat ${SPEC_TEMPLATES_PATH}/namespace.yaml \
  | sed -e  "s@STACK_NAME@${STACK_NAME}@g" \
  | kubectl apply -f -


# deploy stack-config
cat ${SPEC_TEMPLATES_PATH}/app-stack-config.yaml \
  | sed -e  "s@STACKNAME@${STACK_NAME}@g" \
  | sed -e  "s@IMAGETAG@${IMAGE_TAG}@g" \
  | sed -e  "s@POSTGRESHOST@${POSTGRES_HOST}@g" \
  | sed -e  "s@POSTGRESPORT@'${POSTGRES_PORT}'@g" \
  | sed -e  "s@POSTGRESUSER@${POSTGRES_USER}@g" \
  | sed -e  "s@POSTGRESPASSWORD@${POSTGRES_PASSWORD}@g" \
  | sed -e  "s@POSTGRESDB@${POSTGRES_DB}@g" \
  | sed -e  "s@RABBITMQHOST@${RABBITMQ_HOST}@g" \
  | sed -e  "s@RABBITMQPORT@'${RABBITMQ_PORT}'@g" \
  | sed -e  "s@RABBITMQDEFAULTUSER@${RABBITMQ_DEFAULT_USER}@g" \
  | sed -e  "s@RABBITMQDEFAULTPASS@${RABBITMQ_DEFAULT_PASS}@g" \
  | sed -e  "s@RABBITMQDEFAULTVHOST@${RABBITMQ_DEFAULT_VHOST}@g" \
  | sed -e  "s@REDISHOST@${REDIS_HOST}@g" \
  | sed -e  "s@REDISPORT@'${REDIS_PORT}'@g" \
  | sed -e  "s@REDISNAMESPACE@'${REDIS_NAMESPACE}'@g" \
  | sed -e  "s@SUPERUSERPASSWORD@${SUPERUSER_PASSWORD}@g" \
  | sed -e  "s@TESTERUSERPASSWORD@${TESTERUSER_PASSWORD}@g" \
  | kubectl -n ${STACK_NAME} apply -f -


# deploy database
cat ${SPEC_TEMPLATES_PATH}/database.yaml \
  | sed -e  "s@STACK_NAME@${STACK_NAME}@g" \
  | kubectl -n ${STACK_NAME} apply -f -

# deploy queue
cat ${SPEC_TEMPLATES_PATH}/queue.yaml \
  | sed -e  "s@STACK_NAME@${STACK_NAME}@g" \
  | kubectl -n ${STACK_NAME} apply -f -

# deploy redis
cat ${SPEC_TEMPLATES_PATH}/redis.yaml \
  | sed -e  "s@STACK_NAME@${STACK_NAME}@g" \
  | kubectl -n ${STACK_NAME} apply -f -

# # deploy ui
# cat ${SPEC_TEMPLATES_PATH}/ui.yaml \
#   | sed -e  "s@ECR_ID@${ECR_ID}@g" \
#   | sed -e  "s@ECR_REGION@${ECR_REGION}@g" \
#   | sed -e  "s@PROJECT_NAME@${PROJECT_NAME}@g" \
#   | sed -e  "s@STACK_NAME@${STACK_NAME}@g" \
#   | sed -e  "s@IMAGE_TAG@${IMAGE_TAG}@g" \
#   | sed -e  "s@UI_REPLICAS@${UI_REPLICAS}@g" \
#   | kubectl -n ${STACK_NAME} apply -f -

# deploy webapp
cat ${SPEC_TEMPLATES_PATH}/webapp-no-api-gateway.yaml \
  | sed -e  "s@ECR_ID@${ECR_ID}@g" \
  | sed -e  "s@ECR_REGION@${ECR_REGION}@g" \
  | sed -e  "s@PROJECT_NAME@${PROJECT_NAME}@g" \
  | sed -e  "s@STACK_NAME@${STACK_NAME}@g" \
  | sed -e  "s@IMAGE_TAG@${IMAGE_TAG}@g" \
  | sed -e  "s@WEBAPP_REPLICAS@${WEBAPP_REPLICAS}@g" \
  | kubectl -n ${STACK_NAME} apply -f -

# deploy worker
cat ${SPEC_TEMPLATES_PATH}/worker.yaml \
  | sed -e  "s@ECR_ID@${ECR_ID}@g" \
  | sed -e  "s@ECR_REGION@${ECR_REGION}@g" \
  | sed -e  "s@PROJECT_NAME@${PROJECT_NAME}@g" \
  | sed -e  "s@STACK_NAME@${STACK_NAME}@g" \
  | sed -e  "s@IMAGE_TAG@${IMAGE_TAG}@g" \
  | sed -e  "s@WORKER_REPLICAS@${WORKER_REPLICAS}@g" \
  | kubectl -n ${STACK_NAME} apply -f -

# deploy beat
cat ${SPEC_TEMPLATES_PATH}/beat.yaml \
  | sed -e  "s@ECR_ID@${ECR_ID}@g" \
  | sed -e  "s@ECR_REGION@${ECR_REGION}@g" \
  | sed -e  "s@PROJECT_NAME@${PROJECT_NAME}@g" \
  | sed -e  "s@STACK_NAME@${STACK_NAME}@g" \
  | sed -e  "s@IMAGE_TAG@${IMAGE_TAG}@g" \
  | kubectl -n ${STACK_NAME} apply -f -

# # deploy api-gateway
# cat ${SPEC_TEMPLATES_PATH}/api-gateway.yaml \
#   | sed -e  "s@ECR_ID@${ECR_ID}@g" \
#   | sed -e  "s@ECR_REGION@${ECR_REGION}@g" \
#   | sed -e  "s@PROJECT_NAME@${PROJECT_NAME}@g" \
#   | sed -e  "s@DOMAIN_NAME@${DOMAIN_NAME}@g" \
#   | sed -e  "s@STACK_NAME@${STACK_NAME}@g" \
#   | sed -e  "s@IMAGE_TAG@${IMAGE_TAG}@g" \
#   | sed -e  "s@API_GATEWAY_REPLICAS@${API_GATEWAY_REPLICAS}@g" \
#   | kubectl -n ${STACK_NAME} apply -f -


echo "Deployed stack \"${STACK_NAME}\"."