#!/bin/bash

set -e
# set -x

ROOT_PATH=${ROOT_PATH-$PWD}

# environment
DEPLOYMENT_TYPE=${DEPLOYMENT_TYPE-staging}
REGION=${REGION-us-east-1}

if test -z "${AWS_ACCESS_KEY_ID}"; then
      echo "*** AWS_ACCESS_KEY_ID not found! Exiting."
      exit_with_error
fi
if test -z "${AWS_SECRET_ACCESS_KEY}"; then
      echo "*** AWS_SECRET_ACCESS_KEY not found! Exiting."
      exit_with_error
fi

SOURCE_PATH=${ROOT_PATH}/legacy-aws/${REGION}/${DEPLOYMENT_TYPE}
mkdir -p ${SOURCE_PATH}

echo "-----"
KEY_PATH="${ROOT_PATH}/legacy-aws/${AWS_KEY_NAME}.pem"
if test -f "${KEY_PATH}"; then
    echo "Key file ${KEY_PATH} found."
else
    echo "*** Key file ${KEY_PATH} does not exist! Not exiting. ***"
    # exit 1
fi

echo "-----"
echo "REGION: ${REGION}"
echo "DEPLOYMENT_TYPE: ${DEPLOYMENT_TYPE}"
echo "SOURCE_PATH: ${SOURCE_PATH}"
echo "AWS_KEY_NAME: ${AWS_KEY_NAME}"

echo "-----"
echo "Starting Legacy-app AWS deployment..."


#####
# comment out for faster deletes/re-builds
echo "-----"
echo "Deploying remote-state resources with terraform..."
mkdir -p ${SOURCE_PATH}/remote-state
cat ${ROOT_PATH}/legacy-aws/templates/remote_state_resources.tf \
  | sed -e "s@REGION@${REGION}@g" \
  | sed -e "s@DEPLOYMENT_TYPE@${DEPLOYMENT_TYPE}@g" \
  > ${SOURCE_PATH}/remote-state/remote_state_resources.tf
cd ${SOURCE_PATH}/remote-state

terraform init
terraform plan
terraform apply --auto-approve
#####

# create resource files from templates using environment variables:

cat ${ROOT_PATH}/legacy-aws/templates/redux.tf \
  | sed -e "s@REGION@${REGION}@g" \
  | sed -e "s@DEPLOYMENT_TYPE@${DEPLOYMENT_TYPE}@g" \
  | sed -e "s@AWS_KEY_NAME@${AWS_KEY_NAME}@g" \
  | sed -e "s@R53_ZONE@${R53_ZONE}@g" \
  | sed -e "s@RANDOMSTR@${RANDOM}@g" \
  > ${SOURCE_PATH}/infrastructure.tf

# rds resources
cat ${ROOT_PATH}/legacy-aws/templates/rds.tf \
  | sed -e "s@REGION@${REGION}@g" \
  | sed -e "s@DEPLOYMENT_TYPE@${DEPLOYMENT_TYPE}@g" \
  | sed -e "s@AWS_KEY_NAME@${AWS_KEY_NAME}@g" \
  | sed -e "s@R53_ZONE@${R53_ZONE}@g" \
  > ${SOURCE_PATH}/rds.tf

# remote-state
cat ${ROOT_PATH}/legacy-aws/templates/remote_state.tf \
  | sed -e "s@REGION@${REGION}@g" \
  | sed -e "s@DEPLOYMENT_TYPE@${DEPLOYMENT_TYPE}@g" \
  > ${SOURCE_PATH}/remote_state.tf

# push the two files needed to run the docker images, which are pulled from the ec2-instance via instance user_data script
aws s3 cp ${ROOT_PATH}/docker/docker-compose-prod-stack-master.yaml s3://${PROJECT_NAME}-legacy-${DEPLOYMENT_TYPE}-terraform-state-storage-${REGION}/docker-compose.yaml
aws s3 cp ${ROOT_PATH}/container_environments/legacy-prod.yaml s3://${PROJECT_NAME}-legacy-${DEPLOYMENT_TYPE}-terraform-state-storage-${REGION}/stack-config.yaml

sleep 10

#####
# main infrastructure terraform deployment commands
echo "-----"
echo "Deploying VPC and cloud infrastructure with terraform..."
cd ${SOURCE_PATH}
terraform init
terraform plan
terraform apply --auto-approve
#####


# extract information from terraform
DEPLOYMENT_INFO=$(terraform output -json)
# echo "${DEPLOYMENT_INFO}"

echo "-----"
echo "VPC_ID: $(echo ${DEPLOYMENT_INFO} | jq -r ".vpc_id.value")"
echo "-----"
echo "elb_dns_name: $(echo ${DEPLOYMENT_INFO} | jq -r ".elb_dns_name.value")"
echo "-----"
echo "stack_endpoint: $(echo ${DEPLOYMENT_INFO} | jq -r ".stack_endpoint.value")"
echo "-----"
echo "rds_internal_endpoint: $(echo ${DEPLOYMENT_INFO} | jq -r ".rds_internal_endpoint.value")"
echo "-----"
echo "Web server accessible via SSH with (find INSTANCE_IP in the AWS console):"
echo "ssh -i legacy-aws/useast1-devopskey.pem ec2-user@[INSTANCE_IP]"
echo "-----"
echo "Deployment finished."
echo "-----"
echo ""


