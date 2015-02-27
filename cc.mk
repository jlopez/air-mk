COMPC ?= compc
OBJC ?= clang -x objective-c
OBJCXX ?= clang -x objective-c++
LT ?= libtool

DEPDIR ?= .deps
df = $(DEPDIR)/$(*F)

clean::
	rm -fr *.o *.a $(DEPDIR)

$(foreach l,$(filter %_LIB_SOURCES,$(.VARIABLES)),$(call libtool,$(l:_SOURCES=)))

%.o: %.mm | $(DEPDIR)
	$(call silent,OBJCXX $*.mm, \
	$(OBJCXX) $(OBJCXXFLAGS) -MMD -MP -MF $(df).d -o $@ -c $<)

%.o: %.m | $(DEPDIR)
	$(call silent,OBJC $*.m, \
	$(OBJC) $(OBJCFLAGS) -MMD -MP -MF $(df).d -o $@ -c $<)
	
%.o: %.c | $(DEPDIR)
	$(call silent,OBJC $*.c, \
	$(OBJC) $(OBJCFLAGS) -MMD -MP -MF $(df).d -o $@ -c $<)

$(DEPDIR):
	@mkdir $(DEPDIR)

$(foreach p,%.c %.cc %.m %.mm,$(eval vpath $p $(sort $(C_VPATH))))
