#!/bin/bash


set -e


source ${ROOT_PATH}/bash-scripts/devops-functions.sh
source ${ROOT_PATH}/legacy/legacy_environment.sh

echo "SOURCE_PATH: ${SOURCE_PATH}"

validate_aws_config

mkdir -p ${SOURCE_PATH}/infra

echo "-----"
echo "REGION: ${REGION}"
echo "DEPLOYMENT_TYPE: ${DEPLOYMENT_TYPE}"
echo "SOURCE_PATH: ${SOURCE_PATH}"
echo "AWS_KEY_NAME: ${AWS_KEY_NAME}"

if [ "${DEPLOY_KEY_PAIR}" = "true" ]; then
    deploy_ec2_key_pair
fi

if [ "${DEPLOY_REMOTE_STATE}" = "true" ]; then
    deploy_remote_state_resources
fi

echo "-----"
echo "Starting Legacy-app AWS deployment..."

# # push the two files needed to run the docker images, which are pulled from the ec2-instance via instance user_data script
aws s3 cp ${ROOT_PATH}/docker/docker-compose-stack-master.yaml s3://${TERRAFORM_BUCKET_NAME}/docker-compose.yaml
# aws s3 cp ${ROOT_PATH}/container_environments/prod_stack_vars.env s3://${TERRAFORM_BUCKET_NAME}/stack-config.sh
# sleep 5

apply_legacy_templates

#####
# main infrastructure terraform deployment commands
echo "-----"
echo "Deploying VPC and cloud infrastructure with terraform from ${SOURCE_PATH}..."
cd ${SOURCE_PATH}/infra
terraform init
terraform plan

# echo "EXITING"
# exit 1

sleep_one_minute
time terraform apply --auto-approve
#####

# obfuscate secrets
obfuscate_legacy_templates

#####
# extract information from terraform
cd ${SOURCE_PATH}/infra
DEPLOYMENT_INFO="$(terraform output -json)"

# echo "${DEPLOYMENT_INFO}"

echo "-----"
echo "Stack Endpoint: $(echo "${DEPLOYMENT_INFO}" | jq -r ".stack_endpoint.value")"
echo "-----"
echo "Load Balancer: $(echo "${DEPLOYMENT_INFO}" | jq -r ".elb_dns_name.value")"
echo "-----"
echo "RDS Internal Endpoint: $(echo "${DEPLOYMENT_INFO}" | jq -r ".rds_internal_endpoint.value")"
echo "-----"
# echo "Web server accessible via SSH with (find INSTANCE_IP in the AWS console):"
# echo "ssh -i ${PUBLIC_KEY_PATH} ec2-user@[INSTANCE_IP]"
# echo "-----"
echo "Deployment finished."
echo "-----"
get_resources_from_legacy_deployment
echo "-----"
