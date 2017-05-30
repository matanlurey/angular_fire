#!/usr/bin/env bash
# Copyright 2017, Google Inc.  Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.

set -e

DARTIUM_DIST="dartium-linux-x64-release.zip";
echo "Installing Dartium "
curl "http://storage.googleapis.com/dart-archive/channels/stable/raw/latest/dartium/$DARTIUM_DIST" > $DARTIUM_DIST
unzip -u $DARTIUM_DIST > /dev/null
rm $DARTIUM_DIST
mv dartium-* dartiumdir
export DARTIUM_BIN="$PWD/dartiumdir/chrome"
ln -s "$PWD/dartiumdir/chrome" "$PWD/dartium"

export PATH=$PATH":$PWD"
