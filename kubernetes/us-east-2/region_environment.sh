#!/bin/bash


#####
# PROJECT_NAME, DEPLOYMENT_TYPE and REGION need to be set before this script runs.

export REGION=us-east-2

export R53_HOSTED_ZONE=Z1CDZE44WDSMXZ
export SSL_CERT_ARN="arn:aws:acm:us-east-2:421987441365:certificate/a49dc1cf-281f-4abf-a2ca-d79379e2f41b"

export MASTER_ZONES=us-east-2a
export NODE_ZONES=us-east-2a,us-east-2b
export MASTER_COUNT=1
export NODE_COUNT=2
export MASTER_SIZE=t3.large
export NODE_SIZE=t3.small

export RDS_INSTANCE_TYPE=db.t3.small

export POSTGRES_PORT=5432
export POSTGRES_USER=${PROJECT_NAME}
export POSTGRES_DB=${PROJECT_NAME}_db
export POSTGRES_VERSION=12.8
export POSTGRES_PASSWORD=${POSTGRES_PASSWORD-'newborn-invasive-persona-maiden-asbestos-optic-croci-moralist-defat-juniper'}