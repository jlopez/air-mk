################## SWF Variables
ROOT = ..

SWF = $(NAME).swf
IPA = $(NAME).ipa
APK = $(NAME).apk
DSYM = $(NAME).app.dSYM
DSYM_ZIP = $(DSYM).zip

EXT_DIR = ext
FULL_EXT_DIR = $(abspath ext)
EXPANDED_ANES = $(foreach A,$(ANES),$(EXT_DIR)/$(notdir $A))

APP_XML = app.xml
APP_XML_NS := $(shell grep -om1 http:.*[0-9] $(APP_XML_IN))
ICONS := $(shell $(XML) sel -N x=$(APP_XML_NS) -t -v '//x:icon/*' $(APP_XML_IN))

KEYS_ROOT = $(call findparent,keys/$(COMPANY))
KEYS_APP_PATH = $(KEYS_ROOT)/$(APP_ID)
KEYS_PATH = $(KEYS_APP_PATH) $(KEYS_ROOT)
MOBILEPROVISION_NAME = $(if $(findstring app-store,$(TARGET)),appstore,development)
MOBILEPROVISION = $(call findfile,$(KEYS_PATH),$(MOBILEPROVISION_NAME).mobileprovision)
KEY_NAME = $(if $(findstring app-store,$(TARGET)),distribution,development)
KEYSTORE = $(call findfile,$(KEYS_PATH),$(KEY_NAME).p12)
KEYPASS = $(KEYSTORE:.p12=.password)
TARGET = ipa-debug-interpreter
CONNECT = $(if $(findstring debug,$(TARGET)),-connect $(shell hostname))
TARGET_OPT = -target $(TARGET) $(CONNECT)
KEYPASSWORD = $(if $(wildcard $(KEYPASS)),$(shell cat $(KEYPASS)),$(call chkvar,KEY_PASSWORD))
STOREPASS = -storepass $(KEYPASSWORD)
SIGN_OPT = -provisioning-profile $(MOBILEPROVISION) -storetype PKCS12 -keystore $(KEYSTORE) $(STOREPASS)
# ADTX_FLAGS = -Xaotperflog
adtxlinkdir = $(if $(wildcard $1),-Xlinker -L$(abspath $1))
ADT_LDFLAGS = $(foreach a,$(ANES),$(call adtxlinkdir,$(EXT_DIR)/$(notdir $a)/$(ANE_BUNDLED_LIBS_DIR)))
ADTX_FLAGS += -XO1 -Xverbose 0 -Xnostrip $(ADT_LDFLAGS)
ADT_FLAGS = -package $(ADTX_FLAGS) $(TARGET_OPT) $(SIGN_OPT)
ADT_EXTDIRS = $(foreach e,$(ANES),-extdir $(dir $e))
SDK_OPT = -platformsdk $(IOS_SYSROOT)
ANE_BUNDLED_LIBS_DIR = META-INF/ANE/iPhone-ARM-lib


APK_KEYSTORE = $(KEYS_ROOT)/android.pfx
APK_SIGN_OPT = -storetype PKCS12 -keystore $(APK_KEYSTORE) $(STOREPASS)
APK_CONNECT = $(if $(findstring debug,$(APK_TARGET)),-connect $(shell ipconfig getifaddr en1))
APK_TARGET = apk$(if $(DEBUG),-debug,-captive-runtime)
APK_TARGET_OPT = -target $(APK_TARGET) $(APK_CONNECT)
APK_ADTFLAGS = -package $(APK_TARGET_OPT) $(APK_SIGN_OPT)

SCREEN = iPhoneRetina
ADL_SCREENSIZE = $(if $(SCREEN),-screensize $(SCREEN))
