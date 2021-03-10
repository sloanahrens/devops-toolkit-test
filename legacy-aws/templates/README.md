## Currently Active Color: CURRENTLY_ACTIVE_COLOR
-----
#### DEPL_ON_CLR Web Server DNS: COLOR_WEB_DNS
#### DEPL_ON_CLR Web Server IP: COLOR_WEB_IP
#### DEPL_ON_CLR Mongo Public DNS: COLOR_MONGO_PUBLIC
#### DEPL_ON_CLR Mongo Private DNS: COLOR_MONGO_PRIVATE
-----
### Steps to deploy DEPL_ON_CLR:

**Step 0a**: `DEPL_OFF_CLR` should already be deployed and working, and hooked to main DNS at [legacy-DEPLOYMENTTYPE-AWSREGION.stellarbot-k8s.net]().

**Step 0b**: Build the `legacy-devops` Docker image with:
```bash
docker build -t legacy-devops -f devops-image/Dockerfile devops-image
```

**Step 0c**: Set environment variables. *Make sure they are correct!*
```bash
# these will stay the same for the entire process
export AWS_ACCESS_KEY_ID='AWSACCESSKEYID'
export AWS_SECRET_ACCESS_KEY='AWSSECRETACCESSKEY'
export REGION='AWSREGION'
export R53_ZONE='R53ZONE'
export DEPLOYMENT_TYPE='DEPLOYMENTTYPE'
export AWS_KEY_NAME='AWSKEYNAME'
```

**Step 1**: Make sure DEPL_ON_CLR servers have been destroyed by running:
```bash
# In this command, COLOR is DEPL_OFF_CLR, so 'destroy-off-color' means destroy DEPL_ON_CLR
docker run -v $PWD:/src \
  -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e REGION \
  -e DEPLOYMENT_TYPE -e R53_ZONE -e AWS_KEY_NAME \
  -e COLOR='DEPL_OFF_CLR' \
  -e MODE='destroy-off-color' \
  legacy-devops bash /src/scripts/aws/deploy-legacy-aws.sh
```

**Step 2**: Deploy unattached (not hooked to main DNS), unprovisioned (provisioning script not yet executed) DEPL_ON_CLR servers with:
```bash
# this deploys blank servers to DEPL_ON_CLR
docker run -v $PWD:/src \
  -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e REGION \
  -e DEPLOYMENT_TYPE -e R53_ZONE -e AWS_KEY_NAME \
  -e COLOR='DEPL_ON_CLR' \
  -e MODE='deploy-color' \
  legacy-devops bash /src/scripts/aws/deploy-legacy-aws.sh
```

```
**Step 11**: Make sure DEPL_ON_CLR works: https://legacy-DEPLOYMENTTYPE-AWSREGION-DEPL_ON_CLR.stellarbot-k8s.net/

**Step 12**: Attach main DNS (https://legacy-DEPLOYMENTTYPE-AWSREGION.stellarbot-k8s.net/) to DEPL_ON_CLR with:
```bash
docker run -v $PWD:/src \
  -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e REGION \
  -e DEPLOYMENT_TYPE -e R53_ZONE -e AWS_KEY_NAME \
  -e COLOR='DEPL_ON_CLR' \
  -e MODE='attach-color' \
  legacy-devops bash /src/scripts/aws/deploy-legacy-aws.sh
```

**Step 13**: Destroy DEPL_OFF_CLR with:
```bash
docker run -v $PWD:/src \
  -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e REGION \
  -e DEPLOYMENT_TYPE -e R53_ZONE -e AWS_KEY_NAME \
  -e COLOR='DEPL_ON_CLR' \
  -e MODE='destroy-off-color' \
  legacy-devops bash /src/scripts/aws/deploy-legacy-aws.sh
```