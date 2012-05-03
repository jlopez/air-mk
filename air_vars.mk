################## SWF Variables
ROOT = ..

ADT = adt
MXMLC = mxmlc
ADB = adb

ASCFLAGS = +configname=airmobile -swf-version=13 -debug=false

SWF = $(NAME).swf
IPA = $(NAME).ipa
APK = $(NAME).apk
DSYM = $(NAME).app.dSYM
DSYM_ZIP = $(DSYM).zip

EXT_DIR = ext
EXPANDED_ANES = $(foreach A,$(ANES),$(EXT_DIR)/$A)

APP_XML = app.xml
APP_XML_NS := $(shell grep -om1 http:.*[0-9] $(APP_XML_IN))
ICONS := $(shell xml sel -N x=$(APP_XML_NS) -t -v '//x:icon/*' $(APP_XML_IN))

DEVELOPER := $(shell xcode-select -print-path)
IOS_ROOT = $(DEVELOPER)/Platforms/iPhoneOS.platform/Developer
IOS_SYSROOT := $(firstword $(wildcard $(IOS_ROOT)/SDKs/*.sdk))
KEYS_ROOT = $(call findparent,keys/$(COMPANY))
KEYS_PATH = $(KEYS_ROOT)/$(APP_ID) $(KEYS_ROOT)
MOBILEPROVISION = $(call findfile,$(KEYS_PATH),development.mobileprovision)
KEYSTORE = $(call findfile,$(KEYS_PATH),development.p12)
TARGET = ipa-debug-interpreter
CONNECT = $(if $(findstring debug,$(TARGET)),-connect $(shell hostname))
TARGET_OPT = -target $(TARGET) $(CONNECT)
STOREPASS = $(if $(KEY_PASSWORD),-storepass $(KEY_PASSWORD))
SIGN_OPT = -provisioning-profile $(MOBILEPROVISION) -storetype PKCS12 -keystore $(KEYSTORE) $(STOREPASS)
ADT_FLAGS = -package -XO1 -Xverbose 0 -Xaotperflog -Xnostrip $(TARGET_OPT) $(SIGN_OPT)
ADT_FLAGS = -package -XO1 -Xverbose 0 -Xnostrip $(TARGET_OPT) $(SIGN_OPT)
SDK_OPT = -platformsdk $(IOS_SYSROOT)

ANDROID_SDK := $(realpath $(shell which adb)/../..)
APK_KEYSTORE = $(KEYS_ROOT)/android.pfx
APK_SIGN_OPT = -storetype PKCS12 -keystore $(APK_KEYSTORE) $(STOREPASS)
APK_CONNECT := -connect $(shell ipconfig getifaddr en1)
APK_TARGET = apk-debug
APK_TARGET_OPT = -target $(APK_TARGET) $(APK_CONNECT)
APK_ADTFLAGS = -package $(APK_TARGET_OPT) $(APK_SIGN_OPT)

SCREEN = iPhoneRetina
ADL_SCREENSIZE = $(if $(SCREEN),-screensize $(SCREEN))

GIT_HEAD := $(ROOT)/.git/HEAD $(wildcard $(ROOT)/.git/refs/*)
REVISION := $(strip $(shell git log --format=oneline |wc -l))
DIRTY := $(if $(shell git status --porcelain),*)
COMMIT := $(shell git log -n1 --format=format:%h)$(DIRTY)
NOTES = "Build $(VERSION).$(REVISION) ($(COMMIT)) by `id -un`@`hostname` `date +'%Y/%m/%d %H:%M:%S'`"
