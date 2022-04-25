#!/bin/bash


#####
# PROJECT_NAME, DEPLOYMENT_TYPE and REGION need to be set before this script runs.

export DOMAIN=sloanahrens.com

export POSTGRES_HOST=database
export POSTGRES_PORT=5432
export POSTGRES_USER=${PROJECT_NAME}
export POSTGRES_DB=${PROJECT_NAME}_db
export POSTGRES_VERSION=12.8
export POSTGRES_PASSWORD=${POSTGRES_PASSWORD-'newborn-invasive-optic-croci-moralist-defat-juniper'}

export RABBITMQ_HOST=queue
export RABBITMQ_PORT=5672
export RABBITMQ_DEFAULT_USER=k8s_user
export RABBITMQ_DEFAULT_VHOST=k8s_vhost
export REDIS_HOST=redis
export REDIS_PORT=6379
export REDIS_NAMESPACE=0

export SUPERUSER_PASSWORD=${SUPERUSER_PASSWORD-'wren-landmark-pup-eve'}
export TESTERUSER_PASSWORD=${TESTERUSER_PASSWORD-'entendre-wist-surgeon'}
export VIEWERUSER_PASSWORD=${VIEWERUSER_PASSWORD-'foot-bezoar-craving'}
export POSTGRES_PASSWORD=${POSTGRES_PASSWORD-'purse-scandal-seashore-tights'}
export RABBITMQ_DEFAULT_PASS=${RABBITMQ_DEFAULT_PASS-'foot-bezoar-craving-distrust'}

export DEPLOYMENT_NAME=${PROJECT_NAME}-k8s-${DEPLOYMENT_TYPE}-${REGION}

export CLUSTER_NAME=${DEPLOYMENT_NAME}.k8s.local
export KOPS_BUCKET_NAME=kops-state-${DEPLOYMENT_NAME}

export TERRAFORM_BUCKET_NAME=tf-state-${DEPLOYMENT_NAME}
export TERRAFORM_DYNAMODB_TABLE_NAME=tf-state-${DEPLOYMENT_NAME}

export ROOT_PATH=${ROOT_PATH-$PWD}

export SOURCE_PATH=${ROOT_PATH}/kubernetes/${REGION}/${DEPLOYMENT_TYPE}

export TF_INFRA_PATH=${SOURCE_PATH}/infra
export SPECS_PATH=${SOURCE_PATH}/specs

export KUBECONFIG=${TF_INFRA_PATH}/kubecfg.yaml

export TEMPLATES_PATH=${ROOT_PATH}/templates/kubernetes

export AWS_KEY_NAME=${DEPLOYMENT_NAME}
export PRIVATE_KEY_PATH=${ROOT_PATH}/ssh_keys/${AWS_KEY_NAME}.pem
export PUBLIC_KEY_PATH=${ROOT_PATH}/ssh_keys/${AWS_KEY_NAME}.pub

export DEPLOY_KOPS_BUCKET='true'
export DESTROY_KOPS_BUCKET='false'

export DEPLOY_REMOTE_STATE='true'
export DESTROY_REMOTE_STATE='false'

export DEPLOY_KEY_PAIR='true'
export DESTROY_KEY_PAIR='false'

export LEGACY_DEPLOYMENT_NAME=${PROJECT_NAME}-legacy-${DEPLOYMENT_TYPE}-${REGION}

export USE_RDS=${USE_RDS-'false'}