#!/usr/bin/env bash

if [ -v "ISTIO_ENABLED" ]; then
  until curl -fsI http://localhost:15021/healthz/ready; do
    echo \"Waiting for Istio sidecar...\"
    sleep 3
  done
  echo \"Sidecar available. Running the command...\"
fi

TARGET_ID=""
if [ -z "DISTRIBUTION_ID" ]; then
  echo "DISTRIBUTION_ID is not set, using domain from argument"

  echo "Invalidating CloudFront distribution for $1"
  DISTRIBUTIONS=$(aws cloudfront list-distributions --query 'DistributionList.Items[*].{Id:Id,Aliases:Aliases.Items[*]}')
  TARGET_DIST=$(echo $DISTRIBUTIONS | jq --raw-output --arg alias "$1" '.[] | select(.Aliases) | select(.Aliases[] == $alias)')
  TARGET_ID=$(echo $TARGET_DIST | jq --raw-output '.Id')

  echo "Found distribution $TARGET_ID for $1"
else
  TARGET_ID=$DISTRIBUTION_ID
fi
echo "Invalidating CloudFront distribution $TARGET_ID"

INVALIDATION_REQUEST=$(aws cloudfront create-invalidation --distribution-id $TARGET_ID --paths '/*')
INVALIDATION_ID=$(echo $INVALIDATION_REQUEST | jq --raw-output '.Invalidation.Id')

echo "Invalidation request $INVALIDATION_ID created"

aws cloudfront wait invalidation-completed --distribution-id $TARGET_ID --id $INVALIDATION_ID
aws cloudfront get-invalidation --distribution-id $TARGET_ID --id $INVALIDATION_ID
x=$(echo $?)

echo "Invalidation request $INVALIDATION_ID completed"

if [ -v "ISTIO_ENABLED" ]; then
  curl -fsI -X POST http://localhost:15020/quitquitquit
fi
exit $x
