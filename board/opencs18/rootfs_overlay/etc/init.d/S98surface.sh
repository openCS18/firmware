#!/bin/sh

# The app needs this to know where to look for
# certain helper files such as device.txt
export HOME=/home/root

if [ -f /sfs/devmode ]; then
	echo 'in development mode, not starting surface!'
else
	/sbin/ifdown -a
	/usr/bin/psplash-write "PROGRESS 10"
	/sbin/ifup -a
	/usr/bin/psplash-write "PROGRESS 15"
	echo 'starting surface...'
	cd /home/root
	./surface &
	echo 'surface started'
	/usr/bin/psplash-write "PROGRESS 25"
fi




