#!/bin/bash

function exit_with_error {
    echo 'Deployment failed!'
    remove_cluster_updating_status
    exit 1
}

function run_setup {
    source_cluster_env
    validate_source_paths
    validate_cluster_bucket
    validate_aws_config
}

function validate_source_paths {
    echo "SOURCE_PATH: ${SOURCE_PATH}"
    if [ ! -d "${SOURCE_PATH}" ]; then
        echo "*** Source-path ${SOURCE_PATH} does not exist! Exiting."
        exit_with_error
    fi
    if [ ! -d "${SOURCE_PATH}/cluster" ]; then
        echo "*** Cluster-path ${SOURCE_PATH}/cluster does not exist! Creating."
        mkdir -p ${SOURCE_PATH}/cluster
    fi
    if [ ! -d "${SOURCE_PATH}/specs" ]; then
        echo "*** Specs-path ${SOURCE_PATH}/specs does not exist! Creating."
        mkdir -p ${SOURCE_PATH}/specs
    fi
    if [ ! -d "${SOURCE_PATH}/remote-state" ]; then
        echo "*** Remote-state-path ${SOURCE_PATH}/remote-state does not exist! Creating."
        mkdir -p ${SOURCE_PATH}/remote-state
    fi
}

function source_cluster_env {
    if [ ! -f "${SOURCE_PATH}/environment.sh" ]; then
        echo "SOURCE_PATH: ${SOURCE_PATH}"
        echo "*** Environment file ${SOURCE_PATH}/cluster/config.sh does not exist! Exiting."
        exit_with_error
    fi
    source ${SOURCE_PATH}/environment.sh
}

function validate_cluster_bucket {
    if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
        echo "** Bucket ${BUCKET_NAME} found."
    else
        echo "*** Bucket ${BUCKET_NAME} does not exist! Exiting."
        exit_with_error
    fi
}

function validate_aws_config {
    if test -z "${AWS_ACCESS_KEY_ID}"; then
          echo "*** AWS_ACCESS_KEY_ID not found! Exiting."
          exit_with_error
    fi
    if test -z "${AWS_SECRET_ACCESS_KEY}"; then
          echo "*** AWS_SECRET_ACCESS_KEY not found! Exiting."
          exit_with_error
    fi
}

function test_for_kube_config {
    if [ ! -f "${KUBECONFIG}" ]; then
        echo "** Kube-config file ${KUBECONFIG} not found! Exiting."
        exit_with_error
    fi
}

function pull_kube_config {
    totalFoundObjects=$(aws s3 ls s3://${BUCKET_NAME}/kubecfg.yaml --summarize | grep "Total Objects: " | sed 's/[^0-9]*//g')
    if [ "$totalFoundObjects" -eq "0" ]; then
        echo "** kubecfg.yaml not found in ${BUCKET_NAME}."
        if [ -f "${KUBECONFIG}" ]; then
            rm ${KUBECONFIG}
        fi
    else
        aws s3 cp s3://${BUCKET_NAME}/kubecfg.yaml ${KUBECONFIG} >/dev/null
    fi
}

function delete_kube_config {
    totalFoundObjects=$(aws s3 ls s3://${BUCKET_NAME}/kubecfg.yaml --summarize | grep "Total Objects: " | sed 's/[^0-9]*//g')
    if [ "$totalFoundObjects" -eq "0" ]; then
        echo "** kubecfg.yaml not found in ${BUCKET_NAME}."
    else
        aws s3 rm s3://${BUCKET_NAME}/kubecfg.yaml
    fi
    if [ -f "${KUBECONFIG}" ]; then
        rm ${KUBECONFIG}
    fi
}

function test_cluster_updating_status_file_exists {
    # hack I found on SO for checking if a file exists in S3; returns file count
    aws s3 ls s3://${BUCKET_NAME}/cluster_updating_status.txt --summarize | grep "Total Objects: " | sed 's/[^0-9]*//g'
}

function wait_for_external_update {
    limit=15
    looper=${limit}
    fileCount=$(test_cluster_updating_status_file_exists)
    while [[ "$fileCount" != "0" ]]; do
        if [[ $(($looper+0)) == 0 ]]; then
            echo "Timeout after ${limit} minutes!"
            exit_with_error
        fi
        looper=$(($looper-1))
        aws s3 cp s3://${BUCKET_NAME}/cluster_updating_status.txt ${SOURCE_PATH}/cluster_updating_status.txt >/dev/null
        echo "** Cluster ${CLUSTER_NAME} is currently updating, as of: $(cat ${SOURCE_PATH}/cluster_updating_status.txt). Current time: `date`. Sleeping 1 minute ($(($limit-$looper))/$limit)..."
        sleep 60
        fileCount=$(test_cluster_updating_status_file_exists)
    done
}

function set_cluster_updating_status {
    # delete local update file if exists
    if [ -f "${SOURCE_PATH}/cluster_updating_status.txt" ]; then
        rm ${SOURCE_PATH}/cluster_updating_status.txt
    fi
    fileCount=$(test_cluster_updating_status_file_exists)
    if [ "$fileCount" != "0" ]; then
        # if the cluster is already being updated, wait for it to finish and then exit
        wait_for_external_update
        echo "** External update complete. Exiting."
        exit 0
    else
        echo `date` > ${SOURCE_PATH}/cluster_updating_status.txt
        aws s3 cp ${SOURCE_PATH}/cluster_updating_status.txt s3://${BUCKET_NAME}/cluster_updating_status.txt >/dev/null
    fi
}

function remove_cluster_updating_status {
    fileCount=$(test_cluster_updating_status_file_exists)
    if [ "$fileCount" != "0" ]; then
        aws s3 rm s3://${BUCKET_NAME}/cluster_updating_status.txt
    fi
    if [ -f "${SOURCE_PATH}/cluster_updating_status.txt" ]; then
        rm ${SOURCE_PATH}/cluster_updating_status.txt
    fi
}

function show_cluster_env {
    echo "----------"
    echo "R53_HOSTED_ZONE: ${R53_HOSTED_ZONE}"
    echo "REGION: ${REGION}"
    echo "CLUSTER_TYPE: ${CLUSTER_TYPE}"
    echo "CLUSTER_NAME: ${CLUSTER_NAME}"
    echo "BUCKET_NAME: ${BUCKET_NAME}"
    echo "MASTER_ZONES: ${MASTER_ZONES}"
    echo "NODE_ZONES: ${NODE_ZONES}"
    echo "MASTER_SIZE: ${MASTER_SIZE}"
    echo "NODE_SIZE: ${NODE_SIZE}"
    echo "MASTER_COUNT: ${MASTER_COUNT}"
    echo "NODE_COUNT: ${NODE_COUNT}"
    echo "SOURCE_PATH: ${SOURCE_PATH}"
    echo "----------"
}

function test_tests_running_status_file_exists {
    # hack I found on SO for checking if a file exists in S3; returns file count
    aws s3 ls s3://${BUCKET_NAME}/tests_running_status.txt --summarize | grep "Total Objects: " | sed 's/[^0-9]*//g'
}

function wait_for_external_tests_to_complete {
    limit=25
    looper=${limit}
    fileCount=$(test_tests_running_status_file_exists)
    while [[ "$fileCount" != "0" ]]; do
        if [[ $(($looper+0)) == 0 ]]; then
            echo "Timeout after ${limit} minutes!"
            exit_with_error
        fi
        looper=$(($looper-1))
        aws s3 cp s3://${BUCKET_NAME}/tests_running_status.txt ${SOURCE_PATH}/tests_running_status.txt >/dev/null
        echo "** Another test-run is currently underway, as of: $(cat ${SOURCE_PATH}/tests_running_status.txt). Current time: `date`. Sleeping 1 minute ($(($limit-$looper))/$limit)..."
        sleep 60
        fileCount=$(test_tests_running_status_file_exists)
    done
}

function set_tests_running_status {
    # delete local update file if exists
    if [ -f "${SOURCE_PATH}/tests_running_status.txt" ]; then
        rm ${SOURCE_PATH}/tests_running_status.txt
    fi
    fileCount=$(test_tests_running_status_file_exists)
    if [ "$fileCount" != "0" ]; then
        # if the cluster is already being updated, wait for it to finish
        wait_for_external_tests_to_complete
        echo "** External test-run complete. Continuing."
    else
        echo `date` > ${SOURCE_PATH}/tests_running_status.txt
        aws s3 cp ${SOURCE_PATH}/tests_running_status.txt s3://${BUCKET_NAME}/tests_running_status.txt >/dev/null
    fi
}

function remove_tests_running_status {
    fileCount=$(test_tests_running_status_file_exists)
    if [ "$fileCount" != "0" ]; then
        aws s3 rm s3://${BUCKET_NAME}/tests_running_status.txt
    fi
    if [ -f "${SOURCE_PATH}/tests_running_status.txt" ]; then
        rm ${SOURCE_PATH}/tests_running_status.txt
    fi
}
