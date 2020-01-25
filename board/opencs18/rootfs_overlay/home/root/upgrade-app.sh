#!/bin/sh
# Mixer firmware upgrade script
# Copyright (C) 2013 Presonus Audio Electronics
#
# This script performs a firmware upgrade for the X-Men Mixers, returning various 
# nonzero exit codes for varying levels of failure. The process is as follows:
#
# 1. Detect if USB flash drive is mounted. If it isn't, mount the drive.
#    If the drive can't be mounted, return exit code 1.
# 2. Check to see if the correct upgrade file is located in the root of the
#    USB flash drive. If the file is not located on the drive, return exit
#    code 2.
# 3. Extract the archive to temporary location. If extraction fails, return 
#    exit code 3.
# 4. Perform MD5 check of files in archive. If MD5 fails, return exit code 4.
# 5. Backup existing program and default settings. If there are any issues 
#    backing up items, return exit code 5.
# 6. Copy extracted files to active location. If copy fails, return exit code 6.
# 7. Clean-up temporary file location.
# 8. Un-mount USB drive. If un-mount fails, return exit code 7.
# 9. If all items succeed, return exit code 0.
#

NUM_BACKUPS=0
BACKUP_PATH=/sfs/backups
BACKUP_FILE=backup
USBSTICK=`cat /proc/mounts | grep sda`
USBDRIVE=/dev/sda1
USBMOUNTPOINT=/media/sda1
UPGRADEFILE=upgrade.bin
UPGRADEDIR=/tmp/upgrade
UPGRADEFILEDIR=$UPGRADEDIR/files
MD5FILE=checksums.md5
APPDIR=/home/root
APPNAME=speaker

# Check to see if the upgrade file is located in the root of the flash drive

echo "Detecting if upgrade file exists."
if [ `ls -1 $USBMOUNTPOINT | grep $UPGRADEFILE | wc -l` != 1 ]; then
	echo "Upgrade file does not exist on flash drive."
	exit 2
fi

# Extract upgrade into temporary location

echo "Extracting upgrade archive into $UPGRADEDIR"
mkdir $UPGRADEDIR

if [ $? != 0 ]; then
	echo "Creation of temporary directory failed!"
	exit 3
fi

echo "Updating from USB drive..."
tar xzf $USBMOUNTPOINT/$UPGRADEFILE -C $UPGRADEDIR
if [ $? != 0 ]; then
	echo "Extraction failed!"
	exit 3
fi

# Check the MD5 sums of all the files

echo "Checking MD5s of files in archive"
cd $UPGRADEDIR
md5sum -c $MD5FILE

if [ $? != 0 ]; then
	echo "MD5 check failed!"
	exit 4
fi

# Backup existing system.

echo "Backing up existing files"
for i in `seq $NUM_BACKUPS -1 0` 
do
	PREVINDEX=`expr $i - 1`
	if [ $i = 0 ]; then
		echo "Creating $BACKUP_FILE.$i archive"
		cd $APPDIR
		if [ $NUM_BACKUPS = 0 ]; then 
			rm $BACKUP_PATH/$BACKUP_FILE.$i
		fi
		tar cf $BACKUP_PATH/$BACKUP_FILE.$i $APPNAME
		if [ $? != 0 ]; then
			ERRCODE=1
		fi
	else
		if [ -f $BACKUP_PATH/$BACKUP_FILE.$PREVINDEX ]; then
			echo "Copying $BACKUP_FILE.$PREVINDEX to $BACKUP_FILE.$i"
			mv $BACKUP_PATH/$BACKUP_FILE.$PREVINDEX $BACKUP_PATH/$BACKUP_FILE.$i
			if [ $? != 0 ]; then
				ERRCODE=1
			fi
		fi
	fi
done

if [ ERRCODE = 1 ]; then
	echo "Backup of existing files failed!"
	exit 5
fi

# Remove existing files

echo "Removing existing binaries..."
rm $APPDIR/$APPNAME
#rm -r $APPDIR/$SETTINGS

# Copy new files to live location

echo "Copying new files..."
mv $UPGRADEDIR/files/* $APPDIR

if [ $? != 0 ]; then
	echo "File copy failed!"
	echo "Restoring previous backup before exiting."
	tar xzf $BACKUP_PATH/$BACKUP_FILE.0 -C $APPDIR
	exit 6
fi

# Clean up old files in temporary directory
if [ -d ~/presets ]; then
	rm -rf ~/presets
fi

echo "Cleaning up old files..."
rm -rf $UPGRADEDIR

# Unmount USB drive or delete download file and exit

echo "Unmounting USB stick..."
umount $USBDRIVE

if [ $? != 0 ]; then
	echo "Unmounting USB stick failed!"
	exit 7
fi

exit 0
