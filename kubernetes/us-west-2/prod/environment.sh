#!/bin/bash

export REGION=us-west-2
export CLUSTER_TYPE=prod

export PROJECT_NAME=stellarbot

export DOMAIN=sloanahrens.com
export R53_HOSTED_ZONE=Z1CDZE44WDSMXZ
export SSL_CERT_ARN="arn:aws:acm:us-west-2:421987441365:certificate/0dfb8a7a-74c7-4468-bf08-fd19c49347b5"

export KUBECONFIG=${SOURCE_PATH}/cluster/kubecfg.yaml

export CLUSTER_NAME=${PROJECT_NAME}-${REGION}-${CLUSTER_TYPE}.k8s.local
export KOPS_BUCKET_NAME=${PROJECT_NAME}-kops-state-${REGION}-${CLUSTER_TYPE}

export TERRAFORM_BUCKET_NAME=${PROJECT_NAME}-terraform-state-${REGION}-${CLUSTER_TYPE}
export TERRAFORM_DYNAMODB_TABLE_NAME=${PROJECT_NAME}-terraform-state-${REGION}-${CLUSTER_TYPE}

export AWS_KEY_NAME=${PROJECT_NAME}-devops-${REGION}-${CLUSTER_TYPE}
export PRIVATE_KEY_PATH=${ROOT_PATH}/kubernetes/keys/${AWS_KEY_NAME}.pem

export MASTER_ZONES=us-west-2a
export NODE_ZONES=us-west-2a,us-west-2b

export MASTER_COUNT=1
export NODE_COUNT=2

export MASTER_SIZE=t3.large  # $0.0832/hr
export NODE_SIZE=t3.small  # $0.0208/hr

export DEPLOY_RDS='true'

export RDS_INSTANCE_TYPE=db.t3.small  # $0.036/hr

# = $0.1608/hr ~= $115/mo

export WORKER_REPLICAS=${WORKER_REPLICAS-2}

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

export SUPERUSER_PASSWORD=${SUPERUSER_PASSWORD-'oblong-sorority-nifty-caesar-portrait'}
export TESTERUSER_PASSWORD=${TESTERUSER_PASSWORD-'yanqui-caesar-connect-affected'}
export VIEWERUSER_PASSWORD=${VIEWERUSER_PASSWORD-'ranch-nifty-hawk-gorilla-whoa'}
export POSTGRES_PASSWORD=${POSTGRES_PASSWORD-'backfire-bunny-teacart-portrait'}
export RABBITMQ_DEFAULT_PASS=${RABBITMQ_DEFAULT_PASS-'service-ibid-emirate-humdrum'}
