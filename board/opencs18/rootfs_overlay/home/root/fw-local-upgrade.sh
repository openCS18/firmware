#!/bin/sh
# Mixer firmware upgrade script
# Copyright (C) 2013 Presonus Audio Electronics
#
# This script performs a firmware upgrade for the Norge/Worx speakers, returning various
# nonzero exit codes for varying levels of failure. The process is as follows:
#
# 1. Extract the archive to temporary location. If extraction fails, return
#    exit code 3.
# 2. Perform MD5 check of files in archive. If MD5 fails, return exit code 4.
# 3. Backup existing program and default settings. If there are any issues
#    backing up items, return exit code 5.
# 4. Copy extracted files to active location. If copy fails, return exit code 6.
# 5. Clean-up temporary file location.
# 6. Clean-up downloaded file.
# 7. If all items succeed, return exit code 0.

NUM_BACKUPS=0
BACKUP_PATH=/sfs/backups
BACKUP_FILE=backup.tar

USBMOUNTPOINT=/home/root/DFU
UPGRADEFILE=upgrade.bin
UPGRADEDIR=/tmp/upgrade
UPGRADEFILEDIR=$UPGRADEDIR/files
MD5FILE=checksums.md5
SPEAKERMD5FILE=speakerAppCheck.md5
APPDIR=/home/root


echo "***********************************"
echo "starting local firmware upgrade..."
echo "***********************************"

sleep 5s # background transfer thread finishes

# Check to see if the upgrade file is located in the root of the flash drive
echo "Detecting if upgrade file exists."

ls -1 $USBMOUNTPOINT
if [ $? != 0 ]; then
        echo "$USBMOUNTPOINT does not exist"
else
        echo "$USBMOUNTPOINT exists"
fi

echo deleting $UPGRADEDIR # start clean

rm -rf $UPGRADEDIR
if [ $? != 0 ]; then
        echo "delete temporary directory failed!"
fi

# Extract upgrade into temporary location

echo "Extracting upgrade archive into $UPGRADEDIR"
mkdir $UPGRADEDIR

if [ $? != 0 ]; then
        echo "Creation of temporary directory failed!"
        exit 3
fi

echo "Updating from USB drive..."
echo extracting from $USBMOUNTPOINT/$UPGRADEFILE
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
                tar cf $BACKUP_PATH/$BACKUP_FILE.$i speaker
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
rm $APPDIR/speaker

# Copy new files to live location

echo "Copying new files..."
echo "Overwriting application file"
mv $UPGRADEDIR/files/speaker $APPDIR

if [ $? != 0 ]; then
        echo "Speaker App copy failed!"
        echo "Restoring previous backup before exiting."
        tar xzf $BACKUP_PATH/$BACKUP_FILE.0 -C $APPDIR
        exit 6
fi

if [ -f "$UPGRADEDIR/files/$SPEAKERMD5FILE" ]; then
        echo "Moving speaker checksum"
        mv $UPGRADEDIR/files/$SPEAKERMD5FILE $APPDIR

        if [ $? != 0 ]; then
                echo "speaker app checksum copy failed!"
                exit 6
        fi
fi

if [ -d "$UPGRADEDIR/files/presets/" ]; then
        echo "Deleting old presets"
        rm $APPDIR/presets/*
        echo "Copying new preset files"
        mv $UPGRADEDIR/files/presets/* $APPDIR/presets

        if [ $? != 0 ]; then
                echo "Preset copy failed!"
                exit 6
        fi
else
        echo "No new preset files to transfer"
fi

# Clean up old files in temporary directory

echo "Cleaning up old files..."
echo "...removing $UPGRADEDIR"
rm -rf $UPGRADEDIR

# delete download file and exit

echo "Removing download file..."
rm -r $USBMOUNTPOINT

exit 0
