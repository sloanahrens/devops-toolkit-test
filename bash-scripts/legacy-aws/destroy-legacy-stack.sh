#!/bin/bash

set -e
set -x


cd /src/legacy-aws/${REGION}/${DEPLOYMENT_TYPE}


terraform init
terraform destroy --auto-approve


SOURCE_PATH=/src/legacy-aws/${REGION}/${DEPLOYMENT_TYPE}


rm -f /src/legacy-aws/${REGION}/${DEPLOYMENT_TYPE}/core.tf

rm -f /src/legacy-aws/${REGION}/${DEPLOYMENT_TYPE}/vpc.tf
rm -f /src/legacy-aws/${REGION}/${DEPLOYMENT_TYPE}/rds.tf
rm -f /src/legacy-aws/${REGION}/${DEPLOYMENT_TYPE}/output.tf
