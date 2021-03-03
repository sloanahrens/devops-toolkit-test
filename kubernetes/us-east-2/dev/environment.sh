export R53_HOSTED_ZONE=Z1CDZE44WDSMXZ
export DOMAIN_NAME=sloanahrens.com

export ECR_ID=421987441365
export ECR_REGION=us-east-2

export AWS_KEY_NAME=devops-toolkit-key

export SSL_CERT_ARN=arn:aws:acm:us-east-2:421987441365:certificate/b70828c5-7d99-4439-8265-74fd9c852225

export REGION=us-east-2
export CLUSTER_TYPE=dev
export KUBECONFIG=${SOURCE_PATH}/cluster/kubecfg.yaml
export CLUSTER_NAME=stellarbot-${CLUSTER_TYPE}-${REGION}.k8s.local
export BUCKET_NAME=stellarbot-${CLUSTER_TYPE}-k8s-state-${REGION}

export MASTER_ZONES=us-east-2a
export NODE_ZONES=${MASTER_ZONES}
export MASTER_SIZE=r5.xlarge
export NODE_SIZE=r5.large
export MASTER_COUNT=1
export NODE_COUNT=1