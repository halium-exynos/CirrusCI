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

export REPOSYNCHALIUM="https://github.com/LineageOS/android.git"
export STARTSYNCHALIUM="repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j$(nproc --all) || repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j$(nproc --all)"
export DEVICEHALIUM="https://github.com/halium-exynos/android_device_samsung_on7xelte.git"
export DEVICECOMMONHALIUM="https://github.com/halium-exynos/android_device_samsung_exynos7870-common.git"
export VENDORHALIUM="https://github.com/halium-exynos/proprietary_vendor_samsung_on7xelte.git"
export SAMSUNGHARDWAREHALIUM="https://github.com/halium-exynos/android_hardware_samsung.git"
export KERNELHALIUM="https://github.com/halium-exynos/android_kernel_samsung_exynos7870.git"
export BRANCHHALIUM="lineage-16.0"

mkdir -p /tmp/ci/lineage
sudo chmod 0777 /tmp/ci/lineage

git config --global user.name "dopaemon"
git config --global user.email "polarisdp@gmail.com"

cd /tmp
time aria2c https://mirrors.kernelpanix.workers.dev/halium/on7xelte/ccache.tar.gz -x16 -s50
time tar xf ccache.tar.gz
rm -rf ccache.tar.gz

cd /tmp/ci/lineage
repo init -q --no-repo-verify --depth=1 -u $REPOSYNCHALIUM -b lineage-16.0 -g default,-device,-mips,-darwin,-notdefault
git clone https://github.com/halium-exynos/local_manifest.git --depth 1 -b lineage-16.0 .repo/local_manifests
$STARTSYNCHALIUM

cd /tmp/ci
export CCACHE_DIR=/tmp/ccache
sleep 2m

while :
do
ccache -s
echo ''
top -b -i -n 1
sleep 1m
done

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
sleep 85m
kill %1
ccache -s

cd /tmp
com ()
{
    tar --use-compress-program="pigz -k -$2 " -cf $1.tar.gz $1
}
time com ccache 1
time rclone copy ccache.tar.gz drive:Share/halium/on7xelte/
