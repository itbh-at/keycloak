import 'dart:html';

import 'package:keycloak_dart/keycloak.dart';

bool loginRequired = true;

void main() async {
  _handleLoginRequiredCheck();

  _handleNavigation(window.location.hash);

  window.onHashChange.listen((event) {
    _handleNavigation(window.location.hash);
  });
}

void _handleLoginRequiredCheck() {
  loginRequired =
      window.localStorage['login-required'] == 'true' ? true : false ?? false;

  final checkBox = querySelector('#login-required') as CheckboxInputElement;
  checkBox.checked = loginRequired;
  checkBox.onClick.listen((event) {
    loginRequired = checkBox.checked;
    window.localStorage['login-required'] = loginRequired.toString();
  });
}

void _handleNavigation(String hash) {
  print('what hash $hash');
  if (hash.isEmpty) {
    _startUp();
  } else {
    final startOfParam = hash.indexOf('&');
    final flowName =
        hash.substring(1, startOfParam == -1 ? null : startOfParam);

    _startUp(flowName);
  }
}

void _startUp([String flow]) async {
  final keycloak = KeycloakInstance();
  bool initSuccess = false;
  try {
    initSuccess = await keycloak.init(KeycloakInitOptions(
        flow: flow, onLoad: loginRequired ? 'login-required' : ''));
  } on KeycloakError catch (e) {
    _errorPage(e);
    return;
  }

  if (initSuccess) {
    _userSection(keycloak);
  } else {
    _loginSection(keycloak);
  }
}

void _loginSection(KeycloakInstance keycloak) {
  final loginButton = querySelector('#button1') as ButtonElement;
  (querySelector('#button2') as ButtonElement).hidden = true;
  (querySelector('#button3') as ButtonElement).hidden = true;

  loginButton.text = 'Login';
  loginButton.onClick.listen((event) async {
    await keycloak.login();
  });

  final currentSituation = '''
    <h3>${keycloak.flow} Flow: Login</h3>
    <strong>Server:</strong> ${keycloak.authServerUrl} <br>
    <strong>Realm:</strong> ${keycloak.realm} <br>
    <strong>Client:</strong> ${keycloak.clientId} <br>
    ''';

  querySelector('#output').innerHtml = currentSituation;
}

void _userSection(KeycloakInstance keycloak) {
  final profileButton = querySelector('#button1') as ButtonElement;
  final refreshButton = querySelector('#button2') as ButtonElement;
  final logoutButton = querySelector('#button3') as ButtonElement;

  profileButton.text = 'Show Profile';
  refreshButton.text = 'Refresh Token';
  logoutButton.text = 'Logout';

  logoutButton.onClick.listen((event) async {
    await keycloak.logout();
  });

  String currentSituation = '''
    <h3>${keycloak.flow} Flow: Authenticated! </h3>
    <strong>flow:</strong> ${keycloak.flow} <br>
    <strong>token:</strong> ${keycloak.token} <br>
    <strong>refreshToken:</strong> ${keycloak.refreshToken} <br>
    ''';

  querySelector('#output').innerHtml = currentSituation;
}

void _errorPage(KeycloakError error) async {
  querySelector('#error').text = 'Keycloack Error: ${error.error}';
}
