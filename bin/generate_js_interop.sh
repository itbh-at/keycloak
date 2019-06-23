#!/bin/sh

KEYCLOAK_TS_BASE_DIR="../../keycloak/adapters/oidc/js/src/main/resources/"
TARGET_FILE="keycloak.d.ts"
TARGET_FILE_PATH="$KEYCLOAK_TS_BASE_DIR$TARGET_FILE"
DESTINATION="../lib/src/js_interop"

echo "$KEYCLOAK_TS_BASE_DIR"
echo "$DESTINATION"

dart_js_facade_gen --destination=$DESTINATION --basePath=$KEYCLOAK_TS_BASE_DIR $TARGET_FILE_PATH