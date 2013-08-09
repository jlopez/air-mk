################## JAVA Variables

# 1:name 2:path 3:java files
androidSources = $(foreach p,$2,$(call aj1,$1,$p/src))
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
$(foreach p,$2,$(foreach j,$(call find,$p/lib,-name '*.jar'),$(call jc1,$1,$j)))
endef
jc1 = $(if $2,$(call jc2,$1,$2,$(notdir $2)))
define jc2
$1_CLASSPATH += $2
$1_JAR_DEPS += $2

endef

define jar

$1_WORK = $(WORK_DIR)/.$1
$1_CLS = $$($1_WORK)/cls

$1_CP = $$(call joinwith,:,$$(CLASSPATH) $$($1_CLASSPATH))
$1_SP = $$(call joinwith,:,$$($1_SOURCEPATH))

$1_JFLAGS = -d $$($1_CLS) \
            $(if $(DEBUG),-g) \
            $$(if $$($1_CP),-classpath $$($1_CP)) \
            -sourcepath $$($1_SP) \
            -encoding UTF-8 -g \
            $$($1_FLAGS)

$(call jarClasses,$1,$($1_SOURCES))
$(call androidSources,$1,$($1_SOURCES))

$$($1): $$($1_JAR_DEPS) | $$($1_CLS)
	$$(call silent,JAR $$@, \
  $$(JAR) cf $$@ -C $$($1_CLS) .)

$$($1_CLS):
	$$(call silent,MKDIR $$@, mkdir -p $$@)

clean::
	rm -fr $$($1_WORK) $$($1)

endef

$(call suffixrules,JAR,jar)
