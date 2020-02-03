# OpenCS18 Linux

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

This saves defconfig of buildroot and linux kernel. All others changes should be saved manually

    make savedefconfig && make linux-savedefconfig && cp output/build/linux-5.3.18/defconfig ../board/opencs18/v1/linux_defconfig

## Boot

After build is finished, copy two files
   
    buildroot/output/images/uImage.presonus-cs18ai
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

Spin the server on docker. We assume that you are sharing `~/projects/opencs` folder

```
sudo modprobe nfs nfsd
docker run \
  -v ~/projects/opencs:/nfsroot \
  -d --name 'openCS18_NFS' \
  --privileged \
  -p 2049:2049 \
  -e NFS_DISABLE_VERSION_3=1 \
  -e NFS_EXPORT_0='/nfsroot *(rw,fsid=0,sync,insecure,nohide,no_root_squash,subtree_check)' \
  erichough/nfs-server
```

### To stop and reload server
```
docker stop openCS18_NFS && docker rm openCS18_NFS
```

### To mount on target
```
mkdir -p /nfs && mount.nfs4 -v 192.168.10.149:/ /nfs/
```