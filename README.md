# Dart wrapper for Keycloak JavaScript Adapter

Provide a more Dart-ish interface for Keycloak JS Adapter.

## Development

### Generating the interop file

1. Must have [js_facade_gen](https://github.com/dart-lang/js_facade_gen?) installed.
2. Go into `/bin` folder and execute `generate_js_interop.sh`:
   - This script assumed you have [keycloak repository](https://github.com/keycloak/keycloak) cloned locally alongside this project's folder.
3. There will be syntax error after the generation (the generator is old and lack of maintenance):

   1. It mistakenly generate syntax error at ln 316:

   ```'dart'
   abstract class KeycloakInstance<TPromise extends dynamic /*'native'|dynamic*/, undefined> {
   ```

   To fix it, simply remove the second generic parameter `undefined`, it should be just:

   ```'dart'
   abstract class KeycloakInstance<TPromise extends dynamic /*'native'|dynamic*/> {
   ```

   2. It mistakenly thought there was a Keycloak namespace in the keycloak.js, but there isn't. It result in calling all JS functions with a Keycloak namespace in front e.g. `Keycloak.Keycloak()`. To fix it, replace the first line:

   ```'dart'
   @JS("Keycloak")
   ```

   with empty namespace:

   ```'dart'
   @JS()
   ```

   3. It mistakenly make all the JavaScript callback functions into a Dart function. To fix them, convert all callback functions to a set function. Starting from ln 421:

   All these functions need to be replace: (commented out the replaced generated codes)

   ```'dart
    //external void onReady([bool authenticated]);
    external set onReady(dynamic func);

    //external void onAuthSuccess();
    external set onAuthSuccess(dynamic func);

    //external void onAuthError(KeycloakError errorData);
    external set onAuthError(dynamic func);

    //external void onAuthRefreshSuccess();
    external set onAuthRefreshSuccess(dynamic func);

    //external void onAuthRefreshError();
    external set onAuthRefreshError(dynamic func);

    //external void onAuthLogout();
    external set onAuthLogout(dynamic func);

    //external void onTokenExpired();
    external set onTokenExpired(dynamic func);
   ```

## Testing

### Setup

All tests assumes:

- A local Keycloak server running at `http://localhost:8080`.
- A 'demo' realm setup.
- 2 clients:

1. test_alpha
2. test_beta

### Run

Just run command `pub run build_runner test`.
