################## ANE Variables
ROOT ?= ..

ANDROID_BUILD_TOOLS = $(lastword $(sort $(wildcard $(call chkvar,ANDROID_SDK)/build-tools/*)))
AAPT = $(call checkpath,$(if $(ANDROID_BUILD_TOOLS),$(ANDROID_BUILD_TOOLS)/aapt,$(ANDROID_SDK)/platform-tools/aapt))
ADB = $(call checkpath,$(ANDROID_SDK)/platform-tools/adb)
AIDL = $(call checkpath,$(if $(ANDROID_BUILD_TOOLS),$(ANDROID_BUILD_TOOLS)/aidl,$(ANDROID_SDK)/platform-tools/aidl))

ANDROID_DEBUGGABLE = $(if DEBUG,android:debuggable="true")

ANE_IOS_LIB = libIOS.a
ANE_ANDROID_JAR = $(if $(ANE_ANDROID_JAR_SOURCES),android.jar)

ANDROID_SRC_SEARCH_PATHS ?= src

ANE := $(shell echo $(NAME).ane | tr A-Z a-z)
ANE_SRCDIR ?= $(ROOT)/src
ANE_AS3DIR ?= $(ANE_SRCDIR)/as3
ANE_CLASS = $(EXT_ID).$(NAME)
ANE_AS3_SRCS := $(shell find $(ANE_AS3DIR) -name '*.as')
EXT_XML_IN = $(ANE_SRCDIR)/extension.xml.in
EXT_XML = extension.xml
IOS_XML = $(wildcard $(ANE_SRCDIR)/ios/platform.xml)
ANE_SWC = library.swc
ANE_SWF = library.swf

DIST = $(ANE) $(ANE_BUNDLED_LIBS)

OBJC_XIBS := $(notdir $(wildcard $(OBJC_XIBDIRS:=/*.xib)))
OBJC_NIBS := $(OBJC_XIBS:%.xib=%.nib)

vpath %.xib $(OBJC_XIBDIRS)

extractAndroidPackage = $(shell $(XML) sel -T -t -m /manifest -v @package $1)
getPackagePath = $(shell echo $1 | tr . /)

getAndroidResourceFiles = $(call find,$1,! -name '.*' -type f)
getAndroidSourceDir = $(call firstsubdir,$1,$(ANDROID_SRC_SEARCH_PATHS))
getAndroidSupportJar = $(if $1,$(call checkpath,$(ANDROID_SDK)/extras/android/support/v$1/android-support-v$1.jar))

# 1:name, 2:path, 3:manifest, 4:resources, 5:package, 6:packagePath, 7:R.java
androidResources = $(foreach p,$2,$(call ar1,$1,$p))
ar1 = $(call ar2,$1,$2,$2/AndroidManifest.xml,$(call getAndroidResourceFiles,$2/res))
ar2 = $(if $(wildcard $3),$(if $4,$(call ar3,$1,$2,$3,$4)))
ar3 = $(call ar4,$1,$2,$3,$4,$(call extractAndroidPackage,$3))
ar4 = $(call ar5,$1,$2,$3,$4,$5,$(call getPackagePath,$5))
ar5 = $(call ar6,$1,$2,$3,$4,$5,$6,$$($1_GEN)/$6/R.java)
define ar6
$1_SRCS += $7
$1_JAR_DEPS += $(7:$$($1_GEN)/%.java=$$($1_CLS)/%.class)

$7: $4 | $$($1_GEN)
	$$(call silent,AAPT $5, \
  $(AAPT) package --non-constant-id -f -m --auto-add-overlay \
          -M $3 -S $2/res -I $$($1_ANDROID_JAR) -J $$($1_GEN))

endef

# 1:name 2:path 3:aidl files
androidInterfaces = $(foreach p,$2,$(call ai1,$1,$p))
ai1 = $(call ai2,$1,$2/src,$(call find,$2/src,-name '*.aidl'))
ai2 = $(if $3,$(call ai3,$1,$2,$3))
define ai3
$1_SRCS += $(patsubst $2/%.aidl,$$($1_GEN)/%.java,$3)
$1_JAR_DEPS += $(patsubst $2/%.aidl,$$($1_CLS)/%.class,$3)

$$($1_GEN)/%.java: $2/%.aidl | $$($1_GEN)
	$$(call silent,AIDL $$(notdir $$<), \
  $$(AIDL) -p$$($1_FRAMEWORK_AIDL) -o$$($1_GEN) -I$2 $$<)
.PRECIOUS: $$($1_GEN)/%.java

endef

# 1:name 2:path 3:java files
androidSources = $(foreach p,$2,$(call aj1,$1,$(call getAndroidSourceDir,$p)))
aj1 = $(call aj2,$1,$2,$(call find,$2,-name '[A-Z]*.java'))
aj2 = $(if $3,$(call aj3,$1,$2,$3))
define aj3
$1_SOURCEPATH += $2
$1_SRCS += $3
$1_JAR_DEPS += $(patsubst $2/%.java,$$($1_CLS)/%.class,$3)

$$($1_CLS)/%.class: $2/%.java $$($1_CLASSPATH) | $$($1_CLS)
	$$(call silent,JAVA $$($1), \
  $$(JAVAC) $$($1_JFLAGS) $$($1_SRCS))

endef

# 1:name 2:jar full path 3:jar name
define jarClasses
$(foreach p,$(filter %.jar,$2),$(call jc1,$1,$p))
$(foreach p,$2,$(foreach j,$(call find,$p/libs,-name '*.jar'),$(call jc1,$1,$j)))
endef
jc1 = $(if $2,$(call jc2,$1,$2,$(notdir $2)))
define jc2
$1_CLASSPATH += $2
$1_JAR_DEPS += $$($1_WORK)/$3

$$($1_WORK)/$3: $2 | $$($1_CLS)
	$$(call silent,EXTRACT $3, \
  unzip -qqod $$($1_CLS) $2 && touch $$@)

endef

define jar

$1_WORK = .$($1:.jar=)
$1_CLS = $$($1_WORK)/cls
$1_GEN = $$($1_WORK)/gen

$1_CP = $$(call joinwith,:,$$(CLASSPATH) $$($1_CLASSPATH) $$($1_SUPPORT_JAR))
$1_SP = $$(call joinwith,:,$$($1_SOURCEPATH) $$($1_GEN))

$1_API ?= 16
$1_ANDROID_JAR = $$(call checkpath,$$(ANDROID_SDK)/platforms/android-$$($1_API)/android.jar,Missing Android API level $$($1_API))
$1_FRAMEWORK_AIDL = $$(ANDROID_SDK)/platforms/android-$$($1_API)/framework.aidl
$1_SUPPORT_JAR = $$(call getAndroidSupportJar,$$($1_SUPPORT_VERSION))
$1_JFLAGS = -d $$($1_CLS) \
            $(if $(DEBUG),-g) \
            $$(if $$($1_CP),-classpath $$($1_CP)) \
            -sourcepath $$($1_SP) \
            -target 1.5 -bootclasspath $$($1_ANDROID_JAR) \
            -encoding UTF-8 -g -source 1.5 \
            $$($1_FLAGS)

$(call jarClasses,$1,$($1_SOURCES))
$(call androidResources,$1,$($1_SOURCES))
$(call androidInterfaces,$1,$($1_SOURCES))
$(call androidSources,$1,$($1_SOURCES))

$$($1): $$($1_JAR_DEPS) | $$($1_CLS)
	$$(call silent,JAR $$@, \
  $$(JAR) cf $$@ -C $$($1_CLS) .)

$$($1_CLS)/%.class: $$($1_GEN)/%.java $$($1_CLASSPATH) | $$($1_CLS)
	$$(call silent,JAVA $$($1), \
  $$(JAVAC) $$($1_JFLAGS) $$($1_SRCS))

$$($1_CLS):
	$$(call silent,MKDIR $$@, mkdir -p $$@)

$$($1_GEN):
	$$(call silent,MKDIR $$@, mkdir -p $$@)

clean::
	rm -fr $$($1_WORK) $$($1)

endef

XCODE_BUILD_DIR = xcode
ANE_IOS_SRC_LIB = $(XCODE_BUILD_DIR)/Release-iphoneos/lib$(NAME).a
ANE_IOS_PRJ = ../src/ios/$(NAME).xcodeproj
