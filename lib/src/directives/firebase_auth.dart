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
  ///
  /// May optionally disable [prompt] if the user is already authenticated.
  Future<FirebaseUser> googleSignIn({
    bool prompt: true,
    List<String> scopes: const [],
  });

  /// Sign out of any authenticated account.
  Future<Null> signOut();
}

class _SdkFirebaseAuth implements FirebaseAuth {
  final sdk.App _app;
  final _onUserChanged = new StreamController<FirebaseUser>.broadcast();

  FirebaseUser _currentUser;
  bool _wasInitialized = false;

  _SdkFirebaseAuth(this._app) {
    _app.auth().onAuthStateChanged.listen((event) {
      final user = event.user;
      _wasInitialized = true;
      _currentUser = user != null ? new FirebaseUser._fromSdk(user) : null;
      _onUserChanged.add(_currentUser);
    });
  }

  @override
  Stream<FirebaseUser> currentUser() async* {
    if (_wasInitialized) {
      yield _currentUser;
    }
    yield* _onUserChanged.stream;
  }

  @override
  Future<FirebaseUser> googleSignIn({
    bool prompt: true,
    List<String> scopes: const [],
  }) async {
    final googleAuth = new sdk.GoogleAuthProvider();
    scopes.forEach(googleAuth.addScope);
    googleAuth.setCustomParameters(<String, dynamic>{
      'prompt': prompt ? 'select_account' : 'none',
    });
    try {
      final user = await _app.auth().signInWithPopup(googleAuth);
      return new FirebaseUser._fromSdk(user.user);
    } catch (_) {
      return null;
    }
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
  bool _wasInitialized = false;

  IfFirebaseAuthDirective(
    this._authService,
    this._templateRef,
    this._viewContainerRef,
  );

  @Input()
  set ifFirebaseAuth(bool newCondition) {
    _checkCondition = newCondition;
    if (_wasInitialized) {
      _toggle(_checkCondition ? _currentUser != null : _currentUser == null);
    }
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
      _wasInitialized = true;
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
