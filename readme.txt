1. make sure kpartx is installed on linux host PC,
	e.g. install kpartx on ubuntu 
	$sudo apt-get install kpartx
	
2. copy your boot.bin,u-boot.bin,zImage to directory fat_files
	note: rootfile system is placed in directory root_fs
	
3. execute mk_sd_img.sh as root user

	$sudo ./mk_sd_img.sh
	
	the emmc boot image sd_emmc_image.img will be created
	
4. copy sd_emmc_image.img to derectory emmc_sam-ba,
    then,run demo_linux_serialflash.bat to start to write.
	
	
	

appendix:
	source build for booting from emmc
	
	1. bootstrap
	
	$export CROSS_COMPILE=/home/emy/gcc-linaro-4.9.4-2017.01-x86_64_arm-linux-gnueabi/bin/arm-linux-gnueabi-
	$make sama5d2_xplainedemmc_uboot_defconfig

	$make
	
	2. uboot
	$make sama5d2_xplained_mmc_defconfig
	
	modify u-boot-at91/include/configs/sama5d2_xplained.h as below:
	
-----------------------------------------------------------------------------------------	
#define FAT_ENV_DEVICE_AND_PART	"0"
#define CONFIG_BOOTCOMMAND	"fatload mmc 0:1 0x21000000 at91-sama5d2_xplained.dtb; " \
				"fatload mmc 0:1 0x22000000 zImage; " \
				"bootz 0x22000000 - 0x21000000"
#undef CONFIG_BOOTARGS
#define CONFIG_BOOTARGS \
	"console=ttyS0,115200 earlyprintk root=/dev/mmcblk0p2 rw rootwait"
------------------------------------------------------------------------------------------	

	$make
	