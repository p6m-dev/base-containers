#!/bin/bash
# Entrypoint script for nix develop environment

# Source nix profile
source ~/.nix-profile/etc/profile.d/nix.sh

# Execute command in nix develop environment
exec nix develop /ede --command "$@"