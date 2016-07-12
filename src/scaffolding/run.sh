#!/bin/bash

set -ex

FUCHSIA_ROOT=/vagrant/src/fuchsia
TARGET_PLATFORM=x86_64-fuchsia
SDK=$FUCHSIA_ROOT/buildtools/sdk
SYSROOT=$SDK/platforms/$TARGET_PLATFORM
# SYSROOT=$FUCHSIA_ROOT/magenta/build-magenta-qemu-x86-64/sysroot

AR=$SDK/toolchains/clang+llvm-x86_64-linux/bin/llvm-ar
CC=$SDK/toolchains/clang+llvm-x86_64-linux/bin/clang
CXX=$SDK/toolchains/clang+llvm-x86_64-linux/bin/clang++
CFLAGS="--target=$TARGET_PLATFORM -static --sysroot=$SYSROOT -D_BSD_SOURCE"
ARFLAGS=cr

OUT=$HOME/tmp/out
OBJ=$OUT/obj
BOOTFS=$OUT/bootfs

rm -rf $OBJ
mkdir -p $OBJ
rm -rf $BOOTFS
mkdir -p $BOOTFS/bin

cd $FUCHSIA_ROOT/fortune
$CC $CFLAGS fortune.c -o $BOOTFS/bin/fortune

GTEST_INCLUDE=$FUCHSIA_ROOT/third_party/gtest/googletest/include

cd $FUCHSIA_ROOT/third_party/gtest/googletest
$CXX $CFLAGS -I. -I$GTEST_INCLUDE -g -Wall -Wextra -pthread --std=c++11 \
    -c src/gtest-all.cc -o $OBJ/gtest-all.o
rm -f $OUT/libgtest.a && $AR $ARFLAGS $OUT/libgtest.a $OBJ/gtest-all.o

$CXX $CFLAGS -I. -I$GTEST_INCLUDE -g -Wall -Wextra -pthread --std=c++11 \
    -L$OUT -lgtest  \
    src/gtest_main.cc \
    samples/sample1.cc \
    samples/sample1_unittest.cc \
    -o $BOOTFS/bin/sample_unittests

cd $FUCHSIA_ROOT/escher
$CXX $CFLAGS -I. -I$GTEST_INCLUDE -g -Wall -Wextra -pthread --std=c++11 \
    -L$OUT -lgtest  \
    ftl/debug/debugger.cc \
    ftl/test/run_all_unittests.cc \
    ftl/arraysize_unittest.cc \
    ftl/logging.cc \
    -o $BOOTFS/bin/ftl_unittests

cd $FUCHSIA_ROOT/mojo

$CC $CFLAGS -I.. -g -Wall -Wextra --std=c11 \
    -c system/mojo.c -o $OBJ/mojo.o
rm -f $OUT/libmojo.a && $AR $ARFLAGS $OUT/libmojo.a $OBJ/mojo.o

$CXX $CFLAGS -I.. -g -Wall -Wextra --std=c++11 \
    -L$OUT -lmojo  \
    shell/shell.cc \
    shell/spawn.cc \
    -o $BOOTFS/bin/mojo_shell

MAGENTA_ROOT=$FUCHSIA_ROOT/magenta
MKBOOTFS=$MAGENTA_ROOT/build-magenta-qemu-x86-64/tools/mkbootfs
RUN_MAGENTA=$MAGENTA_ROOT/scripts/run-magenta-x86-64
EXTRA_BOOTFS=$OUT/extra.bootfs

cd $MAGENTA_ROOT

rm -f $EXTRA_BOOTFS
$MKBOOTFS -o $EXTRA_BOOTFS @$BOOTFS
$RUN_MAGENTA -x $EXTRA_BOOTFS
