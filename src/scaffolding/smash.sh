#!/bin/bash

set -ex

FUCHSIA_ROOT=/vagrant/src/fuchsia
TARGET_PLATFORM=x86_64-fuchsia
SDK=$FUCHSIA_ROOT/buildtools/sdk
SYSROOT=$SDK/platforms/$TARGET_PLATFORM
BUILT_SYSROOT=$FUCHSIA_ROOT/magenta/build-magenta-pc-x86-64/sysroot

cp $BUILT_SYSROOT/lib/libc.a $SYSROOT/lib/libc.a
cp -rT $BUILT_SYSROOT/include $SYSROOT/include
