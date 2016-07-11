#!/bin/bash
# Copyright 2016 The Fuchsia Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
set -e

readonly FUCHSIA_ROOT="$(dirname $(cd $(dirname "${BASH_SOURCE[0]}") && pwd))"
readonly MAGENTA_ROOT="${FUCHSIA_ROOT}/magenta"
readonly MKBOOTFS="${MAGENTA_ROOT}/build-magenta-qemu-x86-64/tools/mkbootfs"
readonly RUN_MAGENTA="${MAGENTA_ROOT}/scripts/run-magenta-x86-64"
readonly OUT="${FUCHSIA_ROOT}/out"
readonly BOOTFS="${OUT}/bootfs"
readonly EXTRA_BOOTFS="${OUT}/extra.bootfs"

rm -rf -- "${BOOTFS}"
mkdir -p -- "${BOOTFS}/bin"

cp -- ${OUT}/debug/*_unittests "${BOOTFS}/bin"

rm -f -- "${EXTRA_BOOTFS}"
"${MKBOOTFS}" -o "${EXTRA_BOOTFS}" "@${BOOTFS}"
(cd "${MAGENTA_ROOT}" && "${RUN_MAGENTA}" -x "${EXTRA_BOOTFS}")
