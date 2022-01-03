#!/bin/bash

export REGION=us-east-2
export CLUSTER_TYPE=dev

export PROJECT_NAME=stellarbot

export DOMAIN=sloanahrens.com
export R53_HOSTED_ZONE=Z1CDZE44WDSMXZ
export SSL_CERT_ARN="arn:aws:acm:us-east-2:421987441365:certificate/a49dc1cf-281f-4abf-a2ca-d79379e2f41b"

export KUBECONFIG=${SOURCE_PATH}/cluster/kubecfg.yaml

export CLUSTER_NAME=${PROJECT_NAME}-${REGION}-${CLUSTER_TYPE}.k8s.local
export KOPS_BUCKET_NAME=${PROJECT_NAME}-kops-state-${REGION}-${CLUSTER_TYPE}

export TERRAFORM_BUCKET_NAME=${PROJECT_NAME}-terraform-state-${REGION}-${CLUSTER_TYPE}
export TERRAFORM_DYNAMODB_TABLE_NAME=${PROJECT_NAME}-terraform-state-${REGION}-${CLUSTER_TYPE}

export AWS_KEY_NAME=${PROJECT_NAME}-devops-${REGION}-${CLUSTER_TYPE}
export PRIVATE_KEY_PATH=${ROOT_PATH}/kubernetes/keys/${AWS_KEY_NAME}.pem

export MASTER_ZONES=us-east-2a
export NODE_ZONES=${MASTER_ZONES}
export MASTER_SIZE=r5.xlarge
export NODE_SIZE=r5.large
export MASTER_COUNT=1
export NODE_COUNT=1

# export WORKER_REPLICAS=3

export POSTGRES_HOST=database
export POSTGRES_PORT=5432
export POSTGRES_USER=k8s_user
export POSTGRES_DB=db
export RABBITMQ_HOST=queue
export RABBITMQ_PORT=5672
export RABBITMQ_DEFAULT_USER=k8s_user
export RABBITMQ_DEFAULT_VHOST=k8s_vhost
export REDIS_HOST=redis
export REDIS_PORT=6379
export REDIS_NAMESPACE=0
export SUPERUSER_EMAIL='admin@nowhere.com'

export SUPERUSER_PASSWORD=${SUPERUSER_PASSWORD-'wren-landmark-pup-eve'}
export TESTERUSER_PASSWORD=${TESTERUSER_PASSWORD-'entendre-wist-surgeon'}
export VIEWERUSER_PASSWORD=${VIEWERUSER_PASSWORD-'foot-bezoar-craving'}
export POSTGRES_PASSWORD=${POSTGRES_PASSWORD-'purse-scandal-seashore-tights'}
export RABBITMQ_DEFAULT_PASS=${RABBITMQ_DEFAULT_PASS-'foot-bezoar-craving-distrust'}