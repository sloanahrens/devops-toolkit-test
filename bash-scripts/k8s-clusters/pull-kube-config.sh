#!/bin/bash

set -e

source ${ROOT_PATH}/bash-scripts/devops-functions.sh
run_setup
pull_kube_config
