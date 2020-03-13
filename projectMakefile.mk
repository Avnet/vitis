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
# Common Variables
#-=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-

# Light Green (Avnet color)
LGRN=\033[1;32m
# No Color
NC=\033[0m
CSTR=\033[1;32m /_\\VNET\033[0m

XSCT                              := $(XILINX_VITIS)/bin/xsct
MAKENAME                          := vitis_${HDL_BOARD_NAME}_Makefile

HDL_PROJECTS_FOLDER               := ../../hdl/Projects
HDL_SCRIPTS_FOLDER                := ../../hdl/Scripts
PETALINUX_APPS_FOLDER             := ../../petalinux/apps
PETALINUX_CONFIGS_FOLDER          := ../../petalinux/configs
PETALINUX_PROJECTS_FOLDER         := ../../petalinux/projects
PETALINUX_SCRIPTS_FOLDER          := ../../petalinux/scripts

VITIS_PLATFORM_REPO_FOLDER        := ../platform_repo
VITIS_PLATFORM_PLATFORM_WORKSPACE := platform_workspace
VITIS_CONSOLIDATED_FOLDER         := consolidated
VITIS_CONSOLIDATED_BOOT_FOLDER    := ${VITIS_CONSOLIDATED_FOLDER}/boot
VITIS_CONSOLIDATED_IMAGE_FOLDER   := ${VITIS_CONSOLIDATED_FOLDER}/image
VITIS_CONSOLIDATED_XSA_FOLDER     := ${VITIS_CONSOLIDATED_FOLDER}/xsa
VITIS_CONSOLIDATED_SYSROOT_FOLDER := ${VITIS_CONSOLIDATED_FOLDER}/sysroot

#-=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-

TARGETS=' all xsa plnx sysroot pfm app '
CLNTARGETS=' cleanxsa cleanplnx cleansysroot cleanpfm cleanapp '
.PHONY:  ${TARGETS} ${CLNTARGETS}
.SILENT: ${TARGETS}


all: xsa plnx sysroot pfm app

	@echo -e '${CSTR} Platform build complete'

set_bif_filename:
ifneq (,$(wildcard linux.bif))
$(info /_\VNET  Found Platform Specific linux.bif, using platform specific)
BIF_FILENAME   := linux.bif
else ifeq ($(VITIS_ARCHITECTURE),psu_cortexa53)
BIF_FILENAME   := ../mpsoc_linux.bif
$(info /_\VNET  No Platform Specific file located, using ${BIF_FILENAME})
else ifeq ($(VITIS_ARCHITECTURE),psu_cortexa9)
BIF_FILENAME   := ../zynq_linux.bif
$(info /_\VNET  No Platform Specific file located, using ${BIF_FILENAME})
else
$(error -=-=-= /_\\VNET Not Able to Determine LINUX.BIF to use =-=-=-)
endif

set_pfm_tcl:
ifneq (,$(wildcard project_pfm.tcl))
$(info /_\VNET  Located platform specific project_pfm.tcl)
PFM_TCL_FILENAME   := ../project_pfm.tcl
else ifneq (,$(wildcard ../project_pfm.tcl))
$(info /_\VNET  No platform specific project_pfm.tcl, using generic)
PFM_TCL_FILENAME   := ../project_pfm.tcl
else
$(error -=-=-= /_\\VNET Not Able to Determine project_pfm.tcl to use =-=-=-)
endif

xsa:
ifneq (,$(wildcard ${HDL_PROJECTS_FOLDER}/${HDL_PROJECT_NAME}/${HDL_BOARD_NAME}_${PLNX_VER}/${HDL_BOARD_NAME}.xsa))
	@echo -e '${CSTR} XSA Exists, cleanxsa before rebuild'
	@echo -e '${CSTR}         Skipping XSA creation'  
	@echo '        ' ${HDL_PROJECTS_FOLDER}/${HDL_PROJECT_NAME}/${HDL_BOARD_NAME}_${PLNX_VER}/${HDL_BOARD_NAME}.xsa
else
	@echo -e '${CSTR} Making XSA'
	@echo -e 'xsa: \n	@vivado -mode batch -notrace -source make_${HDL_PROJECT_NAME}.tcl \
	                            -tclargs ${HDL_BOARD_NAME} ${HDL_PROJECT_NAME}' > ${HDL_SCRIPTS_FOLDER}/${MAKENAME}
	$(MAKE) -f ${MAKENAME} -C ${HDL_SCRIPTS_FOLDER} xsa
endif

plnx:
ifneq (,$(wildcard ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}.bsp))
	@echo -e '${CSTR} BSP Exists, cleanbsp before rebuild' 
	@echo -e '${CSTR}         Skipping BSP creation'
	@echo '        ' ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}.bsp
else
	@echo -e '${CSTR} Making PLNX Project'
	@echo -e 'plnx: \n	./make_${HDL_PROJECT_NAME}_bsp.sh ${HDL_BOARD_NAME}' > ${PETALINUX_SCRIPTS_FOLDER}/${MAKENAME}
	$(MAKE) -f ${MAKENAME} -C ${PETALINUX_SCRIPTS_FOLDER} plnx  
endif

sysroot:
ifneq (,$(wildcard ${VITIS_CONSOLIDATED_SYSROOT_FOLDER}))
	@echo -e '${CSTR} SYSROOT Exists, cleansysroot before rebuild'
	@echo -e '${CSTR}         Skipping extract sysroot'
else
	@echo -e '${CSTR} Extracting sysroot'
	mkdir -p ${VITIS_CONSOLIDATED_SYSROOT_FOLDER}
	tar -xvf ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/images/linux/rootfs.tar.gz -C ${VITIS_CONSOLIDATED_SYSROOT_FOLDER} ./usr ./lib
	cp -rf ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/build/tmp/work/aarch64-xilinx-linux ${VITIS_CONSOLIDATED_SYSROOT_FOLDER}
endif

	# Seemingly not needed due to the targeted nature of how we are building this
	#mkdir -p ${VITIS_CONSOLIDATED_SYSROOT_FOLDER}
	#@echo -e 'all: sdk\n  \nsdk:\n	petalinux-build -s\n	petalinux-package --sysroot -d' ${VITIS_CONSOLIDATED_SYSROOT_FOLDER} > ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/${MAKENAME} 
	#if [ ! -f "${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/${MAKENAME}" ]; then rm ${PETALINUX_PROJECTS_FOLDER}/${PROJECT}/${MAKENAME} ; else echo -e '${CSTR} sdk.sh Makefile not present'; fi
	#if [ ! -f "${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/images/linux/sdk.sh" ]; then make -f ${MAKENAME} -C ${PETALINUX_PROJECTS_FOLDER}/${PROJECT} all; else echo -e '${CSTR} sdk.sh already packaged'; fi
	#if [ ! -d "${VITIS_CONSOLIDATED_SYSROOT_FOLDER}/sysroots" ]; then ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/images/linux/sdk.sh -y -d ${VITIS_CONSOLIDATED_SYSROOT_FOLDER}; else echo -e '${CSTR} sdk.sh already Installed to SYSROOT'; fi

pfm:
ifneq (,$(wildcard ${VITIS_PLATFORM_REPO_FOLDER}/${HDL_BOARD_NAME}))
	@echo -e '${CSTR} Platform Exists, cleanpfm before rebuild'
	@echo -e '${CSTR}         Skipping create Platform'
else
	@echo -e '${CSTR} Creating Folder Structure'
	mkdir -p ${VITIS_CONSOLIDATED_BOOT_FOLDER}
	mkdir -p ${VITIS_CONSOLIDATED_IMAGE_FOLDER}
	mkdir -p ${VITIS_CONSOLIDATED_XSA_FOLDER}
	@echo -e '${CSTR} Copying in all Build Articles'
	cp ${BIF_FILENAME} ${VITIS_CONSOLIDATED_FOLDER}/linux.bif
	cp ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/images/linux/bl31.elf                   ${VITIS_CONSOLIDATED_BOOT_FOLDER}
	cp ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/images/linux/pmufw.elf                  ${VITIS_CONSOLIDATED_BOOT_FOLDER}
	cp ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/images/linux/u-boot.elf                 ${VITIS_CONSOLIDATED_BOOT_FOLDER}
	cp ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/images/linux/zynqmp_fsbl.elf            ${VITIS_CONSOLIDATED_BOOT_FOLDER}
	cp ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/images/linux/image.ub                   ${VITIS_CONSOLIDATED_IMAGE_FOLDER}
	cp ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/images/linux/rootfs.tar.gz              ${VITIS_CONSOLIDATED_IMAGE_FOLDER}
	cp ${HDL_PROJECTS_FOLDER}/${HDL_PROJECT_NAME}/${HDL_BOARD_NAME}_${PLNX_VER}/${HDL_BOARD_NAME}.xsa ${VITIS_CONSOLIDATED_XSA_FOLDER}
	
	@echo -e '${CSTR} Executing Platform Generation'

	$(XSCT) -sdx ${PFM_TCL_FILENAME} \
	             ${HDL_BOARD_NAME}                    \
	             ${VITIS_CONSOLIDATED_XSA_FOLDER}     \
	             ${VITIS_PLATFORM_PLATFORM_WORKSPACE} \
	             ${VITIS_CONSOLIDATED_FOLDER}         \
	             ${VITIS_CONSOLIDATED_BOOT_FOLDER}    \
	             ${VITIS_CONSOLIDATED_IMAGE_FOLDER}   \
	             ${PROJECT_ROOT_FOLDER}               \
	             ${VITIS_ARCHITECTURE}                \
	             ${VITIS_PROJECT_DESCRIPTION}         \
	# left in case need to use sdk.sh - note correlating third parameter will need to be set in the pfm.tcl
	#$(XSCT) -sdx ${HDL_BOARD_NAME}_pfm.tcl ${HDL_BOARD_NAME} ${VITIS_CONSOLIDATED_XSA_FOLDER} ${VITIS_CONSOLIDATED_SYSROOT_FOLDER}/sysroots/aarch64-xilinx-linux
	@echo -e '${CSTR} Copying Platform from workspace to platform_repo'
	if [ ! -d "${VITIS_PLATFORM_REPO_FOLDER}" ]; then mkdir ${VITIS_PLATFORM_REPO_FOLDER}; fi
	# do not automatically delete - force user to clean first
	# can use make cleanpfm pfm to make this ann up arrow enter action
	#if [ -d "${VITIS_PLATFORM_REPO_FOLDER}/${HDL_BOARD_NAME}" ]; then rm -rf ${VITIS_PLATFORM_REPO_FOLDER}/${HDL_BOARD_NAME}; fi
	cp -rf ./${VITIS_PLATFORM_PLATFORM_WORKSPACE}/${HDL_BOARD_NAME}/export/${HDL_BOARD_NAME} ${VITIS_PLATFORM_REPO_FOLDER}/
endif

app:
	@echo -e '${CSTR} Nothing here yet...'
	#@echo -e '${CSTR} Platform is not built!'
	#@echo -e '${CSTR} Application already generated, run cleanapp'
		
cleanxsa:
	@echo -e '${CSTR} Deleting Vivado Project...'
	# faster to just delete
	#@echo -e 'clean: \n	@vivado -mode batch -source make.tcl -notrace -tclargs board=${HDL_BOARD_NAME} project=${HDL_PROJECT_NAME} clean=yes' > ${HDL_SCRIPTS_FOLDER}/${MAKENAME}
	#$(MAKE) -f ${MAKENAME} -C ${HDL_SCRIPTS_FOLDER}
	${RM} -r ${HDL_PROJECTS_FOLDER}/${HDL_PROJECT_NAME}/${HDL_BOARD_NAME}_${PLNX_VER}
	${RM} ${HDL_SCRIPTS_FOLDER}/${MAKENAME}

cleanplnx:
	@echo -e '${CSTR} Deleting PetaLinux Project...'
	${RM} -r ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}
	${RM} ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}.bsp
	${RM} ${PETALINUX_SCRIPTS_FOLDER}/${MAKENAME}

cleansysroot:
	@echo -e '${CSTR} Deleting Sysroot...'
	# only needed if using the sdk.sh method
	#${RM} ${HDL_SCRIPTS_FOLDER}/${MAKENAME}
	${RM} -r ${VITIS_CONSOLIDATED_SYSROOT_FOLDER}

cleanpfm:
	@echo -e '${CSTR} Deleting platform and project configuration!'
	${RM} -r ${VITIS_PLATFORM_PLATFORM_WORKSPACE}
	${RM} -r ${VITIS_PLATFORM_REPO_FOLDER}/${HDL_BOARD_NAME}
	${RM} -r ${VITIS_CONSOLIDATED_FOLDER}/linux.bif
	${RM} -r ${VITIS_CONSOLIDATED_BOOT_FOLDER}
	${RM} -r ${VITIS_CONSOLIDATED_IMAGE_FOLDER}
	${RM} -r ${VITIS_CONSOLIDATED_XSA_FOLDER}
	${RM} -r .Xil

cleanapp:
	@echo -e '${CSTR} Deleting Application Project...'
	#${RM} ${HDL_SCRIPTS_FOLDER}/${MAKENAME}

cleanall: cleanxsa cleanplnx cleansysroot cleanpfm cleanapp
	@echo -e '${CSTR} Deleted all of the things!!'

	
