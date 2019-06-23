import 'js_interop/keycloak.dart';
import 'js_interop/promise.dart';

class KeycloakClient {
  KeycloakInstance<Promise> _kc;

  String get authServerUrl => _kc.authServerUrl;
  String get clientId => _kc.clientId;
  String get realm => _kc.realm;

  KeycloakClient() {
    _kc = Keycloak();
  }

  Future init(KeycloakInitOptions options) async {
    options.promiseType = 'native';
    return promiseToFuture(_kc.init(options));
  }

  // Future login([KeycloakLoginOptions options]) async {
  //   return promiseToFuture(_keycloakInstance.login(options));
  // }

  // Future logout() async {
  //   return promiseToFuture(_keycloakInstance.logout());
  // }
}
