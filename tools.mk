WORK_DIR ?= .work

JAVAC = javac
JAR = jar

MXMLC_PATH := $(shell which mxmlc)
$(if $(MXMLC_PATH),,$(error Flex SDK not found in the PATH))

FLEX_SDK := $(abspath $(MXMLC_PATH)/../..)
$(if $(wildcard $(FLEX_SDK)/include/FlashRuntimeExtensions.h),,$(error Invalid Flex SDK at $(FLEX_SDK)))

XML = $(shell which xml)
$(if $(wildcard $(XML)),,$(error xml-starlet dependency missing))

ADT = $(FLEX_SDK)/bin/adt
MXMLC = $(FLEX_SDK)/bin/mxmlc

AS_SWF_VERSION = 13
ASCFLAGS = +configname=airmobile -swf-version=$(AS_SWF_VERSION) -debug=$(if $(DEBUG),true,false)

CLASSPATH += $(FLEX_SDK)/lib/android/FlashRuntimeExtensions.jar
CLASSPATH += $(ANDROID_SDK)/tools/support/annotations.jar

CFLAGS += -I$(FLEX_SDK)/include
CXXFLAGS += -I$(FLEX_SDK)/include
OBJCFLAGS += -I$(FLEX_SDK)/include
OBJCXXFLAGS += -I$(FLEX_SDK)/include

GIT_DIR = $(ROOT)/$(shell grep -o '[^ ]*$$' $(ROOT)/.git 2>/dev/null || echo .git)
GIT_HEAD = $(GIT_DIR)/HEAD $(wildcard $(GIT_DIR)/.git/refs/*)
REVISION := $(strip $(shell git log --format=oneline |wc -l))
DIRTY := $(if $(shell git status --porcelain),*)
COMMIT := $(if $(DEBUG),D_)$(shell git log -n1 --format=format:%h)$(DIRTY)
NOTES = "Build $(VERSION).$(REVISION) ($(COMMIT)) by `id -un`@`hostname` `date +'%Y/%m/%d %H:%M:%S'`"
