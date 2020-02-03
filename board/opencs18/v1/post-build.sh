#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

SCRIPT_PATH=${BR2_EXTERNAL_OPENCS18_PATH}/board/opencs18/v1

echo Building production startup script
${DIR}/gen-bootscript.sh

echo Building dev startup script
${DIR}/gen-bootscript.sh ${SCRIPT_PATH}/dev-usb-bootscript.raw ${BINARIES_DIR}/dev-recovery.scr

echo Building NFS startup script

# the following substitution doesn't work yet. #ip and nfsroot is hardcoded
cp $SCRIPT_PATH/nfs-bootscript.tmpl $SCRIPT_PATH/nfs-bootscript.raw
sed -i "s/<ip>/${BR2_PACKAGE_OPENCS18_NFS_TARGET_IP_ADDRESS}/g" $SCRIPT_PATH/nfs-bootscript.raw
sed -i "s/<nfsroot>/${BR2_PACKAGE_OPENCS18_NFS_TARGET_IP_ADDRESS}/g" $SCRIPT_PATH/nfs-bootscript.raw
${DIR}/gen-bootscript.sh ${SCRIPT_PATH}/nfs-bootscript.raw ${BINARIES_DIR}/nfs-recovery.scr

#grep -q "GADGET_SERIAL" "${TARGET_DIR}/etc/inittab" \
#	|| echo '/dev/ttyGS0::respawn:/sbin/getty -L  /dev/ttyGS0 0 vt100 # GADGET_SERIAL' >> "${TARGET_DIR}/etc/inittab"
#grep -q "ubi0:persist" "${TARGET_DIR}/etc/fstab" \
#	|| echo 'ubi0:persist	/root		ubifs	defaults	0	0' >> "${TARGET_DIR}/etc/fstab"
