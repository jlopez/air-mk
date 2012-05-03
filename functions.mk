# findfiles paths,wildcards
findfiles = $(wildcard $(foreach p,$1,$(foreach s,$2,$p/$s)))
findcfiles = $(call findfiles,$1,*.m *.mm *.c *.cc)
# filtercfiles,paths
filtercfiles = $(filter %.m %.mm %.c %.cc,$1)
filteroutcfiles = $(filter-out %.m %.mm %.c %.cc,$1)
# replacesuffix,suffixes,replacement,list
replacesuffix = $(foreach s,$1,$(patsubst %$s,%$2,$(filter %$s,$3)))
# dumpvars,patterns
dumpvars = $(eval $(foreach v,$(sort $(filter $1,$(.VARIABLES))),$$(info $v = $($v))))
setvpath = $(foreach p,$1,vpath $p $(sort $2))

define libtool_impl
$1_OTHER = $$(call filteroutcfiles,$$($1_SOURCES))
$1_CPATHS = $$(call filtercfiles,$$($1_SOURCES))
$1_CDIRS = $$(sort $$(dir $$($1_CPATHS)))
$1_CFILES = $$(notdir $$($1_CPATHS))
$1_CNAMES = $$(basename $$($1_CFILES))
$1_OBJS = $$(addsuffix .o,$$($1_CNAMES))
$1_DEPS = $$(patsubst %,$$(DEPDIR)/%.d,$$($1_CNAMES))

$$($1): CFLAGS += $$($1_CFLAGS)
$$($1): CXXFLAGS += $$($1_CFLAGS)
$$($1): OBJCFLAGS += $$($1_CFLAGS)
$$($1): OBJCXXFLAGS += $$($1_CFLAGS)
$$($1): $$($1_OBJS) $$($1_OTHER)
	$$(call silent,LIBTOOL $$@, \
	$$(LT) $$(LIBTOOL_FLAGS) $$^ -o $$@)

C_VPATH += $$($1_CDIRS)

-include $$($1_DEPS)
endef

libtool = $(eval $(call libtool_impl,$1))

FINDPARENT_PATH_SEARCH = .. ../.. ../../.. ../../../.. \
  ../../../../.. ../../../../../..
findfile = $(call firstpath,$(foreach p,$1,$p/$2))
firstpath = $(firstword $(wildcard $1))
findparent = $(call firstpath,$(foreach p,$(FINDPARENT_PATH_SEARCH),$p/$1))

ansi = $$'\x1B[$1m'
fg = $(call ansi,38;5;$1)
bg = $(call ansi,48;5;$1)
bold = $(call ansi,1)
ul = $(call ansi,4)
blink = $(call ansi,5)
reset = $(call ansi,0)

S := $(if $(V),,@)
define silent
@printf '  '$(call fg,42)$(bold)%-10s$(reset)'$(wordlist 2,$(words $1),$1)''\n' $(firstword $1)
$S$2
endef

macros = $(shell grep -o '@[^@]*@' $1 |sort |uniq |tr -d @)
macrosSed ='$(foreach V,$(call macros,$1),s\#@$V@\#$($V)\#g;)'
expandMacros = $(call silent,MACRO $@,sed $(call macrosSed,$<) $< >$@)
resizeImage = $(call silent,RESIZE $@,sips -z $1 $1 $< --out $@ >/dev/null)
