// This file is part of the Keycloak Dart Adapter
// 
// The Keycloak Dart Adapter is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public License as published
// by the Free Software Foundation; either version 3 of the License, or (at your
// option) any later version.
// 
// This program is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public License along
// with this program; if not, write to the Free Software Foundation, Inc., 51
// Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA

@TestOn("browser")
import 'package:test/test.dart';

import 'package:keycloak/keycloak.dart';

void main() {
  group('Initialization.', () {
    test('Create keycloak instance by config file', () async {
      final keycloak = KeycloakInstance('keycloak.json');
      await keycloak.init(KeycloakInitOptions());

      expect(keycloak.realm, 'demo');
      expect(keycloak.clientId, 'test_alpha');
    });

    test('Create keycloak instance by parameters', () async {
      final keycloak = KeycloakInstance.parameters({
        "realm": "demo",
        "authServerUrl": "http://localhost:8080/auth",
        "clientId": "test_beta"
      });
      await keycloak.init(KeycloakInitOptions());

      expect(keycloak.realm, 'demo');
      expect(keycloak.clientId, 'test_beta');
    });

    test('Create 2 separated instances', () async {
      final keycloakAlpha = KeycloakInstance();
      final keycloakBeta = KeycloakInstance.parameters({
        "realm": "demo",
        "authServerUrl": "http://localhost:8080/auth",
        "clientId": "test_beta"
      });

      await Future.wait([
        keycloakAlpha.init(KeycloakInitOptions()),
        keycloakBeta.init(KeycloakInitOptions())
      ]);

      expect(keycloakAlpha.realm, 'demo');
      expect(keycloakBeta.realm, 'demo');
      expect(keycloakAlpha.clientId, 'test_alpha');
      expect(keycloakBeta.clientId, 'test_beta');
    });
  });
}
