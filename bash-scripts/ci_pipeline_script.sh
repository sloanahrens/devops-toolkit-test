#!/bin/bash

# Exit script when command fails
set -o errexit
# if any of the commands in pipeline fails, script will exit
set -o pipefail

# export AWS_ACCESS_KEY_ID=...
# export AWS_SECRET_ACCESS_KEY=...

echo "-- Building docker images..."
bash scripts/images/build-docker-images.sh

# k8s cluster source
CLUSTER_REGION='us-east-2'
CLUSTER_PATH="kubernetes/${CLUSTER_REGION}/dev"

export SOURCE_PATH="/src/${CLUSTER_PATH}"
echo "SOURCE_PATH: ${SOURCE_PATH}"

export IMAGE_TAG=$(echo "$TRAVIS_BRANCH" | sed 's/[^a-zA-Z0-9]/-/g'| sed -e 's/\(.*\)/\L\1/')
echo "IMAGE_TAG: ${IMAGE_TAG}"

export STACK_NAME="ci-${TRAVIS_BUILD_NUMBER}-${IMAGE_TAG}"
echo "STACK_NAME: ${STACK_NAME}"

echo "-- Running API functional-tests against docker-compose app-stack..."
bash scripts/testing/docker-compose-stack-test.sh

echo "-- Attempting to pull kubeconfig..."
docker run \
  -v $PWD:/src \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  -e SOURCE_PATH \
  devops bash /src/bash-scripts/k8s-clusters/pull-kube-config.sh

if [ ! -f "${CLUSTER_PATH}/cluster/kubecfg.yaml" ]; then
    echo "-- kubeconfig not found, deploying cluster"
    docker run \
      -v $PWD:/src \
      -e AWS_ACCESS_KEY_ID \
      -e AWS_SECRET_ACCESS_KEY \
      -e SOURCE_PATH \
      devops bash /src/scripts/k8s-clusters/deploy-cluster.sh

    # pull kubecfg a second time in case the deployment was aborted due to external update
    echo "-- Attempting to pull kubeconfig (2)..."
    docker run \
      -v $PWD:/src \
      -e AWS_ACCESS_KEY_ID \
      -e AWS_SECRET_ACCESS_KEY \
      -e SOURCE_PATH \
      devops bash /src/scripts/k8s-clusters/pull-kube-config.sh
fi

echo "-- Attempting to validate cluster..."
docker run \
  -v $PWD:/src \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  -e SOURCE_PATH \
  devops bash /src/scripts/k8s-clusters/validate-cluster.sh

echo "-- Pushing docker images to ECR..."
docker run \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $PWD:/src \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  -e IMAGE_TAG \
  devops \
  bash /src/scripts/images/push-images-to-ecr.sh

echo "-- Deploying K8s app-stack to ${CLUSTER_REGION}..."
docker run \
  -v $PWD:/src \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  -e SOURCE_PATH \
  -e CONFIG_PATH='/src/kubernetes/stack-config/test' \
  -e IMAGE_TAG \
  -e STACK_NAME \
  devops bash /src/scripts/app-stacks/deploy-k8s-app-stack.sh

# this is inelegant, but avoids DNS cacheing problems in test script
echo "-- Sleeping 120 seconds..."
sleep 120

echo "-- Running API functional-tests against K8s app-stack..."
docker run \
  -v $PWD:/src \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  -e SOURCE_PATH \
  -e IS_K8S_STACK='yes' \
  -e RUN_ES_TESTS='no' \
  -e API_ENDPOINT="https://${STACK_NAME}.kuberpedia.com/api/v1" \
  -e STACK_NAME \
  --rm devops run-api-tests

echo "-- Destroying app-stack..."
docker run \
  -v $PWD:/src \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  -e IMAGE_TAG \
  -e STACK_NAME \
  -e SOURCE_PATH \
  devops bash /src/scripts/app-stacks/destroy-k8s-app-stack.sh

echo "-- Kubernetes-stack functional tests succeeded."
