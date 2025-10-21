ifneq ($(strip $(LOCAL_SRC_FILES)),)
$(error LOCAL_SRC_FILES are not allowed for phony packages)
endif
<<<<<<< HEAD
$(call record-module-type,PHONY_PACKAGE)
ifneq ($(strip $(LOCAL_SRC_FILES)),)
$(error LOCAL_SRC_FILES are not allowed for phony packages)
=======

ifeq ($(strip $(LOCAL_REQUIRED_MODULES)),)
$(error LOCAL_REQUIRED_MODULES is required for phony packages)
>>>>>>> origin
endif

LOCAL_MODULE_CLASS := FAKE
LOCAL_MODULE_SUFFIX := -timestamp

include $(BUILD_SYSTEM)/base_rules.mk

<<<<<<< HEAD
$(LOCAL_BUILT_MODULE): $(LOCAL_ADDITIONAL_DEPENDENCIES)
=======
$(LOCAL_BUILT_MODULE):
>>>>>>> origin
	$(hide) echo "Fake: $@"
	$(hide) mkdir -p $(dir $@)
	$(hide) touch $@
