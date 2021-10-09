#!/bin/bash

set -x
set -e

# docker kill stacktester   # if it hangs and you don't want to wait

echo "Starting: `date`"

DOMAIN=${DOMAIN-sloanahrens.com}

docker run --rm \
    --name stacktester \
    -e SERVICE="https://${STACK_NAME}.${DOMAIN}/api/v0.1" \
    -e TESTERUSER_PASSWORD \
    stacktest ./integration-tests.sh

echo "Finished: `date`"