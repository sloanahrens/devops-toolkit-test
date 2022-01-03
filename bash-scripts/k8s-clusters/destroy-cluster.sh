#!/bin/bash

# setup
source ${ROOT_PATH}/bash-scripts/devops-functions.sh
run_setup

pull_kube_config

if [ -f "${KUBECONFIG}" ]; then
    echo "Deleting Nginx Ingress..."
    kubectl delete ns ingress-nginx --ignore-not-found=true
fi

if [ -d "${SOURCE_PATH}/cluster" ]; then

    echo "${SOURCE_PATH}/cluster found. Deleting..."

    cd ${SOURCE_PATH}/cluster

    terraform init
    
    echo "Destroying cluster resources..."
    terraform destroy --auto-approve

    kops delete cluster --name ${CLUSTER_NAME} --state s3://${KOPS_BUCKET_NAME} --yes

    delete_kube_config

    echo "Removing cluster files..."
    rm -rf ${SOURCE_PATH}/specs
    rm -rf ${SOURCE_PATH}/cluster
else
    echo "Cluster terraform path '${SOURCE_PATH}/cluster' does not exist. So let's not delete it. ;)"
fi


# # destroy remote state resources
# source ${ROOT_PATH}/bash-scripts/k8s-clusters/destroy-remote-state-resources.sh

# # destroy kops state bucket
# source ${ROOT_PATH}/bash-scripts/k8s-clusters/destroy-kops-bucket.sh


echo "Cluster destroyed at ${SOURCE_PATH}:${SOURCE_PATH}."