#
# Copyright (C) 2006 The Android Open Source Project
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

# Configuration for Darwin (Mac OS X) on x86.
# Included by combo/select.mk

# We build everything in 32-bit, because some host tools are
# 32-bit-only anyway (emulator, acc), and because it gives us
# more consistency between the host tools and the target.
HOST_GLOBAL_CFLAGS += -m32
HOST_GLOBAL_LDFLAGS += -m32

# try to correctly find the 10.6 or at least the 10.5 sdk sysroot
# base version of OS X shouldn't matter..
build_mac_version := $(shell sw_vers -productVersion)
sdks_root_old := /Developer/SDKs
platforms_root := /Applications/XCode.app/Contents/Developer/Platforms
sdks_root := $(platforms_root)/MacOSX.platform/Developer/SDKs

sdks_old := $(wildcard $sdks_root_old/*.sdk)
sdks := $(wildcard $sdks_root/*.sdk)

sdk_root := $(sdks_root)/MacOSX10.8.sdk
ifeq ($(wildcard $(sdk_root)),)
  sdk_root := $(sdks_root)/MacOSX10.7.sdk
  ifeq ($(wildcard $(sdk_root)),)
    sdk_root := $(sdks_root)/MacOSX10.6.sdk
    ifeq ($(wildcard $(sdk_root)),)
      sdk_root := $(sdks_root_old)/MacOSX10.6.sdk
      ifeq ($(wildcard $(sdk_root)),)
        sdk_root := $(sdks_root_old)/MacOSX10.5.sdk
        ifeq ($(wildcard $(sdk_root)),)
          $(warning ***********************************************************)
          $(warning * No 10.5 -- 10.8 SDK found, do you have Xcode installed? *)
          $(warning ***********************************************************)
          sdk_root :=
        endif
      endif
    endif
  endif
endif

ifneq ($(strip sdk_root),)
  # Only some modules will override sysroot for 10.6 / 10.5 compatibility
  # so we leave this unset in the GLOBAL_CFLAGS (but expose HOST_SYSROOT)
  HOST_SYSROOT := $(sdk_root)
endif

HOST_GLOBAL_CFLAGS += -fPIC
HOST_NO_UNDEFINED_LDFLAGS := -Wl,-undefined,error

HOST_OBJCC := cc
HOST_CC := gcc-4.6
ifeq (,$(wildcard /usr/local/bin/gcc-4.6))
HOST_CC := gcc
endif

GCC_REALPATH = $(realpath $(shell which $(HOST_CC)))
ifneq ($(findstring llvm-gcc,$(GCC_REALPATH)),)
    # Using LLVM GCC results in a non functional emulator due to it
    # not honouring global register variables
    $(warning ****************************************)
    $(warning * gcc is linked to llvm-gcc which will *)
    $(warning * not create a useable emulator.       *)
    $(warning ****************************************)
endif

HOST_CXX := g++
HOST_AR := $(AR)
HOST_STRIP := $(STRIP)
HOST_STRIP_COMMAND = $(HOST_STRIP) --strip-debug $< -o $@

HOST_SHLIB_SUFFIX := .dylib
HOST_JNILIB_SUFFIX := .jnilib

HOST_GLOBAL_CFLAGS += \
	-include $(call select-android-config-h,darwin-x86)
ifneq ($(filter 10.7 10.7.% 10.8 10.8.%, $(build_mac_version)),)
       HOST_RUN_RANLIB_AFTER_COPYING := false
else
       HOST_RUN_RANLIB_AFTER_COPYING := true
       PRE_LION_DYNAMIC_LINKER_OPTIONS := -Wl,-dynamic
endif
HOST_GLOBAL_ARFLAGS := cqs

HOST_CUSTOM_LD_COMMAND := true

define transform-host-o-to-shared-lib-inner
$(hide) $(PRIVATE_CXX) \
        -dynamiclib -single_module -read_only_relocs suppress \
        $(HOST_GLOBAL_LD_DIRS) \
        $(HOST_GLOBAL_LDFLAGS) \
        $(PRIVATE_ALL_OBJECTS) \
        $(call normalize-host-libraries,$(PRIVATE_ALL_SHARED_LIBRARIES)) \
        $(call normalize-host-libraries,$(PRIVATE_ALL_WHOLE_STATIC_LIBRARIES)) \
        $(if $(PRIVATE_GROUP_STATIC_LIBRARIES),-Wl$(comma)--start-group) \
        $(call normalize-host-libraries,$(PRIVATE_ALL_STATIC_LIBRARIES)) \
        $(if $(PRIVATE_GROUP_STATIC_LIBRARIES),-Wl$(comma)--end-group) \
        $(PRIVATE_LDLIBS) \
        -o $@ \
        $(PRIVATE_LDFLAGS) \
        $(HOST_LIBGCC)
endef

define transform-host-o-to-executable-inner
$(hide) $(PRIVATE_CXX) \
        -o $@ \
        $(PRE_LION_DYNAMIC_LINKER_OPTIONS) -headerpad_max_install_names \
        $(HOST_GLOBAL_LD_DIRS) \
        $(HOST_GLOBAL_LDFLAGS) \
        $(call normalize-host-libraries,$(PRIVATE_ALL_SHARED_LIBRARIES)) \
        $(PRIVATE_ALL_OBJECTS) \
        $(call normalize-host-libraries,$(PRIVATE_ALL_WHOLE_STATIC_LIBRARIES)) \
        $(if $(PRIVATE_GROUP_STATIC_LIBRARIES),-Wl$(comma)--start-group) \
        $(call normalize-host-libraries,$(PRIVATE_ALL_STATIC_LIBRARIES)) \
        $(if $(PRIVATE_GROUP_STATIC_LIBRARIES),-Wl$(comma)--end-group) \
        $(PRIVATE_LDFLAGS) \
        $(PRIVATE_LDLIBS) \
        $(HOST_LIBGCC)
endef

# $(1): The file to check
define get-file-size
stat -f "%z" $(1)
endef
