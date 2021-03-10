#!/bin/bash

set -e
set -x

# environment
DEPLOYMENT_TYPE=${DEPLOYMENT_TYPE-legacy-staging}
REGION=${REGION-us-east-1}
COLOR=${COLOR-blue}
MODE=${MODE-deploy-color}
AWS_KEY_NAME=${AWS_KEY_NAME-devops-key-${REGION}-${DEPLOYMENT_TYPE}}

if test -z "${AWS_ACCESS_KEY_ID}"; then
      echo "*** AWS_ACCESS_KEY_ID not found! Exiting."
      exit_with_error
fi
if test -z "${AWS_SECRET_ACCESS_KEY}"; then
      echo "*** AWS_SECRET_ACCESS_KEY not found! Exiting."
      exit_with_error
fi

echo "-----"
KEY_PATH="/src/kubernetes/keys/${AWS_KEY_NAME}.pem"
if test -f "${KEY_PATH}"; then
    echo "Key file ${KEY_PATH} found."
else
    echo "*** Key file ${KEY_PATH} does not exist! Exiting. ***"
    exit 1
fi

# S3_STATUS_BUCKET=stellarbot-legacy-blue-green-status

SOURCE_PATH=/src/legacy-aws/${REGION}/${DEPLOYMENT_TYPE}
mkdir -p ${SOURCE_PATH}

if [[ "${COLOR}" == "blue" ]]; then
    OFF_COLOR='green'
elif [[ "${COLOR}" == "green" ]]; then
    OFF_COLOR='blue'
else
    echo "*** COLOR must be 'blue' or 'green'. '${COLOR}' isn't valid. Exiting. ***"
    exit 1
fi

if [[ "${MODE}" != 'deploy-color' && "${MODE}" != 'attach-color' && "${MODE}" != 'destroy-off-color' && "${MODE}" != 'check-colors' ]]; then
    echo "*** MODE must be 'deploy-color', 'attach-color' or 'destroy-off-color'. '${MODE}' isn't valid. Exiting. ***"
    exit 1
fi

echo "-----"
echo "REGION: ${REGION}"
echo "DEPLOYMENT_TYPE: ${DEPLOYMENT_TYPE}"
echo "SOURCE_PATH: ${SOURCE_PATH}"
echo "AWS_KEY_NAME: ${AWS_KEY_NAME}"
echo "COLOR: ${COLOR}"

# active, inactive, destroyed
BLUE_STATUS='destroyed'
GREEN_STATUS='destroyed'

if test -f "${SOURCE_PATH}/blue_status.txt"; then
    BLUE_STATUS=$(cat ${SOURCE_PATH}/blue_status.txt)
fi
if test -f "${SOURCE_PATH}/green_status.txt"; then
    GREEN_STATUS=$(cat ${SOURCE_PATH}/green_status.txt)
fi

echo "BLUE_STATUS: '${BLUE_STATUS}'"
echo "GREEN_STATUS: '${GREEN_STATUS}'"

if [[ "${MODE}" == "attach-color" ]]; then
    if [[ "${COLOR}" == "blue" && "${BLUE_STATUS}" == "destroyed" ]]; then
        echo "*** Cannot attach blue because blue is destroyed! Exiting. ***"
        exit 1
    fi
    if [[ "${COLOR}" == "green" && "${GREEN_STATUS}" == "destroyed" ]]; then
        echo "*** Cannot attach green because green is destroyed! Exiting. ***"
        exit 1
    fi
elif [[ "${MODE}" == "destroy-off-color" ]]; then
    if [[ "${COLOR}" == "blue" && "${BLUE_STATUS}" == "destroyed" ]]; then
        echo "*** Cannot destroy green because blue is destroyed! Exiting. ***"
        exit 1
    fi
    if [[ "${COLOR}" == "green" && "${GREEN_STATUS}" == "destroyed" ]]; then
        echo "*** Cannot destroy blue because green is destroyed! Exiting. ***"
        exit 1
    fi
fi

# this sets up the correct networking for all situations
if [[ "${MODE}" == "deploy-color" ]]; then

    if [[ "${COLOR}" == "blue" ]]; then
        if [[ "${GREEN_STATUS}" == "destroyed" ]]; then
            DNS_COLOR='blue'
        else
            if [[ "${GREEN_STATUS}" == "active" ]]; then
                DNS_COLOR='green'
            else
                DNS_COLOR='blue'
            fi
        fi
    else
        if [[ "${BLUE_STATUS}" == "destroyed" ]]; then
            DNS_COLOR='green'
        else
            if [[ "${BLUE_STATUS}" == "active" ]]; then
                DNS_COLOR='blue'
            else
                DNS_COLOR='green'
            fi
        fi
    fi   

elif [[ "${MODE}" == "attach-color" ]]; then

    DNS_COLOR=${COLOR}

elif [[ "${MODE}" == "destroy-off-color" ]]; then

    DNS_COLOR=${COLOR}
fi

if [[ "${MODE}" != "check-colors" ]]; then

    echo "-----"

    echo "-----"
    echo "Starting Legacy-app AWS deployment, ${COLOR} to ${DEPLOYMENT_TYPE}..."

    # VPC resources
    cat /src/legacy-aws/templates/vpc.tf \
      | sed -e "s@REGION@${REGION}@g" \
      | sed -e "s@DEPLOYMENT_TYPE@${DEPLOYMENT_TYPE}@g" \
      > ${SOURCE_PATH}/vpc.tf

    # core infrastructure 
    cat /src/legacy-aws/templates/core.tf \
      | sed -e "s@COLOR@${COLOR}@g" \
      | sed -e "s@DNS_CLR@${DNS_COLOR}@g" \
      | sed -e "s@REGION@${REGION}@g" \
      | sed -e "s@DEPLOYMENT_TYPE@${DEPLOYMENT_TYPE}@g" \
      | sed -e "s@AWS_KEY_NAME@${AWS_KEY_NAME}@g" \
      | sed -e "s@R53_ZONE@${R53_ZONE}@g" \
      > ${SOURCE_PATH}/${COLOR}.tf

    # # rds resources
    # cat /src/legacy-aws/templates/rds.tf \
    #   | sed -e "s@REGION@${REGION}@g" \
    #   | sed -e "s@DEPLOYMENT_TYPE@${DEPLOYMENT_TYPE}@g" \
    #   | sed -e "s@AWS_KEY_NAME@${AWS_KEY_NAME}@g" \
    #   | sed -e "s@R53_ZONE@${R53_ZONE}@g" \
    #   > ${SOURCE_PATH}/rds.tf

    # output
    cat /src/legacy-aws/templates/output.tf \
      | sed -e "s@COLOR@${COLOR}@g" \
      | sed -e "s@REGION@${REGION}@g" \
      | sed -e "s@DEPLOYMENT_TYPE@${DEPLOYMENT_TYPE}@g" \
      > ${SOURCE_PATH}/output.tf

    # off color servers (destroy if MODE=destroy-old)
    if [[ "${MODE}" == "destroy-off-color" ]]; then
        echo '' > ${SOURCE_PATH}/${OFF_COLOR}.tf
    fi

fi

cd ${SOURCE_PATH}

terraform init

# terraform refresh

terraform plan

# this sets the color status files appropriately
if [[ "${MODE}" != "check-colors" ]]; then

    if [[ "${MODE}" == "deploy-color" ]]; then

        if [[ "${COLOR}" == "blue" ]]; then
            if [[ "${BLUE_STATUS}" == "active" || "${GREEN_STATUS}" == "destroyed" ]]; then
                BLUE_STATUS='active'
            else
                BLUE_STATUS='inactive'
            fi
        else
            if [[ "${GREEN_STATUS}" == "active" || "${BLUE_STATUS}" == "destroyed" ]]; then
                GREEN_STATUS='active'
            else
                GREEN_STATUS='inactive'
            fi
        fi   

    elif [[ "${MODE}" == "attach-color" ]]; then

        if [[ "${COLOR}" == "blue" ]]; then
            BLUE_STATUS='active'
            if [[ "${GREEN_STATUS}" == "active" ]]; then
                GREEN_STATUS='inactive'
            fi
        else
            GREEN_STATUS='active'
            if [[ "${BLUE_STATUS}" == "active" ]]; then
                BLUE_STATUS='inactive'
            fi
        fi 

    elif [[ "${MODE}" == "destroy-off-color" ]]; then

        if [[ "${COLOR}" == "blue" ]]; then
            BLUE_STATUS='active'
            GREEN_STATUS='destroyed'
        else
            GREEN_STATUS='active'
            BLUE_STATUS='destroyed'
        fi 

    fi

    mkdir -p ${SOURCE_PATH}/remote-state
    cat ${ROOT_PATH}/kubernetes/templates/remote_state_resources.tf \
      | sed -e "s@REGION@${REGION}@g" \
      | sed -e "s@CLUSTER_TYPE@${DEPLOYMENT_TYPE}@g" \
      > ${SOURCE_PATH}/remote-state/remote_state_resources.tf
    cd ${SOURCE_PATH}/remote-state
    terraform init
    terraform plan
    # terraform apply --auto-approve

    cat ${ROOT_PATH}/kubernetes/templates/remote_state.tf \
      | sed -e "s@REGION@${REGION}@g" \
      | sed -e "s@CLUSTER_TYPE@${DEPLOYMENT_TYPE}@g" \
      > ${SOURCE_PATH}/remote_state.tf

    # #####
    # cd ${SOURCE_PATH}
    # terraform apply --auto-approve
    # echo "${BLUE_STATUS}" > ${SOURCE_PATH}/blue_status.txt
    # echo "${GREEN_STATUS}" > ${SOURCE_PATH}/green_status.txt
    # #####
fi

echo "-----"
echo "BLUE_STATUS: ${BLUE_STATUS}"
echo "GREEN_STATUS: ${GREEN_STATUS}"
echo "-----"

if [[ "${BLUE_STATUS}" == "active" ]]; then
    CURRENTLY_ACTIVE_COLOR='blue'
elif [[ "${GREEN_STATUS}" == "active" ]]; then
    CURRENTLY_ACTIVE_COLOR='green'
else
    CURRENTLY_ACTIVE_COLOR='NONE'
fi

# extract information from terraform
DEPLOYMENT_INFO=$(terraform output -json)
echo "${DEPLOYMENT_INFO}"

VPC_ID=$(echo ${DEPLOYMENT_INFO} | jq -r ".vpc_id.value")

LEGACY_WEB_PUBLIC_DNS=$(echo ${DEPLOYMENT_INFO} | jq -r ".legacy_web_server_public_dns.value")

BLUE_LEGACY_WEB_IP=$(echo ${DEPLOYMENT_INFO} | jq -r ".blue_legacy_web_server_ip.value")
GREEN_LEGACY_WEB_IP=$(echo ${DEPLOYMENT_INFO} | jq -r ".green_legacy_web_server_ip.value")

BLUE_LEGACY_WEB_PUBLIC_DNS=$(echo ${DEPLOYMENT_INFO} | jq -r ".blue_legacy_web_server_public_dns.value")
GREEN_LEGACY_WEB_PUBLIC_DNS=$(echo ${DEPLOYMENT_INFO} | jq -r ".green_legacy_web_server_public_dns.value")

if [[ "${COLOR}" == "blue" ]]; then
    COLOR_LEGACY_WEB_IP=${BLUE_LEGACY_WEB_IP}
    COLOR_LEGACY_WEB_PUBLIC_DNS=${BLUE_LEGACY_WEB_PUBLIC_DNS}
    OFF_COLOR_LEGACY_WEB_IP=${GREEN_LEGACY_WEB_IP}
    OFF_COLOR_LEGACY_WEB_PUBLIC_DNS=${GREEN_LEGACY_WEB_PUBLIC_DNS}
else
    COLOR_LEGACY_WEB_IP=${GREEN_LEGACY_WEB_IP}
    COLOR_LEGACY_WEB_PUBLIC_DNS=${GREEN_LEGACY_WEB_PUBLIC_DNS}
    OFF_COLOR_LEGACY_WEB_IP=${BLUE_LEGACY_WEB_IP}
    OFF_COLOR_LEGACY_WEB_PUBLIC_DNS=${BLUE_LEGACY_WEB_PUBLIC_DNS}
fi

echo "Deployment finished."
echo "-----"
echo "VPC_ID: ${VPC_ID}"
echo "-----"
echo "BLUE_LEGACY_WEB_IP: ${BLUE_LEGACY_WEB_IP}"
echo "GREEN_LEGACY_WEB_IP: ${GREEN_LEGACY_WEB_IP}"
echo "-----"
echo "MAIN_LEGACY_WEB_PUBLIC_DNS: ${LEGACY_WEB_PUBLIC_DNS}"
echo "CURRENTLY_ACTIVE_COLOR: ${CURRENTLY_ACTIVE_COLOR}"
echo "-----"
echo "BLUE_LEGACY_WEB_PUBLIC_DNS: ${BLUE_LEGACY_WEB_PUBLIC_DNS}"
echo "GREEN_LEGACY_WEB_PUBLIC_DNS: ${GREEN_LEGACY_WEB_PUBLIC_DNS}"
echo "-----"
echo "COLOR_LEGACY_WEB_IP: ${COLOR_LEGACY_WEB_IP}"
echo "-----"
echo "COLOR_LEGACY_WEB_PUBLIC_DNS: ${COLOR_LEGACY_WEB_PUBLIC_DNS}"
echo "-----"

echo ""

