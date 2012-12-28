################## Flash Variables

define swf

$(chkvars $1_SOURCEPATH $1_MAIN $1_CONFIG)

$1_SOURCES = $$(call find,$$($1_SOURCEPATH),-name '*.as')
$1_CLASSPATH = $$(call find,$$($1_SOURCEPATH),-name '*.swc')

$1_CP = $$(call joinwith,$$(,),$$($1_CLASSPATH))
$1_SP = $$(call joinwith,$$(,),$$($1_SOURCEPATH))

$1_CFLAGS = -load-config+=$$($1_CONFIG) \
            $$(if $$($1_SP),-sp+=$$($1_SP)) \
            $$(if $$($1_CP),-l+=$$($1_CP)) \
						-file-specs=$$($1_MAIN) \
            $(if $(DEBUG),-debug) \
            $$($1_FLAGS)

$$($1): $$($1_SOURCES) $$($1_CLASSPATH) $$($1_CONFIG)
	$$(call silent,MXMLC $$@, \
  $$(MXMLC) $$($1_CFLAGS) -o $$@)

clean::
	rm -fr $$($1)

endef

$(call suffixrules,SWF,swf)
