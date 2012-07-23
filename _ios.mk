IBTOOL ?= ibtool

DEVELOPER := $(shell xcode-select -print-path)
IOS_ROOT = $(DEVELOPER)/Platforms/iPhoneOS.platform/Developer
IOS_SYSROOT := $(firstword $(wildcard $(IOS_ROOT)/SDKs/*.sdk))

OBJCDEBUG = $(if $(DEBUG),-DDEBUG=1 -O0,-Os)
OBJCFLAGS = -arch armv7 -fmessage-length=0 \
  -fdiagnostics-show-option \
  -fdiagnostics-print-source-range-info \
  -fdiagnostics-show-category=id -fdiagnostics-parseable-fixits \
  -std=gnu99 -Wno-trigraphs -fpascal-strings -Wreturn-type -Wparentheses \
  -Wswitch -Wno-unused-parameter -Wunused-variable -Wunused-value \
  -Wno-shorten-64-to-32 $(OBJCDEBUG) \
  -isysroot $(IOS_SYSROOT) \
  -gdwarf-2 -Wno-sign-conversion -mthumb \
  "-DIBOutlet=__attribute__((iboutlet))" \
  "-DIBAction=void)__attribute__((ibaction)" \
  "-DIBOutletCollection(ClassName)=__attribute__((iboutletcollection(ClassName)))" \
  -miphoneos-version-min=4.2
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
  $(OBJCDEBUG) \
  -isysroot $(IOS_SYSROOT) \
  -Wprotocol -Wdeprecated-declarations -Winvalid-offsetof -g \
  -Wno-conversion -Wno-sign-conversion -mthumb \
  "-DIBOutlet=__attribute__((iboutlet))" \
  "-DIBOutletCollection(ClassName)=__attribute__((iboutletcollection(ClassName)))" \
  "-DIBAction=void)__attribute__((ibaction)" \
  -miphoneos-version-min=4.2
LIBTOOL_FLAGS = -static -arch_only armv7 \
  -syslibroot $(IOS_SYSROOT) -framework Foundation
IBTOOLFLAGS = --errors --warnings --notices \
  --output-format human-readable-text --sdk $(IOS_SYSROOT)

%.nib: %.xib
	$(call silent,IBTOOL $@, \
	$(IBTOOL) $(IBTOOLFLAGS) --compile $@ $< 2>/dev/null)
