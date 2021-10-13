#!/bin/bash

set -e


if [ -d "${SOURCE_PATH}/kops-bucket" ]; then

    echo "${SOURCE_PATH}/kops-bucket found. Deleting..."

    # setup
    source ${ROOT_PATH}/bash-scripts/devops-functions.sh
    run_setup

    BUCKET=${KOPS_BUCKET_NAME}
    delete_versioned_bucket_contents

    cd ${SOURCE_PATH}/kops-bucket
    terraform init

    echo "Destroying kops state bucket..."
    terraform destroy --auto-approve

    echo "Removing kops-bucket files..."
    rm -rf ${SOURCE_PATH}/kops-bucket

else
    echo "KOPS state bucket path '${SOURCE_PATH}/kops-bucket' does not exist. So let's not delete it. ;)"
fi