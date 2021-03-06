// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart = 2.8

import '../convert.dart';
import '../globals.dart' as globals;

import 'test_device.dart';
import 'watcher.dart';

/// Prints JSON events when running a test in --machine mode.
class EventPrinter extends TestWatcher {
  EventPrinter({StringSink out, TestWatcher parent})
    : _out = out ?? globals.stdio.stdout,
      _parent = parent;

  final StringSink _out;
  final TestWatcher _parent;

  @override
  void handleStartedDevice(Uri observatoryUri) {
    _sendEvent('test.startedProcess',
        <String, dynamic>{'observatoryUri': observatoryUri.toString()});
    _parent?.handleStartedDevice(observatoryUri);
  }

  @override
  Future<void> handleTestCrashed(TestDevice testDevice) async {
    return _parent?.handleTestCrashed(testDevice);
  }

  @override
  Future<void> handleTestTimedOut(TestDevice testDevice) async {
    return _parent?.handleTestTimedOut(testDevice);
  }

  @override
  Future<void> handleFinishedTest(TestDevice testDevice) async {
    return _parent?.handleFinishedTest(testDevice);
  }

  void _sendEvent(String name, [ dynamic params ]) {
    final Map<String, dynamic> map = <String, dynamic>{'event': name};
    if (params != null) {
      map['params'] = params;
    }
    _send(map);
  }

  void _send(Map<String, dynamic> command) {
    final String encoded = json.encode(command, toEncodable: _jsonEncodeObject);
    _out.writeln('\n[$encoded]');
  }

  dynamic _jsonEncodeObject(dynamic object) {
    if (object is Uri) {
      return object.toString();
    }
    return object;
  }
}
