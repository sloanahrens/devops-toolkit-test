#!/bin/bash

set -e

#####
# local scope functions

function get_cluster_info_json {

    cd ${SOURCE_PATH}/cluster
    terraform init >/dev/null
    CLUSTER_INFO=$(terraform output -json)
}

function setup_ec2_ssh_keys {

    check_cluster_path

    PUBLIC_KEY_PATH=${SOURCE_PATH}/cluster/${AWS_KEY_NAME}.pub

    if test -f ${PUBLIC_KEY_PATH}; then
        echo "Public Key file ${PUBLIC_KEY_PATH} found."
    else
        echo "Public Key file ${PUBLIC_KEY_PATH} does not exist! Creating..."
        if test -f ${PRIVATE_KEY_PATH}; then
            echo "Private Key file ${PRIVATE_KEY_PATH} found."
        else
            echo "Private Key file ${PRIVATE_KEY_PATH} does not exist! Creating..."
            export AWS_DEFAULT_REGION=${REGION}
            aws ec2 create-key-pair --key-name ${AWS_KEY_NAME} | jq -r '.KeyMaterial' >${PRIVATE_KEY_PATH}
            chmod 400 ${PRIVATE_KEY_PATH}
        fi
        ssh-keygen -y -f ${PRIVATE_KEY_PATH} > ${PUBLIC_KEY_PATH}
    fi
}

function apply_remote_state_resources_template {

    if [ ! -d "${SOURCE_PATH}/remote-state" ]; then
        echo "Creating ${SOURCE_PATH}/remote-state..."
        mkdir -p ${SOURCE_PATH}/remote-state
    fi

    cat ${ROOT_PATH}/kubernetes/templates/remote_state_resources.tf \
      | sed -e "s@TERRAFORM_DYNAMODB_TABLE_NAME@${TERRAFORM_DYNAMODB_TABLE_NAME}@g" \
      | sed -e "s@TERRAFORM_BUCKET_NAME@${TERRAFORM_BUCKET_NAME}@g" \
      | sed -e "s@CLUSTER_NAME@${CLUSTER_NAME}@g" \
      | sed -e "s@REGION@${REGION}@g" \
      > ${SOURCE_PATH}/remote-state/remote_state_resources.tf
}

function apply_kops_state_bucket_template {

    if [ ! -d "${SOURCE_PATH}/kops-bucket" ]; then
        echo "Creating ${SOURCE_PATH}/kops-bucket..."
        mkdir -p ${SOURCE_PATH}/kops-bucket
    fi

    cat ${ROOT_PATH}/kubernetes/templates/kops_state_bucket.tf \
      | sed -e "s@KOPS_BUCKET_NAME@${KOPS_BUCKET_NAME}@g" \
      | sed -e "s@CLUSTER_NAME@${CLUSTER_NAME}@g" \
      | sed -e "s@REGION@${REGION}@g" \
      > ${SOURCE_PATH}/kops-bucket/kops_state_bucket.tf
}

function run_remote_state_terraform {

    echo "Running remote-state terraform code..."

    apply_remote_state_resources_template

    cd ${SOURCE_PATH}/remote-state
    
    terraform init
    terraform apply --auto-approve
}

function run_kops_bucket_terraform {

    echo "Running kops-state-bucket terraform code..."

    cd ${SOURCE_PATH}/kops-bucket
    
    terraform init
    terraform apply --auto-approve
}

# RDS database
DEPLOY_RDS=${DEPLOY_RDS-'false'}

function apply_cluster_infrastructure_templates {

    # reference to terraform remote state:
    cat ${ROOT_PATH}/kubernetes/templates/remote_state.tf \
      | sed -e "s@TERRAFORM_DYNAMODB_TABLE_NAME@${TERRAFORM_DYNAMODB_TABLE_NAME}@g" \
      | sed -e "s@TERRAFORM_BUCKET_NAME@${TERRAFORM_BUCKET_NAME}@g" \
      | sed -e "s@REGION@${REGION}@g" \
      > ${SOURCE_PATH}/cluster/remote_state.tf

    # need to add some things to k8s node IAM policy:
    cat ${ROOT_PATH}/kubernetes/templates/node_iam_policy.txt \
      | sed -e "s@R53_HOSTED_ZONE@${R53_HOSTED_ZONE}@g" \
      | sed -e "s@KOPS_BUCKET_NAME@${KOPS_BUCKET_NAME}@g" \
      | sed -e "s@CLUSTER_NAME@${CLUSTER_NAME}@g" \
      > ${SOURCE_PATH}/cluster/data/aws_iam_role_policy_nodes.${CLUSTER_NAME}_policy

    # RDS terraform template will get used here
    ##
    if [ "${DEPLOY_RDS}" = "true" ]; then
        source_cluster_env_rds
        echo "Adding RDS template to project..."
        cat ${ROOT_PATH}/kubernetes/templates/rds.tf \
          | sed -e "s@PROJECT_NAME@${PROJECT_NAME}@g" \
          | sed -e "s@REGION@${REGION}@g" \
          | sed -e "s@CLUSTER_TYPE@${CLUSTER_TYPE}@g" \
          | sed -e "s@RDS_INSTANCE_TYPE@${RDS_INSTANCE_TYPE}@g" \
          | sed -e "s@POSTGRES_VERSION@${POSTGRES_VERSION}@g" \
          | sed -e "s@POSTGRES_PORT@${POSTGRES_PORT}@g" \
          | sed -e "s@POSTGRES_DB@${POSTGRES_DB}@g" \
          | sed -e "s@POSTGRES_USER@${POSTGRES_USER}@g" \
          | sed -e "s@POSTGRES_PASSWORD@${POSTGRES_PASSWORD}@g" \
          > ${SOURCE_PATH}/cluster/rds.tf
    fi
}

function run_cluster_terraform {

    echo "Running cluster terraform code..."

    apply_cluster_infrastructure_templates

    cd ${SOURCE_PATH}/cluster

    terraform init
    terraform plan
    terraform apply --auto-approve

    sleep 2
}

function check_cluster_path {

    if [ ! -d "${SOURCE_PATH}/cluster" ]; then
        echo "Creating ${SOURCE_PATH}/cluster..."
        mkdir -p ${SOURCE_PATH}/cluster
    fi
}

function check_specs_path {\

    if [ ! -d "${SOURCE_PATH}/specs" ]; then
        echo "Creating ${SOURCE_PATH}/specs..."
        mkdir -p ${SOURCE_PATH}/specs
    fi
}

function create_kops_cluster {

    check_cluster_path
    check_specs_path

    cd ${SOURCE_PATH}/cluster

    echo "Creating ${CLUSTER_NAME} in ${REGION} with kops..."

    kops create cluster \
        --cloud=aws \
        --name ${CLUSTER_NAME} \
        --state s3://${KOPS_BUCKET_NAME} \
        --master-count ${MASTER_COUNT} \
        --node-count ${NODE_COUNT} \
        --node-size ${NODE_SIZE} \
        --master-size ${MASTER_SIZE} \
        --zones ${NODE_ZONES} \
        --master-zones ${MASTER_ZONES} \
        --ssh-public-key ${AWS_KEY_NAME}.pub \
        --authorization RBAC \
        --kubernetes-version ${KUBERNETES_VERSION} \
        --topology private \
        --networking calico \
        --out=. \
        --target=terraform

    run_cluster_terraform
    export_kubeconfig
}

function export_kubeconfig {

    echo "Exporting Kube-config..."

    kops export kubecfg --name ${CLUSTER_NAME} --state s3://${KOPS_BUCKET_NAME}
    # kops export kubecfg --name ${CLUSTER_NAME} --state s3://${KOPS_BUCKET_NAME} --admin

    # push kubeconfig to private s3 bucket
    aws s3 cp ${SOURCE_PATH}/cluster/kubecfg.yaml s3://${KOPS_BUCKET_NAME}/kubecfg.yaml
}

function update_cluster {

    echo "Updating cluster..."

    cd ${SOURCE_PATH}/cluster

    kops update cluster ${CLUSTER_NAME} --state s3://${KOPS_BUCKET_NAME} --target=terraform --out=.

    sleep 2

    run_cluster_terraform

    kops rolling-update cluster --name ${CLUSTER_NAME} --state s3://${KOPS_BUCKET_NAME} --cloudonly --force --yes
    # kops rolling-update cluster --name ${CLUSTER_NAME} --state s3://${KOPS_BUCKET_NAME} --force --yes
    # kops rolling-update cluster --name ${CLUSTER_NAME} --state s3://${KOPS_BUCKET_NAME} --yes

    export_kubeconfig
}

function wait_for_cluster_health {

    echo "Waiting for cluster health..."
    kops validate cluster --name ${CLUSTER_NAME} --state s3://${KOPS_BUCKET_NAME} --wait 10m
}

function setup_nginx_ingress_plugin {

    echo "Setting up nginx ingress plugin..."

    # apply template
    cat ${ROOT_PATH}/kubernetes/templates/specs/nginx-ingress-load-balancer.yaml \
      | sed -e  "s@SSL_CERT_ARN@${SSL_CERT_ARN}@g" \
      > ${SOURCE_PATH}/specs/nginx-ingress-load-balancer.yaml

    # create Nginx Ingress controller:
    kubectl apply -f ${ROOT_PATH}/kubernetes/specs/nginx-ingress-controller.yaml

    # create nginx (region-specific) load-balancer
    kubectl apply -f ${SOURCE_PATH}/specs/nginx-ingress-load-balancer.yaml
}

function setup_external_dns_plugin {

    echo "Setting up external-dns plugin..."

    # apply template
    cat ${ROOT_PATH}/kubernetes/templates/specs/external-dns.yaml \
      | sed -e  "s@PROJECT_NAME@${PROJECT_NAME}@g" \
      | sed -e  "s@DOMAIN@${DOMAIN}@g" \
      > ${SOURCE_PATH}/specs/external-dns.yaml

    kubectl apply -f ${SOURCE_PATH}/specs/external-dns.yaml
}

# # function setup_autoscaler {

#     # WIP:

#     # create cluster auto-scaler
#     cat ${ROOT_PATH}/kubernetes/specs/cluster-autoscaler-autodiscover.yaml \
#       | sed -e  "s@CLUSTER_NAME@${CLUSTER_NAME}@g" \
#       | kubectl apply -f -

#     # create kubernetes dashboard:
#     # kubectl apply -f kubernetes/specs/kubernetes-dashboard.yaml
#     kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml
# # }
#####


# setup
echo "Starting K8s-cluster deployment/update for SOURCE_PATH: ${SOURCE_PATH}..."

source ${ROOT_PATH}/bash-scripts/devops-functions.sh

echo "Running setup and tests..."
validate_aws_config
validate_source_path
source_cluster_env
show_cluster_env

# check for EC2 SSH key
setup_ec2_ssh_keys

# create kops state bucket if needed
apply_kops_state_bucket_template
run_kops_bucket_terraform

# create remote state setup if needed
run_remote_state_terraform

# check for kops-state S3 bucket
validate_cluster_bucket

# pull kubecfg if it exists
pull_kube_config

# use kubcfg if found, otherwise create cluster
if test -f "${KUBECONFIG}"; then
    echo "Kube-config file ${KUBECONFIG} found. Updating..."
else
    echo "Kube-config file ${KUBECONFIG} not found! Creating cluster..."
    create_kops_cluster
fi

update_cluster

wait_for_cluster_health

setup_nginx_ingress_plugin
setup_external_dns_plugin

echo "K8s cluster deployment finished."
