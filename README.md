# Dart wrapper for Keycloak JavaScript Adapter

Provide a more Dart-ish interface for Keycloak JS Adapter.

## Development

### Generating the interop file

1. You must have [js_facade_gen](https://github.com/dart-lang/js_facade_gen?) installed.
2. Go into `/bin` folder and execute `generate_js_interop.sh`:
   - This script assumed you have keycloak repo locally alongside this project's folder
3. There will be syntax error after the generation (the generator is old and lack of maintainence):

   1. It mistakenly generate this at ln 316:

   ```'dart'
   abstract class KeycloakInstance<TPromise extends dynamic /*'native'|dynamic*/, undefined> {
   ```

   To fix it, simply remove the second generic parameter `undefined`, it should be just:

   ```'dart'
   abstract class KeycloakInstance<TPromise extends dynamic /*'native'|dynamic*/> {
   ```
