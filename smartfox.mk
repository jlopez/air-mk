################## Smartfox rules
SFS_ROOT = /Applications/SmartFoxServer2X
SFS_AS3_SWC = $(SFS_ROOT)/Client/ActionScript3/SFS2X_API_AS3.swc
SFS_SERVER_ROOT = $(SFS_ROOT)/SFS2X
SFS_SERVICE = $(SFS_SERVER_ROOT)/sfs2x-service
SFS_LOG_DIR = $(SFS_SERVER_ROOT)/logs
SFS_ZONES_DIR = $(SFS_SERVER_ROOT)/zones
SFS_EXT_DIR = $(SFS_SERVER_ROOT)/extensions
SFS_EXT_LIB_DIR = $(SFS_EXT_DIR)/__lib__
SFS_LOG = $(SFS_LOG_DIR)/smartfox.log
SFS_LIBS = $(wildcard $(SFS_SERVER_ROOT)/lib/*.jar)
SFS_LIBS_PATTERN = $(addprefix %/,$(notdir $(SFS_LIBS)))
sfsjarfilter = $(filter-out $(SFS_LIBS_PATTERN),$1)

sfs-%: | $(SFS_SERVICE)
	$(SFS_SERVICE) $* |cat

sfs-debug: | $(SFS_SERVICE)
	INSTALL4J_ADD_VM_PARAMS='-Xdebug -Xrunjdwp:transport=dt_socket,address=8787,server=y,suspend=n' $(SFS_SERVICE) start-launchd

sfs-debug-connect: | $(SFS_SERVICE)
	INSTALL4J_ADD_VM_PARAMS='-Xdebug -Xrunjdwp:transport=dt_socket,address=8787,server=n,suspend=n' $(SFS_SERVICE) start-launchd

sfs-log: $(SFS_LOG)
	tail -F $<

sfs-clear-log:
	rm -f $(SFS_LOG)

$(SFS_LOG): | $(SFS_LOG_DIR)
	touch $(SFS_LOG)

$(SFS_ROOT) $(SFS_AS3_SWC) $(SFS_SERVER_ROOT) $(SFS_SERVICE) $(SFS_LOG_DIR) $(SFS_ZONES_DIR) $(SFS_EXT_DIR) $(SFS_EXT_LIB_DIR):
	$(error SmartFoxServer2x not found. Please install...)

define sfs

$(call chkvars,$1_ZONE)

$1_EXT_DIR = $$(SFS_EXT_DIR)/$$($1)

$1_LIBS = $$(call sfsjarfilter,$$($2_JAR_CLASSPATH))
$1_DST_LIBS = $$(addprefix $$(SFS_EXT_LIB_DIR)/,$$(notdir $$($1_LIBS)))
$1_DST_ZONE = $$(SFS_ZONES_DIR)/$$($1).zone.xml
$1_DST_JAR_ = $$($1_EXT_DIR)/extension.jar

sfs-install:: $$($1_DST_JAR_) $$($1_DST_ZONE) $$($1_DST_LIBS)
	@

sfs-uninstall::
	rm -fr $$($1_EXT_DIR)
	rm -f $$($1_DST_ZONE) $$($1_DST_LIBS)

$$($1_DST_JAR_): $$($2_JAR) |$$($1_EXT_DIR)
	$$(call silent,COPY $4 jar, \
	cp $$< $$@)

$$($1_DST_ZONE): $$($1_ZONE) |$$(SFS_ZONES_DIR)
	$$(call silent,COPY $4 zone.xml,cp $$< $$@)

$$($1_DST_LIBS):: $$($1_LIBS) |$$(SFS_EXT_LIB_DIR)
	$$(call silent,COPY $4 libs,cp $$^ $$(SFS_EXT_LIB_DIR))

$$($1_EXT_DIR):
	$$(call silent,MKDIR $$@,mkdir $$@)

endef

$(call suffixrules,SFS,sfs)
