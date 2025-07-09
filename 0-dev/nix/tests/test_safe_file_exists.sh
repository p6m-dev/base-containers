#!/usr/bin/env bash
# Test safe file exists functionality

echo "Testing safe file exists functionality..."

# Create a test directory structure
mkdir -p /tmp/test-safe-exists/accessible-dir
mkdir -p /tmp/test-safe-exists/restricted-dir

# Create some test files
echo '{"test": true}' > /tmp/test-safe-exists/accessible-dir/package.json
echo '{"test": true}' > /tmp/test-safe-exists/restricted-dir/package.json

# Make one directory inaccessible
chmod 000 /tmp/test-safe-exists/restricted-dir

# Test from the parent directory
cd /tmp/test-safe-exists

# This should work without permission errors
echo "Testing nix-shell with mixed permissions..."
nix-shell /etc/nix/default.nix --impure --command 'echo "Nix shell loaded successfully"' 2>&1 | head -20

# Check if Node.js was detected from the accessible directory
if nix-shell /etc/nix/default.nix --impure --command 'command -v node' >/dev/null 2>&1; then
    echo "✓ Node.js detected despite permission issues"
else
    echo "✗ Node.js not detected"
fi

# Cleanup
chmod 755 /tmp/test-safe-exists/restricted-dir
rm -rf /tmp/test-safe-exists

echo "Safe file exists test completed!"