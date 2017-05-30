// Copyright 2017, Google Inc.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('browser')
@Tags(const ['aot'])
import 'package:angular2/angular2.dart';
import 'package:angular_fire/angular_fire.dart';
import 'package:angular_test/angular_test.dart';
import 'package:test/test.dart';

@AngularEntrypoint()
void main() {
  test('should render a $GoogleSignInComponent', () async {
    final fixture = await new NgTestBed<TestGoogleSignIn>().create();
    expect(fixture.rootElement, isNotNull);

    final button = fixture.rootElement.querySelector('google-sign-in');
    expect(fixture.text, contains('Pressed: 0'));
    await fixture.update((_) => button.click());
    expect(fixture.text, contains('Pressed: 1'));

    expect(
      button.getComputedStyle().backgroundImage,
      startsWith(
        'url(http://localhost:8080/assets/btn_google_signin_light_normal_web',
      ),
    );
  });
}

@Component(
  selector: 'google-sign-in-test',
  directives: const <dynamic>[
    GoogleSignInComponent,
  ],
  template: r'''
    <google-sign-in (trigger)="pressCount = pressCount + 1"></google-sign-in>
    Pressed: {{pressCount}}
  ''',
)
class TestGoogleSignIn {
  int pressCount = 0;
}
