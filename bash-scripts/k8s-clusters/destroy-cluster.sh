#!/bin/bash

# setup
source ${ROOT_PATH}/bash-scripts/devops-functions.sh
run_setup

set_cluster_updating_status

pull_kube_config

if [ -f "${KUBECONFIG}" ]; then
    echo "Deleting Nginx Ingress..."
    kubectl delete ns ingress-nginx --ignore-not-found=true
fi

cd ${SOURCE_PATH}/cluster
terraform init
terraform destroy --auto-approve

kops delete cluster --name $CLUSTER_NAME --state s3://$BUCKET_NAME --yes

delete_kube_config

echo "Removing cluster terraform files..."
rm -rf ${SOURCE_PATH}/cluster/.terraform*

# destroy remote state resources
# source ${ROOT_PATH}/bash-scripts/k8s-clusters/destroy-terraform-remote-state.sh

remove_cluster_updating_status