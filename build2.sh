#!/bin/bash
#
# Compile Script 2021
# Licensed under the Apache License, Version 2.0 (the "License")
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

cd /tmp/ci/lineage
. build/envsetup.sh
lunch lineage_on7xelte-userdebug
export CCACHE_DIR=/tmp/ccache
export CCACHE_EXEC=$(which ccache)
export USE_CCACHE=1
ccache -M 20G
ccache -o compression=true
ccache -z
make api-stubs-docs || echo no problem
make system-api-stubs-docs || echo no problem
make test-api-stubs-docs || echo no problem
mka bacon -j$(nproc --all) &
sleep 80m
kill %1
ccache -s
