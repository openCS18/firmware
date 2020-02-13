################################################################################
#
# virtual touchscreen
#
################################################################################

VIRTUAL_TOUCHSCREEN_VERSION = v1.2
VIRTUAL_TOUCHSCREEN_GIT_SUBMODULES = NO
VIRTUAL_TOUCHSCREEN_SITE = https://github.com/openCS18/virtual_touchscreen.git
VIRTUAL_TOUCHSCREEN_SITE_METHOD = git
VIRTUAL_TOUCHSCREEN_LICENSE = GPLv2
VIRTUAL_TOUCHSCREEN_LICENSE_FILES = LICENSE

define KERNEL_MODULE_BUILD_CMDS
        $(MAKE) -C '$(@D)' LINUX_DIR='$(LINUX_DIR)' CC='$(TARGET_CC)' LD='$(TARGET_LD)' modules
endef

$(eval $(kernel-module))
$(eval $(generic-package))
