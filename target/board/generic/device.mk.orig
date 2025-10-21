#
# Copyright (C) 2009 The Android Open Source Project
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

<<<<<<< HEAD
# NFC:
#   Provide default libnfc-nci.conf file for devices that does not have one in
#   vendor/etc because aosp system image (of aosp_$arch products) is going to
#   be used as GSI.
#   May need to remove the following for newly launched devices in P since this
#   NFC configuration file should be in vendor/etc, instead of system/etc
PRODUCT_COPY_FILES += \
    device/generic/common/nfc/libnfc-nci.conf:system/etc/libnfc-nci.conf
=======
# This is a build configuration for the product aspects that
# are specific to the emulator.

PRODUCT_PROPERTY_OVERRIDES := \
    ro.ril.hsxpa=1 \
    ro.ril.gprsclass=10 \
    ro.adb.qemud=1

PRODUCT_COPY_FILES := \
    development/data/etc/vold.conf:system/etc/vold.conf \
    development/tools/emulator/system/camera/media_profiles.xml:system/etc/media_profiles.xml \

PRODUCT_PACKAGES := \
    audio.primary.goldfish
>>>>>>> 1b0db93f (Merge pull request #122 from kanru/bug1031593)
