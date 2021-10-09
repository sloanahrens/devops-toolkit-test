#!/bin/bash
# set -x

function exit_with_error {
    echo 'TESTFAIL'
    exit 1
}

function wait_for_and_test_endpoint {
    period=10
    limit=20
    looper=${limit}
    # wait for the app to be all hooked up and working
    url="$1"
    res=$(curl -XGET -s ${url} -H 'Content-Type: application/json' -H 'Accept: application/json' -H 'Cache-Control: no-cache' -H "Authorization: Bearer ${ACCESS_TOKEN}")
    status=$(echo ${res} | jq '.status' || echo 'nada')
    while [[ "$status" != '"healthy"' ]]; do
        echo "url: $url; res: $res; status: $status"
        if [[ $(($looper+0)) == 0 ]]; then
            echo "URL: \"$url\" Response: \"$res\""
            echo "Timeout waiting for health of \"$url\" after $(($limit * $period)) seconds!"
            exit 1
        fi
        looper=$(($looper-1))
        echo "Sleeping $period seconds [$(($limit-$looper))/$limit]..."
        sleep ${period}

        res=$(curl -X POST -s ${SERVICE}/api/token/refresh -d "{\"refresh\": \"${REFRESH_TOKEN}\"}" -H 'Content-Type: application/json' -H 'Accept: application/json' -H 'Cache-Control: no-cache')
        echo "$res"
        ACCESS_TOKEN=$(echo ${res} | jq -r '.access')

        res=$(curl -XGET -s ${url} -H 'Content-Type: application/json' -H 'Accept: application/json' -H 'Cache-Control: no-cache' -H "Authorization: Bearer ${ACCESS_TOKEN}")
        status=$(echo ${res} | jq '.status' || echo 'nada')
    done
    echo "url: $url; res: $res; status: $status"
    if [[ ${status} == 'nada' || ${status} != '"healthy"' ]]; then
      echo "Test Fail: $url; Expected:'"healthy"'; Actual:$status"
      exit 1
    else
      echo "Test Pass: $1"
    fi
}

function test_jwt_tokens {
    
    echo "ACCESS_TOKEN: ${ACCESS_TOKEN}"
    if [[ "${ACCESS_TOKEN}" == null ]]; then
        echo -e "** Error: ACCESS_TOKEN empty!"
        exit_with_error
    fi
    LENGTH=${#ACCESS_TOKEN}
    # echo "ACCESS_TOKEN length: ${LENGTH}"
    if [[ ${LENGTH} != 205 ]]; then
        echo -e "** Error: ACCESS_TOKEN length wrong! **\n - Expected 205\n - Got ${LENGTH}"
        exit_with_error
    fi

    echo "REFRESH_TOKEN: ${REFRESH_TOKEN}"
    if [[ "${REFRESH_TOKEN}" == null ]]; then
        echo -e "** Error: REFRESH_TOKEN empty!"
        exit_with_error
    fi
    LENGTH=${#REFRESH_TOKEN}
    # echo "REFRESH_TOKEN length: ${LENGTH}"
    if [[ ${LENGTH} != 207 ]]; then
        echo -e "** Error: REFRESH_TOKEN length wrong! **\n - Expected 207\n - Got ${LENGTH}"
        exit_with_error
    fi
    echo "API JWT token tests passed!"
    echo "-----"
    #####
}


echo "-----"
echo "SERVICE: ${SERVICE}"
echo "-----"

#####
# test API token with stacktester user
PASSWORD=${TESTERUSER_PASSWORD-'boatymcboatface'}
USERNAME=stacktester
echo "${USERNAME}:${PASSWORD}"

res=$(curl -X POST -s ${SERVICE}/api/token -d "{\"username\": \"${USERNAME}\", \"password\": \"${PASSWORD}\"}" -H 'Content-Type: application/json' -H 'Accept: application/json' -H 'Cache-Control: no-cache')
echo "$res"

REFRESH_TOKEN=$(echo ${res} | jq -r '.refresh')
ACCESS_TOKEN=$(echo ${res} | jq -r '.access')

echo "get tokens test..."
test_jwt_tokens

sleep 1

res=$(curl -X POST -s ${SERVICE}/api/token/refresh -d "{\"refresh\": \"${REFRESH_TOKEN}\"}" -H 'Content-Type: application/json' -H 'Accept: application/json' -H 'Cache-Control: no-cache')
echo "$res"

ACCESS_TOKEN=$(echo ${res} | jq -r '.access')

echo "refresh token test..."
test_jwt_tokens

wait_for_and_test_endpoint "${SERVICE}/health/app/"
wait_for_and_test_endpoint "${SERVICE}/health/database/"
wait_for_and_test_endpoint "${SERVICE}/health/celery/"
wait_for_and_test_endpoint "${SERVICE}/health/data/"

echo "Basic integration tests passed!"
echo "-----"
