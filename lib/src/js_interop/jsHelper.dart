// This file is part of the Keycloak Dart Adapter
// 
// The Keycloak Dart Adapter is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public License as published
// by the Free Software Foundation; either version 3 of the License, or (at your
// option) any later version.
// 
// This program is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public License along
// with this program; if not, write to the Free Software Foundation, Inc., 51
// Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA

@JS()
library js_helper;

import 'dart:async' show Completer;

import 'package:js/js.dart' show allowInterop, JS;

typedef void ResolveFn<T>(T value);
typedef void RejectFn(dynamic error);

@JS("JSON.parse")
external dynamic parse(obj);

@JS('Promise')
class Promise<T> extends Thenable<T> {
  external Promise(void callback(ResolveFn<T> resolveFn, RejectFn rejectFn));
  external static Promise<List> all(List<Promise> values);
  external static Promise reject(dynamic error);
  external static Promise resolve(dynamic value);
}

@JS('Thenable')
abstract class Thenable<T> {
  // ignore: non_constant_identifier_names
  external Thenable JS$catch([RejectFn rejectFn]);
  external Thenable then([ResolveFn<T> resolveFn, RejectFn rejectFn]);
}

Future<T> promiseToFuture<J, T>(Promise<J> promise,
    [T unwrapValue(J jsValue)]) {
  // handle if promise object is already a future.
  Completer<T> completer = new Completer();
  promise.then(allowInterop((value) {
    T unwrapped;
    if (unwrapValue == null) {
      unwrapped = value as T;
    } else if (value != null) {
      unwrapped = unwrapValue(value);
    }
    completer.complete(unwrapped);
  }), allowInterop((error) {
    completer.completeError(error);
  }));
  return completer.future;
}
