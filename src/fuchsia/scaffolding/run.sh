#!/bin/bash

set -ex

FUCHSIA_ROOT=/vagrant/src/fuchsia
TARGET_PLATFORM=x86_64-fuchsia
SDK=$FUCHSIA_ROOT/sdk
SYSROOT=$SDK/platforms/$TARGET_PLATFORM
# SYSROOT=$FUCHSIA_ROOT/magenta/build-magenta-qemu-x86-64/sysroot

CC=$SDK/toolchains/clang+llvm-x86_64-linux/bin/clang
CXX=$SDK/toolchains/clang+llvm-x86_64-linux/bin/clang++
CFLAGS="--target=$TARGET_PLATFORM -static --sysroot=$SYSROOT"

OUT=$HOME/tmp/out
BOOTFS=$OUT/bootfs

rm -rf $BOOTFS
mkdir -p $BOOTFS/bin

cd $FUCHSIA_ROOT/fortune
$CC $CFLAGS fortune.c -o $BOOTFS/bin/fortune

cd $FUCHSIA_ROOT/third_party/gtest/googletest
$CXX $CFLAGS -I. -isystem include -g -Wall -Wextra -pthread --std=c++11 \
    src/gtest-all.cc \
    src/gtest_main.cc \
    samples/sample1.cc \
    samples/sample1_unittest.cc \
    -o $BOOTFS/bin/t

MAGENTA_ROOT=$FUCHSIA_ROOT/magenta
MKBOOTFS=$MAGENTA_ROOT/build-magenta-qemu-x86-64/tools/mkbootfs
RUN_MAGENTA=$MAGENTA_ROOT/scripts/run-magenta-x86-64
EXTRA_BOOTFS=$OUT/extra.bootfs

cd $MAGENTA_ROOT

rm -f $EXTRA_BOOTFS
$MKBOOTFS -o $EXTRA_BOOTFS @$BOOTFS
$RUN_MAGENTA -x $EXTRA_BOOTFS
