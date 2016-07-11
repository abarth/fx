#!/bin/bash
# Copyright 2016 The Fuchsia Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
set -e

if [ "$#" -ne 1 ]; then
    echo "Project name required"
    exit 1
fi

readonly PROJECT="${1}"
readonly FUCHSIA_ROOT="$(dirname $(cd $(dirname "${BASH_SOURCE[0]}") && pwd))"

cd "${FUCHSIA_ROOT}"

if [[ ! -d "${PROJECT}" ]]; then
  echo "Cannot find directory ${FUCHSIA_ROOT}/${PROJECT}"
  exit 1
fi

if [[ ! -f "${PROJECT}/.gn" ]]; then
  echo "Project ${FUCHSIA_ROOT}/${PROJECT} lacks a .gn file"
  exit 1
fi

buildtools/gn gen out/debug --root=. "--dotfile=${PROJECT}/.gn"
