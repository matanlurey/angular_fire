// Copyright 2017, Google Inc.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:html';

import 'package:angular2/angular2.dart';
import 'package:meta/meta.dart';

/// An [OpaqueToken] that may provided to override the default image path.
///
/// ## Example
///
/// ```dart
/// import 'package:angular2/angular2.dart';
/// import 'package:angular2/platform/browser.dart';
/// import 'package:angular_fire/angular_fire.dart';
///
/// main() {
///   bootstrap(AppComponent, [
///     // When drawing the google-sign in button, assume the following:
///     // - https://cdn.io/img/btn_google_signin_light_normal_web.png
///     // - https://cdn.io/img/btn_google_signin_light_pressed_web.png
///     // etc...
///     const Provide(googleSignInAssetPath, useValue: 'https://cdn.io/img/'),
///   ]);
/// }
/// ```
///
/// See the [branding guidelines](https://developers.google.com/identity/branding-guidelines)
/// for a full list of assets.
const googleSignInAssetPath = const OpaqueToken('googleSignInAssetPath');

/// An [OpaqueToken] that may be provided to enable the alternative dark theme.
///
/// ## Example
///
/// ```dart
/// import 'package:angular2/angular2.dart';
/// import 'package:angular2/platform/browser.dart';
/// import 'package:angular_fire/angular_fire.dart';
///
/// main() {
///   bootstrap(AppComponent, [
///     const Provide(googleSignInDarkTheme, useValue: true),
///   ]);
/// }
/// ```
const googleSignInDarkTheme = const OpaqueToken('googleSignInRetina');

/// A default value for [googleSignInAssetPath] if not provided otherwise.
///
/// This means for `http://localhost`, we assume an image is located in
/// `http://localhost/assets/google_sign_in/btn_google_signin_light_normal_web.png`.
///
/// For users of `pub serve` and `pub build`, this means putting the files
/// directly in the `web` folder or using a reverse proxy. It is also possible
/// to upload the assets to a CDN and configure [googleSignInAssetPath] instead.
const String defaultAssetPath = 'assets/';

/// A sign-in button to authenticate with a personal or G Suite Google account.
///
/// **NOTE**: By default, this component does nothing. Read below for details.
///
/// ## Configuring your image path
///
/// We don't make any assumptions about your server setup, or use (or non-use)
/// of a CDN, so there are no image files bundled with this component. To
/// include a default configuration everywhere, see [googleSignInAssetPath],
/// otherwise you may also just set [assetPath]:
///
/// ```html
/// <google-sign-in [assetPath]="https://cdn.io/img/"></google-sign-in>
/// ```
///
/// ## Authenticating
///
/// You can listen to the `trigger` event to be notified when it is pressed:
///
/// ```html
/// <google-sign-in (trigger)="doAuth()"></google-sign-in>
/// ```
@Component(
  selector: 'google-sign-in',
  templateUrl: 'google_sign_in.html',
  styleUrls: const ['google_sign_in.css'],
)
class GoogleSignInComponent {
  static final bool _isHighResolution = window.devicePixelRatio > 1.0;

  final HtmlElement _element;

  factory GoogleSignInComponent(
    ElementRef elementRef,
    @Optional() @Inject(googleSignInAssetPath) String assetPath,
    @Optional() @Inject(googleSignInDarkTheme) bool useDarkTheme,
  ) =>
      new GoogleSignInComponent._(
        elementRef.nativeElement as HtmlElement,
        assetPath: assetPath ?? defaultAssetPath,
        useDarkTheme: useDarkTheme ?? false,
      );

  GoogleSignInComponent._(
    this._element, {
    @required String assetPath,
    @required bool useDarkTheme,
  }) {
    // This is used instead of @Host() as an optimization.
    _element
      ..tabIndex = 0
      ..onFocus.listen((_) {
        if (_status != 'pressed') {
          _status = 'focus';
          _render();
        }
      })
      ..onBlur.listen((_) {
        _status = 'normal';
        _render();
      })
      ..onMouseDown.listen((_) {
        _status = 'pressed';
        _render();
      })
      ..onMouseUp.listen((event) {
        _status = 'focus';
        _render();
      })
      ..onClick.listen(_onTrigger.add);

    _assetPath = assetPath;
    _useDarkTheme = useDarkTheme;
    _render();
  }

  /// Fires when the button is pressed.
  @Output()
  Stream<Event> get trigger => _onTrigger.stream;
  final _onTrigger = new StreamController<Event>(sync: true);

  // Either disabled, focus, normal, pressed.
  String _status = 'normal';

  void _render() {
    const prefix = 'btn_google_signin_';
    final asset = '$prefix${_useDarkTheme ? 'dark' : 'light'}_${_status}_web';
    final suffix = _isHighResolution ? '@2x' : '';
    print('$asset$suffix');
    _element.style.backgroundImage = 'url($_assetPath$asset$suffix.png)';
  }

  String _assetPath;

  /// An alternative way to set the asset path per component.
  ///
  /// ```html
  /// <google-sign-in [assetPath]="https://cdn.io/img/"></google-sign-in>
  /// ```
  ///
  /// See [googleSignInAssetPath] for details.
  @Input()
  set assetPath(String assetPath) {
    _assetPath = assetPath;
    _render();
  }

  bool _useDarkTheme;

  /// An alternative way to set use of the dark theme per component.
  ///
  /// ```html
  /// <google-sign-in [useDarkTheme]="isDarkThemeEnabled"></google-sign-in>
  /// ```
  ///
  /// See [googleSignInDarkTheme] for details.
  @Input()
  set useDarkTheme(bool useDarkTheme) {
    _useDarkTheme = useDarkTheme;
    _render();
  }
}
