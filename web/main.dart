// Copyright 2017, Google Inc.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:html';

import 'package:angular2/angular2.dart';
import 'package:angular2/platform/browser.dart';
import 'package:angular_fire/angular_fire.dart';

@AngularEntrypoint()
void main() {
  bootstrap(AngularFireExample, <dynamic>[]);
}

@Component(
  selector: 'angular-fire-example',
  directives: const <dynamic>[
    GoogleSignInComponent,
  ],
  template: r'''
    <google-sign-in (trigger)="onTrigger()">
    </google-sign-in>

    <google-sign-in [useDarkTheme]="true" (trigger)="onTrigger()">
    </google-sign-in>
  ''',
  preserveWhitespace: false,
)
class AngularFireExample {
  void onTrigger() {
    window.alert('Pressed!');
  }
}
