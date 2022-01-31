#!/bin/bash

set -e


export USE_RDS='true'
export WORKER_REPLICAS=3

source ${ROOT_PATH}/bash-scripts/app-stacks/deploy-k8s-app-stack.sh