#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Load libraries
. /opt/bitnami/scripts/libkeycloak-ext.sh

########################
# Configure database settings
#   Overrides: keycloak_configure_database() in libkeycloak-ext.sh
#   Changes: removed conditional on KC_DB
# Globals:
#   KEYCLOAK_*,KC_DB_*
# Arguments:
#   None
# Returns:
#   None
#########################
keycloak_configure_database() {
    local jdbc_params
    jdbc_params="$(echo "$KEYCLOAK_JDBC_PARAMS" | sed -E '/^$|^\&.+$/!s/^/\&/;s/\&/\\&/g')"

    info "Configuring database settings"
    # DEVNOTE: removed conditional on KC_DB # if [[ "$KC_DB" = "postgres" ]]; then
        # Backwards compatibility with old environment variables
        if [[ -z "${KC_DB_URL:-}" ]]; then
            keycloak_conf_set "db-url" "jdbc:${KEYCLOAK_JDBC_DRIVER}://${KEYCLOAK_DATABASE_HOST}:${KEYCLOAK_DATABASE_PORT}/${KEYCLOAK_DATABASE_NAME}?currentSchema=${KC_DB_SCHEMA}${jdbc_params}"
        fi
    # DEVNOTE: removed conditional on KC_DB # fi
}

########################
# Initialize keycloak installation
#   Overrides: keycloak_initialize() in libkeycloak-ext.sh
#   Changes: removed conditional on KC_DB
# Globals:
#   KEYCLOAK_*,KC_*
# Arguments:
#   None
# Returns:
#   None
#########################
keycloak_initialize() {
    # Clean to avoid issues when running docker restart
    # DEVNOTE: removed conditional on KC_DB # if [[ "$KC_DB" = "postgres" ]]; then
        local db_host db_port
        if [[ -z "${KC_DB_URL:-}" ]]; then
            db_host="$KEYCLOAK_DATABASE_HOST"
            db_port="$KEYCLOAK_DATABASE_PORT"
        else
            # Extract host and port from KC_DB_URL
            db_host="$(echo "$KC_DB_URL" | sed -E 's/.*\/\/([^:]+):([0-9]+).*/\1/')"
            db_port="$(echo "$KC_DB_URL" | sed -E 's/.*\/\/[^:]+:([0-9]+).*/\1/')"
        fi
        # Wait for database
        # DEVNOTE: added $KC_DB to info message
        info "Trying to connect to $KC_DB server $db_host..."
        if ! retry_while "wait-for-port --host $db_host --timeout 10 $db_port" "$KEYCLOAK_INIT_MAX_RETRIES"; then
            error "Unable to connect to host $db_host"
            exit 1
        else
            # DEVNOTE: added $KC_DB to info message
            info "Found $KC_DB server listening at $db_host:$db_port"
        fi
    # DEVNOTE: removed conditional on KC_DB # fi
    if ! is_dir_empty "$KEYCLOAK_MOUNTED_CONF_DIR"; then
        cp -Lr "$KEYCLOAK_MOUNTED_CONF_DIR"/* "$KEYCLOAK_CONF_DIR"
        # Add new line to the end of the file to avoid issues when mounting
        # config files with no new line at the end
        echo >> "${KEYCLOAK_CONF_DIR}/${KEYCLOAK_CONF_FILE}"
    fi

    keycloak_configure_database
    true
}
