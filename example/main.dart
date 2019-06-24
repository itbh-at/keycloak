import 'dart:html';

import 'package:keycloak_dart/keycloak.dart';

void main() async {
  final keycloak = KeycloakInstance();
  await keycloak.init(KeycloakInitOptions());

  var loginButton = querySelector('#loginButton') as ButtonElement;
  loginButton.onClick.listen((event) async {
    await keycloak.login();
  });

  String currentSituation;
  if (keycloak.authenticated) {
    currentSituation = 'Authenticated. You can only logout now.';
  } else {
    currentSituation = 'Please log in. ${keycloak.clientId}';
  }

  querySelector('#output').text = currentSituation;
}
