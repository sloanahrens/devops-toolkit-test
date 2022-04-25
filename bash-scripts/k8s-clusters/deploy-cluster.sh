#!/bin/bash


set -e


#####
# local scope functions

function create_kops_cluster {

    cd ${TF_INFRA_PATH}

    echo "Creating ${CLUSTER_NAME} in ${REGION} with kops..."

        # # no idea why this doesn't work but it doesn't
        # --vpc=${VPC_ID} \
        # --subnets=${SUBNET_IDS} \
        # --utility-subnets=${UTILITY_SUBNET_IDS} \

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
}

function run_cluster_terraform {

    # # don't need this if I can't launch k8s into the RDS VPC (and get it to actually work)
    # # RDS security-group rule:
    # cat ${TEMPLATES_PATH}/rds_sg_rule.tf \
    #   | sed -e "s@DEPLOYMENT_NAME@${DEPLOYMENT_NAME}@g" \
    #   | sed -e "s@RDS_SG_ID@${RDS_SG_ID}@g" \
    #   | sed -e "s@POSTGRES_PORT@${POSTGRES_PORT}@g" \
    #   > ${TF_INFRA_PATH}/rds_sg_rule.tf

    # reference to terraform remote state:
    cat ${ROOT_PATH}/templates/shared/remote_state.tf \
      | sed -e "s@DEPLOYMENT_NAME@${DEPLOYMENT_NAME}@g" \
      | sed -e "s@TERRAFORM_DYNAMODB_TABLE_NAME@${TERRAFORM_DYNAMODB_TABLE_NAME}@g" \
      | sed -e "s@TERRAFORM_BUCKET_NAME@${TERRAFORM_BUCKET_NAME}@g" \
      | sed -e "s@REGION@${REGION}@g" \
      > ${TF_INFRA_PATH}/remote_state.tf

    # need to add some things to k8s node IAM policy:
    cat ${TEMPLATES_PATH}/node_iam_policy.txt \
      | sed -e "s@R53_HOSTED_ZONE@${R53_HOSTED_ZONE}@g" \
      | sed -e "s@KOPS_BUCKET_NAME@${KOPS_BUCKET_NAME}@g" \
      | sed -e "s@CLUSTER_NAME@${CLUSTER_NAME}@g" \
      > ${TF_INFRA_PATH}/data/aws_iam_role_policy_nodes.${CLUSTER_NAME}_policy

    echo "Running cluster terraform code..."

    cd ${TF_INFRA_PATH}

    terraform init

    terraform plan
    
    time terraform apply --auto-approve

    sleep 2
}

function update_cluster {

    echo "Updating cluster..."

    cd ${TF_INFRA_PATH}

    kops update cluster ${CLUSTER_NAME} --state s3://${KOPS_BUCKET_NAME} --target=terraform --out=.

    sleep 2

    run_cluster_terraform

    kops rolling-update cluster --name ${CLUSTER_NAME} --state s3://${KOPS_BUCKET_NAME} --cloudonly --force --yes
    # kops rolling-update cluster --name ${CLUSTER_NAME} --state s3://${KOPS_BUCKET_NAME} --force --yes
    # kops rolling-update cluster --name ${CLUSTER_NAME} --state s3://${KOPS_BUCKET_NAME} --yes

    echo "Exporting Kube-config..."
    kops export kubecfg --name ${CLUSTER_NAME} --state s3://${KOPS_BUCKET_NAME}
    # kops export kubecfg --name ${CLUSTER_NAME} --state s3://${KOPS_BUCKET_NAME} --admin

    # push kubeconfig to private s3 bucket
    aws s3 cp ${TF_INFRA_PATH}/kubecfg.yaml s3://${KOPS_BUCKET_NAME}/kubecfg.yaml
}

function wait_for_cluster_health {

    echo "Waiting for cluster health..."
    kops validate cluster --name ${CLUSTER_NAME} --state s3://${KOPS_BUCKET_NAME} --wait 10m
}

function setup_nginx_ingress_plugin {

    echo "Setting up nginx ingress plugin..."

    # apply template
    cat ${TEMPLATES_PATH}/specs/nginx-ingress-load-balancer.yaml \
      | sed -e  "s@SSL_CERT_ARN@${SSL_CERT_ARN}@g" \
      > ${SPECS_PATH}/nginx-ingress-load-balancer.yaml

    # create Nginx Ingress controller:
    kubectl apply -f ${ROOT_PATH}/kubernetes/specs/nginx-ingress-controller.yaml

    # create nginx (region-specific) load-balancer
    kubectl apply -f ${SPECS_PATH}/nginx-ingress-load-balancer.yaml
}

function setup_external_dns_plugin {

    echo "Setting up external-dns plugin..."

    # apply template
    cat ${TEMPLATES_PATH}/specs/external-dns.yaml \
      | sed -e  "s@PROJECT_NAME@${PROJECT_NAME}@g" \
      | sed -e  "s@DOMAIN@${DOMAIN}@g" \
      > ${SPECS_PATH}/external-dns.yaml

    kubectl apply -f ${SPECS_PATH}/external-dns.yaml
}

# # function setup_autoscaler {

#     # WIP:

#     # create cluster auto-scaler
#     cat ${TEMPLATES_PATH}/specs/cluster-autoscaler-autodiscover.yaml \
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

# # get infrastructure ids for kops and rds-rule template
# get_resources_from_legacy_deployment

source_cluster_env
show_cluster_env

mkdir -p ${TF_INFRA_PATH}
mkdir -p ${SPECS_PATH}

if [ "${DEPLOY_KOPS_BUCKET}" = "true" ]; then
    deploy_kops_bucket
fi

if [ "${DEPLOY_REMOTE_STATE}" = "true" ]; then
    deploy_remote_state_resources
fi

if [ "${DEPLOY_KEY_PAIR}" = "true" ]; then
    deploy_ec2_key_pair
fi
cp -f ${PUBLIC_KEY_PATH} ${TF_INFRA_PATH}/

# echo "EXITING"
# exit 1

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
    run_cluster_terraform

    # sleep_one_minute
    # # not sure why I need to update a new cluster twice but I do, or the LB cert ends up wrong somehow 
    # # (TODO: update k8s version?)
    update_cluster
    # sleep_one_minute
fi

update_cluster

sleep_one_minute

wait_for_cluster_health

setup_nginx_ingress_plugin
setup_external_dns_plugin

echo "K8s cluster deployment finished."
