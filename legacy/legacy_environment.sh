#!/bin/bash

#!/bin/bash


export REGION=us-east-2
export DEPLOYMENT_TYPE=prod
export PROJECT_NAME=stellarbot

export DOMAIN=sloanahrens.com
export R53_HOSTED_ZONE=Z1CDZE44WDSMXZ
export SSL_CERT_ARN='arn:aws:acm:us-east-2:421987441365:certificate/a49dc1cf-281f-4abf-a2ca-d79379e2f41b'
export RDS_INSTANCE_TYPE=db.t3.small

export DEPLOYMENT_NAME=${PROJECT_NAME}-legacy-${DEPLOYMENT_TYPE}-${REGION}

export TERRAFORM_BUCKET_NAME=tf-state-${DEPLOYMENT_NAME}
export TERRAFORM_DYNAMODB_TABLE_NAME=tf-state-${DEPLOYMENT_NAME}

export ROOT_PATH=${ROOT_PATH-$PWD}

export SOURCE_PATH=${ROOT_PATH}/legacy/${REGION}/${DEPLOYMENT_TYPE}
export TEMPLATES_PATH=${ROOT_PATH}/templates/legacy

export AWS_KEY_NAME=${DEPLOYMENT_NAME}
export PRIVATE_KEY_PATH=${ROOT_PATH}/ssh_keys/${AWS_KEY_NAME}.pem
export PUBLIC_KEY_PATH=${ROOT_PATH}/ssh_keys/${AWS_KEY_NAME}.pub

export POSTGRES_HOST=postgres-primary.${DEPLOYMENT_NAME}.net

export POSTGRES_PORT=5432
export POSTGRES_USER=${PROJECT_NAME}
export POSTGRES_DB=${PROJECT_NAME}_db
export POSTGRES_VERSION=12.8
export POSTGRES_PASSWORD=${POSTGRES_PASSWORD-'newborn-invasive-optic-croci-moralist-defat-juniper'}

export RABBITMQ_HOST=queue
export RABBITMQ_PORT=5672
export RABBITMQ_DEFAULT_USER=legacy_user
export RABBITMQ_DEFAULT_VHOST=legacy_vhost
export REDIS_HOST=redis
export REDIS_PORT=6379
export REDIS_NAMESPACE=0

export SUPERUSER_PASSWORD=${SUPERUSER_PASSWORD-'wren-landmark-pup-eve'}
export TESTERUSER_PASSWORD=${TESTERUSER_PASSWORD-'entendre-wist-surgeon'}
export VIEWERUSER_PASSWORD=${VIEWERUSER_PASSWORD-'foot-bezoar-craving'}
export POSTGRES_PASSWORD=${POSTGRES_PASSWORD-'purse-scandal-seashore-tights'}
export RABBITMQ_DEFAULT_PASS=${RABBITMQ_DEFAULT_PASS-'foot-bezoar-craving-distrust'}

export DEPLOY_REMOTE_STATE='true'
export DESTROY_REMOTE_STATE='true'

export DEPLOY_KEY_PAIR='true'
export DESTROY_KEY_PAIR='true'

export K8S_CLUSTER_NAME=${DEPLOYMENT_NAME}.k8s.local