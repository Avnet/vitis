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

#-=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-
# Get Environment Variables
#-=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-

PLNX_VER             = $(strip $(subst .,_, ${PETALINUX_VER}))
PROJECT_ROOT_FOLDER  = $(shell pwd)
BASENAME_FOLDER      = $(shell basename ${PROJECT_ROOT_FOLDER})

#-=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-
# Project Variables
#-=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-
#
# Enter the    Project Name     (from HDL repository)
#              Board Name       (from HDL repository, will become Platform Name)
#              PLNX Proj name   (from PetaLinux Make Script)
#              PLNX ROOTFS name (from PetaLinux Make Script)


HDL_PROJECT_NAME                  := minized_petalinux
HDL_BOARD_NAME                    := minized
PETALINUX_PROJECT_NAME            := minized_${PLNX_VER}
PETALINUX_ROOTFS_NAME             := minized

VITIS_ARCHITECTURE                := ps7_cortexa9
VITIS_PROJECT_DESCRIPTION         := "MiniZed Vitis platform based on the Out Of Box image.  More information can be found at https://www.element14.com/community/community/designcenter/zedboardcommunity/minized"

# MPSoC     = aarch64-xilinx-linux
# Zynq 7000 = cortexa9t2hf-neon-xilinx-linux-gnueabi
SYSROOTTYPE                       := cortexa9t2hf-neon-xilinx-linux-gnueabi

#-=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-
# Check for Environment Configuration
#-=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-

ifeq ($(PETALINUX_ROOTFS_NAME)_, $(PETALINUX_PROJECT_NAME))
$(error -=-=-= /_\\VNET Build Environment _NOT_ Set, Please Setup Environment =-=-=-)
else
$(info /_\VNET  Build Environment Configured for ${PLNX_VER} and)
$(info /_\VNET  ${PROJECT_ROOT_FOLDER} with)
$(info /_\VNET  Basename ${BASENAME_FOLDER})
endif

#-=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-
# Include Project Makefile
#-=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-

# generic Makefile
include ../../projectMakefile.mk
