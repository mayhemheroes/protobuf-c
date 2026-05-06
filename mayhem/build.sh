#!/bin/bash -eu
# Copyright 2019 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
################################################################################

export ASAN_OPTIONS=alloc_dealloc_mismatch=0

if [[ $CFLAGS = *sanitize=address* ]]
then
    export CXXFLAGS="$CXXFLAGS -DASAN"
fi

if [[ $CFLAGS = *sanitize=memory* ]]
then
    export CXXFLAGS="$CXXFLAGS -DMSAN"
fi

if [[ $SANITIZER = coverage ]]
then
    export CXXFLAGS="$CXXFLAGS -fno-use-cxa-atexit"
fi

# Build protobuf using CMake (autotools no longer available in modern protobuf)
SAVED_CFLAGS="$CFLAGS"
SAVED_CXXFLAGS="$CXXFLAGS"
unset CFLAGS CXXFLAGS
mkdir -p $SRC/protobuf-build
cd $SRC/protobuf-build
cmake $SRC/protobuf \
    -Dprotobuf_BUILD_TESTS=OFF \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$SRC/protobuf-install \
    -DBUILD_SHARED_LIBS=OFF
make -j$(nproc)
make install
export CFLAGS="$SAVED_CFLAGS"
export CXXFLAGS="$SAVED_CXXFLAGS"

export PROTOC="$SRC/protobuf-install/bin/protoc"

# Build protobuf-c using autotools
# Point it to the protobuf cmake install using explicit flags
cd $SRC/protobuf-c/
./autogen.sh
PKG_CONFIG_PATH="$SRC/protobuf-install/lib/pkgconfig" PROTOBUF_CFLAGS="-I$SRC/protobuf-install/include" PROTOBUF_LIBS="-L$SRC/protobuf-install/lib -lprotobuf" \
./configure --enable-static=yes --enable-shared=false

make -j$(nproc)
make install

cd $SRC/fuzzing-headers/
./install.sh

cd $SRC/protobuf-c-fuzzers/
cp $SRC/protobuf-c/t/test-full.proto $SRC/protobuf-c-fuzzers/
export PATH=$PATH:$SRC/protobuf-c/protoc-c
$PROTOC --c_out=. -I. -I/usr/local/include test-full.proto
$CC $CFLAGS test-full.pb-c.c -I $SRC/protobuf-install/include -I $SRC/protobuf-c -c -o test-full.pb-c.o
$CXX $CXXFLAGS fuzzer.cpp -I $SRC/protobuf-install/include -I $SRC/protobuf-c test-full.pb-c.o $SRC/protobuf-c/protobuf-c/.libs/libprotobuf-c.a $LIB_FUZZING_ENGINE -o $OUT/fuzzer
