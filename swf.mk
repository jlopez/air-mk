################## SWF Variables
MXMLC = $(FLEX_SDK)/bin/mxmlc
ADL = $(FLEX_SDK)/bin/adl

DEVELOPER = $(shell xcode-select -print-path 2>/dev/null)
IOS_ROOT = $(DEVELOPER)/Platforms/iPhoneOS.platform/Developer
IOS_SYSROOT = $(firstword $(wildcard $(IOS_ROOT)/SDKs/*.sdk))

extracticons = $(if $(wildcard $1),$(shell xml sel -t -v "//*[local-name()='icon']/*" $1))
swficons = $(call swficons1,$1,$2,$(call extracticons,$(wildcard $3)))
swficons1 = $(if $3,$(call swficons2,$1,$2,$3))
define swficons2
$(call chkvars,$1_ICON)

$1_ICON_DIR = $$(WORK_DIR)/$2-icons
$1_ICONS = $$(addprefix $$($1_ICON_DIR)/,$3)

$(foreach i,$3,$(call swficons3,$1,$i))

$$($1_ICON_DIR):
	$$(call mkdir)

endef

define swficons3

$$($1_ICON_DIR)/$2: $$($1_ICON) | $$($1_ICON_DIR)
	$$(call swfresize,$$<,$$@)

endef

swfresize = $(call swfresize1,$1,$2,$(call swfimagesize,$2))
swfimagesize = $(shell echo $1 | grep -Po '\d+x\d+' |sed 's/x/ /')
swfresize1 = $(call silent,RESIZE $@,sips -z $3 $1 --out $2 >/dev/null)


define swf

$(call chkvars,$1_SOURCES $1_MAIN)

$1_SOURCE_DIRS = $$(filter-out %.swc,$$($1_SOURCES))
$1_SOURCE_SWCS = $$(filter %.swc,$$($1_SOURCES))

$1_SOURCE_FILES = $$(call find,$$($1_SOURCE_DIRS),-name '*.as' -o -name '*.mxml')
$1_CLASSPATH = $$(call find,$$($1_SOURCE_DIRS),-name '*.swc') $$($1_SOURCE_SWCS)

$1_CP = $$(call joinwith,$$(,),$$($1_CLASSPATH))
$1_SP = $$(call joinwith,$$(,),$$($1_SOURCE_DIRS))

$1_CFLAGS = $$($1_FLAGS) \
            $$(if $$($1_CONFIG),-load-config+=$$($1_CONFIG)) \
            $$(if $$($1_SP),-sp+=$$($1_SP)) \
            $$(if $$($1_CP),-l+=$$($1_CP)) \
            -file-specs=$$($1_MAIN) \
            $(if $(DEBUG),-debug) \

$$($1): $$($1_SOURCE_FILES) $$($1_CLASSPATH) $$($1_CONFIG)
	$$(call silent,MXMLC $$@, \
  $$(MXMLC) $$($1_CFLAGS) -o $$@)

ifdef $1_APP_XML
$1_ADL_FLAGS ?= -profile mobileDevice -screensize iPhoneRetina

.PHONY: run-$4
run-$4: $$($1_APP_XML) $$($1)
	$$(call silent,ADL $4, \
  $$(ADL) $$($1_ADL_FLAGS) $$<)

ifdef $1_IPA

$1_COMPANY ?= $$(call chkvar,COMPANY)
$1_ADT_XFLAGS ?= -XO1 -Xverbose 0 -Xnostrip
$1_ADT_TARGET ?= ipa-debug-interpreter
$1_ADT_CONNECT = $$(if $$(findstring debug,$$($1_ADT_TARGET)),-connect $$(shell hostname))
$1_KEYS_ROOT = $$(call findparent,keys/$$($1_COMPANY))
$1_KEYS_PATHS = $$(if $$($1_APP_ID),$$($1_KEYS_ROOT)/$$($1_APP_ID)) $$($1_KEYS_ROOT)
$1_MOBILEPROVISION_NAME = $$(if $$(findstring app-store,$$($1_TARGET)),appstore,development).mobileprovision
$1_MOBILEPROVISION = $$(call check,$$(call findfile,$$($1_KEYS_PATHS),$$($1_MOBILEPROVISION_NAME)),Unable to locate provisioning profile '$$($1_MOBILEPROVISION_NAME)' at paths $$($1_KEYS_PATHS))
$1_KEY_NAME = $$(if $$(findstring app-store,$$($1_ADT_TARGET)),distribution,development).p12
$1_KEYSTORE = $$(call check,$$(call findfile,$$($1_KEYS_PATHS),$$($1_KEY_NAME)),Unable to locate key file '$$($1_KEY_NAME)' at [$$($1_KEYS_PATHS)])
$1_KEYPASS = $$($1_KEYSTORE:.p12=.password)
$1_STOREPASS = $$(if $$(wildcard $$($1_KEYPASS)),-storepass $$(shell cat $$($1_KEYPASS)))
$1_ADT_SIGNING = -provisioning-profile $$($1_MOBILEPROVISION) \
                 -storetype PKCS12 \
                 -keystore $$($1_KEYSTORE) \
                 $$($1_STOREPASS)
$1_ADT_FLAGS = -package $$($1_ADT_XFLAGS) \
               -target $$($1_ADT_TARGET) $$($1_ADT_CONNECT) \
               $$($1_ADT_SIGNING)
$1_SDK_OPT = $$(if $$(IOS_SYSROOT),-platformsdk $$(IOS_SYSROOT))

$(call swficons,$1,$4,$(call firstpath,$($1_APP_XML) $($1_APP_XML_IN)))

$$($1_IPA): $$($1) $$($1_APP_XML) $$($1_ICONS)
	$$(call silent,ADT $$@, \
  $$(ADT) $$($1_ADT_FLAGS) $$@ $$($1_APP_XML) $$($1_SDK_OPT) \
  -C $$(dir $$<) $$(notdir $$<) \
  -C $$($1_ICON_DIR) .)

.PHONY: install-$4
install-$4: $$($1_IPA)
	$$(call silent,INSTALL $$<, ideviceinstaller -i $$< >/dev/null)

ipa-debug-$4:
	@echo "COMPANY: $$($1_COMPANY)."
	@echo "ADT_XFLAGS: $$($1_ADT_XFLAGS)."
	@echo "ADT_TARGET: $$($1_ADT_TARGET)."
	@echo "ADT_CONNECT: $$($1_ADT_CONNECT)."
	@echo "KEYS_ROOT: $$($1_KEYS_ROOT)."
	@echo "KEYS_PATHS: $$($1_KEYS_PATHS)."
	@echo "MOBILEPROVISION_NAME: $$($1_MOBILEPROVISION_NAME)."
	@echo "MOBILEPROVISION: $$($1_MOBILEPROVISION)."
	@echo "KEY_NAME: $$($1_KEY_NAME)."
	@echo "KEYSTORE: $$($1_KEYSTORE)."
	@echo "KEYPASS: $$($1_KEYPASS)."
	@echo "STOREPASS: $$($1_STOREPASS)."
	@echo "ADT_SIGNING: $$($1_ADT_SIGNING)."
	@echo "ADT_FLAGS: $$($1_ADT_FLAGS)."
	@echo "SDK_OPT: $$($1_SDK_OPT)."
	@echo "ICON_DIR: $$($1_ICON_DIR)."
	@echo "ICONS: $$($1_ICONS)."

endif

endif

clean::
	rm -fr $$($1)

endef

$(call suffixrules,SWF,swf)
