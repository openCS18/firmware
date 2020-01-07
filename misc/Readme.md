# Misc data

## Boot commands

```
setenv bootargs console=ttyS2,115200n8 debug earlyprintk root=/dev/ram0 ramdisk_size=20480 initrd=0xC0000000,20M rw;usb start;fatload usb 0:1 0xC2000000 uImage.presonus-cs18ai;fatload usb 0:1 0xC1900000 rootfs.cpio.uboot;setenv initrd_size ${filesize}; bootm 0xC2000000 0xC1900000

setenv bootargs console=ttyS2,115200n8 debug earlyprintk root=/dev/ram0 rw ramdisk_size=20480 initrd=0xC1900000,20M;usb start;fatload usb 0:1 0xC2000000 uImage.presonus-cs18ai;fatload usb 0:1 0xC1900000 rootfs.cpio; bootm 0xC2000000

setenv bootargs console=ttyS2,115200n8 debug earlyprintk root=/dev/ram0 ramdisk_image=0xC1900000 ramdisk_size=20480 rw;usb start;fatload usb 0:1 0xC2000000 uImage.presonus-cs18ai;fatload usb 0:1 0xC1900000 rootfs.cpio.gz;setenv initrd_size ${filesize}; bootm 0xC2000000

setenv bootargs console=ttyS2,115200n8 debug earlyprintk rw;usb start;fatload usb 0:1 0xC2000000 uImage.presonus-cs18ai;fatload usb 0:1 0xC1900000 rootfs.cpio.uboot;setenv initrd_size ${filesize}; bootm 0xC2000000 0xC1900000

setenv bootargs console=ttyS2,115200n8 debug earlyprintk root=/dev/ram rw;usb start;fatload usb 0:1 0xC2000000 uImage.presonus-cs18ai;bootm 0xC2000000
```

## Kernel defconfig for da850

```
davinci_all
```