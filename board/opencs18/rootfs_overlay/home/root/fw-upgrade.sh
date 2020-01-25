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
# As of 17.JUL.13, execution time currently takes about 3 minutes. Longest 
# segment executing is the creation of the backup archive.
#
# 7/24/15 - added dynamic device naming based on device.txt

NUM_BACKUPS=0
BACKUP_PATH=/sfs/backups
BACKUP_FILE=backup.tar
USBSTICK=`cat /proc/mounts | grep sda`
USBDRIVE=/dev/sda1
USBMOUNTPOINT=/media/sda1
UPGRADEFILE=upgrade.bin
DOWNLOADFILE=mixer
UPGRADEDIR=/tmp/upgrade
UPGRADEFILEDIR=$UPGRADEDIR/files
MD5FILE=checksums.md5
APPDIR=/home/root
DOWNLOAD_URI=$1
DOWNLOAD_FILENAME=$2
DEVICE_NAME_FILE=/home/root/device.txt

# Determine mixer or surface
if grep -Fq "surface" $DEVICE_NAME_FILE
then
    DEVICE=surface
else
    DEVICE=mixer
fi

# First, detect if USB flash drive is mounted.

echo "Detecting if flash drive is mounted..."
echo "USBSTICK variable is $USBSTICK"
if [ -z $USBSTICK ]; then
	echo "USB Stick not mounted"

	mount $USBDRIVE $USBMOUNTPOINT

	if [ $? != 0 ]; then
		echo "Checking for update URL..."
		if [ -z $DOWNLOAD_URI ]; then
			echo "URL not set, exiting..."
			exit 1
		else
			echo "URL set. Fetching..."
			if [ -f $UPGRADEDIR/$DOWNLOAD_FILENAME ]; then
				rm $UPGRADEDIR/$DOWNLOAD_FILENAME
			fi
			if [ -f /tmp/$DOWNLOADFILE ]; then
				rm /tmp/$DOWNLOADFILE
			fi
			wget -P/tmp $DOWNLOAD_URI
			if [ $? != 0 ]; then
				echo "URL Fetch failed!"
				exit 1
			fi
			NETUPDATE=1
		fi
	else
		echo "Can't mount drive!"
		exit 1
	fi
fi

# Check to see if the upgrade file is located in the root of the flash drive

echo "Detecting if upgrade file exists."
if [ -z $NETUPDATE ]; then
	if [ `ls -1 $USBMOUNTPOINT | grep $UPGRADEFILE | wc -l` != 1 ]; then
		echo "Upgrade file does not exist on flash drive."
		exit 2
	fi
else
	if [ ! -z $DOWNLOAD_FILENAME ]; then
		DOWNLOADFILE=$DOWNLOAD_FILENAME
	fi
	ls $UPGRADEDIR/$DOWNLOADFILE
	if [ $? != 0 ]; then
			echo "/tmp/$DOWNLOADFILE does not exist"
		exit 2
	fi
fi

# Precaution - Move the application and presets to USB to ensure we have enough room for the upgrade
mv $APPDIR/$DOWNLOADFILE $USBMOUNTPOINT
mv $APPDIR/presonus/* $USBMOUNTPOINT/presonus

# Extract upgrade into temporary location

echo "Extracting upgrade archive into $UPGRADEDIR"
mkdir $UPGRADEDIR

if [ $? != 0 ]; then
	echo "Creation of temporary directory failed!"
	exit 3
fi

if [ -z $NETUPDATE ]; then
	echo "Updating from USB drive..."
	tar xzf $USBMOUNTPOINT/$UPGRADEFILE -C $UPGRADEDIR
	if [ $? != 0 ]; then
		echo "Extraction failed!"
		exit 3
	fi
else
	echo "Updating from downloaded file..."
#	tar xzf $UPGRADEDIR/$DOWNLOADFILE -C $UPGRADEDIR
#	if [ $? != 0]; then
#		echo "Extraction failed!"
#		exit 3
#	fi
fi

# Check the MD5 sums of all the files

if [ -z $NETUPDATE ]; then
  	echo "Checking MD5s of files in archive"
  	cd $UPGRADEDIR
  	md5sum -c $MD5FILE

	if [ $? != 0 ]; then
		echo "MD5 check failed!"
		exit 4
	fi
fi
# Backup existing system.
mkdir /sfs/backups
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
		tar cf $BACKUP_PATH/$BACKUP_FILE.$i $DEVICE
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
rm $APPDIR/$DEVICE

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

echo "Cleaning up old files..."
rm -rf $UPGRADEDIR

# Unmount USB drive or delete download file and exit

if [ -z $NETUPDATE ]; then
	echo "Unmounting USB stick..."
	umount $USBDRIVE

	if [ $? != 0 ]; then
		echo "Unmounting USB stick failed!"
		exit 7
	fi
else
	echo "Removing download file..."
	rm $UPGRADEDIR/$UPGRADEFILE
	if [ $? != 0 ]; then
		echo "Could not remove download file!"
		exit 7
	fi
fi

exit 0
