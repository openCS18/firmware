# OpenCS18 Linux

## Build

Make sure submodules are initialized:

	git submodule update --init

Change to the top-level Buildroot directory:

	cd buildroot

Initialize the configuration, including the defconfig and this external directory:

	make BR2_EXTERNAL=$PWD/../ opencs18_defconfig

And compile:

	make

This may take a couple hours to do from scratch, depending on the speed of your machine.

## Boot

```
setenv bootargs console=ttyS2,115200n8 debug earlyprintk root=/dev/ram rw;usb start;fatload usb 0:1 0xC2000000 uImage.presonus-cs18ai;bootm 0xC2000000
```

## Installation

