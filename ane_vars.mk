################## ANE Variables
COMPC = compc
OBJC = clang -x objective-c
OBJCXX = clang -x objective-c++
LT = libtool
IBTOOL = ibtool

ANE := $(shell echo $(NAME).ane | tr A-Z a-z)
ANE_SRCDIR = $(ROOT)/src
ANE_AS3DIR = $(ANE_SRCDIR)/as3
ANE_CLASS = $(EXT_ID).$(NAME)
ANE_AS3_SRCS := $(shell find $(ANE_AS3DIR) -name '*.as')
EXT_XML = $(ANE_SRCDIR)/extension.xml
IOS_XML = $(ANE_SRCDIR)/ios/platform.xml
IOS_LIB = libIOS.a
ANE_SWC = library.swc
ANE_SWF = library.swf

EXT_XML_NS := $(shell grep -om1 http:.*[0-9] $(EXT_XML))
EXT_ID := $(shell xml sel -N x=$(EXT_XML_NS) -t -v 'x:extension/x:id' $(EXT_XML))

DEPDIR = .deps
OBJC_SRCS := $(notdir $(wildcard $(OBJC_SRCDIRS:=/*.m)))
OBJCXX_SRCS := $(notdir $(wildcard $(OBJC_SRCDIRS:=/*.mm)))
OBJC_OBJS := $(OBJC_SRCS:%.m=%.o) $(OBJCXX_SRCS:%.mm=%.o)
OBJC_DEPS := $(OBJC_SRCS:%.m=%(DEPDIR)/%.d) $(OBJCXX_SRCS:%.m=%(DEPDIR)/%.d)
df = $(DEPDIR)/$(*F)
OBJC_XIBS := $(notdir $(wildcard $(OBJC_XIBDIRS:=/*.xib)))
OBJC_NIBS := $(OBJC_XIBS:%.xib=%.nib)

vpath %.m $(OBJC_SRCDIRS)
vpath %.mm $(OBJC_SRCDIRS)
vpath %.xib $(OBJC_XIBDIRS)

FLEX_SDK := $(shell dirname $(shell dirname $(shell which mxmlc)))
# For Debug build -DDEBUG=1 -O0
OBJCFLAGS = -arch armv7 -fmessage-length=0 \
  -fdiagnostics-show-option \
  -fdiagnostics-print-source-range-info \
  -fdiagnostics-show-category=id -fdiagnostics-parseable-fixits \
  -std=gnu99 -Wno-trigraphs -fpascal-strings -Os -Wreturn-type -Wparentheses \
  -Wswitch -Wno-unused-parameter -Wunused-variable -Wunused-value \
  -Wno-shorten-64-to-32 -isysroot $(IOS_SYSROOT) \
  -gdwarf-2 -Wno-sign-conversion -mthumb \
  "-DIBOutlet=__attribute__((iboutlet))" \
  "-DIBAction=void)__attribute__((ibaction)" \
  "-DIBOutletCollection(ClassName)=__attribute__((iboutletcollection(ClassName)))" \
  -miphoneos-version-min=4.2 \
  $(OBJC_INCLDIRS:%=-I%) \
  -I$(FLEX_SDK)/include
OBJCXXFLAGS = -arch armv7 -fmessage-length=0 \
  -Wno-trigraphs -fpascal-strings -Wno-missing-field-initializers \
  -Wno-missing-prototypes -Wreturn-type -Wno-implicit-atomic-properties \
  -Wno-non-virtual-dtor -Wno-overloaded-virtual -Wno-exit-time-destructors \
  -Wformat -Wno-missing-braces -Wparentheses -Wswitch -Wno-unused-function \
  -Wno-unused-label -Wno-unused-parameter -Wunused-variable -Wunused-value \
  -Wno-uninitialized -Wno-unknown-pragmas -Wno-shadow -Wno-four-char-constants \
  -Wno-sign-compare -Wno-shorten-64-to-32 -Wno-newline-eof -Wno-selector \
  -Wno-strict-selector-match -Wno-undeclared-selector \
  -Wno-deprecated-implementations -Wno-arc-abi -Wc++11-extensions \
  -isysroot $(IOS_SYSROOT) \
  -Wprotocol -Wdeprecated-declarations -Winvalid-offsetof -g \
  -Wno-conversion -Wno-sign-conversion -mthumb \
  "-DIBOutlet=__attribute__((iboutlet))" \
  "-DIBOutletCollection(ClassName)=__attribute__((iboutletcollection(ClassName)))" \
  "-DIBAction=void)__attribute__((ibaction)" \
  -miphoneos-version-min=4.2 \
  $(OBJC_INCLDIRS:%=-I%) \
  -I$(FLEX_SDK)/include
LIBTOOL_FLAGS = -static -arch_only armv7 \
  -syslibroot $(IOS_SYSROOT) -framework Foundation
IBTOOLFLAGS = --errors --warnings --notices \
  --output-format human-readable-text --sdk $(IOS_SYSROOT)
