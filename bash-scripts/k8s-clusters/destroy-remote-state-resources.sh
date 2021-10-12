#!/bin/bash

set -e


# setup
source ${ROOT_PATH}/bash-scripts/devops-functions.sh
run_setup

BUCKET=${TERRAFORM_BUCKET_NAME}
delete_versioned_bucket_contents

cd ${SOURCE_PATH}/remote-state
terraform init

echo "Destroying remote state resources..."
terraform destroy --auto-approve