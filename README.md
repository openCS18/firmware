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

## Installation

