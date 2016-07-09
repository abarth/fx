#!/bin/bash

set -ex

FUCHSIA_ROOT=/vagrant/src/fuchsia
SDK=$FUCHSIA_ROOT/sdk

CC=$SDK/toolchains/clang+llvm-x86_64-linux/bin/clang
CXX=$SDK/toolchains/clang+llvm-x86_64-linux/bin/clang++
TARGET_PLATFORM=x86_64-fuchsia
CFLAGS="--target=$TARGET_PLATFORM -static --sysroot=$SDK/platforms/$TARGET_PLATFORM"

OUT=$HOME/tmp/out
BOOTFS=$OUT/bootfs

rm -rf $BOOTFS
mkdir -p $BOOTFS

cd $FUCHSIA_ROOT/fortune
$CC $CFLAGS fortune.c -o $BOOTFS/fortune

cd $FUCHSIA_ROOT/third_party/gtest/googletest
$CXX $CFLAGS -I. -isystem include -g -Wall -Wextra -pthread \
    src/gtest-all.cc \
    src/gtest_main.cc \
    samples/sample1.cc \
    samples/sample1_unittest.cc \
    -o $BOOTFS/sample1_unittest

MAGENTA_ROOT=$FUCHSIA_ROOT/magenta
MKBOOTFS=$MAGENTA_ROOT/build-magenta-qemu-x86-64/tools/mkbootfs
RUN_MAGENTA=$MAGENTA_ROOT/scripts/run-magenta-x86-64
EXTRA_BOOTFS=$OUT/extra.bootfs

cd $MAGENTA_ROOT

rm -f $EXTRA_BOOTFS
$MKBOOTFS -o $EXTRA_BOOTFS @$BOOTFS
$RUN_MAGENTA -x $EXTRA_BOOTFS
