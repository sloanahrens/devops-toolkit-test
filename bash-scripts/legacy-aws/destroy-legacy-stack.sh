#!/bin/bash

set -e
set -x

cd /src/legacy-aws/${REGION}/${DEPLOYMENT_TYPE}

terraform destroy --auto-approve
