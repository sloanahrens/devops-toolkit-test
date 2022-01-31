#!/bin/bash

# set -x


function exit_with_error {
    echo 'Deployment failed!'
    # remove_cluster_updating_status
    exit 1
}

function sleep_one_minute {
    echo 'Sleeping 60 seconds...'
    sleep 60
}

function show_cluster_env {
    echo "----------"
    echo "R53_HOSTED_ZONE: ${R53_HOSTED_ZONE}"
    echo "REGION: ${REGION}"
    echo "CLUSTER_TYPE: ${CLUSTER_TYPE}"
    echo "CLUSTER_NAME: ${CLUSTER_NAME}"
    echo "KOPS_BUCKET_NAME: ${KOPS_BUCKET_NAME}"
    echo "MASTER_ZONES: ${MASTER_ZONES}"
    echo "NODE_ZONES: ${NODE_ZONES}"
    echo "MASTER_SIZE: ${MASTER_SIZE}"
    echo "NODE_SIZE: ${NODE_SIZE}"
    echo "MASTER_COUNT: ${MASTER_COUNT}"
    echo "NODE_COUNT: ${NODE_COUNT}"
    echo "SOURCE_PATH: ${SOURCE_PATH}"
    echo "ROOT_PATH: ${ROOT_PATH}"
    echo "PROJECT_NAME: ${PROJECT_NAME}"
    echo "----------"
}

function run_setup {
    validate_aws_config
    validate_source_path
    source_cluster_env
    validate_cluster_bucket
}

function validate_source_path {
    if [ ! -d "${SOURCE_PATH}" ]; then
        echo "*** Source-path '${SOURCE_PATH}' does not exist! Exiting."
        exit_with_error
    fi
}

function source_cluster_env {
    if [ ! -f "${SOURCE_PATH}/environment.sh" ]; then
        echo "SOURCE_PATH: ${SOURCE_PATH}"
        echo "*** Environment file ${SOURCE_PATH}/environment.sh does not exist!"
        exit_with_error
    else
        source ${SOURCE_PATH}/environment.sh
        source ${ROOT_PATH}/kubernetes/${REGION}/region_environment.sh
        source ${ROOT_PATH}/kubernetes/k8s_environment.sh
    fi
}

function validate_cluster_bucket {
    if aws s3api head-bucket --bucket "${KOPS_BUCKET_NAME}" 2>/dev/null; then
        echo "Bucket ${KOPS_BUCKET_NAME} found."
    else
        echo "*** Bucket ${KOPS_BUCKET_NAME} does not exist!"
        # exit_with_error
    fi
}

function validate_aws_config {
    if test -z "${AWS_ACCESS_KEY_ID}"; then
          echo "*** AWS_ACCESS_KEY_ID not found! Exiting."
          exit_with_error
    fi
    if test -z "${AWS_SECRET_ACCESS_KEY}"; then
          echo "*** AWS_SECRET_ACCESS_KEY not found! Exiting."
          exit_with_error
    fi
}

function validate_ecr_config {
    if test -z "${ECR_REGION}"; then
          echo "*** ECR_REGION not found! Exiting."
          exit_with_error
    fi
    if test -z "${ECR_ID}"; then
          echo "*** ECR_ID not found! Exiting."
          exit_with_error
    fi
    if test -z "${IMAGE_TAG}"; then
          echo "*** IMAGE_TAG not found! Exiting."
          exit_with_error
    fi
}

function test_for_kube_config {
    if [ ! -f "${KUBECONFIG}" ]; then
        echo "** Kube-config file ${KUBECONFIG} not found! Exiting."
        exit_with_error
    fi
}

function pull_kube_config {
    totalFoundObjects=$(aws s3 ls s3://${KOPS_BUCKET_NAME}/kubecfg.yaml --summarize | grep "Total Objects: " | sed 's/[^0-9]*//g')
    if [ "$totalFoundObjects" -eq "0" ]; then
        echo "** kubecfg.yaml not found in ${KOPS_BUCKET_NAME}."
        if [ -f "${KUBECONFIG}" ]; then
            rm ${KUBECONFIG}
        fi
    else
        aws s3 cp s3://${KOPS_BUCKET_NAME}/kubecfg.yaml ${KUBECONFIG} >/dev/null
    fi
}

function delete_kube_config {
    
    totalFoundObjects=$(aws s3 ls s3://${KOPS_BUCKET_NAME}/kubecfg.yaml --summarize | grep "Total Objects: " | sed 's/[^0-9]*//g')
    if [ "$totalFoundObjects" -eq "0" ]; then
        echo "** kubecfg.yaml not found in ${KOPS_BUCKET_NAME}."
    else
        aws s3 rm s3://${KOPS_BUCKET_NAME}/kubecfg.yaml
    fi
    if [ -f "${KUBECONFIG}" ]; then
        rm ${KUBECONFIG}
    fi
}

function deploy_ec2_key_pair {

    echo "PUBLIC_KEY_PATH: ${PUBLIC_KEY_PATH}"
    if test -f ${PUBLIC_KEY_PATH}; then
        echo "Public key '${PUBLIC_KEY_PATH}' found."
    else
        if test -f ${PRIVATE_KEY_PATH}.gpg; then
            # always decrypt encrypted key file
            echo "Encrypted Private Key file ${PRIVATE_KEY_PATH}.gpg found."
            gpg --decrypt --batch --yes --passphrase ${KEY_ENCRYPTION_PASSPHRASE} ${PRIVATE_KEY_PATH}.gpg > ${PRIVATE_KEY_PATH}
            chmod 600 ${PRIVATE_KEY_PATH}
        else
            echo "Encrypted Private Key file ${PRIVATE_KEY_PATH}.gpg does not exist! Creating..."
            export AWS_DEFAULT_REGION=${REGION}
            aws ec2 create-key-pair --key-name ${AWS_KEY_NAME} | jq -r '.KeyMaterial' >${PRIVATE_KEY_PATH}
            chmod 600 ${PRIVATE_KEY_PATH}
            # encrypt key so we can use it from public repo CI jobs
            gpg --symmetric --batch --yes --passphrase ${KEY_ENCRYPTION_PASSPHRASE} ${PRIVATE_KEY_PATH}
        fi
        # create public key that can be checked in
        ssh-keygen -y -f ${PRIVATE_KEY_PATH} > ${PUBLIC_KEY_PATH}
    fi
    echo '-----'
}

function destroy_ec2_key_pair {

    if test -f ${PUBLIC_KEY_PATH}; then
        echo "Destroying public key..."
        rm -rf ${PUBLIC_KEY_PATH}*
    fi
    if test -f ${PRIVATE_KEY_PATH}; then
        echo "Destroying EC2 key-pair..."
        export AWS_DEFAULT_REGION=${REGION}
        aws ec2 delete-key-pair --key-name ${AWS_KEY_NAME}
        rm -rf ${PRIVATE_KEY_PATH}*
    fi
}

function delete_versioned_bucket_contents {

    echo "Removing all versions from ${BUCKET}..."
    versions=`aws s3api list-object-versions --bucket ${BUCKET} |jq '.Versions'`
    markers=`aws s3api list-object-versions --bucket ${BUCKET} |jq '.DeleteMarkers'`

    let count=`echo $versions |jq 'length'`-1
    if [ $count -gt -1 ]; then
        echo "removing files"
        for i in $(seq 0 $count); do
            key=`echo $versions | jq .[$i].Key |sed -e 's/\"//g'`
            versionId=`echo $versions | jq .[$i].VersionId |sed -e 's/\"//g'`
            cmd="aws s3api delete-object --bucket ${BUCKET} --key $key --version-id $versionId"
            echo $cmd
            $cmd
        done
    fi

    let count=`echo $markers |jq 'length'`-1
    if [ $count -gt -1 ]; then
        echo "removing delete markers"
        for i in $(seq 0 $count); do
            key=`echo $markers | jq .[$i].Key |sed -e 's/\"//g'`
            versionId=`echo $markers | jq .[$i].VersionId |sed -e 's/\"//g'`
            cmd="aws s3api delete-object --bucket ${BUCKET} --key $key --version-id $versionId"
            echo $cmd
            $cmd
        done
    fi
}

function deploy_remote_state_resources {

    echo "Deploying remote-state resources with terraform..."
    mkdir -p ${SOURCE_PATH}/remote-state

    cat ${ROOT_PATH}/templates/shared/remote_state_resources.tf \
      | sed -e "s@DEPLOYMENT_NAME@${DEPLOYMENT_NAME}@g" \
      | sed -e "s@TERRAFORM_DYNAMODB_TABLE_NAME@${TERRAFORM_DYNAMODB_TABLE_NAME}@g" \
      | sed -e "s@TERRAFORM_BUCKET_NAME@${TERRAFORM_BUCKET_NAME}@g" \
      | sed -e "s@REGION@${REGION}@g" \
      > ${SOURCE_PATH}/remote-state/remote_state_resources.tf
    cd ${SOURCE_PATH}/remote-state

    terraform init
    time terraform apply --auto-approve
}

function destroy_remote_state_resources {

    if [ -d "${SOURCE_PATH}/remote-state" ]; then

        echo "${SOURCE_PATH}/remote-state found. Destroying..."

        BUCKET=${TERRAFORM_BUCKET_NAME}
        delete_versioned_bucket_contents

        set -e

        echo "Destroying terraform remote-state resources..."
        cd ${SOURCE_PATH}/remote-state
        terraform init
        terraform destroy --auto-approve

        echo "Destroying remote-state files..."
        cd ${ROOT_PATH}
        rm -rf ${SOURCE_PATH}/remote-state
    else
        echo "Remote-state resources path '${SOURCE_PATH}/remote-state' does not exist. So let's not delete it."
    fi
}

function deploy_kops_bucket {
    echo "Running kops-state-bucket terraform code..."

    if [ ! -d "${SOURCE_PATH}/kops-bucket" ]; then
        echo "Creating ${SOURCE_PATH}/kops-bucket..."
        mkdir -p ${SOURCE_PATH}/kops-bucket
    fi

    cat ${TEMPLATES_PATH}/kops_state_bucket.tf \
      | sed -e "s@KOPS_BUCKET_NAME@${KOPS_BUCKET_NAME}@g" \
      | sed -e "s@CLUSTER_NAME@${CLUSTER_NAME}@g" \
      | sed -e "s@REGION@${REGION}@g" \
      > ${SOURCE_PATH}/kops-bucket/kops_state_bucket.tf

    cd ${SOURCE_PATH}/kops-bucket
    
    terraform init
    time terraform apply --auto-approve
}

function destroy_kops_state_bucket {
    echo "-----"
    if [ -d "${SOURCE_PATH}/kops-bucket" ]; then

        echo "${SOURCE_PATH}/kops-bucket found. Deleting..."

        BUCKET=${KOPS_BUCKET_NAME}
        delete_versioned_bucket_contents

        set -e

        echo "Destroying kops-state bucket..."
        cd ${SOURCE_PATH}/kops-bucket
        terraform init
        terraform destroy --auto-approve

        echo "Removing kops-state bucket files..."
        cd ${ROOT_PATH}
        rm -rf ${SOURCE_PATH}/kops-bucket

    else
        echo "KOPS state bucket path '${SOURCE_PATH}/kops-bucket' does not exist. So let's not delete it."
    fi
}

function get_resources_from_legacy_deployment {

    CLUSTER_PATH=${SOURCE_PATH}
    source ${ROOT_PATH}/legacy/legacy_environment.sh
    if [ -d "${SOURCE_PATH}" ]; then

        # extract information from terraform
        cd ${SOURCE_PATH}
        DEPLOYMENT_INFO=$(terraform output -json)

        export VPC_ID=$(echo ${DEPLOYMENT_INFO} | jq -r ".vpc_id.value")
        export RDS_SG_ID=$(echo ${DEPLOYMENT_INFO} | jq -r ".rds_security_group_id.value")
        export RDS_ENDPOINT=$(echo ${DEPLOYMENT_INFO} | jq -r ".rds_internal_endpoint.value")

        SUBNET_A=$(echo ${DEPLOYMENT_INFO} | jq -r ".public_subnet_a_id.value")
        SUBNET_B=$(echo ${DEPLOYMENT_INFO} | jq -r ".public_subnet_b_id.value")
        UTILITY_SUBNET_A=$(echo ${DEPLOYMENT_INFO} | jq -r ".utility_subnet_a_id.value")
        UTILITY_SUBNET_B=$(echo ${DEPLOYMENT_INFO} | jq -r ".utility_subnet_b_id.value")

        export SUBNET_IDS="${SUBNET_A},${SUBNET_B}"
        export UTILITY_SUBNET_IDS="${UTILITY_SUBNET_A},${UTILITY_SUBNET_B}"
        
        echo "VPC_ID=${VPC_ID}"
        echo "SUBNET_IDS=${SUBNET_IDS}"
        echo "UTILITY_SUBNET_IDS=${UTILITY_SUBNET_IDS}"
        echo "RDS_SG_ID=${RDS_SG_ID}"
        echo "RDS_ENDPOINT=${RDS_ENDPOINT}"
    else
        echo "Legacy deployment path '${SOURCE_PATH}' does not exist. Exiting."
        exit_with_error
    fi
    export SOURCE_PATH=${CLUSTER_PATH}
    cd ${SOURCE_PATH}
}

function apply_legacy_templates {

    # create resource files from templates using environment variables:
    RANDOMSTR="${RANDOM}"
    cat ${TEMPLATES_PATH}/infrastructure.tf \
      | sed -e "s@REGION@${REGION}@g" \
      | sed -e "s@PROJECT_NAME@${PROJECT_NAME}@g" \
      | sed -e "s@DEPLOYMENT_NAME@${DEPLOYMENT_NAME}@g" \
      | sed -e "s@AWS_KEY_NAME@${AWS_KEY_NAME}@g" \
      | sed -e "s@R53_HOSTED_ZONE@${R53_HOSTED_ZONE}@g" \
      | sed -e "s@TERRAFORM_BUCKET_NAME@${TERRAFORM_BUCKET_NAME}@g" \
      | sed -e "s@SSL_CERT_ARN@${SSL_CERT_ARN}@g" \
      | sed -e "s@AWSACCESSKEYID@${AWS_ACCESS_KEY_ID}@g" \
      | sed -e "s@AWSSECRETACCESSKEY@${AWS_SECRET_ACCESS_KEY}@g" \
      | sed -e "s@RANDOMSTR@${RANDOMSTR}@g" \
      | sed -e "s@POSTGRESHOST@${POSTGRES_HOST}@g" \
      | sed -e "s@POSTGRESPORT@${POSTGRES_PORT}@g" \
      | sed -e "s@POSTGRESUSER@${POSTGRES_USER}@g" \
      | sed -e "s@POSTGRESPASSWORD@${POSTGRES_PASSWORD}@g" \
      | sed -e "s@POSTGRESDB@${POSTGRES_DB}@g" \
      | sed -e "s@RABBITMQHOST@${RABBITMQ_HOST}@g" \
      | sed -e "s@RABBITMQPORT@${RABBITMQ_PORT}@g" \
      | sed -e "s@RABBITMQDEFAULTUSER@${RABBITMQ_DEFAULT_USER}@g" \
      | sed -e "s@RABBITMQDEFAULTPASS@${RABBITMQ_DEFAULT_PASS}@g" \
      | sed -e "s@RABBITMQDEFAULTVHOST@${RABBITMQ_DEFAULT_VHOST}@g" \
      | sed -e "s@REDISHOST@${REDIS_HOST}@g" \
      | sed -e "s@REDISPORT@${REDIS_PORT}@g" \
      | sed -e "s@REDISNAMESPACE@${REDIS_NAMESPACE}@g" \
      | sed -e "s@SUPERUSERPASSWORD@${SUPERUSER_PASSWORD}@g" \
      | sed -e "s@TESTERUSERPASSWORD@${TESTERUSER_PASSWORD}@g" \
      | sed -e "s@VIEWERUSERPASSWORD@${VIEWERUSER_PASSWORD}@g" \
      | sed -e "s@K8S_CLUSTER_NAME@${K8S_CLUSTER_NAME}@g" \
      | sed -e "s@TERRAFORM_BUCKET_NAME@${TERRAFORM_BUCKET_NAME}@g" \
      > ${SOURCE_PATH}/infrastructure.tf

    # RDS setup
    cat ${TEMPLATES_PATH}/rds.tf \
      | sed -e "s@REGION@${REGION}@g" \
      | sed -e "s@DEPLOYMENT_NAME@${DEPLOYMENT_NAME}@g" \
      | sed -e "s@RDS_INSTANCE_TYPE@${RDS_INSTANCE_TYPE}@g" \
      | sed -e "s@POSTGRES_VERSION@${POSTGRES_VERSION}@g" \
      | sed -e "s@POSTGRES_PORT@${POSTGRES_PORT}@g" \
      | sed -e "s@POSTGRES_DB@${POSTGRES_DB}@g" \
      | sed -e "s@POSTGRES_USER@${POSTGRES_USER}@g" \
      | sed -e "s@POSTGRES_PASSWORD@${POSTGRES_PASSWORD}@g" \
      > ${SOURCE_PATH}/rds.tf

    # reference to terraform remote state:
    cat ${ROOT_PATH}/templates/shared/remote_state.tf \
      | sed -e "s@REGION@${REGION}@g" \
      | sed -e "s@TERRAFORM_BUCKET_NAME@${TERRAFORM_BUCKET_NAME}@g" \
      | sed -e "s@TERRAFORM_DYNAMODB_TABLE_NAME@${TERRAFORM_DYNAMODB_TABLE_NAME}@g" \
      > ${SOURCE_PATH}/remote_state.tf
}

function obfuscate_legacy_templates {
    
    cat ${TEMPLATES_PATH}/rds.tf \
      | sed -e "s@REGION@${REGION}@g" \
      | sed -e "s@DEPLOYMENT_NAME@${DEPLOYMENT_NAME}@g" \
      | sed -e "s@RDS_INSTANCE_TYPE@${RDS_INSTANCE_TYPE}@g" \
      | sed -e "s@POSTGRES_VERSION@${POSTGRES_VERSION}@g" \
      | sed -e "s@POSTGRES_PORT@${POSTGRES_PORT}@g" \
      | sed -e "s@POSTGRES_DB@${POSTGRES_DB}@g" \
      | sed -e "s@POSTGRES_USER@${POSTGRES_USER}@g" \
      | sed -e "s@POSTGRES_PASSWORD@****************@g" \
      > ${SOURCE_PATH}/rds.tf

    cat ${TEMPLATES_PATH}/infrastructure.tf \
      | sed -e "s@REGION@${REGION}@g" \
      | sed -e "s@PROJECT_NAME@${PROJECT_NAME}@g" \
      | sed -e "s@DEPLOYMENT_NAME@${DEPLOYMENT_NAME}@g" \
      | sed -e "s@AWS_KEY_NAME@${AWS_KEY_NAME}@g" \
      | sed -e "s@R53_HOSTED_ZONE@${R53_HOSTED_ZONE}@g" \
      | sed -e "s@TERRAFORM_BUCKET_NAME@${TERRAFORM_BUCKET_NAME}@g" \
      | sed -e "s@SSL_CERT_ARN@****************@g" \
      | sed -e "s@AWSACCESSKEYID@****************@g" \
      | sed -e "s@AWSSECRETACCESSKEY@****************@g" \
      | sed -e "s@RANDOMSTR@******@g" \
      | sed -e "s@POSTGRESHOST@${POSTGRES_HOST}@g" \
      | sed -e "s@POSTGRESPORT@${POSTGRES_PORT}@g" \
      | sed -e "s@POSTGRESUSER@${POSTGRES_USER}@g" \
      | sed -e "s@POSTGRESPASSWORD@****************@g" \
      | sed -e "s@POSTGRESDB@${POSTGRES_DB}@g" \
      | sed -e "s@RABBITMQHOST@${RABBITMQ_HOST}@g" \
      | sed -e "s@RABBITMQPORT@${RABBITMQ_PORT}@g" \
      | sed -e "s@RABBITMQDEFAULTUSER@${RABBITMQ_DEFAULT_USER}@g" \
      | sed -e "s@RABBITMQDEFAULTPASS@****************@g" \
      | sed -e "s@RABBITMQDEFAULTVHOST@${RABBITMQ_DEFAULT_VHOST}@g" \
      | sed -e "s@REDISHOST@${REDIS_HOST}@g" \
      | sed -e "s@REDISPORT@${REDIS_PORT}@g" \
      | sed -e "s@REDISNAMESPACE@'${REDIS_NAMESPACE}'@g" \
      | sed -e "s@SUPERUSERPASSWORD@****************@g" \
      | sed -e "s@TESTERUSERPASSWORD@****************@g" \
      | sed -e "s@VIEWERUSERPASSWORD@****************@g" \
      | sed -e "s@K8S_CLUSTER_NAME@${K8S_CLUSTER_NAME}@g" \
      > ${SOURCE_PATH}/infrastructure.tf
}

#####