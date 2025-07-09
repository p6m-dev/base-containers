#!/usr/bin/env bash
# Test default environment (no .envrc)

echo "Testing default environment (no .envrc)..."

# Should have jq available from base packages
if command -v jq >/dev/null 2>&1; then
    echo "✓ jq is available in default environment"
else
    echo "✗ jq is NOT available in default environment"
    exit 1
fi

# Should NOT have node available (no package.json)
if command -v node >/dev/null 2>&1; then
    echo "✗ node is unexpectedly available in default environment"
    exit 1
else
    echo "✓ node is correctly NOT available in default environment"
fi

echo "Default environment test passed!"