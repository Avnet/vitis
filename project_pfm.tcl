# ----------------------------------------------------------------------------
#
#        ** **        **          **  ****      **  **********  ********** ®
#       **   **        **        **   ** **     **  **              **
#      **     **        **      **    **  **    **  **              **
#     **       **        **    **     **   **   **  *********       **
#    **         **        **  **      **    **  **  **              **
#   **           **        ****       **     ** **  **              **
#  **  .........  **        **        **      ****  **********      **
#     ...........
#                                     Reach Further™
#
# ----------------------------------------------------------------------------
# 
#  This design is the property of Avnet.  Publication of this
#  design is not authorized without written consent from Avnet.
# 
#  For product information and support questions:
#     https://www.element14.com/community/community/designcenter/zedboardcommunity
# 
#  Disclaimer:
#     Avnet, Inc. makes no warranty for the use of this code or design.
#     This code is provided  "As Is". Avnet, Inc assumes no responsibility for
#     any errors, which may appear in this code, nor does it make a commitment
#     to update the information contained herein. Avnet, Inc specifically
#     disclaims any implied warranties of fitness for a particular purpose.
#                      Copyright(c) 2020 Avnet, Inc.
#                              All rights reserved.
# 
# ----------------------------------------------------------------------------


set platform_name [lindex $argv 0]
puts "platform name       : \"$platform_name\"" 
set pfm_folder [lindex $argv 1]
puts "platform_workspace  :  \"$pfm_folder\"" 
set consolidated_folder [lindex $argv 2]
puts "consolidated folder : \"$consolidated_folder\"" 
set boot_folder [lindex $argv 3]
puts "boot folder         : \"$boot_folder\"" 
set image_folder [lindex $argv 4]
puts "image folder        : \"$image_folder\"" 
set xsa_folder [lindex $argv 5]
puts "xsa folder          : \"$xsa_folder\"" 
set sysroot_folder [lindex $argv 6]
puts "sysroot folder      : \"$sysroot_folder\"" 
set root_folder [lindex $argv 7]
puts "root folder         : \"$root_folder\"" 
set architecture [lindex $argv 8]
puts "architecture        : \"$architecture\"" 
set description [lindex $argv 9]
puts "description         : \"$description\"" 
set rootfs_folder [lindex $argv 10]
puts "rootfs_folder       : \"$rootfs_folder\"" 

platform -name $platform_name -no-boot-bsp -desc $description -hw $root_folder/$xsa_folder/$platform_name.xsa -out $root_folder/$pfm_folder

domain -name PetaLinux -proc $architecture -os linux -image $image_folder
domain config -boot $root_folder/$boot_folder
domain config -bif $root_folder/$consolidated_folder/linux.bif
platform config -pmufw-elf $consolidated_folder/pmufw.elf
platform config -fsbl-elf $consolidated_folder/fsbl.elf
domain -runtime opencl
domain -pmuqemu-args $consolidated_folder/pmu_args.txt
domain -qemu-args $consolidated_folder/qemu_args.txt
domain -qemu-data $root_folder/$boot_folder
domain -sysroot  $root_folder/$sysroot_folder
domain -rootfs $root_folder/$rootfs_folder/rootfs.ext4

platform -generate
