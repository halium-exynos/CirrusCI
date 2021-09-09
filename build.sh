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

git clone -b lineage-16.0 https://github.com/halium-exynos/CirrusCI.git /tmp/ci/cirrus

export REPOSYNCHALIUM="https://github.com/LineageOS/android.git"
export DEVICEHALIUM="https://github.com/halium-exynos/android_device_samsung_on7xelte.git"
export DEVICECOMMONHALIUM="https://github.com/halium-exynos/android_device_samsung_exynos7870-common.git"
export VENDORHALIUM="https://github.com/halium-exynos/proprietary_vendor_samsung_on7xelte.git"
export SAMSUNGHARDWAREHALIUM="https://github.com/halium-exynos/android_hardware_samsung.git"
export KERNELHALIUM="https://github.com/halium-exynos/android_kernel_samsung_exynos7870.git"
export MIRRORSH="https://mirrors.kernelpanix.workers.dev/0:/halium/on7xelte/ccache.tar.gz"
export BRANCHHALIUM="lineage-16.0"

mkdir -p /tmp/ci/lineage
sudo chmod 0777 /tmp/ci/lineage

git config --global user.name "dopaemon"
git config --global user.email "polarisdp@gmail.com"

sudo apt-get install aria2 pigz -y

cd /tmp
time aria2c $MIRRORSH -x16 -s50
time tar xf ccache.tar.gz
rm -rf ccache.tar.gz

cd /tmp/ci/lineage
repo init -q --no-repo-verify --depth=1 -u $REPOSYNCHALIUM -b lineage-16.0 -g default,-device,-mips,-darwin,-notdefault
git clone https://github.com/halium-exynos/CirrusCI.git --depth 1 -b lineage-16.0 .repo/local_manifests
repo sync -v -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j$(nproc --all) || repo sync -v -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j$(nproc --all)
