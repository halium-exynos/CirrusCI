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

cd /tmp
time rclone copy /tmp/ci/lineage/out/target/product/halium_arm64/android-rootfs.img drive:Share/halium/GSI/halium-10.0-arm64/
com ()
{
    tar --use-compress-program="pigz -k -$2 " -cf $1.tar.gz $1
}
time com ccache 1
time rclone copy ccache.tar.gz drive:Share/halium/GSI/halium-10.0-arm64/
