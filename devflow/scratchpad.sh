#======================================================================================================
# 1) log into AWS with root user
# 2) create `devops-toolkit-api` user, with full admin programmatic access, download API keys
# 3) create `devops-toolkit-console` user, with full admin console access, log into AWS console
# 4) create Route53 hosted zone for [domain].com, note Zone-ID
# 5) create certificate for zone and region, note cert ARN
# 6) create ECR docker-image registry, note ECR-ID and REGION
# 7) create EC2 key-pair, download .pem file to kubernetes/keys folder in repo, note key-name
#======================================================================================================


# -----
# environment variables:

export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...

export SOURCE_PATH=/src/kubernetes/us-east-2/dev

export TESTERUSER_PASSWORD=...
export SUPERUSER_PASSWORD=...
export RABBITMQ_DEFAULT_PASS=...
export POSTGRES_PASSWORD=...

export IMAGE_TAG=testtag
export STACK_NAME=teststack

#####
# ----- DANGER! - this deletes all docker images and volumes from local machine
# docker system prune -af --volumes
#####

#####

# ----- this command builds all the required docker images
bash bash-scripts/images/build-docker-images.sh


# ----- run local image tests
bash bash-scripts/testing/test-local-image-docker-compose-stack.sh


# ----- push docker images to ECR repos
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $PWD:/src \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  -e IMAGE_TAG \
  devops bash /src/bash-scripts/images/push-docker-images.sh


# ----- run tagged image tests
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $PWD:/src \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  -e IMAGE_TAG \
  devops bash /src/bash-scripts/testing/test-tagged-image-docker-compose-stack.sh

#####

# ----- devops image terminal
docker run --rm -it \
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
  devops bash

#####

# ----- deploy cluster (takes awhile)
docker run --rm \
  -v $PWD:/src \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  -e SOURCE_PATH \
  devops bash bash-scripts/k8s-clusters/deploy-cluster.sh


# ----- destroy cluster (takes awhile)
docker run --rm \
  -v $PWD:/src \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  -e SOURCE_PATH \
  devops bash /src/bash-scripts/k8s-clusters/destroy-cluster.sh

#####

# ----- deploy app stack (deploy is fast but it takes a few minutes for the stack to spin up)
docker run --rm \
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
  devops bash /src/bash-scripts/app-stacks/deploy-k8s-app-stack.sh


# ----- test app stack
sleep 180 && \
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $PWD:/src \
  -e DOMAIN \
  -e STACK_NAME \
  -e TESTERUSER_PASSWORD \
  devops bash /src/bash-scripts/testing/test-kubernetes-stack.sh


# ----- destroy app stack
docker run --rm \
  -v $PWD:/src \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  -e STACK_NAME \
  -e SOURCE_PATH \
  devops bash /src/bash-scripts/app-stacks/destroy-k8s-app-stack.sh

#####

# # ----- CircleCI job base-image is the devops image
# docker tag devops sloanahrens/devops-toolkit-ci-dev-env
# docker push sloanahrens/devops-toolkit-ci-dev-env

# #####



###############################
# run local docker-compose dev stack:
#####
docker-compose -f devflow/docker-compose-local-dev.yaml up

# kill stack when finished:
docker-compose -f devflow/docker-compose-local-dev.yaml down --remove-orphans

# "SSH" into running baseimage:
docker exec -it local_dev_baseimage bash



# =====


##########
# set up django project:
#####

# run baseimage terminal
docker run -it \
  -v $PWD:/src \
  baseimage bash

# install pip packages
pip install psycopg2 redis celery uwsgi stellar-sdk django==3.1.4 djangorestframework==3.12.2 djangorestframework-simplejwt==4.4.0 pyjwt==1.7.1

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
npm install vuelidate



docker-compose -f devflow/docker-compose-prod-stack.yaml down --remove-orphans
bash bash-scripts/images/build-docker-images.sh
docker-compose -f devflow/docker-compose-prod-stack.yaml up -d
docker run -e SERVICE="localhost:8000" --network container:local_prod_webapp stacktest ./integration-tests.sh
docker-compose -f devflow/docker-compose-prod-stack.yaml down --remove-orphans


docker run -e SERVICE="localhost:8000" --network container:local_prod_webapp stacktest ./integration-tests.sh


