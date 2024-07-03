#!/usr/bin/env bash

# Validate the environment variables
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
