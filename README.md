# OpenCS18

Open source Linux platform for Presonus Studiolive CS18AI

[![Become a patron!](https://c5.patreon.com/external/logo/become_a_patron_button.png)](https://www.patreon.com/bePatron?u=7980870) 

**Please [support](https://www.patreon.com/bePatron?u=7980870) this project on [Patreon](https://www.patreon.com/bePatron?u=7980870)**

## Prerequisites

You need docker to be configured on host machine.

## Build

Make sure submodules are initialized:

	git submodule update --init

Build Docker image

    ./build-env.sh

Run into docker container

    ./run.sh

Initialize the configuration, including the defconfig and this external directory:

	make opencs18_defconfig

And compile:

	make

This may take a couple hours to do from scratch, depending on the speed of your machine.

## Saving configuration changes

This saves defconfig of buildroot, busybox and linux kernel. All others changes should be saved manually

    ../savedef.sh

## Boot

After build is finished, copy three files
   
    buildroot/output/images/uImage.presonus-cs18ai
    buildroot/output/images/rootfs.squashfs
    buildroot/output/images/recovery.scr 

on USB stick. Then

* Power off the unit
* Place USB stick in USB connector on the rear of the unit
* Hold `Home` button
* Power on the unit
* Wait bouncing pattern of the meters
* Release `Home` button
* Enjoy benefits of OpenCS18

## Using NFS with OpenCS18

Using NFS will dramatically speedup your development process. OpenCS18 usese NFSv4 and [awesome NFS docker image](https://github.com/ehough/docker-nfs-server)

### To boot from NFS

Prepare network infrastructure and configure boot parameters in `board/opencs18/v1/nfs-bootscript.tmpl` the following way

* Determine your server's IP address that will be visible from your CS18 box.
* Replace default IP of `nfsroot=` parameter with your server's IP
* Ensure CS18 will get its IP using DHCP or edit `ip=` parameter manually
* Rebuild images with `make build`
* Place resulting `/buildroot/output/images/nfs-recovery.scr` to USB stick
* Rename `nfs-recovery.scr` to  `recovery.scr`, replacing existing file
* [Spin NFS server](#Spin-NFS-server-on-docker)
* [Boot](#boot) as usual
* For questions refer to [Kernel's NFS Root manual](https://www.kernel.org/doc/Documentation/filesystems/nfs/nfsroot.txt)

### Spin NFS server on docker

This shoud be done **AFTER** build process has finished, because NFS server will bind to `buildroot/output/target` dir that is created during build step
	
	spin-nfs.sh

It will require your sudo privileges and password to load NFS kernel modules. If you load them yourself, then comment out `modprobe` command out of the script

### NFS Gotchas

* After running `make clean` or removing `buildroot/output/target` dir, you have to restart NFS server with steps above.
* DNS subsystem is not properly working after system startup at the moment due to absense of `/etc/resolv.conf` configuration. Use `echo nameserver 8.8.8.8 > /etc/resolv.conf` to set default google DNS server.

### To stop and reload server

Run `spin-nfs.sh` again

### To mount on target
```
mkdir -p /nfs && mount.nfs4 -v 192.168.10.149:/ /nfs/
```

