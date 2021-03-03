#!/bin/bash

# setup
source ${ROOT_PATH}/bash-scripts/devops-functions.sh
run_setup

remove_cluster_updating_status

source ${ROOT_PATH}/bash-scripts/k8s-clusters/deploy-cluster.sh