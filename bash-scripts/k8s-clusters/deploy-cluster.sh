#!/bin/bash

set -e

#####
# local scope functions

function run_remote_state_terraform {

    cat ${ROOT_PATH}/kubernetes/templates/remote_state_resources.tf \
      | sed -e "s@REGION@${REGION}@g" \
      | sed -e "s@CLUSTER_TYPE@${CLUSTER_TYPE}@g" \
      > ${SOURCE_PATH}/remote-state/remote_state_resources.tf

    cd ${SOURCE_PATH}/remote-state
    
    terraform init
    terraform apply --auto-approve
}

function run_cluster_terraform {

    cat ${ROOT_PATH}/kubernetes/templates/remote_state.tf \
      | sed -e "s@REGION@${REGION}@g" \
      | sed -e "s@CLUSTER_TYPE@${CLUSTER_TYPE}@g" \
      > ${SOURCE_PATH}/cluster/remote_state.tf

    cat ${ROOT_PATH}/kubernetes/templates/node_iam_policy.txt \
      | sed -e "s@R53_HOSTED_ZONE@${R53_HOSTED_ZONE}@g" \
      | sed -e "s@BUCKET_NAME@${BUCKET_NAME}@g" \
      | sed -e "s@CLUSTER_NAME@${CLUSTER_NAME}@g" \
      > ${SOURCE_PATH}/cluster/data/aws_iam_role_policy_nodes.${CLUSTER_NAME}_policy

    cd ${SOURCE_PATH}/cluster

    terraform init
    terraform plan
    terraform apply --auto-approve
}

function create_cluster {

    cd ${SOURCE_PATH}/cluster

    if test -f "$PWD/${AWS_KEY_NAME}.pem"; then
        echo "** Key file $PWD/${AWS_KEY_NAME}.pem found."
        ssh-keygen -y -f $PWD/${AWS_KEY_NAME}.pem > $PWD/${AWS_KEY_NAME}.pub
    else
        echo "*** Key file $PWD/${AWS_KEY_NAME}.pem does not exist! Exiting."
        exit_with_error
    fi

    echo "** Deploying ${CLUSTER_NAME} in ${REGION}."

    # always start with 3 nodes, node auto-scale groups will be added
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

    sleep 5

    run_cluster_terraform

    sleep 5

    kops export kubecfg --name ${CLUSTER_NAME} --state s3://${BUCKET_NAME}
}

function update_cluster {

    ## DANGER this needs work

    cd ${SOURCE_PATH}/cluster

    # need to figure out why this is necessary; it removes the load-balancer from the master ASG for some reason
    kops update cluster ${CLUSTER_NAME} --state s3://${BUCKET_NAME} --target=terraform --out=.

    # running terraform screws up the cluster because the previous step removes the load-balancer
    # run_cluster_terraform
    # this is only here to keep the code in source-control matching the deployed resources, since kops update overwrites the IAM policy doc
    cat ${ROOT_PATH}/kubernetes/templates/node_iam_policy.txt \
      | sed -e "s@R53_HOSTED_ZONE@${R53_HOSTED_ZONE}@g" \
      | sed -e "s@BUCKET_NAME@${BUCKET_NAME}@g" \
      | sed -e "s@CLUSTER_NAME@${CLUSTER_NAME}@g" \
      > ${SOURCE_PATH}/cluster/data/aws_iam_role_policy_nodes.${CLUSTER_NAME}_policy

    sleep 5

    kops rolling-update cluster --name ${CLUSTER_NAME} --state s3://${BUCKET_NAME} --cloudonly --force --yes
    # kops rolling-update cluster --name ${CLUSTER_NAME} --state s3://${BUCKET_NAME} --force --yes
    # kops rolling-update cluster --name ${CLUSTER_NAME} --state s3://${BUCKET_NAME} --yes
}

function get_cluster_info_json {

    cd ${SOURCE_PATH}/cluster
    terraform init >/dev/null
    CLUSTER_INFO=$(terraform output -json)
}

function wait_for_cluster_health {

    kops validate cluster --wait 10m --name ${CLUSTER_NAME} --state s3://${BUCKET_NAME}
    # kops validate cluster --name ${CLUSTER_NAME} --state s3://${BUCKET_NAME}
}

function setup_k8s_scaffolding {

    # create Nginx Ingress controller:
    kubectl apply -f ${ROOT_PATH}/kubernetes/specs/nginx-ingress-controller.yaml

    mkdir -p ${SOURCE_PATH}/cluster/specs

    # create nginx (region-specific) load-balancer
    cat ${ROOT_PATH}/kubernetes/templates/specs/nginx-ingress-load-balancer.yaml \
      | sed -e  "s@SSL_CERT_ARN@${SSL_CERT_ARN}@g" \
      > ${SOURCE_PATH}/specs/nginx-ingress-load-balancer.yaml
    kubectl apply -f ${SOURCE_PATH}/specs/nginx-ingress-load-balancer.yaml

    # create external-dns stuff:
    cat ${ROOT_PATH}/kubernetes/templates/specs/external-dns.yaml \
      | sed -e  "s@DOMAIN_NAME@${DOMAIN_NAME}@g" \
      > ${SOURCE_PATH}/specs/external-dns.yaml
    kubectl apply -f ${SOURCE_PATH}/specs/external-dns.yaml

    # # create cluster auto-scaler
    # cat ${ROOT_PATH}/kubernetes/specs/cluster-autoscaler-autodiscover.yaml \
    #   | sed -e  "s@CLUSTER_NAME@${CLUSTER_NAME}@g" \
    #   | kubectl apply -f -

    # # create kubernetes dashboard:
    # # kubectl apply -f kubernetes/specs/kubernetes-dashboard.yaml
    # kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml
}
#####


# setup
echo "Running setup"
source ${ROOT_PATH}/bash-scripts/devops-functions.sh
run_setup

mkdir -p ${SOURCE_PATH}/cluster
mkdir -p ${SOURCE_PATH}/remote-state

if [ "$1" == "force" ]; then
    echo "** Forcing cluster update **"
    remove_cluster_updating_status
fi

echo "Updating cluster status"
# avoid simultaneous cluster updates
set_cluster_updating_status

echo "Starting K8s-cluster deployment for SOURCE_PATH: ${SOURCE_PATH}"

# create remote state setup if needed
run_remote_state_terraform

# pull kubecfg if it exists
pull_kube_config

# use kubcfg if found, otherwise create cluster
if test -f "${KUBECONFIG}"; then
    echo "** Kube-config file ${KUBECONFIG} found. Updating..."
else
    echo "** Kube-config file ${KUBECONFIG} not found! Creating cluster..."
    create_cluster
fi
update_cluster # this needs work
wait_for_cluster_health

setup_k8s_scaffolding

# push kubeconfig to private s3 bucket
# aws s3 cp kubecfg.yaml s3://$BUCKET_NAME/kubecfg.yaml

remove_cluster_updating_status
