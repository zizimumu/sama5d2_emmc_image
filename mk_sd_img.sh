#! /bin/bash


const_1M=1024*1024*1024
const_1G=1024*1024*1024

# sd image file size
file_size=$((1*$const_1G))
# output file namme
file_name="sd_emmc_image.img"
#fat part size,MB 
fat_size=100



if [ -f "./${file_name}" ];then
	rm ./${file_name}
fi

dd if=/dev/zero of=$file_name  bs=1 seek=$file_size count=0


    cat <<EOT | fdisk $file_name 
n
p
1

+$((fat_size))M
n
p
2


t
1
b
t
2
83
a
1
w
EOT


LOOP_DEV=0
losetup /dev/loop${LOOP_DEV} $file_name

if [ $? -ne 0 ] ; then

	LOOP_DEV=1
	losetup /dev/loop${LOOP_DEV} $file_name
	if [ $? -ne 0 ] ; then
		echo "error: could not add loopback device /dev/loop0 and /dev/loop1"
		exit -1
	fi
fi
	
kpartx -av /dev/loop${LOOP_DEV}
if [ $? -ne 0 ] ; then
	echo "error:kpartx"
	exit -1
fi

# wait for ready
sleep 2


if [ ! -e "/dev/mapper/loop${LOOP_DEV}p1" ];then

	echo "no /dev/mapper/loop${LOOP_DEV}p1 found"
	kpartx -d /dev/loop${LOOP_DEV}
	losetup -d /dev/loop${LOOP_DEV}
	exit -1
fi




mkfs.vfat /dev/mapper/loop${LOOP_DEV}p1
mkfs.ext4 /dev/mapper/loop${LOOP_DEV}p2

mkdir -p /mnt/fat_part
mkdir -p /mnt/ext_part

sync
mount /dev/mapper/loop${LOOP_DEV}p1 /mnt/fat_part
mount /dev/mapper/loop${LOOP_DEV}p2 /mnt/ext_part

echo "copy files to fat part..."
cp -f ./fat_files/* /mnt/fat_part
echo "copy rootfs ..."
#cp -rf root_fs/* /mnt/ext_part
tar xjf ./root_fs/rootfs.tar.bz2 -C /mnt/ext_part

sync
umount /mnt/fat_part
umount /mnt/ext_part

rm -r /mnt/fat_part
rm -r /mnt/ext_part


kpartx -d /dev/loop${LOOP_DEV}
losetup -d /dev/loop${LOOP_DEV}

