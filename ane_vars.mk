################## ANE Variables
ANE_IOS_LIB = libIOS.a

ANE := $(shell echo $(NAME).ane | tr A-Z a-z)
ANE_SRCDIR = $(ROOT)/src
ANE_AS3DIR ?= $(ANE_SRCDIR)/as3
ANE_CLASS = $(EXT_ID).$(NAME)
ANE_AS3_SRCS := $(shell find $(ANE_AS3DIR) -name '*.as')
EXT_XML_IN = $(ANE_SRCDIR)/extension.xml.in
EXT_XML = extension.xml
IOS_XML = $(ANE_SRCDIR)/ios/platform.xml
ANE_SWC = library.swc
ANE_SWF = library.swf

DIST = $(ANE) $(ANE_BUNDLED_LIBS)
WIKI_DIR = wiki
WIKI_MANIFEST = $(WIKI_DIR)/manifest.md
WIKI_DIST = $(foreach f,$(DIST),$(WIKI_DIR)/$f)

OBJC_XIBS := $(notdir $(wildcard $(OBJC_XIBDIRS:=/*.xib)))
OBJC_NIBS := $(OBJC_XIBS:%.xib=%.nib)

vpath %.xib $(OBJC_XIBDIRS)
