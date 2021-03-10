#!/bin/bash

set -x

# docker kill stacktester   # if it hangs and you don't want to wait

echo "Starting: `date`"

docker build -t stacktest -f docker/stacktest/Dockerfile .

docker run -e SERVICE="https://${STACK_NAME}.${DOMAIN}" stacktest ./integration-tests.sh

echo "Finished: `date`"