import 'dart:convert' show json;

import 'package:js/js.dart';

import 'js_interop/keycloak.dart' as js;
import 'js_interop/promise.dart';

typedef void Func();

class KeycloakInstance {
  js.KeycloakInstance<Promise> _kc;

  /// Is true if the user is authenticated, false otherwise.
  bool get authenticated => _kc.authenticated;
  set authenticated(bool v) => _kc.authenticated = v;

  /// The user id.
  String get subject => _kc.subject;
  set subject(String v) => _kc.subject = v;

  /// Response mode passed in init (default value is `'fragment'`).
  String get responseMode => _kc.responseMode;
  set responseMode(String v) => _kc.responseMode = v;

  /// Response type sent to Keycloak with login requests. This is determined
  /// based on the flow value used during initialization, but can be overridden
  /// by setting this value.
  String get responseType => _kc.responseType;
  set responseType(String v) => _kc.responseType = v;

  /// Flow passed in init.
  String get flow => _kc.flow;
  set flow(String v) => _kc.flow = v;

  /// The realm roles associated with the token.
  js.KeycloakRoles get realmAccess => _kc.realmAccess;
  set realmAccess(js.KeycloakRoles v) => _kc.realmAccess = v;

  /// The resource roles associated with the token.
  js.KeycloakResourceAccess get resourceAccess => _kc.resourceAccess;
  set resourceAccess(js.KeycloakResourceAccess v) => _kc.resourceAccess = v;

  /// The base64 encoded token that can be sent in the Authorization header in
  /// requests to services.
  String get token => _kc.token;
  set token(String v) => _kc.token = v;

  /// The parsed token as a JavaScript object.
  js.KeycloakTokenParsed get tokenParsed => _kc.tokenParsed;
  set tokenParsed(js.KeycloakTokenParsed v) => _kc.tokenParsed = v;

  /// The base64 encoded refresh token that can be used to retrieve a new token.
  String get refreshToken => _kc.refreshToken;
  set refreshToken(String v) => _kc.refreshToken = v;

  /// The parsed refresh token as a JavaScript object.
  js.KeycloakTokenParsed get refreshTokenParsed => _kc.refreshTokenParsed;
  set refreshTokenParsed(js.KeycloakTokenParsed v) =>
      _kc.refreshTokenParsed = v;

  /// The base64 encoded ID token.
  String get idToken => _kc.idToken;
  set idToken(String v) => _kc.idToken = v;

  /// The parsed id token as a JavaScript object.
  js.KeycloakTokenParsed get idTokenParsed => _kc.idTokenParsed;
  set idTokenParsed(js.KeycloakTokenParsed v) => _kc.idTokenParsed = v;

  /// The estimated time difference between the browser time and the Keycloak
  /// server in seconds. This value is just an estimation, but is accurate
  /// enough when determining if a token is expired or not.
  num get timeSkew => _kc.timeSkew;
  set timeSkew(num v) => _kc.timeSkew = v;

  bool get loginRequired => _kc.loginRequired;
  set loginRequired(bool v) => _kc.loginRequired = v;

  String get authServerUrl => _kc.authServerUrl;
  set authServerUrl(String v) => _kc.authServerUrl = v;

  String get realm => _kc.realm;
  set realm(String v) => _kc.realm = v;

  String get clientId => _kc.clientId;
  set clientId(String v) => _kc.clientId = v;

  String get clientSecret => _kc.clientSecret;
  set clientSecret(String v) => _kc.clientSecret = v;

  String get redirectUri => _kc.redirectUri;
  set redirectUri(String v) => _kc.redirectUri = v;

  String get sessionId => _kc.sessionId;
  set sessionId(String v) => _kc.sessionId = v;

  js.KeycloakProfile get profile => _kc.profile;
  set profile(js.KeycloakProfile v) => _kc.profile = v;

  get userInfo => _kc.userInfo;
  set userInfo(v) => _kc.userInfo = v;

  /// Called when the adapter is initialized.
  set onReady(Func f) => _kc.onReady = allowInterop(f);

  /// Called when a user is successfully authenticated.
  set onAuthSuccess(Func f) => _kc.onAuthSuccess = allowInterop(f);

  /// Called if there was an error during authentication.
  set onAuthError(Func f) => _kc.onAuthError = allowInterop(f);

  /// Called when the token is refreshed.
  set onAuthRefreshSuccess(Func f) =>
      _kc.onAuthRefreshSuccess = allowInterop(f);

  /// Called if there was an error while trying to refresh the token.
  set onAuthRefreshError(Func f) => _kc.onAuthRefreshError = allowInterop(f);

  /// Called if the user is logged out (will only be called if the session
  /// status iframe is enabled, or in Cordova mode).
  set onAuthLogout(Func f) => _kc.onAuthLogout = allowInterop(f);

  /// Called when the access token is expired. If a refresh token is available
  /// the token can be refreshed with Keycloak#updateToken, or in cases where
  /// it's not (ie. with implicit flow) you can redirect to login screen to
  /// obtain a new access token.
  set onTokenExpired(Func f) => _kc.onTokenExpired = allowInterop(f);

  KeycloakInstance([config]) {
    _kc = js.Keycloak(config);
  }

  KeycloakInstance.parameters(Map params) {
    _kc = js.Keycloak(parse(json.encode(params)));
  }

  /// Called to initialize the adapter.
  Future<bool> init(js.KeycloakInitOptions options) async {
    // If user define a `promiseType` and it is not 'native'
    if (options.promiseType != null && options.promiseType != 'native') {
      throw ArgumentError.value(options.promiseType,
          "We only support 'native' promiseType, given ${options.promiseType}");
    }

    // Forced native Promise in order to use our `Promise` interop
    options.promiseType = 'native';

    return promiseToFuture(_kc.init(options));
  }

  /// Redirects to login form.
  Future login([js.KeycloakLoginOptions options]) =>
      promiseToFuture(_kc.login(options));

  //TODO: We need a Dart interop for this option
  /// Redirects to logout.
  Future logout([dynamic options]) => promiseToFuture(_kc.logout(options));

  //TODO: We need a Dart interop for this option
  /// Redirects to registration form.
  /// set to `'register'`.
  Future register([dynamic options]) => promiseToFuture(_kc.register(options));

  /// Redirects to the Account Management Console.
  Future accountManagement() => promiseToFuture(_kc.accountManagement());

  /// Returns the URL to login form.
  String createLoginUrl([js.KeycloakLoginOptions options]) =>
      _kc.createLoginUrl(options);

  /// Returns the URL to logout the user.
  String createLogoutUrl([dynamic options]) => _kc.createLogoutUrl(options);

  /// Returns the URL to registration page.
  /// `action` is set to `'register'`.
  String createRegisterUrl([js.KeycloakLoginOptions options]) =>
      _kc.createRegisterUrl(options);

  /// Returns the URL to the Account Management Console.
  String createAccountUrl() => _kc.createAccountUrl();

  /// Returns true if the token has less than `minValidity` seconds left before
  /// it expires.
  bool isTokenExpired([num minValidity]) => _kc.isTokenExpired(minValidity);

  /// If the token expires within `minValidity` seconds, the token is refreshed.
  /// If the session status iframe is enabled, the session status is also
  /// checked.
  /// still valid, or if the token is no longer valid.
  /// @example
  /// ```js
  /// keycloak.updateToken(5).success(function(refreshed) {
  /// if (refreshed) {
  /// alert('Token was successfully refreshed');
  /// } else {
  /// alert('Token is still valid');
  /// }
  /// }).error(function() {
  /// alert('Failed to refresh the token, or the session has expired');
  /// });
  Future<bool> updateToken(num minValidity) =>
      promiseToFuture(_kc.updateToken(minValidity));

  /// Clears authentication state, including tokens. This can be useful if
  /// the application has detected the session was expired, for example if
  /// updating token fails. Invoking this results in Keycloak#onAuthLogout
  /// callback listener being invoked.
  void clearToken() => _kc.clearToken();

  /// Returns true if the token has the given realm role.
  bool hasRealmRole(String role) => _kc.hasRealmRole(role);

  /// Returns true if the token has the given role for the resource.
  bool hasResourceRole(String role, [String resource]) =>
      _kc.hasResourceRole(role, resource);

  /// Loads the user's profile.
  Future<js.KeycloakProfile> loadUserProfile() =>
      promiseToFuture(_kc.loadUserProfile());

  /// @private Undocumented.
  Future loadUserInfo() => promiseToFuture(_kc.loadUserInfo());
}
