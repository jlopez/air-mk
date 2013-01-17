, := ,
comma := ,
space :=
space +=
$(space) :=
$(space) +=
joinwith = $(subst $(space),$1,$(strip $2))
# findfiles paths,wildcards
find = $(if $(wildcard $1),$(shell find $1 $2))
findfiles = $(wildcard $(foreach p,$1,$(foreach s,$2,$p/$s)))
findcfiles = $(call findfiles,$1,*.m *.mm *.c *.cc)
findjavafiles = $(call find,$1,-iname '*.java')
filterout = $(foreach s,$2,$(if $(findstring $1,$s),,$s))
# filtercfiles,paths
filtercfiles = $(filter %.m %.mm %.c %.cc,$1)
filteroutcfiles = $(filter-out %.m %.mm %.c %.cc,$1)
# replacesuffix,suffixes,replacement,list
replacesuffix = $(foreach s,$1,$(patsubst %$s,%$2,$(filter %$s,$3)))
# replacedir,fromdirs,todir,files[,fromext,toext]
replacedir = $(foreach p,$1,$(patsubst $p/%$4,$2/%$5,$(filter $p/%$4,$3)))
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
findparent = $(call check,$(call firstpath,$(foreach p,$(FINDPARENT_PATH_SEARCH),$p/$1)),Parent path $1 not found)

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

define dumpvar
$(info $(shell printf $(call fg,42)$(bold)$1$(reset)' "$($1)"'))
endef

macros = $(shell grep -o '@[^@]*@' $1 |sort |uniq |tr -d @)
macrosSed ='$(foreach V,$(call macros,$1),s\#@$V@\#$($V)\#g;)'
expandMacros = $(call silent,MACRO $@,sed $(call macrosSed,$<) $< >$@)
resizeImage = $(call silent,RESIZE $@,sips -z $1 $1 $< --out $@ >/dev/null)

SPACE = $(eval) $(eval)
# Join list with separator
joinsep = $(subst $(SPACE),$2,$1)

# Fail if given path does not exist
checkpath = $(if $(wildcard $1),$1,$(error Path $1 does not exist))
# Fail if given value missing
check = $(if $1,$1,$(error $2))
# Fail if given variable is undefined $(call chkvar,VAR_NAME)
chkvar = $(if $($1),$($1),$(error Variable '$1' not defined))
# Fail if any of the variables given is undefined $(call chkvars,VAR1 VAR2...)
chkvars = $(foreach v,$1,$(if $($v),,$(error Variable '$v' not defined)))

# Find first subdir that exists: $(call firstsubdir,path,subdir1 subdir2 subdir3)
firstsubdir = $(firstword $(wildcard $(patsubst %,$1/%,$2)))

# Evaluates definition (definition name, variable name, suffix)
# Parameters passed to definition: (variable name, variable stem, dir, basename, suffix)
_suffixrules2 = $(call $1,$2,$3,$4,$5,$6)$(call $6_PLUGIN,$2,$3,$4,$5,$6)
_suffixrules = $(eval $(call _suffixrules2,$1,$2,$(patsubst %_$3,%,$2),$(dir $($2)),$(basename $(notdir $($2))),$3))
suffixrules = $(foreach l,$(filter %_$1,$(.VARIABLES)),$(if $($l),$(call _suffixrules,$2,$l,$1)))
# Debug suffix rule
# Usage: $$(call debugsuffixrule,$1,$5)
debugsuffixrule = $(foreach v,$(filter $1_%,$(.VARIABLES)),$(call dumpvar,$v))$(error Bye)
