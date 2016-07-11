#!/bin/bash
# Copyright 2016 The Fuchsia Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
set -e

readonly FUCHSIA_ROOT="$(dirname $(cd $(dirname "${BASH_SOURCE[0]}") && pwd))"
exec "${FUCHSIA_ROOT}/buildtools/ninja" -C out/debug "$@"
