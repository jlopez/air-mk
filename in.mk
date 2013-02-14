################## IN files

define in

$1_WORK = $$(WORK_DIR)/$2

$2 ?= $$($1_WORK)/$(4:%.in=%)

$$($2): $$($1) | $$($1_WORK)
	$$(call expandMacros)

$$($1_WORK):
	$$(call mkdir)

endef

$(call suffixrules,IN,in)
