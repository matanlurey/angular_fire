## 0.2.0

- Fixed a bug that flashed signed off content before loading.
- Changed the default behavior of Google sign-in to prompt for account:

```dart
abstract class FirebaseAuth {
  Future<FirebaseUser> googleSignIn({bool prompt: true});
}
```

## 0.1.1

- Removed a `print` statement that was always occurring.
- Added a high-level `FirebaseAuth` class, and Google sign-in.
- Added `IfFirebaseAuthDirective`.

## 0.1.0

- Initial commit of `GoogleSignInComppnent`.
