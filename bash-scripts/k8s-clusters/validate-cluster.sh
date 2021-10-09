#!/bin/bash

set -e

source ${ROOT_PATH}/bash-scripts/devops-functions.sh
run_setup

pull_kube_config

test_for_kube_config

kops validate cluster --name ${CLUSTER_NAME} --state s3://${BUCKET_NAME}
