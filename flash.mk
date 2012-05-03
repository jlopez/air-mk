MXMLC_PATH := $(shell which mxmlc)
$(if $(MXMLC_PATH),,$(error Flex SDK not found in the PATH))

FLEX_SDK := $(abspath $(MXMLC_PATH)/../..)
$(if $(wildcard $(FLEX_SDK)/include/FlashRuntimeExtensions.h),,$(error Invalid Flex SDK at $(FLEX_SDK)))

CFLAGS += -I$(FLEX_SDK)/include
CXXFLAGS += -I$(FLEX_SDK)/include
OBJCFLAGS += -I$(FLEX_SDK)/include
OBJCXXFLAGS += -I$(FLEX_SDK)/include
