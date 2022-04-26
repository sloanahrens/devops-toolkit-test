#!/bin/bash


set -e


source ${ROOT_PATH}/bash-scripts/devops-functions.sh

source ${ROOT_PATH}/legacy/legacy_environment.sh

if [ -d "${TF_INFRA_PATH}" ]; then
    echo "${TF_INFRA_PATH} found. Deleting deployment..."

    if [ -d "${TF_INFRA_PATH}" ]; then

        # terraform won't destroy if we have incorrect (obfuscated) parameters
        apply_legacy_templates

        cd ${TF_INFRA_PATH}
        terraform init
        time terraform destroy --auto-approve
    else
        echo "Deployment terraform path '${TF_INFRA_PATH}' does not exist, no infrastructure to delete. ;)"
    fi

    echo "Removing deployment files..."
    cd ${TF_INFRA_PATH}
    cd ..
    rm -rf ${TF_INFRA_PATH}

    if [ "${DESTROY_KEY_PAIR}" = "true" ]; then
        destroy_ec2_key_pair
    fi
    if [ "${DESTROY_REMOTE_STATE}" = "true" ]; then
        destroy_remote_state_resources
    fi
else
    echo "Deployment terraform path '${TF_INFRA_PATH}' does not exist. So let's not delete it. ;)"
fi