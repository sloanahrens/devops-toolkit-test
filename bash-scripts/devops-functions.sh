#!/bin/bash

function exit_with_error {
    echo 'Deployment failed!'
    # remove_cluster_updating_status
    exit 1
}

function show_cluster_env {
    echo "----------"
    echo "R53_HOSTED_ZONE: ${R53_HOSTED_ZONE}"
    echo "REGION: ${REGION}"
    echo "CLUSTER_TYPE: ${CLUSTER_TYPE}"
    echo "CLUSTER_NAME: ${CLUSTER_NAME}"
    echo "KOPS_BUCKET_NAME: ${KOPS_BUCKET_NAME}"
    echo "MASTER_ZONES: ${MASTER_ZONES}"
    echo "NODE_ZONES: ${NODE_ZONES}"
    echo "MASTER_SIZE: ${MASTER_SIZE}"
    echo "NODE_SIZE: ${NODE_SIZE}"
    echo "MASTER_COUNT: ${MASTER_COUNT}"
    echo "NODE_COUNT: ${NODE_COUNT}"
    echo "SOURCE_PATH: ${SOURCE_PATH}"
    echo "----------"
}

function run_setup {
    echo "ROOT_PATH: ${ROOT_PATH}"
    validate_aws_config
    validate_source_paths
    source_cluster_env
    validate_cluster_bucket
}

function validate_source_paths {
    echo "SOURCE_PATH: ${SOURCE_PATH}"
    if [ ! -d "${SOURCE_PATH}" ]; then
        echo "*** Source-path '${SOURCE_PATH}' does not exist! Exiting."
        exit_with_error
    fi
    if [ ! -d "${SOURCE_PATH}/cluster" ]; then
        echo "Creating ${SOURCE_PATH}/cluster..."
        mkdir -p ${SOURCE_PATH}/cluster
    fi
    if [ ! -d "${SOURCE_PATH}/specs" ]; then
        echo "Creating ${SOURCE_PATH}/specs..."
        mkdir -p ${SOURCE_PATH}/specs
    fi
    if [ ! -d "${SOURCE_PATH}/remote-state" ]; then
        echo "Creating ${SOURCE_PATH}/remote-state..."
        mkdir -p ${SOURCE_PATH}/remote-state
    fi
    if [ ! -d "${SOURCE_PATH}/kops-bucket" ]; then
        echo "Creating ${SOURCE_PATH}/kops-bucket..."
        mkdir -p ${SOURCE_PATH}/kops-bucket
    fi
}

function source_cluster_env {
    if [ ! -f "${SOURCE_PATH}/environment.sh" ]; then
        echo "SOURCE_PATH: ${SOURCE_PATH}"
        echo "*** Environment file ${SOURCE_PATH}/environment.sh does not exist! Exiting."
        exit_with_error
    fi
    source ${SOURCE_PATH}/environment.sh
}

function validate_cluster_bucket {
    if aws s3api head-bucket --bucket "${KOPS_BUCKET_NAME}" 2>/dev/null; then
        echo "Bucket ${KOPS_BUCKET_NAME} found."
    else
        echo "*** Bucket ${KOPS_BUCKET_NAME} does not exist!"
        # exit_with_error
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

function validate_ecr_config {
    if test -z "${ECR_REGION}"; then
          echo "*** ECR_REGION not found! Exiting."
          exit_with_error
    fi
    if test -z "${ECR_ID}"; then
          echo "*** ECR_ID not found! Exiting."
          exit_with_error
    fi
    if test -z "${IMAGE_TAG}"; then
          echo "*** IMAGE_TAG not found! Exiting."
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
    totalFoundObjects=$(aws s3 ls s3://${KOPS_BUCKET_NAME}/kubecfg.yaml --summarize | grep "Total Objects: " | sed 's/[^0-9]*//g')
    if [ "$totalFoundObjects" -eq "0" ]; then
        echo "** kubecfg.yaml not found in ${KOPS_BUCKET_NAME}."
        if [ -f "${KUBECONFIG}" ]; then
            rm ${KUBECONFIG}
        fi
    else
        aws s3 cp s3://${KOPS_BUCKET_NAME}/kubecfg.yaml ${KUBECONFIG} >/dev/null
    fi
}

function delete_kube_config {
    totalFoundObjects=$(aws s3 ls s3://${KOPS_BUCKET_NAME}/kubecfg.yaml --summarize | grep "Total Objects: " | sed 's/[^0-9]*//g')
    if [ "$totalFoundObjects" -eq "0" ]; then
        echo "** kubecfg.yaml not found in ${KOPS_BUCKET_NAME}."
    else
        aws s3 rm s3://${KOPS_BUCKET_NAME}/kubecfg.yaml
    fi
    if [ -f "${KUBECONFIG}" ]; then
        rm ${KUBECONFIG}
    fi
}

function delete_versioned_bucket_contents {

        echo "Removing all versions from ${BUCKET}..."
        versions=`aws s3api list-object-versions --bucket ${BUCKET} |jq '.Versions'`
        markers=`aws s3api list-object-versions --bucket ${BUCKET} |jq '.DeleteMarkers'`
        let count=`echo $versions |jq 'length'`-1

        if [ $count -gt -1 ]; then
                echo "removing files"
                for i in $(seq 0 $count); do
                        key=`echo $versions | jq .[$i].Key |sed -e 's/\"//g'`
                        versionId=`echo $versions | jq .[$i].VersionId |sed -e 's/\"//g'`
                        cmd="aws s3api delete-object --bucket ${BUCKET} --key $key --version-id $versionId"
                        echo $cmd
                        $cmd
                done
        fi

        let count=`echo $markers |jq 'length'`-1

        if [ $count -gt -1 ]; then
                echo "removing delete markers"

                for i in $(seq 0 $count); do
                        key=`echo $markers | jq .[$i].Key |sed -e 's/\"//g'`
                        versionId=`echo $markers | jq .[$i].VersionId |sed -e 's/\"//g'`
                        cmd="aws s3api delete-object --bucket ${BUCKET} --key $key --version-id $versionId"
                        echo $cmd
                        $cmd
                done
        fi
}


# #####
# function test_cluster_updating_status_file_exists {
#     # hack I found on SO for checking if a file exists in S3; returns file count
#     aws s3 ls s3://${KOPS_BUCKET_NAME}/cluster_updating_status.txt --summarize | grep "Total Objects: " | sed 's/[^0-9]*//g'
# }

# function wait_for_external_update {
#     limit=15
#     looper=${limit}
#     fileCount=$(test_cluster_updating_status_file_exists)
#     while [[ "$fileCount" != "0" ]]; do
#         if [[ $(($looper+0)) == 0 ]]; then
#             echo "Timeout after ${limit} minutes!"
#             exit_with_error
#         fi
#         looper=$(($looper-1))
#         aws s3 cp s3://${KOPS_BUCKET_NAME}/cluster_updating_status.txt ${SOURCE_PATH}/cluster_updating_status.txt >/dev/null
#         echo "** Cluster ${CLUSTER_NAME} is currently updating, as of: $(cat ${SOURCE_PATH}/cluster_updating_status.txt). Current time: `date`. Sleeping 1 minute ($(($limit-$looper))/$limit)..."
#         sleep 60
#         fileCount=$(test_cluster_updating_status_file_exists)
#     done
# }

# function set_cluster_updating_status {
#     # delete local update file if exists
#     if [ -f "${SOURCE_PATH}/cluster_updating_status.txt" ]; then
#         rm ${SOURCE_PATH}/cluster_updating_status.txt
#     fi
#     fileCount=$(test_cluster_updating_status_file_exists)
#     if [ "$fileCount" != "0" ]; then
#         # if the cluster is already being updated, wait for it to finish and then exit
#         wait_for_external_update
#         echo "** External update complete. Exiting."
#         exit 0
#     else
#         echo `date` > ${SOURCE_PATH}/cluster_updating_status.txt
#         aws s3 cp ${SOURCE_PATH}/cluster_updating_status.txt s3://${KOPS_BUCKET_NAME}/cluster_updating_status.txt >/dev/null
#     fi
# }

# function remove_cluster_updating_status {
#     fileCount=$(test_cluster_updating_status_file_exists)
#     if [ "$fileCount" != "0" ]; then
#         aws s3 rm s3://${KOPS_BUCKET_NAME}/cluster_updating_status.txt
#     fi
#     if [ -f "${SOURCE_PATH}/cluster_updating_status.txt" ]; then
#         rm ${SOURCE_PATH}/cluster_updating_status.txt
#     fi
# }

# function test_tests_running_status_file_exists {
#     # hack I found on SO for checking if a file exists in S3; returns file count
#     aws s3 ls s3://${KOPS_BUCKET_NAME}/tests_running_status.txt --summarize | grep "Total Objects: " | sed 's/[^0-9]*//g'
# }

# function wait_for_external_tests_to_complete {
#     limit=25
#     looper=${limit}
#     fileCount=$(test_tests_running_status_file_exists)
#     while [[ "$fileCount" != "0" ]]; do
#         if [[ $(($looper+0)) == 0 ]]; then
#             echo "Timeout after ${limit} minutes!"
#             exit_with_error
#         fi
#         looper=$(($looper-1))
#         aws s3 cp s3://${KOPS_BUCKET_NAME}/tests_running_status.txt ${SOURCE_PATH}/tests_running_status.txt >/dev/null
#         echo "** Another test-run is currently underway, as of: $(cat ${SOURCE_PATH}/tests_running_status.txt). Current time: `date`. Sleeping 1 minute ($(($limit-$looper))/$limit)..."
#         sleep 60
#         fileCount=$(test_tests_running_status_file_exists)
#     done
# }

# function set_tests_running_status {
#     # delete local update file if exists
#     if [ -f "${SOURCE_PATH}/tests_running_status.txt" ]; then
#         rm ${SOURCE_PATH}/tests_running_status.txt
#     fi
#     fileCount=$(test_tests_running_status_file_exists)
#     if [ "$fileCount" != "0" ]; then
#         # if the cluster is already being updated, wait for it to finish
#         wait_for_external_tests_to_complete
#         echo "** External test-run complete. Continuing."
#     else
#         echo `date` > ${SOURCE_PATH}/tests_running_status.txt
#         aws s3 cp ${SOURCE_PATH}/tests_running_status.txt s3://${KOPS_BUCKET_NAME}/tests_running_status.txt >/dev/null
#     fi
# }

# function remove_tests_running_status {
#     fileCount=$(test_tests_running_status_file_exists)
#     if [ "$fileCount" != "0" ]; then
#         aws s3 rm s3://${KOPS_BUCKET_NAME}/tests_running_status.txt
#     fi
#     if [ -f "${SOURCE_PATH}/tests_running_status.txt" ]; then
#         rm ${SOURCE_PATH}/tests_running_status.txt
#     fi
# }
# #####