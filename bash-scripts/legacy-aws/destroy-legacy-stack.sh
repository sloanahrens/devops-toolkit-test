#!/bin/bash

set -e
set -x


cd ${ROOT_PATH}/legacy-aws/${REGION}/${DEPLOYMENT_TYPE}


terraform init
terraform destroy --auto-approve

#####
# comment out for faster deletes/re-builds
source ${ROOT_PATH}/bash-scripts/legacy-aws/destroy-terraform-remote-state.sh
rm -rf ${ROOT_PATH}/legacy-aws/${REGION}/${DEPLOYMENT_TYPE}
#####
