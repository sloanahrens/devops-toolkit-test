#!/bin/bash

set -e

source /src/bash-scripts/devops-functions.sh
validate_source_paths
source_cluster_env
validate_aws_config
pull_kube_config
