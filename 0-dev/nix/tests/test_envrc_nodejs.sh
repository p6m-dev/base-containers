#!/usr/bin/env bash
# Test .envrc environment with Node.js project

echo "Testing .envrc environment with Node.js project..."

# Debug: Check current directory and files
echo "Current directory: $(pwd)"
echo "Files in current directory:"
ls -la
echo "Files in nodejs-project subdirectory:"
ls -la nodejs-project/ || echo "nodejs-project directory not found"

# Should have jq available from base packages
if command -v jq >/dev/null 2>&1; then
    echo "✓ jq is available in .envrc environment"
else
    echo "✗ jq is NOT available in .envrc environment"
    exit 1
fi

# Should have node available (package.json present)
if command -v node >/dev/null 2>&1; then
    echo "✓ node is available in .envrc environment"
    node_version=$(node --version)
    echo "  Node.js version: $node_version"
else
    echo "✗ node is NOT available in .envrc environment"
    echo "Debugging: PATH is $PATH"
    echo "Debugging: which node returns:"
    which node || echo "node not found"
    exit 1
fi

# Should have npm available (comes with node)
if command -v npm >/dev/null 2>&1; then
    echo "✓ npm is available in .envrc environment"
else
    echo "✗ npm is NOT available in .envrc environment"
    exit 1
fi

echo ".envrc Node.js environment test passed!"