#======================================================================================================
# 1) log into AWS with root user
# 2) create `devops-toolkit-api` user, with full admin programmatic access, download API keys
# 3) create `devops-toolkit-console` user, with full admin console access, log into AWS console
# 4) create Route53 hosted zone for [domain].com, note Zone-ID
# 5) create certificate for zone and region, note cert ARN
#======================================================================================================


# -----
# environment variables:

export AWS_ACCESS_KEY_ID=[...]
export AWS_SECRET_ACCESS_KEY=[...]

export SOURCE_PATH=/src/kubernetes/us-east-2/dev
export DOMAIN=example.com

export VIEWERUSER_PASSWORD=[...]
export TESTERUSER_PASSWORD=[...]
export SUPERUSER_PASSWORD=[...]
export RABBITMQ_DEFAULT_PASS=[...]
export POSTGRES_PASSWORD=[...]

export WORKER_REPLICAS=1

export IMAGE_TAG=test-tag
export STACK_NAME=test-stack


#####


# ----- this command builds all the required docker images
bash bash-scripts/images/build-docker-images.sh


# ----- run local image tests
bash bash-scripts/testing/test-local-image-docker-compose-stack.sh


# ----- push docker images to ECR repos
docker run --rm \
  --name devops_image_push \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $PWD:/src \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  -e IMAGE_TAG \
  devops bash /src/bash-scripts/images/push-docker-images.sh


# ----- run tagged image tests
docker run --rm \
  --name devops_image_test \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $PWD:/src \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  -e IMAGE_TAG \
  devops bash /src/bash-scripts/testing/test-tagged-image-docker-compose-stack.sh

#####

# ----- devops image terminal
docker run --rm -it \
  --name devops_terminal \
  -v $PWD:/src \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  -e KEY_ENCRYPTION_PASSPHRASE \
  -e SOURCE_PATH \
  -e IMAGE_TAG \
  -e STACK_NAME \
  -e POSTGRES_PASSWORD \
  -e RABBITMQ_DEFAULT_PASS \
  -e SUPERUSER_PASSWORD \
  -e TESTERUSER_PASSWORD \
  -e VIEWERUSER_PASSWORD \
  devops bash

#####

# ----- deploy cluster (takes awhile)
docker run --rm \
  --name devops_deploy_cluster \
  -v $PWD:/src \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  -e KEY_ENCRYPTION_PASSPHRASE \
  -e SOURCE_PATH \
  -e POSTGRES_PASSWORD \
  devops bash bash-scripts/k8s-clusters/deploy-cluster.sh


# ----- destroy cluster (takes awhile)
docker run --rm \
  --name devops_destroy_cluster\
  -v $PWD:/src \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  -e SOURCE_PATH \
  devops bash /src/bash-scripts/k8s-clusters/destroy-cluster.sh

#####

# ----- deploy app stack (deploy is fast but it takes a few minutes for the stack to spin up)
docker run --rm \
  --name devops_deploy_app_stack \
  -v $PWD:/src \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  -e SOURCE_PATH \
  -e IMAGE_TAG \
  -e STACK_NAME \
  -e POSTGRES_PASSWORD \
  -e RABBITMQ_DEFAULT_PASS \
  -e SUPERUSER_PASSWORD \
  -e TESTERUSER_PASSWORD \
  -e VIEWERUSER_PASSWORD \
  -e WORKER_REPLICAS \
  devops bash /src/bash-scripts/app-stacks/deploy-k8s-app-stack.sh


# RDS deployment (careful!!)
docker run --rm \
  --name devops_deploy_app_stack_rds \
  -v $PWD:/src \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  -e SOURCE_PATH \
  -e IMAGE_TAG \
  -e STACK_NAME \
  -e POSTGRES_PASSWORD \
  -e RABBITMQ_DEFAULT_PASS \
  -e SUPERUSER_PASSWORD \
  -e TESTERUSER_PASSWORD \
  -e VIEWERUSER_PASSWORD \
  -e WORKER_REPLICAS \
  devops bash /src/bash-scripts/app-stacks/deploy-k8s-app-stack-rds.sh


# ----- test app stack
sleep 180

docker run --rm \
    --name stacktester_remote \
    -e SERVICE="https://${STACK_NAME}.${DOMAIN-sloanahrens.com}/api/v0.1" \
    -e TESTERUSER_PASSWORD \
    stacktest ./integration-tests.sh


# ----- destroy app stack
docker run --rm \
  --name devops_destroy_app_stack \
  -v $PWD:/src \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  -e STACK_NAME \
  -e SOURCE_PATH \
  devops bash /src/bash-scripts/app-stacks/destroy-k8s-app-stack.sh

#####

# ----- CircleCI job base-image is the devops image
docker tag devops sloanahrens/devops-toolkit-ci-dev-env:0.3
docker push sloanahrens/devops-toolkit-ci-dev-env:0.3

#####



###############################
# run local docker-compose dev stack:
#####
docker-compose -f devflow/docker-compose-local-dev.yaml up

# kill stack when finished:
docker-compose -f devflow/docker-compose-local-dev.yaml down --remove-orphans

# "SSH" into running baseimage:
docker exec -it local_dev_baseimage bash




# legacy (non-k8s) aws ec2 deployment with docker-compose
docker run \
  --name devops_deploy_legacy \
  -v $PWD:/src \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  -e POSTGRES_PASSWORD \
  -e RABBITMQ_DEFAULT_PASS \
  -e SUPERUSER_PASSWORD \
  -e TESTERUSER_PASSWORD \
  -e VIEWERUSER_PASSWORD \
  devops bash /src/bash-scripts/legacy/deploy-docker-compose-ec2-rds-stack.sh
#####

# ### destroy legacy stack
docker run \
  --name devops_destroy_legacy \
  -v $PWD:/src \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  devops bash /src/bash-scripts/legacy/destroy-legacy-stack.sh
#####


