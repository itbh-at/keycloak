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
