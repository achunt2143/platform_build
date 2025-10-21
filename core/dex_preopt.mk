####################################
<<<<<<< HEAD
# dexpreopt support - typically used on user builds to run dexopt (for Dalvik) or dex2oat (for ART) ahead of time
#
####################################

include $(BUILD_SYSTEM)/dex_preopt_config.mk

# Method returning whether the install path $(1) should be for system_other.
# Under SANITIZE_LITE, we do not want system_other. Just put things under /data/asan.
ifeq ($(SANITIZE_LITE),true)
install-on-system-other =
else
install-on-system-other = $(filter-out $(PRODUCT_DEXPREOPT_SPEED_APPS) $(PRODUCT_SYSTEM_SERVER_APPS),$(basename $(notdir $(filter $(foreach f,$(SYSTEM_OTHER_ODEX_FILTER),$(TARGET_OUT)/$(f)),$(1)))))
endif

# We want to install the profile even if we are not using preopt since it is required to generate
# the image on the device.
ALL_DEFAULT_INSTALLED_MODULES += $(call copy-many-files,$(DEXPREOPT_IMAGE_PROFILE_BUILT_INSTALLED),$(PRODUCT_OUT))

# Install boot images. Note that there can be multiple.
DEFAULT_DEX_PREOPT_INSTALLED_IMAGE :=
$(TARGET_2ND_ARCH_VAR_PREFIX)DEFAULT_DEX_PREOPT_INSTALLED_IMAGE :=
$(foreach my_boot_image_name,$(DEXPREOPT_IMAGE_NAMES),$(eval include $(BUILD_SYSTEM)/dex_preopt_libart.mk))

# Build the boot.zip which contains the boot jars and their compilation output
# We can do this only if preopt is enabled and if the product uses libart config (which sets the
# default properties for preopting).
ifeq ($(WITH_DEXPREOPT), true)
ifeq ($(PRODUCT_USES_ART), true)

boot_zip := $(PRODUCT_OUT)/boot.zip
bootclasspath_jars := $(DEXPREOPT_BOOTCLASSPATH_DEX_FILES)
system_server_jars := $(foreach m,$(PRODUCT_SYSTEM_SERVER_JARS),$(PRODUCT_OUT)/system/framework/$(m).jar)

$(boot_zip): PRIVATE_BOOTCLASSPATH_JARS := $(bootclasspath_jars)
$(boot_zip): PRIVATE_SYSTEM_SERVER_JARS := $(system_server_jars)
$(boot_zip): $(bootclasspath_jars) $(system_server_jars) $(SOONG_ZIP) $(MERGE_ZIPS) $(DEXPREOPT_IMAGE_ZIP_boot)
	@echo "Create boot package: $@"
	rm -f $@
	$(SOONG_ZIP) -o $@.tmp \
	  -C $(dir $(firstword $(PRIVATE_BOOTCLASSPATH_JARS)))/.. $(addprefix -f ,$(PRIVATE_BOOTCLASSPATH_JARS)) \
	  -C $(PRODUCT_OUT) $(addprefix -f ,$(PRIVATE_SYSTEM_SERVER_JARS))
	$(MERGE_ZIPS) $@ $@.tmp $(DEXPREOPT_IMAGE_ZIP_boot)
	rm -f $@.tmp

$(call dist-for-goals, droidcore, $(boot_zip))

endif  #PRODUCT_USES_ART
endif  #WITH_DEXPREOPT
=======
# Dexpreopt on the boot jars
#
####################################

# TODO: replace it with device's BOOTCLASSPATH
DEXPREOPT_BOOT_JARS := core:core-junit:bouncycastle:ext:framework:android.policy:services:apache-xml:filterfw
DEXPREOPT_BOOT_JARS_MODULES := $(subst :, ,$(DEXPREOPT_BOOT_JARS))

DEXPREOPT_BUILD_DIR := $(OUT_DIR)
DEXPREOPT_PRODUCT_DIR := $(patsubst $(DEXPREOPT_BUILD_DIR)/%,%,$(PRODUCT_OUT))/dex_bootjars
DEXPREOPT_BOOT_JAR_DIR := system/framework
DEXPREOPT_DEXOPT := $(patsubst $(DEXPREOPT_BUILD_DIR)/%,%,$(DEXOPT))

DEXPREOPT_BOOT_JAR_DIR_FULL_PATH := $(DEXPREOPT_BUILD_DIR)/$(DEXPREOPT_PRODUCT_DIR)/$(DEXPREOPT_BOOT_JAR_DIR)

DEXPREOPT_BOOT_ODEXS := $(foreach b,$(DEXPREOPT_BOOT_JARS_MODULES),\
    $(DEXPREOPT_BOOT_JAR_DIR_FULL_PATH)/$(b).odex)

# If the target is a uniprocessor, then explicitly tell the preoptimizer
# that fact. (By default, it always optimizes for an SMP target.)
ifeq ($(TARGET_CPU_SMP),true)
DEXPREOPT_UNIPROCESSOR :=
else
DEXPREOPT_UNIPROCESSOR := --uniprocessor
endif

# $(1): the .jar or .apk to remove classes.dex
define dexpreopt-remove-classes.dex
$(hide) $(AAPT) remove $(1) classes.dex
endef

# $(1): the input .jar or .apk file
# $(2): the output .odex file
define dexpreopt-one-file
$(hide) $(DEXPREOPT) --dexopt=$(DEXPREOPT_DEXOPT) --build-dir=$(DEXPREOPT_BUILD_DIR) \
	--product-dir=$(DEXPREOPT_PRODUCT_DIR) --boot-dir=$(DEXPREOPT_BOOT_JAR_DIR) \
	--boot-jars=$(DEXPREOPT_BOOT_JARS) $(DEXPREOPT_UNIPROCESSOR) \
	$(patsubst $(DEXPREOPT_BUILD_DIR)/%,%,$(1)) \
	$(patsubst $(DEXPREOPT_BUILD_DIR)/%,%,$(2))
endef

# $(1): boot jar module name
define _dexpreopt-boot-jar
$(eval _dbj_jar := $(DEXPREOPT_BOOT_JAR_DIR_FULL_PATH)/$(1).jar)
$(eval _dbj_odex := $(DEXPREOPT_BOOT_JAR_DIR_FULL_PATH)/$(1).odex)
$(eval _dbj_jar_no_dex := $(DEXPREOPT_BOOT_JAR_DIR_FULL_PATH)/$(1)_nodex.jar)
$(eval _dbj_src_jar := $(call intermediates-dir-for,JAVA_LIBRARIES,$(1),,COMMON)/javalib.jar)
$(eval $(_dbj_odex): PRIVATE_DBJ_JAR := $(_dbj_jar))
$(_dbj_odex) : $(_dbj_src_jar) | $(ACP) $(DEXPREOPT) $(DEXOPT)
	@echo "Dexpreopt Boot Jar: $$@"
	$(hide) rm -f $$@
	$(hide) mkdir -p $$(dir $$@)
	$(hide) $(ACP) -fp $$< $$(PRIVATE_DBJ_JAR)
	$$(call dexpreopt-one-file,$$(PRIVATE_DBJ_JAR),$$@)

$(_dbj_jar_no_dex) : $(_dbj_src_jar) | $(ACP) $(AAPT)
	$$(call copy-file-to-target)
	$$(call dexpreopt-remove-classes.dex,$$@)

$(eval _dbj_jar :=)
$(eval _dbj_odex :=)
$(eval _dbj_jar_no_dex :=)
$(eval _dbj_src_jar :=)
endef

$(foreach b,$(DEXPREOPT_BOOT_JARS_MODULES),$(eval $(call _dexpreopt-boot-jar,$(b))))

# $(1): the rest list of boot jars
define _build-dexpreopt-boot-jar-dependency-pair
$(if $(filter 1,$(words $(1)))$(filter 0,$(words $(1))),,\
	$(eval _bdbjdp_target := $(DEXPREOPT_BOOT_JAR_DIR_FULL_PATH)/$(word 2,$(1)).odex) \
	$(eval _bdbjdp_dep := $(DEXPREOPT_BOOT_JAR_DIR_FULL_PATH)/$(word 1,$(1)).odex) \
	$(eval $(call add-dependency,$(_bdbjdp_target),$(_bdbjdp_dep))) \
	$(eval $(call _build-dexpreopt-boot-jar-dependency-pair,$(wordlist 2,999,$(1)))))
endef

define _build-dexpreopt-boot-jar-dependency
$(call _build-dexpreopt-boot-jar-dependency-pair,$(DEXPREOPT_BOOT_JARS_MODULES))
endef

$(eval $(call _build-dexpreopt-boot-jar-dependency))
>>>>>>> origin
