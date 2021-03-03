#!/bin/bash

# setup
source /src/bash-scripts/devops-functions.sh
validate_source_paths
source_cluster_env
validate_aws_config
pull_kube_config
test_for_kube_config

if [ -z "$STACK_NAME" ]; then
  echo "STACK_NAME not set! Exiting."
  exit_with_error
fi

echo "Deleting K8s resources for STACK_NAME: ${STACK_NAME}"
kubectl -n ${STACK_NAME} delete service,deployment,ingress,statefulset,pod,pvc,cm --all --grace-period=0 --force
kubectl delete ns ${STACK_NAME}  --ignore-not-found=true

aws route53 list-resource-record-sets  --hosted-zone-id ${R53_HOSTED_ZONE} | jq -c '.ResourceRecordSets[]' |
while read -r resourcerecordset; do
  read -r name type <<<$(echo $(jq -r '.Name,.Type' <<<"$resourcerecordset"))
  if [[ $name = ${STACK_NAME}* ]]; then
        echo "Deleting Route53 records for STACK_NAME: ${STACK_NAME}"
        aws route53 change-resource-record-sets \
          --hosted-zone-id ${R53_HOSTED_ZONE} \
          --change-batch '{"Changes":[{"Action":"DELETE","ResourceRecordSet":
              '"$resourcerecordset"'
            }]}' \
          --output text --query 'ChangeInfo.Id'
  fi
done