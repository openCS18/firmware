#!/bin/sh

SRC_SCRIPT=${BR2_EXTERNAL_OPENCS18_PATH}/board/opencs18/v1/usb-bootscript.raw
DST_IMG=${BINARIES_DIR}/recovery.scr

SRC_SCRIPT=${1:-$SRC_SCRIPT}
DST_IMG=${2:-$DST_IMG}

#env

echo Generating $DST_IMG
mkimage -T script -C none -n 'Default Environment' -A arm -d "$SRC_SCRIPT" "$DST_IMG"