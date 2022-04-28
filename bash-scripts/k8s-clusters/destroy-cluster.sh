#!/bin/bash


echo "Destroying cluster at SOURCE_PATH:${SOURCE_PATH}..."

# setup
source ${ROOT_PATH}/bash-scripts/devops-functions.sh
run_setup

pull_kube_config
if [ -f "${KUBECONFIG}" ]; then
    kubectl delete ns stellarbot-k8s --ignore-not-found=true
    kubectl delete ns ingress-nginx --ignore-not-found=true
fi

if [ -d "${TF_INFRA_PATH}" ]; then
    echo "${SOURCE_PATH}/cluster found. Deleting cluster resources..."

    cd ${TF_INFRA_PATH}
    terraform init
    time terraform destroy --auto-approve

    kops delete cluster --name ${CLUSTER_NAME} --state s3://${KOPS_BUCKET_NAME} --yes

    delete_kube_config

    echo "Removing cluster files..."
    rm -rf ${SPECS_PATH}
    rm -rf ${TF_INFRA_PATH}
else
    echo "Cluster terraform path '${TF_INFRA_PATH}' does not exist. So let's not delete it. ;)"
fi

if [ "${DESTROY_KEY_PAIR}" = "true" ]; then
    destroy_ec2_key_pair
fi
if [ "${DESTROY_REMOTE_STATE}" = "true" ]; then
    destroy_remote_state_resources
fi
if [ "${DESTROY_KOPS_BUCKET}" = "true" ]; then
     destroy_kops_state_bucket
fi

echo "Cluster destroyed at TF_INFRA_PATH: ${TF_INFRA_PATH}."