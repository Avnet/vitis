#!/bin/bash
#
# 1 Overview
#    1.1
#        The Vitis built-in sd_card.img creation functionnality
#        defines fixed sizes for a dual partition SD card:
#        - 1.1GB partition
#        - 2.2GB partition
#        Unfortunately, the ULTRA96V2's root file system
#        is larger than 2.2GB, so this functionnality
#        will not work with the ULTRA96V2.
#
#    1.2
#        This script will create a working sd_card.img image
#        from the following sd_card directory content:
#
#        sd_card
#        ----| BOOT.BIN
#        ----| boot.scr
#        ----| image.ub
#        ----| init.sh
#        ----| platform_desc.txt
#        ----| binary_container_1.xclbin
#        ----| vadd
#        ----| rootfs.tar.gz
#
#        Where roots.tar.gz needs to be copied to the ext4 partition, other 
#        files need to be copied to the fat32 partition.
#        This script accomplishes with by defining the following dual partition SD card:
#        - BOOT : 0.5GB partition (defined by BOOT_DIM)
#        - ROOTFS : size of extracted rootfs.tar.gz content

#
#
# 2 What will the script do
#    2.1
#        This script based on the loop device create two partitions automatically.
#        The first partition is FAT32, the size is 400MB, the second partition
#        is EXT4, and the size is the actual size after decompressing rootfs.tar.gz.
#    2.2
#        Automatic copy the corresponding file to the corresponding partition
#    2.3
#        Produce an image file with a .img suffix. This image can be used to 
#        flash SD cards on any machine. For example, using the "etcher" tool,
#        you can directly FLash this .img to SD on MAC, Windows, and Linux machines.
#    2.4
#        If the user inserts the SD card, it can also help the user to flash
#        the image to the SD card by specifying the device name of the SD
#        card device. Note: This step must be specified correct, otherwise
#        it may broken the data of other disks.
#
#
# 3 How to use scripts
#        If there is no sd_card directory, create one and copy the files you
#        need to use in the sd_card directory, then put the script into the
#        directory and execute.
#
# 4 Output
#        ➜sudo ./create_sd_card_image.sh
#        Setting up partition      [✔]
#        Copying contents to fat32 [✔]
#        Copying contents to ext4  [✔]
#        sd_card.img successful generated[✔]
#
#        Congratulations, done!
#
# 5 Requirements
#        *pv
#        *dd
#        *mkfs
#
#        have sudo permission or root user
#

set -e

############################  SETUP PARAMETERS
version=1.0

ROOTFS="rootfs"
BOOT_DIM=512
FREELO="$( losetup -f)"

RF_LIST=(\
    sd_card/BOOT.BIN \ls 
    sd_card/boot.scr \
    sd_card/image.ub \
    sd_card/init.sh \
    sd_card/platform_desc.txt  \
    sd_card/binary_container_1.xclbin \
    sd_card/vadd \
)

############################  BASIC SETUP TOOLS
msg() {
    printf '%b' "$1" >&2
}

report() {
    if [ "$ret" -eq '0' ]; then
        printf "\33[32m[✔]\33[0m\n"
    else
        printf "\33[31m[✘]\33[0m\n"
    fi
}

privs ()
{
    if [ "$(id -u)" != 0 ]; then
        echo "Sorry, $(basename "$0") must be run as root."
        exit 1
    fi
}


file_must_exists() {
    if [ ! -e "$1" ]; then
        echo "You must have '$1' file to continue."
        clean_work_area
        exit 1
    fi
}

############################ SETUP FUNCTIONS

lodetach () {
    device="${1}"
    attempt="${2:-1}"

    if [ "${attempt}" -gt 3 ]
    then
        echo "Failed to detach loop device '${device}'."
        exit 1
    fi

    if [ -x "$(which udevadm 2>/dev/null)" ]
    then
        udevadm settle
    fi

    sync
    sleep 1

     losetup -d "${device}" || lodetach "${device}" "$(expr ${attempt} + 1)"
}

calc_space () {
    local tar_file="$1"

    mkdir ${ROOTFS} && tar -zxf "$tar_file" -C ${ROOTFS}

    rootfs_dim="$( du -ms ${ROOTFS} | cut -f1)"
    img_dim="$(echo $(expr "${rootfs_dim}" + "${rootfs_dim}" \* 10 / 100 + 1))"
    img_dim="$((img_dim + BOOT_DIM + 100))"

    dd if=/dev/zero of=$IMG bs=1024k count=0 seek=${img_dim} >/dev/null 2>&1
}

mkpart_mkfs () {
    msg "Setting up partition      "

    losetup "$FREELO" "$IMG" 0
    parted -s "${FREELO}" mklabel msdos || true
    parted -a optimal -s "${FREELO}" mkpart primary fat32 1 "${BOOT_DIM}" || true
    parted -a optimal -s "${FREELO}" mkpart primary ext4 "${BOOT_DIM}" 100% || true
    parted -s "${FREELO}" set 1 boot on || true
    parted -s "${FREELO}" set 1 lba off || true

    mkfs.vfat -F 32 -n "BOOT" "${FREELO}"p1 >/dev/null 2>&1
    mkfs.ext4 -L "ROOTFS" "${FREELO}"p2 >/dev/null 2>&1

    ret="$?"
    report
}

boot_cp () {
    msg "Copying contents to fat32 "

    mkdir -p binary.tmp
    mount "${FREELO}"p1 binary.tmp

    for ((item=0;item<${#RF_LIST[@]};item++))
    do
        [ -e "${RF_LIST[item]}" ] && cp -fr "${RF_LIST[item]}" binary.tmp
    done

    sync
    sleep 1
    umount binary.tmp

    ret="$?"
    report
    }

rootfs_cp () {
    msg "Copying contents to ext4  "

    mount "${FREELO}"p2 binary.tmp

    tar -xzf "$1" -C binary.tmp

    sync
    sync
    sleep 1

    umount binary.tmp
    rmdir binary.tmp

    lodetach ${FREELO}

    ret="$?"
    report

    msg "$IMG successful generated"
    ret="$?"
    report
    echo ''
}

clean_work_area () {

    if mount | grep "binary.tmp" >/dev/null 2>&1;
    then
        umount ./binary.tmp >/dev/null 2>&1
    fi

    [ -d "binary.tmp" ] && rm -rf binary.tmp
    [ -d ${ROOTFS} ] && rm -rf ${ROOTFS}
}

finalize () {

    printf "\nCongratulations, done!"

    clean_work_area
}

############################ MAIN()

main () {

    trap "echo; echo -n Removing work area...; clean_work_area; echo exit;exit" INT

    IMG="sd_card.img"

    privs

    file_must_exists "sd_card/BOOT.BIN"
    file_must_exists "sd_card/boot.scr"
    file_must_exists "sd_card/image.ub"
    file_must_exists "sd_card/rootfs.tar.gz"

    calc_space       "sd_card/rootfs.tar.gz"
    mkpart_mkfs

    boot_cp
    rootfs_cp        "sd_card/rootfs.tar.gz"

    finalize
}

main "$@"
