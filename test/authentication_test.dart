@TestOn("browser")
import 'package:test/test.dart';

import 'package:keycloak_dart/keycloak.dart';

void main() {
  group('Initialization.', () {
    test('Create keycloak instance by config file', () async {
      final client = KeycloakInstance('keycloak.json');
      await client.init(KeycloakInitOptions());

      expect(client.realm, 'demo');
      expect(client.clientId, 'test_alpha');
    });

    test('Create keycloak instance by parameters', () async {
      final service = KeycloakInstance.parameters({
        "realm": "demo",
        "authServerUrl": "http://localhost:8080/auth",
        "clientId": "test_beta"
      });
      await service.init(KeycloakInitOptions());

      expect(service.realm, 'demo');
      expect(service.clientId, 'test_beta');
    });

    test('Create 2 separated instances', () async {
      final serviceAlpha = KeycloakInstance();
      final serviceBeta = KeycloakInstance.parameters({
        "realm": "demo",
        "authServerUrl": "http://localhost:8080/auth",
        "clientId": "test_beta"
      });

      await Future.wait([
        serviceAlpha.init(KeycloakInitOptions()),
        serviceBeta.init(KeycloakInitOptions())
      ]);

      expect(serviceAlpha.realm, 'demo');
      expect(serviceBeta.realm, 'demo');
      expect(serviceAlpha.clientId, 'test_alpha');
      expect(serviceBeta.clientId, 'test_beta');
    });
  });
}
