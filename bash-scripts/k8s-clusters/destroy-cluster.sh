#!/bin/bash

# setup
source ${ROOT_PATH}/bash-scripts/devops-functions.sh
run_setup

if [ "$1" == "force" ]; then
    echo "** Forcing cluster update **"
    remove_cluster_updating_status
fi

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

remove_cluster_updating_status

source /src/bash-scripts/k8s-clusters/destroy-terraform-remote-state.sh