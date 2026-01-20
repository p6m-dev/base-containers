#!/bin/sh
set -e

# Wait for token file to be mounted (sometimes takes a moment)
TIMEOUT=30
ELAPSED=0
while [ ! -f "$AZURE_FEDERATED_TOKEN_FILE" ]; do
  if [ $ELAPSED -ge $TIMEOUT ]; then
    echo "ERROR: Timed out waiting for federated token file at $AZURE_FEDERATED_TOKEN_FILE"
    echo "Check that workload identity is properly configured and the azure-identity-token volume is mounted"
    exit 1
  fi
  echo "Waiting for federated token... ($ELAPSED/$TIMEOUT seconds)"
  sleep 1
  ELAPSED=$((ELAPSED + 1))
done

# Authenticate az cli with workload identity
if [ -n "$AZURE_SUBSCRIPTION_ID" ]; then
  az login --federated-token "$(cat $AZURE_FEDERATED_TOKEN_FILE)" \
           --service-principal \
           --username "$AZURE_CLIENT_ID" \
           --tenant "$AZURE_TENANT_ID" \
           --subscription "$AZURE_SUBSCRIPTION_ID"
else
  az login --federated-token "$(cat $AZURE_FEDERATED_TOKEN_FILE)" \
           --service-principal \
           --username "$AZURE_CLIENT_ID" \
           --tenant "$AZURE_TENANT_ID" \
           --allow-no-subscriptions
fi

# Now run whatever your actual workload is
exec "$@"
