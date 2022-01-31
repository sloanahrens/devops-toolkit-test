FROM python:3.6-buster

ENV PYTHONUNBUFFERED 1

ENV ROOT_PATH /src

WORKDIR /src

RUN echo 'if test -f /src/bash-scripts/devops-functions.sh; then source /src/bash-scripts/devops-functions.sh && source_cluster_env && show_cluster_env; fi' >> /root/.bashrc

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv 5DE6FD698AD6FDD2 \
    && echo "deb http://repo.krakend.io/apt stable main" | tee /etc/apt/sources.list.d/krakend.list \
    && apt-get update \
    && apt-get install -y krakend 

RUN apt-get update -qq \
    && apt-get install -qqy apt-transport-https ca-certificates curl gnupg2 software-properties-common >/dev/null \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - \
    && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" \
    && apt-get update -qq \
    && apt-get install -qqy docker-ce jq vim

RUN pip install awscli psycopg2 sqlalchemy asyncio-nats-streaming yq --upgrade

ENV DOCKER_COMPOSE_VERSION 1.25.5
RUN curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > docker-compose \
    && chmod +x docker-compose \
    && mv docker-compose /usr/local/bin

ENV KUBERNETES_VERSION 1.20.11
RUN curl --silent -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
    && chmod +x ./kubectl \
    && mv ./kubectl /usr/local/bin/

ENV KOPS_VERSION v1.20.1
RUN curl --silent -LO https://github.com/kubernetes/kops/releases/download/${KOPS_VERSION}/kops-linux-amd64 \
    && chmod +x kops-linux-amd64 \
    && mv kops-linux-amd64 /usr/local/bin/kops

ENV TERRAFORM_VERSION 0.15.5
RUN wget --quiet https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    mv terraform /usr/local/bin/ && \
    rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip