@TestOn("browser")
import 'package:test/test.dart';

import 'package:keycloak_dart/keycloak.dart';

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
