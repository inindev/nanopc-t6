.PHONY : debian dtb kernel kernel_install uboot all

all: uboot kernel debian kernel_install
	xz -z8v debian/mmc_2g.img

debian:
	sudo sh debian/make_debian_img.sh nocomp

dtb:
	sh dtb/make_dtb.sh

kernel:
	sh kernel/make_kernel.sh

kernel_install:
	sudo sh debian/install_kernel.sh

uboot:
	sh uboot/make_uboot.sh cp

