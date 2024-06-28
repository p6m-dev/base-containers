#!/usr/bin/env bash

if [ -v "ISTIO_ENABLED" ]; then
  until curl -fsI http://localhost:15021/healthz/ready; do
    echo \"Waiting for Istio sidecar...\"
    sleep 3
  done
  echo \"Sidecar available. Running the command...\"
fi

if [ -z "DISTRIBUTION_ID" ]; then
  echo "Set DISTRIBUTION_ID environment variable"
  exit 1
fi

if [ -z "ROLE_ARN" ]; then
  echo "Set ROLE_ARN environment variable"
  exit 1
fi

export WEB_IDENTITY_TOKEN_FILE="/var/run/secrets/tokens/sa-token"

# Assume the role with web identity
assume_role_output=$(aws sts assume-role-with-web-identity \
    --role-arn $ROLE_ARN \
    --role-session-name "invalidate-cloudfront-distribution" \
    --web-identity-token file://$WEB_IDENTITY_TOKEN_FILE \
    --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
    --output text)

# Parse the output into variables
ACCESS_KEY_ID=$(echo $assume_role_output | awk '{print $1}')
SECRET_ACCESS_KEY=$(echo $assume_role_output | awk '{print $2}')
SESSION_TOKEN=$(echo $assume_role_output | awk '{print $3}')

# Export the temporary credentials as environment variables
export AWS_ACCESS_KEY_ID=$ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$SECRET_ACCESS_KEY
export AWS_SESSION_TOKEN=$SESSION_TOKEN

# Perform an AWS CLI action with the temporary credentials
echo "Invalidating CloudFront distribution $DISTRIBUTION_ID"

INVALIDATION_REQUEST=$(aws cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths '/*')
INVALIDATION_ID=$(echo $INVALIDATION_REQUEST | jq --raw-output '.Invalidation.Id')

echo "Invalidation request $INVALIDATION_ID created"

aws cloudfront wait invalidation-completed --distribution-id $DISTRIBUTION_ID --id $INVALIDATION_ID
aws cloudfront get-invalidation --distribution-id $DISTRIBUTION_ID --id $INVALIDATION_ID
RETURN_CODE=$(echo $?)

echo "Invalidation request $INVALIDATION_ID completed"

if [ -v "ISTIO_ENABLED" ]; then
  curl -fsI -X POST http://localhost:15020/quitquitquit
fi

# Unset the environment variables
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN
unset WEB_IDENTITY_TOKEN_FILE

exit $RETURN_CODE
