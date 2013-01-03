################## SWF Variables
MXMLC = $(FLEX_SDK)/bin/mxmlc

define swf

$(call chkvars,$1_SOURCES $1_MAIN)

$1_SOURCE_DIRS = $$(filter-out %.swc,$$($1_SOURCES))
$1_SOURCE_SWCS = $$(filter %.swc,$$($1_SOURCES))

$1_SOURCE_FILES = $$(call find,$$($1_SOURCE_DIRS),-name '*.as')
$1_CLASSPATH = $$(call find,$$($1_SOURCE_DIRS),-name '*.swc') $$($1_SOURCE_SWCS)

$1_CP = $$(call joinwith,$$(,),$$($1_CLASSPATH))
$1_SP = $$(call joinwith,$$(,),$$($1_SOURCE_DIRS))

$1_CFLAGS = $$($1_FLAGS) \
            $$(if $$($1_CONFIG),-load-config+=$$($1_CONFIG)) \
            $$(if $$($1_SP),-sp+=$$($1_SP)) \
            $$(if $$($1_CP),-l+=$$($1_CP)) \
						-file-specs=$$($1_MAIN) \
            $(if $(DEBUG),-debug) \

$$($1): $$($1_SOURCES) $$($1_CLASSPATH) $$($1_CONFIG)
	$$(call silent,MXMLC $$@, \
  $$(MXMLC) $$($1_CFLAGS) -o $$@)

clean::
	rm -fr $$($1)

endef

$(call suffixrules,SWF,swf)
