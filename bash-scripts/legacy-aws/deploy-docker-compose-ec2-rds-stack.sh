#!/bin/bash

set -e
set -x

# environment
DEPLOYMENT_TYPE=${DEPLOYMENT_TYPE-legacy-staging}
REGION=${REGION-us-east-1}
AWS_KEY_NAME=${AWS_KEY_NAME-devops-key-${REGION}-${DEPLOYMENT_TYPE}}

if test -z "${AWS_ACCESS_KEY_ID}"; then
      echo "*** AWS_ACCESS_KEY_ID not found! Exiting."
      exit_with_error
fi
if test -z "${AWS_SECRET_ACCESS_KEY}"; then
      echo "*** AWS_SECRET_ACCESS_KEY not found! Exiting."
      exit_with_error
fi

echo "-----"
KEY_PATH="/src/kubernetes/keys/${AWS_KEY_NAME}.pem"
if test -f "${KEY_PATH}"; then
    echo "Key file ${KEY_PATH} found."
else
    echo "*** Key file ${KEY_PATH} does not exist! Exiting. ***"
    exit 1
fi

# S3_STATUS_BUCKET=stellarbot-legacy-blue-green-status

SOURCE_PATH=/src/legacy-aws/${REGION}/${DEPLOYMENT_TYPE}
mkdir -p ${SOURCE_PATH}

echo "-----"
echo "REGION: ${REGION}"
echo "DEPLOYMENT_TYPE: ${DEPLOYMENT_TYPE}"
echo "SOURCE_PATH: ${SOURCE_PATH}"
echo "AWS_KEY_NAME: ${AWS_KEY_NAME}"

echo "-----"
echo "Starting Legacy-app AWS deployment..."

# VPC resources
cat /src/legacy-aws/templates/vpc.tf \
  | sed -e "s@REGION@${REGION}@g" \
  | sed -e "s@DEPLOYMENT_TYPE@${DEPLOYMENT_TYPE}@g" \
  > ${SOURCE_PATH}/vpc.tf

# core infrastructure 
cat /src/legacy-aws/templates/core.tf \
  | sed -e "s@REGION@${REGION}@g" \
  | sed -e "s@DEPLOYMENT_TYPE@${DEPLOYMENT_TYPE}@g" \
  | sed -e "s@AWS_KEY_NAME@${AWS_KEY_NAME}@g" \
  | sed -e "s@R53_ZONE@${R53_ZONE}@g" \
  > ${SOURCE_PATH}/core.tf

# rds resources
cat /src/legacy-aws/templates/rds.tf \
  | sed -e "s@REGION@${REGION}@g" \
  | sed -e "s@DEPLOYMENT_TYPE@${DEPLOYMENT_TYPE}@g" \
  | sed -e "s@AWS_KEY_NAME@${AWS_KEY_NAME}@g" \
  | sed -e "s@R53_ZONE@${R53_ZONE}@g" \
  > ${SOURCE_PATH}/rds.tf


cd ${SOURCE_PATH}

# mkdir -p ${SOURCE_PATH}/remote-state
# cat ${ROOT_PATH}/kubernetes/templates/remote_state_resources.tf \
#   | sed -e "s@REGION@${REGION}@g" \
#   | sed -e "s@CLUSTER_TYPE@${DEPLOYMENT_TYPE}@g" \
#   > ${SOURCE_PATH}/remote-state/remote_state_resources.tf
# cd ${SOURCE_PATH}/remote-state
# terraform init
# terraform plan
# terraform apply --auto-approve

cat ${ROOT_PATH}/kubernetes/templates/remote_state.tf \
  | sed -e "s@REGION@${REGION}@g" \
  | sed -e "s@CLUSTER_TYPE@${DEPLOYMENT_TYPE}@g" \
  > ${SOURCE_PATH}/remote_state.tf

#####
cd ${SOURCE_PATH}
terraform init
terraform plan
terraform apply --auto-approve


# extract information from terraform
DEPLOYMENT_INFO=$(terraform output -json)
echo "${DEPLOYMENT_INFO}"

VPC_ID=$(echo ${DEPLOYMENT_INFO} | jq -r ".vpc_id.value")

LEGACY_WEB_PUBLIC_DNS=$(echo ${DEPLOYMENT_INFO} | jq -r ".legacy_web_server_public_dns.value")

LEGACY_WEB_PUBLIC_IP=$(echo ${DEPLOYMENT_INFO} | jq -r ".legacy_web_server_public_ip.value")

echo "VPC_ID: ${VPC_ID}"
echo "-----"
echo "LEGACY_WEB_PUBLIC_DNS: ${LEGACY_WEB_PUBLIC_DNS}"
echo "LEGACY_WEB_PUBLIC_IP: ${LEGACY_WEB_PUBLIC_IP}"
echo "-----"
echo "Deployment finished."
echo "-----"
echo ""

