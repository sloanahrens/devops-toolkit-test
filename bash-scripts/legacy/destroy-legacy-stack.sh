#!/bin/bash


set -e


source ${ROOT_PATH}/bash-scripts/devops-functions.sh

source ${ROOT_PATH}/legacy/legacy_environment.sh

if [ -d "${SOURCE_PATH}" ]; then
    echo "${SOURCE_PATH} found. Deleting deployment..."

    # terraform won't destroy if we have incorrect (obfuscated) parameters
    apply_legacy_templates

    cd ${SOURCE_PATH}
    terraform init
    time terraform destroy --auto-approve

    echo "Removing deployment files..."
    rm -f ${SOURCE_PATH}/rds.tf
    rm -f ${SOURCE_PATH}/infrastructure.tf
    rm -f ${SOURCE_PATH}/remote_state.tf

    if [ "${DESTROY_KEY_PAIR}" = "true" ]; then
        destroy_ec2_key_pair
    fi
    if [ "${DESTROY_REMOTE_STATE}" = "true" ]; then
        destroy_remote_state_resources
        cd ${ROOT_PATH}
        rm -rf ${SOURCE_PATH}
    fi
else
    echo "Deployment terraform path '${SOURCE_PATH}' does not exist. So let's not delete it. ;)"
fi