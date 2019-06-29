# Dart wrapper for Keycloak JavaScript Adapter

Provide a more Dart-ish interface for [Keycloak JS Adapter](https://www.keycloak.org/docs/latest/securing_apps/index.html#_javascript_adapter).

## Usage

### Constructing Keycloak instance

It supports the original 3 flavours of constructing a `KeycloakInstance`.

```'dart'
// This will find the keycloak.json file in the root path
final keycloak = KeycloakInstance();

// This will load the config file at the given path
final keycloak = KeycloakInstance('other_keycloak.json');

// This will construct with the given map
final keycloak = KeycloakInstance.parameters({
    "realm": "demo",
    "authServerUrl": "http://localhost:8080/auth",
    "clientId": "client"
});
```

### Initializing Keycloak

All [flows](https://www.keycloak.org/docs/latest/securing_apps/index.html#flows) are supported. For example, to initialize a Keycloak instance with implicit flow and login immediately:

```'dart'
try {
    final authenticated = await keycloak.init(KeycloakInitOptions(
        flow: 'implicit',
        onLoad: 'login-required'));
    if (authenticated) {
        _loadPage();
    }
} on catch (e) {
    _handleError(e);
}
```

There is one **restriction**: `KeycloakInitOptions.promiseType` must be `'native'` or leave blank. In order to have Dart's `Future` works for all API.

### All Promise based API is Dart's `Future`

As demonstrated above, all `KeycloakInstance` promise based API are converted to Dart's `Future`. You can use the `Future.then()` too if you want:

```'dart'
keycloak.updateToken(55).then((success) {
    if (success) {
        print("Token Refreshed!");
    } else {
        print("Token hasn't expired!");
    }
}).catchError((e) {
    _handleError(e);
});
```

### Registers callbacks

There are a few callback function one can listen to, simply assign a function to such setter. Example:

```'dart'
keycloak.onAuthSuccess = () => print('on auth success');
```

### Handling Exceptions

Not all exception thrown by keycloak JS adapter is a valid `KeycloakError`. It does threw empty exception for some methods. In Dart, it will became a `NullThrownError`.

We can first try to cast the error to `KeycloakError` and see if we can display meaningful error message. If it doesn't, we just display the generic error message. Nonetheless, there is an exception thrown and we should handle the situation.

```'dart'
try {
    final profile = await keycloak.loadUserProfile();
    _displayProfile(profile);
} catch (e) {
    final errorMessage = e is KeycloakError
      ? e.error
      : e?.toString() ?? 'Unknown Error';
    print(errorMessage);
}
```

## Development

### Generating the interop file

1. Must have [js_facade_gen](https://github.com/dart-lang/js_facade_gen?) installed.
2. Go into `/bin` folder and execute `generate_js_interop.sh`:
   - This script assumed you have [keycloak repository](https://github.com/keycloak/keycloak) cloned locally alongside this project's folder.
3. There will be syntax error after the generation (the generator is old and lack of maintenance). You have to repair the generated `/lib/src/js_interop/keycloak.dart`

Here are the repair instructions:

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

3. It mistakenly made all the JavaScript callback functions into a Dart function. To fix them, convert all callback functions to a set function.

   All these functions need to be replace, starting from ln 421: (commented out the replaced generated codes)

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

4. `KeycloakTokenParsed` is using outdated types. This is not a code generator issue but an outdated TypeScript definition [issue](https://issues.jboss.org/browse/KEYCLOAK-10745). [PR](https://github.com/keycloak/keycloak/pull/6132) to fix it is active here. This repair is no longer needed once the fix it in.

   Replace the type of `realm_access` and `resources_access` to the responding class respectively: (commented out the replaced generated codes)

   ln 278

   ```'dart'
   // external dynamic /*{ roles: string[] }*/ get realm_access;
   // external set realm_access(dynamic /*{ roles: string[] }*/ v);
   // external List<String> get resource_access;
   // external set resource_access(List<String> v);
   external KeycloakRoles get realm_access;
   external set realm_access(KeycloakRoles v);
   external KeycloakResourceAccess get resource_access;
   external set resource_access(KeycloakResourceAccess v);
   ```

   ln 288

   ```'dart'
   //dynamic /*{ roles: string[] }*/ realm_access,
   //List<String> resource_access});
   KeycloakRoles realm_access,
   KeycloakResourceAccess resource_access});
   ```

### Running the example

Example are a web page demonstrating most of the functionality you can do with this Keycloak Adapter.

#### Setup the Keycloak server

- A local Keycloak server running at `http://localhost:8080`.
- A 'demo' realm setup.
- A 'test_alpha' client.

You can run with your own configuration, just make sure you replace the `keycloak.json` in the `example/` folder.

#### Serve the example

Run it with `webdev serve example:2700`. and visit `http://localhost:2700`.

#### The take-away

This example shows:

- Constructing `KeycloakInstance`
- All 3 [flows](https://www.keycloak.org/docs/latest/securing_apps/index.html#flows) initializations.
- 'login-required' initialization.
- Acquiring user profile, realm access and client access.
- Update token.
- Future APIs.
- Register callbacks.

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
