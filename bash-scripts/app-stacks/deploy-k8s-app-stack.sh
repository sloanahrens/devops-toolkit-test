#!/bin/bash

set -e

# default to one replica for each microservice
UI_REPLICAS=${UI_REPLICAS-'1'}
WEBAPP_REPLICAS=${WEBAPP_REPLICAS-'1'}
WEBAPP_REPLICAS=${WORKER_REPLICAS-'1'}
WEBAPP_REPLICAS=${BEAT_REPLICAS-'1'}
API_GATEWAY_REPLICAS=${API_GATEWAY_REPLICAS-'1'}

CONFIG_PATH='/src/kubernetes/stack-config/test'

echo "Deploying k8s stack:"
echo "SOURCE_PATH: ${SOURCE_PATH}"
echo "STACK_NAME: ${STACK_NAME}"
echo "IMAGE_TAG: ${IMAGE_TAG}"
echo "CONFIG_PATH: ${CONFIG_PATH}"

echo "UI_REPLICAS: ${UI_REPLICAS}"
echo "WEBAPP_REPLICAS: ${WEBAPP_REPLICAS}"
echo "API_GATEWAY_REPLICAS: ${API_GATEWAY_REPLICAS}"


# setup
source /src/bash-scripts/devops-functions.sh
validate_source_paths
source_cluster_env
validate_aws_config
pull_kube_config
test_for_kube_config

# validate CONFIG_PATH
if [ ! -d "${CONFIG_PATH}" ]; then
    echo "*** CONFIG_PATH: ${CONFIG_PATH} does not exist! Exiting."
    exit_with_error
fi

SPEC_TEMPLATES_PATH='/src/kubernetes/templates/specs'


# deploy namespace
cat ${SPEC_TEMPLATES_PATH}/namespace.yaml \
  | sed -e  "s@STACK_NAME@${STACK_NAME}@g" \
  | kubectl apply -f -


# deploy database-config
cat ${CONFIG_PATH}/database-config.yaml \
  | sed -e  "s@STACKNAME@${STACK_NAME}@g" \
  | sed -e  "s@IMAGETAG@${IMAGE_TAG}@g" \
  | sed -e  "s@CONFIGPATH@${CONFIG_PATH}@g" \
  | kubectl -n ${STACK_NAME} apply -f -

# deploy ui-config
cat ${CONFIG_PATH}/ui-config.yaml \
  | sed -e  "s@STACKNAME@${STACK_NAME}@g" \
  | sed -e  "s@IMAGETAG@${IMAGE_TAG}@g" \
  | sed -e  "s@CONFIGPATH@${CONFIG_PATH}@g" \
  | kubectl -n ${STACK_NAME} apply -f -

# deploy webapp-config
cat ${CONFIG_PATH}/webapp-config.yaml \
  | sed -e  "s@STACKNAME@${STACK_NAME}@g" \
  | sed -e  "s@IMAGETAG@${IMAGE_TAG}@g" \
  | sed -e  "s@CONFIGPATH@${CONFIG_PATH}@g" \
  | kubectl -n ${STACK_NAME} apply -f -

# deploy api-gateway-config
cat ${CONFIG_PATH}/api-gateway-config.yaml \
  | sed -e  "s@STACKNAME@${STACK_NAME}@g" \
  | sed -e  "s@IMAGETAG@${IMAGE_TAG}@g" \
  | sed -e  "s@CONFIGPATH@${CONFIG_PATH}@g" \
  | kubectl -n ${STACK_NAME} apply -f -


# deploy database
cat ${SPEC_TEMPLATES_PATH}/database.yaml \
  | sed -e  "s@STACK_NAME@${STACK_NAME}@g" \
  | kubectl -n ${STACK_NAME} apply -f -

# deploy ui
cat ${SPEC_TEMPLATES_PATH}/ui.yaml \
  | sed -e  "s@ECR_ID@${ECR_ID}@g" \
  | sed -e  "s@ECR_REGION@${ECR_REGION}@g" \
  | sed -e  "s@STACK_NAME@${STACK_NAME}@g" \
  | sed -e  "s@IMAGE_TAG@${IMAGE_TAG}@g" \
  | sed -e  "s@UI_REPLICAS@${UI_REPLICAS}@g" \
  | kubectl -n ${STACK_NAME} apply -f -

# deploy webapp
cat ${SPEC_TEMPLATES_PATH}/webapp.yaml \
  | sed -e  "s@ECR_ID@${ECR_ID}@g" \
  | sed -e  "s@ECR_REGION@${ECR_REGION}@g" \
  | sed -e  "s@STACK_NAME@${STACK_NAME}@g" \
  | sed -e  "s@IMAGE_TAG@${IMAGE_TAG}@g" \
  | sed -e  "s@WEBAPP_REPLICAS@${WEBAPP_REPLICAS}@g" \
  | kubectl -n ${STACK_NAME} apply -f -

# deploy worker
cat ${SPEC_TEMPLATES_PATH}/worker.yaml \
  | sed -e  "s@ECR_ID@${ECR_ID}@g" \
  | sed -e  "s@ECR_REGION@${ECR_REGION}@g" \
  | sed -e  "s@STACK_NAME@${STACK_NAME}@g" \
  | sed -e  "s@IMAGE_TAG@${IMAGE_TAG}@g" \
  | sed -e  "s@WEBAPP_REPLICAS@${WORKER_REPLICAS}@g" \
  | kubectl -n ${STACK_NAME} apply -f -

# deploy beat
cat ${SPEC_TEMPLATES_PATH}/beat.yaml \
  | sed -e  "s@ECR_ID@${ECR_ID}@g" \
  | sed -e  "s@ECR_REGION@${ECR_REGION}@g" \
  | sed -e  "s@STACK_NAME@${STACK_NAME}@g" \
  | sed -e  "s@IMAGE_TAG@${IMAGE_TAG}@g" \
  | sed -e  "s@WEBAPP_REPLICAS@${BEAT_REPLICAS}@g" \
  | kubectl -n ${STACK_NAME} apply -f -

# deploy api-gateway
cat ${SPEC_TEMPLATES_PATH}/api-gateway.yaml \
  | sed -e  "s@ECR_ID@${ECR_ID}@g" \
  | sed -e  "s@ECR_REGION@${ECR_REGION}@g" \
  | sed -e  "s@STACK_NAME@${STACK_NAME}@g" \
  | sed -e  "s@IMAGE_TAG@${IMAGE_TAG}@g" \
  | sed -e  "s@API_GATEWAY_REPLICAS@${API_GATEWAY_REPLICAS}@g" \
  | kubectl -n ${STACK_NAME} apply -f -


echo "Deployed stack \"${STACK_NAME}\"."
