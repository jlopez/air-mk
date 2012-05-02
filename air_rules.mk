################## SWF Rules
all: ipa

clean::
	rm -fr *.swf ext *.out *.ipa *.apk *.dSYM* aot* AOT* air*
	rm -fr install* $(APP_XML) $(ICONS)

ipa: $(IPA)

apk: $(APK)

swf: $(SWF)

icons: $(ICONS)

test: $(APP_XML) $(EXPANDED_ANES) $(SWF) | $(EXT_DIR)
	$(call silent,ADL $<, \
	adl -profile mobileDevice -extdir $(EXT_DIR) \
    $(ADL_SCREENSIZE) $< . |grep -v DVFreeThread |cat)

$(EXPANDED_ANES): $(EXT_DIR)/%.ane : %.ane
	$(call silent,EXPAND $<, \
	rm -fr $@; \
	mkdir -p $@; \
	unzip -qd $@ $<)

install: $(IPA)
	$(call silent,INSTALL $<, \
	ideviceinstaller -i $< >/dev/null)
	@touch $@

upload: $(IPA) $(DSYM_ZIP)
	$(call silent,UPLOAD $(IPA) $(VERSION).$(REVISION) $(COMMIT), \
	curl http://testflightapp.com/api/builds.json -\#\
    -F file=@$< \
    -F dsym=@$(DSYM_ZIP) \
    -F api_token=$(TESTFLIGHT_API_TOKEN) \
    -F team_token=$(TESTFLIGHT_TEAM_TOKEN) \
    -F notes=$(NOTES) \
    -F distribution_lists=$(TESTFLIGHT_DLS) \
    -F notify=$(TESTFLIGHT_NOTIFY) \
    -F replace=True >upload.out)

$(DSYM_ZIP): $(DSYM)
	$(call silent,ZIP $<, \
	zip -9rq $@ $<)

$(APP_XML): $(APP_XML_IN) $(GIT_HEAD)
	$(call expandMacros)

$(IPA): $(SWF) $(APP_XML) $(ANES) $(OTHER_RESOURCES) $(ICONS)
	$(call silent,ADT $@, \
	rm -fr $(DSYM); \
	$(ADT) $(ADT_FLAGS) $@ $(APP_XML) $(SDK_OPT) $< $(ICONS) \
    -extdir . $(OTHER_RESOURCES) >adt.out; \
	grep -v 4-byte adt.out |cat)

# Android
run-apk: install-apk
	$(call silent,RUN $(APK), \
	$(ADT) -launchApp -platform android \
	  -platformsdk $(ANDROID_SDK) -appid $(APP_ID))

install-apk: $(APK)
	$(call silent,INSTALL $<, \
	$(ADB) install -r $<; \
	touch $@)

$(APK): $(SWF) $(APP_XML)

%.apk: %.swf
	$(call silent,ADT $@, \
	$(ADT) $(APK_ADTFLAGS) $@ $(APP_XML) $< $(ICONS) \
	  -extdir . $(OTHER_RESOURCES))

$(SWF): $(SRC_MAIN) $(ANES)
	$(call silent,MXMLC $@, \
	$(MXMLC) $(ASCFLAGS) \
    $(foreach A,$(ANES),-external-library-path+=$A) \
    -output $@ $<)

%-29x29.png: %.png
	$(call resizeImage,29)

%-36x36.png: %.png
	$(call resizeImage,36)

%-48x48.png: %.png
	$(call resizeImage,48)

%-57x57.png: %.png
	$(call resizeImage,57)

%-72x72.png: %.png
	$(call resizeImage,72)

%-114x114.png: %.png
	$(call resizeImage,114)

%-512x512.png: %.png
	$(call resizeImage,512)

.PHONY: all clean ipa swf icons test upload
.PHONY: apk run-apk

