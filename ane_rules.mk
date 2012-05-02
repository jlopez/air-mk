################## ANE Rules
clean::
	rm -fr *.ane *.sw? *.nib *.o *.a

ane: $(ANE)

$(ANE): $(EXT_XML) $(ANE_SWC) $(ANE_SWF) $(IOS_XML) $(IOS_LIB)
	$(call silent,ADT $@, \
	adt -package -target ane $(ANE) $(EXT_XML) -swc $(ANE_SWC) \
      -platform iPhone-ARM -platformoptions $(IOS_XML) $(IOS_LIB) $(ANE_SWF) \
      -platform default $(ANE_SWF))

$(ANE_SWC): $(ANE_AS3_SRCS)
	$(call silent,COMPC $(ANE_CLASS), \
	$(COMPC) $(ASCFLAGS) -sp+=$(ANE_AS3DIR) -output $@ $(ANE_CLASS))

$(ANE_SWF): $(ANE_SWC)
	$(call silent,EXTRACT $@, unzip -qo $< $@)
	@touch $@

$(IOS_LIB): $(OBJC_OBJS)
	$(call silent,LIBTOOL $@, \
	$(LT) $(LIBTOOL_FLAGS) $^ -o $@)

%.o: %.mm | $(DEPDIR)
	$(call silent,OBJCXX $*.mm, \
	$(OBJCXX) $(OBJCXXFLAGS) -MMD -MP -MF $(df).d -o $@ -c $<)

%.o: %.m | $(DEPDIR)
	$(call silent,OBJC $*.m, \
	$(OBJC) $(OBJCFLAGS) -MMD -MP -MF $(df).d -o $@ -c $<)

%.nib: %.xib
	$(call silent,IBTOOL $@, \
	$(IBTOOL) $(IBTOOLFLAGS) --compile $@ $< 2>/dev/null)

$(DEPDIR):
	mkdir $(DEPDIR)

-include $(OBJC_DEPS)

.PHONY: ane clean
