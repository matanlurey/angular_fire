// Copyright 2017, Google Inc.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular2/angular2.dart';
import 'package:angular2/platform/browser.dart';
import 'package:angular_fire/angular_fire.dart';
import 'package:firebase/firebase.dart' as sdk;

@AngularEntrypoint()
void main() {
  bootstrap(AngularFireExample, <dynamic>[
    provide(
      FirebaseAuth,
      useValue: new FirebaseAuth(
        sdk.initializeApp(
          apiKey: 'AIzaSyA717X1TrdsnUS90pUdk1FVVS2AX_S-0mE',
          authDomain: 'angular-fire-dart-demo.firebaseapp.com',
          databaseURL: 'https://angular-fire-dart-demo.firebaseio.com',
          storageBucket: 'angular-fire-dart-demo.appspot.com',
        ),
      ),
    ),
  ]);
}

@Component(
  selector: 'angular-fire-example',
  directives: const <dynamic>[
    IfFirebaseAuthDirective,
    GoogleSignInComponent,
  ],
  template: r'''
    <div *ifFirebaseAuth="true; let currentUser = currentUser">
      Logged in as: {{currentUser.displayName}}.
      <button (click)="signOut()">Sign Out</button>
    </div>

    <div *ifFirebaseAuth="false">
      Waiting for sign in...

      <br>

      <google-sign-in
          (trigger)="signIn()">
      </google-sign-in>

      <google-sign-in
          [useDarkTheme]="true"
          (trigger)="signIn()">
      </google-sign-in>
    </div>
  ''',
  preserveWhitespace: false,
)
class AngularFireExample {
  final FirebaseAuth _auth;

  AngularFireExample(this._auth);

  void signIn() {
    _auth.googleSignIn();
  }

  void signOut() {
    _auth.signOut();
  }
}
