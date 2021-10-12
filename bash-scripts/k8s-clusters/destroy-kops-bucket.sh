#!/bin/bash

set -e


# setup
source ${ROOT_PATH}/bash-scripts/devops-functions.sh
run_setup

BUCKET=${KOPS_BUCKET_NAME}
delete_versioned_bucket_contents

cd ${SOURCE_PATH}/kops-bucket
terraform init

echo "Destroying kops state bucket..."
terraform destroy --auto-approve