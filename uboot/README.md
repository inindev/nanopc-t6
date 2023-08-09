## u-boot 2023.07 for the nanopc-t6

<i>Note: This script is intended to be run from a 64 bit arm device such as a rock 5b or an odroid m1.</i>

<br/>

**1. build u-boot images for the nanopc-t6**
```
sh make_uboot.sh
```

<i>the build will produce the target files idbloader.img, and u-boot.itb</i>

<br/>

**2. copy u-boot to mmc or file image**
```
sudo dd bs=4K seek=8 if=idbloader.img of=/dev/sdX conv=notrunc
sudo dd bs=4K seek=2048 if=u-boot.itb of=/dev/sdX conv=notrunc,fsync
```
* note: to write to emmc while booted from mmc, use ```/dev/mmcblk1``` for ```/dev/sdX```

<br/>

**4. optional: clean target**
```
sh make_uboot.sh clean
```

