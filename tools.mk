AAPT = $(call chkvar,ANDROID_SDK)/platform-tools/aapt
ADB = $(ANDROID_SDK)/platform-tools/adb
AIDL = $(ANDROID_SDK)/platform-tools/aidl
JAVAC = javac
JAR = jar

ANDROID_DEBUGGABLE = $(if DEBUG,android:debuggable="true")

$(if $(wildcard $(AAPT)),,$(error Invalid Android SDK at $(ANDROID_SDK)))

MXMLC_PATH := $(shell which mxmlc)
$(if $(MXMLC_PATH),,$(error Flex SDK not found in the PATH))

FLEX_SDK := $(abspath $(MXMLC_PATH)/../..)
$(if $(wildcard $(FLEX_SDK)/include/FlashRuntimeExtensions.h),,$(error Invalid Flex SDK at $(FLEX_SDK)))

ADT = $(FLEX_SDK)/bin/adt
MXMLC = $(FLEX_SDK)/bin/mxmlc

ASCFLAGS = +configname=airmobile -swf-version=13 -debug=$(if $(DEBUG),true,false)

CLASSPATH += $(FLEX_SDK)/lib/android/FlashRuntimeExtensions.jar
CLASSPATH += $(ANDROID_SDK)/tools/support/annotations.jar

CFLAGS += -I$(FLEX_SDK)/include
CXXFLAGS += -I$(FLEX_SDK)/include
OBJCFLAGS += -I$(FLEX_SDK)/include
OBJCXXFLAGS += -I$(FLEX_SDK)/include

GIT_HEAD = $(ROOT)/.git/HEAD $(wildcard $(ROOT)/.git/refs/*)
REVISION := $(strip $(shell git log --format=oneline |wc -l))
DIRTY := $(if $(shell git status --porcelain),*)
COMMIT := $(if $(DEBUG),D_)$(shell git log -n1 --format=format:%h)$(DIRTY)
NOTES = "Build $(VERSION).$(REVISION) ($(COMMIT)) by `id -un`@`hostname` `date +'%Y/%m/%d %H:%M:%S'`"
