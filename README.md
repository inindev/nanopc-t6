# nanopc-t6
#### *Debian ARM64 Linux for the FriendlyElec NanoPC-T6*

This Debian ARM64 Linux image is built directly from official packages using the Debian [Debootstrap](https://wiki.debian.org/Debootstrap) utility, see: https://github.com/inindev/nanopc-t6/blob/main/debian/make_debian_img.sh#L119

Most patches are directly available from the Debian repos using the built-in ```apt``` package manager, see: https://github.com/inindev/nanopc-t6/blob/main/debian/make_debian_img.sh#L351-L358

* Note: The kernel in this bundle is from kernel.org and will not get updates from debian.

<br/>

---
### debian bookworm setup

<br/>

**1. download image**
```
wget https://github.com/inindev/nanopc-t6/releases/download/v12.0.1/nanopc-t6_bookworm-1201.img.xz
```

<br/>

**2. determine the location of the target micro sd card**

 * before plugging-in device
```
ls -l /dev/sd*
ls: cannot access '/dev/sd*': No such file or directory
```

 * after plugging-in device
```
ls -l /dev/sd*
brw-rw---- 1 root disk 8, 0 Jul 15 10:33 /dev/sda
```
* note: for mac, the device is ```/dev/rdiskX```

<br/>

**3. in the case above, substitute 'a' for 'X' in the command below (for /dev/sda)**
```
sudo sh -c 'xzcat nanopc-t6_bookworm-1201.img.xz > /dev/sdX && sync'
```

#### when the micro sd has finished imaging, eject it and boot the rock 5b to finish setup

<br/>

**4. login account**
```
user: debian
pass: debian
```

<br/>

**5. take updates**
```
sudo apt update
sudo apt upgrade
```

<br/>

**6. create account & login as new user**
```
sudo adduser youruserid
echo '<youruserid> ALL=(ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/<youruserid>
sudo chmod 440 /etc/sudoers.d/<youruserid>
```

<br/>

**7. lockout and/or delete debian account**
```
sudo passwd -l debian
sudo chsh -s /usr/sbin/nologin debian
```

```
sudo deluser --remove-home debian
sudo rm /etc/sudoers.d/debian
```

<br/>

**8. change hostname (optional)**
```
sudo nano /etc/hostname
sudo nano /etc/hosts
```

<br/>

---
### building debian bookworm arm64 for the nanopc-t6 from scratch

<br/>

The build script builds native arm64 binaries and thus needs to be run from an arm64 device such as an odroid m1 running 
a 64 bit arm linux. The initial build of this project used a debian arm64 raspberry pi4, but now uses a rock 5b running 
debian trixie arm64.

<br/>

**1. clone the repo**
```
git clone https://github.com/inindev/nanopc-t6.git
cd nanopc-t6
```

<br/>

**2. run the debian build script**
```
cd debian
sudo sh make_debian_img.sh nocomp
```
* note: edit the build script to change various options: ```nano make_debian_img.sh```

<br/>

**3. the output if the build completes successfully**
```
mmc_2g.img
```

**4. install the kernel**
```
cd debian
sudo sh install_kernel.sh
```
* note: kernel needs to be built and available in the ```../kernel``` directory

<br/>

<br/>
