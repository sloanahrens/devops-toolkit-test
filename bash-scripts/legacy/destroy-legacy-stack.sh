#!/bin/bash


set -e


source ${ROOT_PATH}/bash-scripts/devops-functions.sh

source ${ROOT_PATH}/legacy/legacy_environment.sh

if [ -d "${SOURCE_PATH}" ]; then
    echo "${SOURCE_PATH} found. Deleting deployment..."

    if [ -d "${SOURCE_PATH}/infra" ]; then

        # terraform won't destroy if we have incorrect (obfuscated) parameters
        apply_legacy_templates

        cd ${SOURCE_PATH}/infra
        terraform init
        time terraform destroy --auto-approve
    else
        echo "Deployment terraform path '${SOURCE_PATH}/infra' does not exist, no infrastructure to delete. ;)"
    fi

    echo "Removing deployment files..."
    cd ${SOURCE_PATH}
    rm -rf ${SOURCE_PATH}/infra

    if [ "${DESTROY_KEY_PAIR}" = "true" ]; then
        destroy_ec2_key_pair
    fi
    if [ "${DESTROY_REMOTE_STATE}" = "true" ]; then
        destroy_remote_state_resources
    fi
else
    echo "Deployment terraform path '${SOURCE_PATH}' does not exist. So let's not delete it. ;)"
fi