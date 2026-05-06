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
#
################################################################################

FROM gcr.io/oss-fuzz-base/base-builder
ENV GIT_TERMINAL_PROMPT=0
MAINTAINER guidovranken@gmail.com
RUN apt-get -o Acquire::Retries=5 update && apt-get -o Acquire::Retries=5 install -y make cmake autoconf automake libtool pkg-config
RUN for i in 1 2 3; do git clone --depth 1 --recursive https://github.com/protocolbuffers/protobuf.git && break || sleep 5; done
COPY . protobuf-c
RUN rm -rf protobuf-c/mayhem
RUN for i in 1 2 3; do git clone --depth 1 https://github.com/guidovranken/fuzzing-headers.git && break || sleep 5; done
RUN for i in 1 2 3; do git clone --depth 1 https://github.com/guidovranken/protobuf-c-fuzzers.git && break || sleep 5; done
COPY mayhem/build.sh $SRC/

ENV FUZZING_LANGUAGE=c SANITIZER=address
RUN compile