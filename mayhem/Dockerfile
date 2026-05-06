# Copyright 2019 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM gcr.io/oss-fuzz-base/base-builder
RUN sed -i s|snapshot.ubuntu.com|archive.ubuntu.com|g /etc/apt/sources.list /etc/apt/sources.list.d/*.list 2>/dev/null || true
MAINTAINER guidovranken@gmail.com
RUN apt-get -o Acquire::Retries=5 update && apt-get -o Acquire::Retries=5 install -y \
  make autoconf automake libtool pkg-config \
  protobuf-compiler libprotobuf-dev libprotoc-dev
COPY . protobuf-c
RUN rm -rf protobuf-c/mayhem
COPY mayhem/build.sh mayhem/unpack_fuzzer.c $SRC/
ENV FUZZING_LANGUAGE=c SANITIZER=address
RUN compile
