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
