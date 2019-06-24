import 'dart:html';

import 'package:keycloak_dart/keycloak.dart';

void main() async {
  final loginButton = querySelector('#loginButton') as ButtonElement;
  final keycloak = KeycloakInstance();
  bool initSuccess = false;
  try {
    initSuccess = await keycloak.init(KeycloakInitOptions());
  } on KeycloakError catch (e) {
    print('error init: ${e.error}');
  }

  String currentSituation;
  if (initSuccess) {
    currentSituation = '''
    <h3>Authenticated!</h3>
    <strong>flow:</strong> ${keycloak.flow} <br>
    <strong>token:</strong> ${keycloak.token} <br>
    <strong>refreshToken:</strong> ${keycloak.refreshToken} <br>
    ''';
    loginButton.text = 'Logout';
    loginButton.onClick.listen((event) async {
      await keycloak.logout();
    });
  } else {
    currentSituation = '''
    <h3>Keycloak testing</h3>
    <strong>token:</strong> ${keycloak.token} <br>
    ''';
    loginButton.text = 'Login';
    loginButton.onClick.listen((event) async {
      await keycloak.login();
    });
  }

  querySelector('#output').innerHtml = currentSituation;
}

void _basicFlow() async {}
