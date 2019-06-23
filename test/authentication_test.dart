@TestOn("browser")
import 'package:test/test.dart';

import 'package:keycloak_dart/keycloak.dart';

void main() {
  group('Initialization.', () {
    test('Create keycloak instance by config file', () async {
      final client = KeycloakClient();
      await client.init(KeycloakInitOptions());

      expect(client.realm, 'demo');
      expect(client.clientId, 'test_alpha');
    });

    // test('Create keycloak instance by parameters', () async {
    //   final service = KeycloakService.parameters({
    //     "realm": "demo",
    //     "authServerUrl": "http://localhost:8080/auth",
    //     "clientId": "angulardart_beta"
    //   });
    //   await service.init();

    //   expect(service.realm, 'demo');
    //   expect(service.clientId, 'angulardart_beta');
    // });

    // test('Create 2 separated instances', () async {
    //   final serviceAlpha = KeycloakService();
    //   final serviceBeta = KeycloakService.parameters({
    //     "realm": "demo",
    //     "authServerUrl": "http://localhost:8080/auth",
    //     "clientId": "angulardart_beta"
    //   });

    //   await Future.wait([serviceAlpha.init(), serviceBeta.init()]);

    //   expect(serviceAlpha.realm, 'demo');
    //   expect(serviceBeta.realm, 'demo');
    //   expect(serviceAlpha.clientId, 'angulardart_alpha');
    //   expect(serviceBeta.clientId, 'angulardart_beta');
    // });
  });
}
