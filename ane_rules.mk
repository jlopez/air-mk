################## ANE Rules
clean::
	rm -fr $(EXT_XML) *.ane *.sw? *.nib META-INF

ane: $(ANE)

$(EXT_XML): $(EXT_XML_IN)
	$(call expandMacros)

$(ANE): $(EXT_XML) $(ANE_SWC) $(ANE_SWF) $(IOS_XML) $(ANE_IOS_LIB) $(ANE_BUNDLED_LIBS)
	$(call silent,ADT $@, \
	adt -package -target ane $(ANE) $(EXT_XML) -swc $(ANE_SWC) \
      -platform iPhone-ARM -platformoptions $(IOS_XML) $(ANE_IOS_LIB) $(ANE_SWF) \
      -platform default $(ANE_SWF))
	$(if $(ANE_BUNDLED_LIBS), \
	  $(call silent,MERGE $@, \
	  rm -fr $(ANE_BUNDLED_LIBS_DIR) && \
	  mkdir -p $(ANE_BUNDLED_LIBS_DIR) && \
	  cp $(ANE_BUNDLED_LIBS) $(ANE_BUNDLED_LIBS_DIR) && \
	  zip -9qr $@ $(ANE_BUNDLED_LIBS_DIR)))

$(ANE_SWC): $(ANE_AS3_SRCS)
	$(call silent,COMPC $(ANE_CLASS), \
	$(COMPC) $(ASCFLAGS) -sp+=$(ANE_AS3DIR) -output $@ $(ANE_CLASS))

$(ANE_SWF): $(ANE_SWC)
	$(call silent,EXTRACT $@, unzip -qo $< $@)
	@touch $@

.PHONY: ane clean
