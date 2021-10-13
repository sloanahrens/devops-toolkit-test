#!/bin/bash

set -e

if [ -d "${SOURCE_PATH}/remote-state" ]; then

    echo "${SOURCE_PATH}/remote-state found. Deleting..."

    # setup
    source ${ROOT_PATH}/bash-scripts/devops-functions.sh
    run_setup

    BUCKET=${TERRAFORM_BUCKET_NAME}
    delete_versioned_bucket_contents

    cd ${SOURCE_PATH}/remote-state
    terraform init

    echo "Destroying terraform remote-state resources..."
    terraform destroy --auto-approve

    echo "Destroying remote-state files..."
    rm -rf ${SOURCE_PATH}/remote-state
else
    echo "Remote-state resources path '${SOURCE_PATH}/remote-state' does not exist. So let's not delete it. ;)"
fi