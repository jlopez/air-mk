################## Python (virtualenv) rules
VIRTUALENV = $(WORK_DIR)/virtualenv.py

$(VIRTUALENV): | $(WORK_DIR)
	$(call silent,CURL virtualenv, \
	curl -s -o$@ https://raw.github.com/pypa/virtualenv/master/virtualenv.py)

define virtualenv

$(call chkvars,$1_REQUIREMENTS)

$1_SENTRY = $$($1)/.sentry

$$($1): | $$(VIRTUALENV)
	$$(call silent,VIRTUALENV $2, \
	python $$(VIRTUALENV) $$@)

$$($1_SENTRY): $$($1_REQUIREMENTS) | $$($1)
	$$(call silent,PIP $2, \
	. $$($1)/bin/activate && pip install -r $$<)
	$$(call silent,TOUCH $2,touch $$@)

endef

$(call suffixrules,VIRTUALENV,virtualenv)
