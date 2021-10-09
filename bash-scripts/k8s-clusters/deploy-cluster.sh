#!/bin/bash

set -e

#####
# local scope functions

function get_cluster_info_json {

    cd ${SOURCE_PATH}/cluster
    terraform init >/dev/null
    CLUSTER_INFO=$(terraform output -json)
}

function check_ssh_key {

    if test -f "${SOURCE_PATH}/${AWS_KEY_NAME}.pem"; then
        echo "** Key file ${SOURCE_PATH}/${AWS_KEY_NAME}.pem found."
        ssh-keygen -y -f ${SOURCE_PATH}/${AWS_KEY_NAME}.pem > ${SOURCE_PATH}/cluster/${AWS_KEY_NAME}.pub
    else
        echo "*** Key file ${SOURCE_PATH}/${AWS_KEY_NAME}.pem does not exist! Exiting."
        exit_with_error
    fi
}

function apply_remote_state_resources_template {

    cat ${ROOT_PATH}/kubernetes/templates/remote_state_resources.tf \
      | sed -e "s@REGION@${REGION}@g" \
      | sed -e "s@CLUSTER_TYPE@${CLUSTER_TYPE}@g" \
      > ${SOURCE_PATH}/remote-state/remote_state_resources.tf
}

function run_remote_state_terraform {

    echo "Running remote-state terraform code..."

    apply_remote_state_resources_template

    cd ${SOURCE_PATH}/remote-state
    
    terraform init
    terraform apply --auto-approve
}

function apply_cluster_infrastructure_templates {

    # reference to terraform remote state:
    cat ${ROOT_PATH}/kubernetes/templates/remote_state.tf \
      | sed -e "s@REGION@${REGION}@g" \
      | sed -e "s@CLUSTER_TYPE@${CLUSTER_TYPE}@g" \
      > ${SOURCE_PATH}/cluster/remote_state.tf

    # need to add some things to k8s node IAM policy:
    cat ${ROOT_PATH}/kubernetes/templates/node_iam_policy.txt \
      | sed -e "s@R53_HOSTED_ZONE@${R53_HOSTED_ZONE}@g" \
      | sed -e "s@BUCKET_NAME@${BUCKET_NAME}@g" \
      | sed -e "s@CLUSTER_NAME@${CLUSTER_NAME}@g" \
      > ${SOURCE_PATH}/cluster/data/aws_iam_role_policy_nodes.${CLUSTER_NAME}_policy

    # RDS terraform template will get used here
    ##
}

function run_cluster_terraform {

    echo "Running cluster terraform code..."

    apply_cluster_infrastructure_templates

    cd ${SOURCE_PATH}/cluster

    terraform init
    terraform plan
    terraform apply --auto-approve

    sleep 1
}

function create_kops_cluster {

    cd ${SOURCE_PATH}/cluster

    echo "** Creating ${CLUSTER_NAME} in ${REGION} with kops..."

    kops create cluster \
        --cloud=aws \
        --name ${CLUSTER_NAME} \
        --state s3://${BUCKET_NAME} \
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

    kops export kubecfg --name ${CLUSTER_NAME} --state s3://${BUCKET_NAME}
    # kops export kubecfg --name ${CLUSTER_NAME} --state s3://${BUCKET_NAME} --admin

    # push kubeconfig to private s3 bucket
    aws s3 cp ${SOURCE_PATH}/cluster/kubecfg.yaml s3://${BUCKET_NAME}/kubecfg.yaml
}

function update_cluster {

    echo "Updating cluster..."

    cd ${SOURCE_PATH}/cluster

    kops update cluster ${CLUSTER_NAME} --state s3://${BUCKET_NAME} --target=terraform --out=.

    sleep 1

    run_cluster_terraform

    kops rolling-update cluster --name ${CLUSTER_NAME} --state s3://${BUCKET_NAME} --cloudonly --force --yes
    # kops rolling-update cluster --name ${CLUSTER_NAME} --state s3://${BUCKET_NAME} --force --yes
    # kops rolling-update cluster --name ${CLUSTER_NAME} --state s3://${BUCKET_NAME} --yes

    export_kubeconfig
}

function wait_for_cluster_health {

    echo "Waiting for cluster health..."
    kops validate cluster --name ${CLUSTER_NAME} --state s3://${BUCKET_NAME} --wait 10m
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
echo "Running setup..."
source ${ROOT_PATH}/bash-scripts/devops-functions.sh
run_setup

echo "Updating cluster status..."
# avoid simultaneous cluster updates
set_cluster_updating_status

echo "Starting K8s-cluster deployment for SOURCE_PATH: ${SOURCE_PATH}..."

# create remote state setup if needed
# run_remote_state_terraform

# pull kubecfg if it exists
pull_kube_config

# check for EC2 SSH key
check_ssh_key

# use kubcfg if found, otherwise create cluster
if test -f "${KUBECONFIG}"; then
    echo "** Kube-config file ${KUBECONFIG} found. Updating..."
else
    echo "** Kube-config file ${KUBECONFIG} not found! Creating cluster..."
    create_kops_cluster
fi

update_cluster

wait_for_cluster_health

setup_nginx_ingress_plugin
setup_external_dns_plugin

remove_cluster_updating_status

echo "K8s cluster deployment finished."
