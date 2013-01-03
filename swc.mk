################## SWC Variables
COMPC = $(FLEX_SDK)/bin/compc

define swc

$(call chkvars,$1_SOURCES)

$1_SOURCE_DIRS = $$(filter-out %.swc,$$($1_SOURCES))
$1_SOURCE_SWCS = $$(filter %.swc,$$($1_SOURCES))

$1_SOURCE_FILES = $$(call find,$$($1_SOURCE_DIRS),-name '*.as')
$1_CLASSPATH = $$(call find,$$($1_SOURCE_DIRS),-name '*.swc') $$($1_SOURCE_SWCS)

$1_CP = $$(call joinwith,$$(,),$$($1_CLASSPATH))
$1_SP = $$(call joinwith,$$(,),$$($1_SOURCE_DIRS))

$1_CFLAGS = $$(if $$($1_SP),-is+=$$($1_SP) -sp+=$$($1_SP)) \
            $$(if $$($1_CP),-l+=$$($1_CP)) \
            $(if $(DEBUG),-debug) \
            $$($1_FLAGS)

$$($1): $$($1_SOURCE_FILES) $$($1_CLASSPATH)
	$$(call silent,COMPC $$@, \
  $$(COMPC) $$($1_CFLAGS) -o $$@)

clean::
	rm -fr $$($1)

endef

$(call suffixrules,SWC,swc)
