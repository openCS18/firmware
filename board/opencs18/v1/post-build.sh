#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# build production startup script
${DIR}/gen-bootscript.sh

# build dev startup script
${DIR}/gen-bootscript.sh ${BR2_EXTERNAL_OPENCS18_PATH}/board/opencs18/v1/dev-usb-bootscript.raw ${BINARIES_DIR}/dev-recovery.scr

#grep -q "GADGET_SERIAL" "${TARGET_DIR}/etc/inittab" \
#	|| echo '/dev/ttyGS0::respawn:/sbin/getty -L  /dev/ttyGS0 0 vt100 # GADGET_SERIAL' >> "${TARGET_DIR}/etc/inittab"
#grep -q "ubi0:persist" "${TARGET_DIR}/etc/fstab" \
#	|| echo 'ubi0:persist	/root		ubifs	defaults	0	0' >> "${TARGET_DIR}/etc/fstab"
