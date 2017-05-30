// Copyright 2017, Google Inc.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:angular2/angular2.dart';
import 'package:firebase/firebase.dart' as sdk;

/// An injectable service representing authentication with Firebase.
///
/// The default implementation requires providing a [sdk.App] object:
/// ```dart
/// import 'package:angular2/angular2.dart';
/// import 'package:angular2/platform/browser.dart';
/// import 'package:firebase/firebase.dart' as sdk;
///
/// bootstrap(AngularFireExample, [
///   provide(FirebaseAuth, useValue: new FirebaseAuth(
///     sdk.initializeApp(
///       ...
///     ),
///   )),
/// ]);
/// ````
@Injectable()
abstract class FirebaseAuth {
  factory FirebaseAuth(sdk.App app) = _SdkFirebaseAuth;

  /// Returns a stream of authenticated users.
  ///
  /// A value of `null` should be treated as not signed in.
  Stream<FirebaseUser> currentUser();

  /// Returns a future that completes after authenticated.
  Future<FirebaseUser> googleSignIn();

  /// Sign out of any authenticated account.
  Future<Null> signOut();
}

class _SdkFirebaseAuth implements FirebaseAuth {
  static final sdk.AuthProvider _googleAuth = new sdk.GoogleAuthProvider();

  final sdk.App _app;
  final _onUserChanged = new StreamController<FirebaseUser>.broadcast();

  FirebaseUser _currentUser;

  _SdkFirebaseAuth(this._app) {
    _app.auth().onAuthStateChanged.listen((event) {
      final user = event.user;
      _currentUser = user != null ? new FirebaseUser._fromSdk(user) : null;
      _onUserChanged.add(_currentUser);
    });
  }

  @override
  Stream<FirebaseUser> currentUser() async* {
    yield _currentUser;
    yield* _onUserChanged.stream;
  }

  @override
  Future<FirebaseUser> googleSignIn() async {
    final user = await _app.auth().signInWithPopup(_googleAuth);
    return new FirebaseUser._fromSdk(user.user);
  }

  @override
  Future<Null> signOut() async {
    await _app.auth().signOut();
  }
}

/// Represents a user that is authenticated with Firebase.
class FirebaseUser {
  final String displayName;
  final String emailAddress;
  final String userId;
  final String photoUrl;
  final String providerId;

  factory FirebaseUser._fromSdk(sdk.User user) {
    return new FirebaseUser(
      displayName: user.displayName,
      emailAddress: user.email,
      userId: user.uid,
      photoUrl: user.photoURL,
      providerId: user.providerId,
    );
  }

  const FirebaseUser({
    this.displayName,
    this.emailAddress,
    this.userId,
    this.photoUrl,
    this.providerId,
  });
}

/// Conditionally shows content based on authentication status with Firebase.
///
/// ```html
/// <div *ifFirebaseAuth="true">
///   Logged in!
/// </div>
/// <div *ifFirebaseAuth="false">
///   Logged out!
/// </div>
/// ````
///
/// **NOTE**: Only a static value of "true" or "false" is supported.
///
/// You can get a handle to the logged in user:
///
/// ```html
/// <div *ifFirebaseAuth="true; let currentUser = currentUser">
///   Logged in as {{currentUser.displayName}}!
/// </div>
/// ```
@Directive(
  selector: '[ifFirebaseAuth]',
)
class IfFirebaseAuthDirective implements OnDestroy, OnInit {
  final FirebaseAuth _authService;
  final TemplateRef _templateRef;
  final ViewContainerRef _viewContainerRef;

  bool _checkCondition;
  bool _lastCondition;
  FirebaseUser _currentUser;
  StreamSubscription<FirebaseUser> _userSub;

  IfFirebaseAuthDirective(
    this._authService,
    this._templateRef,
    this._viewContainerRef,
  );

  @Input()
  set ifFirebaseAuth(bool newCondition) {
    _checkCondition = newCondition;
    _toggle(_checkCondition ? _currentUser != null : _currentUser == null);
  }

  @override
  void ngOnDestroy() {
    _userSub.cancel();
  }

  @override
  void ngOnInit() {
    _userSub = _authService.currentUser().listen((user) {
      _currentUser = user;
      _toggle(_checkCondition ? _currentUser != null : _currentUser == null);
    });
  }

  void _toggle(bool show) {
    if (!show) {
      _signedOut();
    } else {
      _signedIn();
    }
  }

  void _signedIn() {
    if (_lastCondition == true) return;
    _viewContainerRef
        .createEmbeddedView(_templateRef)
        .setLocal('currentUser', _currentUser);
    _lastCondition = true;
  }

  void _signedOut() {
    if (_lastCondition == false) return;
    _viewContainerRef.clear();
    _lastCondition = false;
  }
}
