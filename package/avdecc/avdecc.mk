################################################################################
#
# avdecc
#
################################################################################

AVDECC_VERSION = v2.11.3
AVDECC_GIT_SUBMODULES = YES
AVDECC_SITE = https://github.com/openCS18/avdecc.git
AVDECC_SITE_METHOD = git
#AVDECC_SOURCE = v$(AVDECC_VERSION).tar.gz
AVDECC_LICENSE = Custom
AVDECC_LICENSE_FILES = LICENSE
AVDECC_DEPENDENCIES = ncurses libpcap

AVDECC_CONF_OPTS = -DBUILD_AVDECC_EXAMPLES=ON -DINSTALL_AVDECC_EXAMPLES=ON

$(eval $(cmake-package))
