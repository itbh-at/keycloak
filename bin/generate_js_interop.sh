#!/bin/sh

# This file is part of the Keycloak Dart Adapter
# 
# The Keycloak Dart Adapter is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation; either version 3 of the License, or (at your
# option) any later version.
# 
# This program is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more details.
# 
# You should have received a copy of the GNU Lesser General Public License along
# with this program; if not, write to the Free Software Foundation, Inc., 51
# Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA

KEYCLOAK_TS_BASE_DIR="../../keycloak/adapters/oidc/js/src/main/resources/"
TARGET_FILE="keycloak.d.ts"
TARGET_FILE_PATH="$KEYCLOAK_TS_BASE_DIR$TARGET_FILE"
DESTINATION="../lib/src/js_interop"

echo "$KEYCLOAK_TS_BASE_DIR"
echo "$DESTINATION"

dart_js_facade_gen --destination=$DESTINATION --basePath=$KEYCLOAK_TS_BASE_DIR $TARGET_FILE_PATH