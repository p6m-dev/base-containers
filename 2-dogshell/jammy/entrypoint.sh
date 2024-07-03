#!/usr/bin/env bash

# Validate the environment variables

# If the DATADOG_CROSSPLANE_CONFIG environment variable is set, the necessary environment variables will be extracted
# from the given JSON string.
if [ -v "DATADOG_CROSSPLANE_CONFIG" ]; then
  export DD_API_KEY=$(echo $DATADOG_CROSSPLANE_CONFIG | jq -r '.api_key')
  export DD_APP_KEY=$(echo $DATADOG_CROSSPLANE_CONFIG | jq -r '.app_key')
  export DATADOG_HOST=$(echo $DATADOG_CROSSPLANE_CONFIG | jq -r '.api_url')
fi

if [ -z "$DD_API_KEY" ]; then
  echo "Set DD_API_KEY environment variable"
  exit 1
fi

if [ -z "$DD_APP_KEY" ]; then
  echo "Set DD_APP_KEY environment variable"
  exit 1
fi

if [ -z "$DATADOG_HOST" ]; then
  echo "Set DATADOG_HOST environment variable"
  exit 1
fi

# Pass all arguments to the Datadog CLI
dog "$@"
exit $?
