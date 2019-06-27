import 'dart:html';

import 'package:keycloak_dart/keycloak.dart';

/// A global flag to determine should we use 'login-required' when initializing Keycloak
bool loginRequired = true;

/// Start Up will always run after the URL has has been parsed, which determine which `flow` to use.
///
/// Here, we can see how to register callbacks function with `KeycloakInstance`.
/// And how to initialize the instance as well.
///
/// Base on the result of the `init()`, it then decide to show different UI for aunthenticard user vs none.
void _startUp([String flow]) async {
  final keycloak = KeycloakInstance();

  // Register callback and print out in the console
  keycloak.onReady = ([bool authenticate]) => print('on ready $authenticate');
  keycloak.onAuthSuccess = () => print('on auth success');
  keycloak.onAuthError =
      ([KeycloakError error]) => print('on auth error: ${error.error}');
  keycloak.onAuthRefreshSuccess = () => print('on auth refresh success');
  keycloak.onAuthRefreshError = () => print('on auth refresh error');
  keycloak.onAuthLogout = () => print('on logout');
  keycloak.onTokenExpired = () => print('on token expired');

  // Init Keycloak
  bool autenticated = false;
  try {
    autenticated = await keycloak.init(KeycloakInitOptions(
        flow: flow, onLoad: loginRequired ? 'login-required' : ''));
  } on KeycloakError catch (e) {
    _errorPage(e);
    return;
  }

  // Checking `keycloak.authenticated` achieved the same thing here.
  if (autenticated) {
    _userSection(keycloak);
  } else {
    _loginSection(keycloak);
  }
}

/// Login Section will be shown if the user is not authenticated.
///
/// It then will show only the Login button which call `Keycloak.login()`.
/// At the same time, it demonstrate that an unauthenticated instance still carries
/// useful informations.
void _loginSection(KeycloakInstance keycloak) {
  final loginButton = querySelector('#button1') as ButtonElement;
  (querySelector('#button2') as ButtonElement).hidden = true;
  (querySelector('#button3') as ButtonElement).hidden = true;

  // Login Button
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

/// User Section will be shown if the user is aunthenticated.
///
/// There are 3 possible actions here:
/// 1. User can click on profile button, then we made an asynchonous call to `Keycloak.loadUserProfile()`,
///    And display the user information when the `Future` succeeded.
///
/// 2. User can click on update button (if the flow is not `imlicit`).
///    It will too make an asynchonous call to `Keycloak.updateToken()` and return later with result.
///
/// 3. User can logout.
///
void _userSection(KeycloakInstance keycloak) {
  final profileButton = querySelector('#button1') as ButtonElement;
  final updateButton = querySelector('#button2') as ButtonElement;
  final logoutButton = querySelector('#button3') as ButtonElement;

  // Show Profile Button
  profileButton.text = 'Show Profile';
  profileButton.onClick.listen((event) async {
    try {
      final profile = await keycloak.loadUserProfile();
      String profileText = '''
      <h4>${profile.username}'s Profile</h4>
      <strong>Name:</strong> ${profile.firstName} ${profile.lastName}<br>
      <strong>Email:</strong> ${profile.email}<br>
      <strong>Created on:</strong> ${profile.createdTimestamp}<br>
    ''';

      querySelector('#profile').innerHtml = profileText;
    } on KeycloakError catch (e) {
      _errorPage(e);
      return;
    }
  });

  // Update Token Button
  updateButton.text = 'Update Token';

  // Do not allow updateToken for implicit flow as refreshToken is not available
  if (keycloak.flow == 'implicit') {
    updateButton.disabled = true;
  }
  updateButton.onClick.listen((event) {
    // Showing another usage of `Future`.
    keycloak.updateToken(55).then((success) {
      if (success) {
        _displayAuthenticatedInfo(
            keycloak, "${keycloak.flow} Flow: Token Updated!");
      } else {
        _displayAuthenticatedInfo(
            keycloak, "${keycloak.flow} Flow: Token hasn't expired!");
      }
    }).catchError((e) {
      if (e is KeycloakError) {
        _errorPage(e);
      }
    });
  });

  // Logout Button
  logoutButton.text = 'Logout';
  logoutButton.onClick.listen((event) async {
    await keycloak.logout();
  });

  _displayAuthenticatedInfo(keycloak, "${keycloak.flow} Flow: Authenticated!");
}

/// Display Authenticated Info will print out information for aunthenticated user.
///
/// These include the tokens and also roles.
///
void _displayAuthenticatedInfo(KeycloakInstance keycloak, String header) {
  final currentSituation = '''
    <h3>$header</h3>
    <strong>idToken:</strong> ${_ellipsi(keycloak.idToken)} <br>
    <strong>token:</strong> ${_ellipsi(keycloak.token)} <br>
    <strong>refreshToken:</strong> ${_ellipsi(keycloak.refreshToken)} <br>
    <strong>realm roles:</strong> ${keycloak.realmAccess.roles} <br>
    <strong>resource access:</strong> ${keycloak.resourceAccess[keycloak.clientId]?.roles} <br>
    ''';

  querySelector('#output').innerHtml = currentSituation;
}

void main() async {
  _handleLoginRequiredCheck();

  // Parse the URL hash at the beginning and whenever user click on a link.
  _handleNavigation(window.location.hash);
  window.onHashChange.listen((event) {
    _handleNavigation(window.location.hash);
  });
}

void _handleLoginRequiredCheck() {
  // Acquire the saved decision about using 'login-required'
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
  if (hash.isEmpty) {
    _startUp();
  } else {
    // A special handling of URL hash to make sure we use the correct `KeycloakInitOption` after
    // redirected back from login page.
    var flowName = RegExp(r'^#\w*').stringMatch(hash);
    switch (flowName) {
      case '#standard':
      case '#implicit':
      case '#hybrid':
        _highlightFlow(flowName);
        flowName = flowName.substring(1);
        break;
      default:
        flowName = null;
        break;
    }

    _startUp(flowName);
  }
}

void _highlightFlow(String flowName) {
  final anchors = querySelectorAll('.activeLink');
  for (var anchor in anchors) {
    anchor.className = 'flowLink';
  }

  final activeAnchor = querySelector(flowName) as AnchorElement;
  activeAnchor.className = 'activeLink';
}

void _errorPage(KeycloakError error) {
  querySelector('#error').text = 'Keycloack Error: ${error.error}';
}

String _ellipsi(String s) {
  if (s?.isNotEmpty ?? false) {
    return s.replaceRange(0, s.length - 10, '...');
  }
  return s;
}
