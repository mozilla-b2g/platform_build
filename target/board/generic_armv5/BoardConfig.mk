#
# Copyright (C) 2011 The Android Open Source Project
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

include build/target/board/generic/BoardConfig.mk

TARGET_ARCH_VARIANT := armv5te
TARGET_CPU_ABI := armeabi
TARGET_CPU_ABI2 :=

WITH_DEXPREOPT := false

# Build flags for Wifi Marionette Test
BOARD_WPA_SUPPLICANT_DRIVER := TEST
BOARD_HOSTAPD_DRIVER := TEST
WPA_SUPPLICANT_VERSION := VER_0_8_X

CONFIG_EAP := true
CONFIG_EAP_PEAP := true
CONFIG_EAP_TTLS := true
CONFIG_EAP_TLS := true
