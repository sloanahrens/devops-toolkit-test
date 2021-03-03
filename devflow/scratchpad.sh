# squash commits in branch
git reset --soft HEAD~4 && git commit -m "basic django app with admin views and sample data"


# build devops docker image:
docker build -t devops -f docker/devops-image/Dockerfile .


# AWS creds (I can provide these as needed):
export AWS_ACCESS_KEY_ID=[REPLACE]
export AWS_SECRET_ACCESS_KEY=[REPLACE]
export IMAGE_TAG=test
export STACK_NAME=teststack

# destroy k8s cluster:
docker run \
  -v $PWD:/src \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  devops bash bash-scripts/k8s-clusters/destroy-cluster.sh


# deploy k8s cluster:
docker run \
  -v $PWD:/src \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  devops bash bash-scripts/k8s-clusters/deploy-cluster.sh


# run devops image terminal:
docker run -it \
  -v $PWD:/src \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  devops bash

# build docker images
bash bash-scripts/images/build-docker-images.sh

# push docker images
docker run \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $PWD:/src \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  -e IMAGE_TAG \
  devops \
  bash /src/bash-scripts/images/push-docker-images.sh

# deploy app stack
docker run \
  -v $PWD:/src \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  -e IMAGE_TAG \
  -e STACK_NAME \
  devops bash /src/bash-scripts/app-stacks/deploy-k8s-app-stack.sh

# destroy app stack
docker run \
  -v $PWD:/src \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  -e STACK_NAME \
  devops bash /src/bash-scripts/app-stacks/destroy-k8s-app-stack.sh


###############################
# run docker-compose dev stack:
#####
docker-compose -f devflow/docker-compose-local-dev.yaml up

# kill stack when finished:
docker-compose -f devflow/docker-compose-local-dev.yaml down --remove-orphans

# "SSH" into running baseimage:
docker exec -it local_dev_baseimage bash


################################
# run docker-compose prod stack:
#####
docker-compose -f devflow/docker-compose-prod-stack.yaml up

# kill stack when finished:
docker-compose -f devflow/docker-compose-prod-stack.yaml down --remove-orphans

# "SSH" into running baseimage:
docker exec -it local_dev_baseimage bash


##########
# set up django project:
#####

# run baseimage terminal
docker run -it \
  -v $PWD:/src \
  baseimage bash

# install pip packages
pip install django djangorestframework celery psycopg2 redis

# export python dependency requirements to file
pip freeze > /src/django/requirements.txt

# test requirements file
pip install -r /src/django/requirements.txt

# create django project
django-admin startproject stellarbot

# create api app:
cd stellarbot
python manage.py startapp api


# run django development server (with devops image):
#####

# terminal with port forwarding and docker-in-docker
docker run -it \
  -p 8000:8000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $PWD:/src \
  devops bash

# install pip dependencies:
pip install -r /src/django/requirements.txt

# collect static files (for admin to work):
cd /src/django/stellarbot && python manage.py collectstatic

# run migrations:
cd /src/django/stellarbot && python manage.py migrate

# run dev server:
cd /src/django/stellarbot && python manage.py runserver 0.0.0.0:8000


##################
# set up Vue.js project:
#####
# first install vue cli (https://cli.vuejs.org/), then:
vue create ui
# select: babel, eslint, vuex, router

# run vue dev server (from host os):
cd ui
npm install
npm run serve

npm install axios
npm install ?bootstrap-vue



docker-compose -f devflow/docker-compose-prod-stack.yaml down --remove-orphans
bash bash-scripts/images/build-docker-images.sh
docker-compose -f devflow/docker-compose-prod-stack.yaml up -d
docker run -e SERVICE="localhost:8000" --network container:local_prod_webapp stacktest ./integration-tests.sh
docker-compose -f devflow/docker-compose-prod-stack.yaml down --remove-orphans


docker run -e SERVICE="localhost:8000" --network container:local_prod_webapp stacktest ./integration-tests.sh




#####

export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
export IMAGE_TAG=test
export STACK_NAME=teststack
export SOURCE_PATH=kubernetes/us-east-2/dev

# this is the image used by circleci
docker build -t ci-exec -f docker/ci-executor/Dockerfile .

# this simulates running the pipeline in circleci;
# aws keys will be available in the environment
# IMAGE_TAG will be constructed based on the git commit/branch
# STACK_NAME will be constructed from the CI job ID, and/or other unique parameters
time docker run --rm -it \
 -v /var/run/docker.sock:/var/run/docker.sock \
 -v $PWD:/src \
 -e AWS_ACCESS_KEY_ID \
 -e AWS_SECRET_ACCESS_KEY \
 -e IMAGE_TAG \
 -e STACK_NAME \
 -e SOURCE_PATH \
 ci-exec bash -c "bash bash-scripts/images/build-docker-images.sh \
  && bash bash-scripts/testing/docker-compose-stack-test-local.sh \
  && bash bash-scripts/images/push-docker-images.sh"

time docker run \
  -v $PWD:/src \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  -e SOURCE_PATH \
  devops bash /src/bash-scripts/k8s-clusters/destroy-cluster.sh

time docker run \
  -v $PWD:/src \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  -e SOURCE_PATH \
  devops bash /src/bash-scripts/k8s-clusters/deploy-cluster.sh
