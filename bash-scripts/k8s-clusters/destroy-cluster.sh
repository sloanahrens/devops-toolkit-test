#!/bin/bash

# setup
source ${ROOT_PATH}/bash-scripts/devops-functions.sh
run_setup

pull_kube_config

if [ -f "${KUBECONFIG}" ]; then
    echo "Deleting Nginx Ingress..."
    kubectl delete ns ingress-nginx --ignore-not-found=true
fi

cd ${SOURCE_PATH}/cluster
terraform init
terraform destroy --auto-approve

kops delete cluster --name ${CLUSTER_NAME} --state s3://${KOPS_BUCKET_NAME} --yes

delete_kube_config


# destroy remote state resources
source ${ROOT_PATH}/bash-scripts/k8s-clusters/destroy-remote-state-resources.sh

echo "Removing cluster files..."
rm -rf ${SOURCE_PATH}/specs
rm -rf ${SOURCE_PATH}/cluster
rm -rf ${SOURCE_PATH}/remote-state


echo "Cluster destroyed at ${SOURCE_PATH}:${SOURCE_PATH}"