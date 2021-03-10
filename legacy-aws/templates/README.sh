#!/bin/bash

set -e

docker build -t legacy-devops -f devops-image/Dockerfile devops-image

export AWS_ACCESS_KEY_ID='AWSACCESSKEYID'
export AWS_SECRET_ACCESS_KEY='AWSSECRETACCESSKEY'

export REGION='AWSREGION'
export R53_ZONE='R53ZONE'
export DEPLOYMENT_TYPE='DEPLOYMENTTYPE'
export AWS_KEY_NAME='AWSKEYNAME'

docker run -v $PWD:/src \
  -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e REGION \
  -e DEPLOYMENT_TYPE -e R53_ZONE -e AWS_KEY_NAME \
  -e COLOR='DEPL_ON_CLR' \
  -e MODE='deploy-color' \
  legacy-devops bash /src/scripts/aws/deploy-legacy-aws.sh


# scp -oStrictHostKeyChecking=no -i vm-data/stellarbot-keys/AWSKEYNAME.pem -r conf ubuntu@COLOR_WEB_DNS:/home/ubuntu
# scp -oStrictHostKeyChecking=no -i vm-data/stellarbot-keys/AWSKEYNAME.pem scripts/aws/provision_legacy_web_server.sh ubuntu@COLOR_WEB_DNS:/home/ubuntu
# scp -oStrictHostKeyChecking=no -i vm-data/stellarbot-keys/AWSKEYNAME.pem vm-data/stellarbot-keys/stellarbot_cloud_credentials.yml ubuntu@COLOR_WEB_DNS:/home/ubuntu
# scp -oStrictHostKeyChecking=no -i vm-data/stellarbot-keys/AWSKEYNAME.pem vm-data/stellarbot-keys/stellarbot_github_private_key ubuntu@COLOR_WEB_DNS:/home/ubuntu
# scp -oStrictHostKeyChecking=no -i vm-data/stellarbot-keys/AWSKEYNAME.pem vm-data/stellarbot-keys/AWSKEYNAME.pem ubuntu@COLOR_WEB_DNS:/home/ubuntu
# ssh -oStrictHostKeyChecking=no -i vm-data/stellarbot-keys/AWSKEYNAME.pem ubuntu@COLOR_WEB_DNS
# sudo su
# export HOSTNAME=stellarbot-web-DEPLOYMENTTYPE-DEPL_ON_CLR \
#  && export HOST_IP=COLOR_WEB_IP \
#  && export MONGO_ADDRESS=COLOR_MONGO_PRIVATE \
#  && bash /home/ubuntu/provision_legacy_web_server.sh


docker run -v $PWD:/src \
  -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e REGION \
  -e DEPLOYMENT_TYPE -e R53_ZONE -e AWS_KEY_NAME \
  -e COLOR='DEPL_ON_CLR' \
  -e MODE='attach-color' \
  legacy-devops bash /src/scripts/aws/deploy-legacy-aws.sh

docker run -v $PWD:/src \
  -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e REGION \
  -e DEPLOYMENT_TYPE -e R53_ZONE -e AWS_KEY_NAME \
  -e COLOR='DEPL_ON_CLR' \
  -e MODE='destroy-off-color' \
  legacy-devops bash /src/scripts/aws/deploy-legacy-aws.sh
