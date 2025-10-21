###########################################################
## Standard rules for building any target-side binaries
## with dynamic linkage (dynamic libraries or executables
## that link with dynamic libraries)
##
## Files including this file must define a rule to build
## the target $(linked_module).
###########################################################

# This constraint means that we can hard-code any $(TARGET_*) variables.
ifdef LOCAL_IS_HOST_MODULE
$(error This file should not be used to build host binaries.  Included by (or near) $(lastword $(filter-out config/%,$(MAKEFILE_LIST))))
endif

<<<<<<< HEAD
# The name of the target file, without any path prepended.
# This duplicates logic from base_rules.mk because we need to
# know its results before base_rules.mk is included.
include $(BUILD_SYSTEM)/configure_module_stem.mk

intermediates := $(call local-intermediates-dir,,$(LOCAL_2ND_ARCH_VAR_PREFIX))
=======
LOCAL_UNSTRIPPED_PATH := $(strip $(LOCAL_UNSTRIPPED_PATH))
ifeq ($(LOCAL_UNSTRIPPED_PATH),)
  ifeq ($(LOCAL_MODULE_PATH),)
    LOCAL_UNSTRIPPED_PATH := $(TARGET_OUT_$(LOCAL_MODULE_CLASS)_UNSTRIPPED)
  else
    # We have to figure out the corresponding unstripped path if LOCAL_MODULE_PATH is customized.
    LOCAL_UNSTRIPPED_PATH := $(TARGET_OUT_UNSTRIPPED)/$(patsubst $(PRODUCT_OUT)/%,%,$(LOCAL_MODULE_PATH))
  endif
endif

# The name of the target file, without any path prepended.
# TODO: This duplicates logic from base_rules.mk because we need to
#       know its results before base_rules.mk is included.
#       Consolidate the duplicates.
LOCAL_MODULE_STEM := $(strip $(LOCAL_MODULE_STEM))
ifeq ($(LOCAL_MODULE_STEM),)
  LOCAL_MODULE_STEM := $(LOCAL_MODULE)
endif
LOCAL_INSTALLED_MODULE_STEM := $(LOCAL_MODULE_STEM)$(LOCAL_MODULE_SUFFIX)
LOCAL_BUILT_MODULE_STEM := $(LOCAL_INSTALLED_MODULE_STEM)

# base_rules.make defines $(intermediates), but we need its value
# before we include base_rules.  Make a guess, and verify that
# it's correct once the real value is defined.
guessed_intermediates := $(call local-intermediates-dir)
>>>>>>> origin

# Define the target that is the unmodified output of the linker.
# The basename of this target must be the same as the final output
# binary name, because it's used to set the "soname" in the binary.
# The includer of this file will define a rule to build this target.
<<<<<<< HEAD
linked_module := $(intermediates)/LINKED/$(notdir $(my_installed_module_stem))
=======
linked_module := $(guessed_intermediates)/LINKED/$(LOCAL_BUILT_MODULE_STEM)
>>>>>>> origin

ALL_ORIGINAL_DYNAMIC_BINARIES += $(linked_module)

# Because TARGET_SYMBOL_FILTER_FILE depends on ALL_ORIGINAL_DYNAMIC_BINARIES,
# the linked_module rules won't necessarily inherit the PRIVATE_
# variables from LOCAL_BUILT_MODULE.  This tells binary.make to explicitly
# define the PRIVATE_ variables for linked_module as well as for
# LOCAL_BUILT_MODULE.
LOCAL_INTERMEDIATE_TARGETS := $(linked_module)

###################################
<<<<<<< HEAD
include $(BUILD_SYSTEM)/use_lld_setup.mk
include $(BUILD_SYSTEM)/binary.mk
###################################

###########################################################
## Store a copy with symbols for symbolic debugging
###########################################################
ifeq ($(LOCAL_UNSTRIPPED_PATH),)
my_unstripped_path := $(TARGET_OUT_UNSTRIPPED)/$(patsubst $(PRODUCT_OUT)/%,%,$(my_module_path))
else
my_unstripped_path := $(LOCAL_UNSTRIPPED_PATH)
endif
symbolic_input := $(linked_module)
symbolic_output := $(my_unstripped_path)/$(my_installed_module_stem)
$(symbolic_output) : $(symbolic_input)
	@echo "target Symbolic: $(PRIVATE_MODULE) ($@)"
	$(copy-file-to-target)

###########################################################
## Store breakpad symbols
###########################################################

ifeq ($(BREAKPAD_GENERATE_SYMBOLS),true)
my_breakpad_path := $(TARGET_OUT_BREAKPAD)/$(patsubst $(PRODUCT_OUT)/%,%,$(my_module_path))
breakpad_input := $(linked_module)
breakpad_output := $(my_breakpad_path)/$(my_installed_module_stem).sym
$(breakpad_output) : $(breakpad_input) | $(BREAKPAD_DUMP_SYMS) $(PRIVATE_READELF)
	@echo "target breakpad: $(PRIVATE_MODULE) ($@)"
	@mkdir -p $(dir $@)
	$(hide) if $(PRIVATE_READELF) -S $< > /dev/null 2>&1 ; then \
	  $(BREAKPAD_DUMP_SYMS) -c $< > $@ ; \
	else \
	  echo "skipped for non-elf file."; \
	  touch $@; \
	fi
$(LOCAL_BUILT_MODULE) : $(breakpad_output)
endif
=======
include $(BUILD_SYSTEM)/binary.mk
###################################

# Make sure that our guess at the value of intermediates was correct.
ifneq ($(intermediates),$(guessed_intermediates))
$(error Internal error: guessed path '$(guessed_intermediates)' doesn't match '$(intermediates))
endif

###########################################################
## Compress
###########################################################
compress_input := $(linked_module)

ifeq ($(strip $(LOCAL_COMPRESS_MODULE_SYMBOLS)),)
  LOCAL_COMPRESS_MODULE_SYMBOLS := $(strip $(TARGET_COMPRESS_MODULE_SYMBOLS))
endif

ifeq ($(LOCAL_COMPRESS_MODULE_SYMBOLS),true)
$(error Symbol compression not yet supported.)
compress_output := $(intermediates)/COMPRESSED-$(LOCAL_BUILT_MODULE_STEM)

#TODO: write the real $(STRIPPER) rule.
#TODO: define a rule to build TARGET_SYMBOL_FILTER_FILE, and
#      make it depend on ALL_ORIGINAL_DYNAMIC_BINARIES.
$(compress_output): $(compress_input) $(TARGET_SYMBOL_FILTER_FILE) | $(ACP)
	@echo "target Compress Symbols: $(PRIVATE_MODULE) ($@)"
	$(copy-file-to-target)
else
# Skip this step.
compress_output := $(compress_input)
endif

###########################################################
## Store a copy with symbols for symbolic debugging
###########################################################
symbolic_input := $(compress_output)
symbolic_output := $(LOCAL_UNSTRIPPED_PATH)/$(LOCAL_BUILT_MODULE_STEM)
$(symbolic_output) : $(symbolic_input) | $(ACP)
	@echo "target Symbolic: $(PRIVATE_MODULE) ($@)"
	$(copy-file-to-target)

>>>>>>> origin

###########################################################
## Strip
###########################################################
strip_input := $(symbolic_output)
strip_output := $(LOCAL_BUILT_MODULE)

<<<<<<< HEAD
my_strip_module := $(firstword \
  $(LOCAL_STRIP_MODULE_$($(my_prefix)$(LOCAL_2ND_ARCH_VAR_PREFIX)ARCH)) \
  $(LOCAL_STRIP_MODULE))
ifeq ($(my_strip_module),)
  my_strip_module := mini-debug-info
endif

ifeq ($(my_strip_module),false)
  my_strip_module :=
endif

my_strip_args :=
ifeq ($(my_strip_module),mini-debug-info)
  my_strip_args += --keep-mini-debug-info
else ifeq ($(my_strip_module),keep_symbols)
  my_strip_args += --keep-symbols
endif

ifeq (,$(filter no_debuglink mini-debug-info,$(my_strip_module)))
  ifneq ($(TARGET_BUILD_VARIANT),user)
    my_strip_args += --add-gnu-debuglink
  endif
endif

ifeq ($($(my_prefix)OS),darwin)
  # llvm-strip does not support Darwin Mach-O yet.
  my_strip_args += --use-gnu-strip
endif

valid_strip := mini-debug-info keep_symbols true no_debuglink
ifneq (,$(filter-out $(valid_strip),$(my_strip_module)))
  $(call pretty-error,Invalid strip value $(my_strip_module), only one of $(valid_strip) allowed)
endif

ifneq (,$(my_strip_module))
  $(strip_output): PRIVATE_STRIP_ARGS := $(my_strip_args)
  $(strip_output): PRIVATE_TOOLS_PREFIX := $($(LOCAL_2ND_ARCH_VAR_PREFIX)$(my_prefix)TOOLS_PREFIX)
  $(strip_output): $(strip_input) $(SOONG_STRIP_PATH)
	@echo "$($(PRIVATE_PREFIX)DISPLAY) Strip: $(PRIVATE_MODULE) ($@)"
	CLANG_BIN=$(LLVM_PREBUILTS_PATH) \
	CROSS_COMPILE=$(PRIVATE_TOOLS_PREFIX) \
	XZ=$(XZ) \
	$(SOONG_STRIP_PATH) -i $< -o $@ -d $@.d $(PRIVATE_STRIP_ARGS)
  $(call include-depfile,$(strip_output).d)
else
  # Don't strip the binary, just copy it.  We can't skip this step
  # because a copy of the binary must appear at LOCAL_BUILT_MODULE.
  $(strip_output): $(strip_input)
	@echo "target Unstripped: $(PRIVATE_MODULE) ($@)"
	$(copy-file-to-target)
endif # my_strip_module

$(cleantarget): PRIVATE_CLEAN_FILES += \
    $(linked_module) \
    $(breakpad_output) \
    $(symbolic_output) \
    $(strip_output)
=======
ifeq ($(strip $(LOCAL_STRIP_MODULE)),)
  LOCAL_STRIP_MODULE := $(strip $(TARGET_STRIP_MODULE))
endif

ifeq ($(LOCAL_STRIP_MODULE),true)
# Strip the binary
$(strip_output): $(strip_input) | $(TARGET_STRIP)
	$(transform-to-stripped)
else
# Don't strip the binary, just copy it.  We can't skip this step
# because a copy of the binary must appear at LOCAL_BUILT_MODULE.
#
# If the binary we're copying is acp or a prerequisite,
# use cp(1) instead.
ifneq ($(LOCAL_ACP_UNAVAILABLE),true)
$(strip_output): $(strip_input) | $(ACP)
	@echo "target Unstripped: $(PRIVATE_MODULE) ($@)"
	$(copy-file-to-target)
else
$(strip_output): $(strip_input)
	@echo "target Unstripped: $(PRIVATE_MODULE) ($@)"
	$(copy-file-to-target-with-cp)
endif
endif # LOCAL_STRIP_MODULE


$(cleantarget): PRIVATE_CLEAN_FILES := \
			$(PRIVATE_CLEAN_FILES) \
			$(linked_module) \
			$(symbolic_output) \
			$(compress_output)
>>>>>>> origin
