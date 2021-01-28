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

XSCT                               := $(XILINX_VITIS)/bin/xsct
MAKENAME                           := vitis_${HDL_BOARD_NAME}_Makefile

HDL_PROJECTS_FOLDER                := ../../../hdl/projects
HDL_SCRIPTS_FOLDER                 := ../../../hdl/scripts
PETALINUX_APPS_FOLDER              := ../../../petalinux/apps
PETALINUX_CONFIGS_FOLDER           := ../../../petalinux/configs
PETALINUX_PROJECTS_FOLDER          := ../../../petalinux/projects
PETALINUX_SCRIPTS_FOLDER           := ../../../petalinux/scripts
PETALINUX_TO_VITIS_PFM_FOLDER      := ../../../vitis/pfm_def

VITIS_PLATFORM_REPO_FOLDER         := ../../platform_repo
VITIS_PLATFORM_PLATFORM_WORKSPACE  := platform_workspace
VITIS_CONSOLIDATED_FOLDER          := consolidated
VITIS_CONSOLIDATED_BOOT_FOLDER     := ${VITIS_CONSOLIDATED_FOLDER}/boot
VITIS_CONSOLIDATED_IMAGE_FOLDER    := ${VITIS_CONSOLIDATED_FOLDER}/image
VITIS_CONSOLIDATED_XSA_FOLDER      := ${VITIS_CONSOLIDATED_FOLDER}/xsa
VITIS_CONSOLIDATED_ROOTFS_FOLDER   := ${VITIS_CONSOLIDATED_FOLDER}/rootfs
VITIS_CONSOLIDATED_SYSROOT_FOLDER  := ${VITIS_CONSOLIDATED_FOLDER}/sysroot
VITIS_CONSOLIDATED_SYSROOTS_FOLDER := ${VITIS_CONSOLIDATED_SYSROOT_FOLDER}/sysroots/${SYSROOTTYPE}

VITIS_AI_FOLDER                    := Vitis-AI-1.3
VITIS_AI_BRANCH                    := "-b v1.3"

DPU_PROJECT_NAME                   := ${HDL_BOARD_NAME}_${HDL_PROJECT_NAME}_${PLNX_VER}_dpu
ZOO_PROJECT_NAME                   := ${HDL_BOARD_NAME}_${HDL_PROJECT_NAME}_${PLNX_VER}_zoo

#-=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-

TARGETS=' all allplus xsa plnx sysroot pfm vadd dpu zoo '
CLNTARGETS=' cleanxsa cleanplnx cleansysroot cleanpfm cleanvadd cleandpu cleanzoo '
.PHONY:  ${TARGETS} ${CLNTARGETS}
.SILENT: ${TARGETS}


all: xsa plnx sysroot pfm

	@echo -e '${CSTR} Make all complete'

allplus: all vadd

	@echo -e '${CSTR} Make all plus complete'

set_bif_filename:
ifneq (,$(wildcard linux.bif))
$(info /_\VNET  Found Platform Specific linux.bif, using platform specific)
BIF_FILENAME   := linux.bif
else ifeq ($(VITIS_ARCHITECTURE),psu_cortexa53)
BIF_FILENAME   := ../../mpsoc_linux.bif
$(info /_\VNET  No Platform Specific file located, using ${BIF_FILENAME})
else ifeq ($(VITIS_ARCHITECTURE),ps7_cortexa9)
BIF_FILENAME   := ../../zynq_linux.bif
$(info /_\VNET  No Platform Specific file located, using ${BIF_FILENAME})
else
$(error -=-=-= /_\\VNET Not Able to Determine LINUX.BIF to use =-=-=-)
endif

set_pfm_tcl:
ifneq (,$(wildcard project_pfm.tcl))
$(info /_\VNET  Located platform specific project_pfm.tcl)
PFM_TCL_FILENAME   := ../../project_pfm.tcl
else ifneq (,$(wildcard ../../project_pfm.tcl))
$(info /_\VNET  No platform specific project_pfm.tcl, using ../../project_pfm.tcl)
PFM_TCL_FILENAME   := ../../project_pfm.tcl
else
$(error -=-=-= /_\\VNET Not Able to Determine project_pfm.tcl to use =-=-=-)
endif

xsa:
ifneq (,$(wildcard ${HDL_PROJECTS_FOLDER}/${HDL_BOARD_NAME}_${HDL_PROJECT_NAME}_${PLNX_VER}/${HDL_BOARD_NAME}_${HDL_PROJECT_NAME}.xsa))
	@echo -e '${CSTR} XSA Exists, cleanxsa before rebuild'
	@echo -e '${CSTR}         Skipping XSA creation'  
	@echo '        ' ${HDL_PROJECTS_FOLDER}/${HDL_BOARD_NAME}_${HDL_PROJECT_NAME}_${PLNX_VER}/${HDL_BOARD_NAME}_${HDL_PROJECT_NAME}.xsa
else
	@echo -e '${CSTR} Making XSA'
	@echo -e 'xsa: \n	@vivado -mode batch -notrace -source make_${HDL_BOARD_NAME}_${HDL_PROJECT_NAME}.tcl \
	                            -tclargs ${HDL_BOARD_NAME} ${HDL_PROJECT_NAME}' > ${HDL_SCRIPTS_FOLDER}/${MAKENAME}
	$(MAKE) -f ${MAKENAME} -C ${HDL_SCRIPTS_FOLDER} xsa
endif

plnx:
ifneq (,$(wildcard ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_ROOTFS_NAME}_${PETALINUX_PROJECT_NAME}_${PLNX_VER}.bsp))
	@echo -e '${CSTR} BSP Exists, cleanbsp before rebuild' 
	@echo -e '${CSTR}         Skipping BSP creation'
	@echo '        ' ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_ROOTFS_NAME}_${PETALINUX_PROJECT_NAME}_${PLNX_VER}.bsp
else
	@echo -e '${CSTR} Making PLNX Project'
	@echo -e 'plnx: \n	./make_${PETALINUX_ROOTFS_NAME}_${PETALINUX_PROJECT_NAME}.sh' > ${PETALINUX_SCRIPTS_FOLDER}/${MAKENAME}
	$(MAKE) -f ${MAKENAME} -C ${PETALINUX_SCRIPTS_FOLDER} plnx  
endif

sysroot:
	# patch to force inclusion of rootfs packages in sdk.sh
	#    "petalinux-build --sdk" will not include all content in sdk.sh for avnet-image-minimal build target, unless it is specified in rootfs_config
	@echo -e '${CSTR} Applying patch to force inclusion of rootfs packages in sdk.sh'
	cp ../../add_petalinux_packages.sh ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_ROOTFS_NAME}_${PETALINUX_PROJECT_NAME}_${PLNX_VER}/.
	cd ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_ROOTFS_NAME}_${PETALINUX_PROJECT_NAME}_${PLNX_VER}; source ./add_petalinux_packages.sh

ifneq (,$(wildcard ${VITIS_CONSOLIDATED_SYSROOTS_FOLDER}))
	@echo -e '${CSTR} SYSROOT Exists, cleansysroot before rebuild'
	@echo -e '${CSTR}         Skipping sysroot generation'
else
	@echo -e '${CSTR} Generating sysroot'
	mkdir -p ${VITIS_CONSOLIDATED_SYSROOT_FOLDER}
	@echo -e 'all: sdk\n  \nsdk:\n	petalinux-build -s\n	petalinux-package --sysroot -d' ${PETALINUX_TO_VITIS_PFM_FOLDER}/${BASENAME_FOLDER}/${VITIS_CONSOLIDATED_SYSROOT_FOLDER} > ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_ROOTFS_NAME}_${PETALINUX_PROJECT_NAME}_${PLNX_VER}/${MAKENAME}
	if [ ! -f "${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_ROOTFS_NAME}_${PETALINUX_PROJECT_NAME}_${PLNX_VER}/images/linux/sdk.sh" ];                                                      \
              then make -f ${MAKENAME} -C ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_ROOTFS_NAME}_${PETALINUX_PROJECT_NAME}_${PLNX_VER} all;                                              \
              else echo -e '${CSTR} sdk.sh already packaged';                                                                                      \
    fi
	if [ ! -d "${VITIS_CONSOLIDATED_SYSROOT_FOLDER}/sysroots" ];                                                                                   \
              then ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_ROOTFS_NAME}_${PETALINUX_PROJECT_NAME}_${PLNX_VER}/images/linux/sdk.sh -y -d ${VITIS_CONSOLIDATED_SYSROOT_FOLDER};          \
              else echo -e '${CSTR} sdk.sh already Installed to SYSROOT';                                                                          \
    fi
endif

pfm:
ifneq (,$(wildcard ${VITIS_PLATFORM_REPO_FOLDER}/${HDL_BOARD_NAME}_${HDL_PROJECT_NAME}))
	@echo -e '${CSTR} Platform Exists, cleanpfm before rebuild'
	@echo -e '${CSTR}         Skipping create Platform'
else
	@echo -e '${CSTR} Starting Platform Generation'
	@echo -e '${CSTR} Creating Folder Structure'
	mkdir -pv ${VITIS_CONSOLIDATED_BOOT_FOLDER}
	mkdir -pv ${VITIS_CONSOLIDATED_IMAGE_FOLDER}
	mkdir -pv ${VITIS_CONSOLIDATED_ROOTFS_FOLDER}
	mkdir -pv ${VITIS_CONSOLIDATED_XSA_FOLDER}
	@echo -e '${CSTR} Copying in all Build Articles'

	cp -v ${BIF_FILENAME} ${VITIS_CONSOLIDATED_FOLDER}/linux.bif
	cp -v ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_ROOTFS_NAME}_${PETALINUX_PROJECT_NAME}_${PLNX_VER}/images/linux/boot.scr                   ${VITIS_CONSOLIDATED_IMAGE_FOLDER}
	cp -v ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_ROOTFS_NAME}_${PETALINUX_PROJECT_NAME}_${PLNX_VER}/images/linux/image.ub                   ${VITIS_CONSOLIDATED_IMAGE_FOLDER}
	cp -v ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_ROOTFS_NAME}_${PETALINUX_PROJECT_NAME}_${PLNX_VER}/images/linux/rootfs.tar.gz              ${VITIS_CONSOLIDATED_IMAGE_FOLDER}
	cp -v ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_ROOTFS_NAME}_${PETALINUX_PROJECT_NAME}_${PLNX_VER}/images/linux/rootfs.ext4                ${VITIS_CONSOLIDATED_ROOTFS_FOLDER}
	cp -v ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_ROOTFS_NAME}_${PETALINUX_PROJECT_NAME}_${PLNX_VER}/images/linux/u-boot.elf                 ${VITIS_CONSOLIDATED_BOOT_FOLDER}
ifeq ($(VITIS_ARCHITECTURE),psu_cortexa53)
	@echo -e '${CSTR} Copying Build Articles for Zynq MPSoC'
	cp -v ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_ROOTFS_NAME}_${PETALINUX_PROJECT_NAME}_${PLNX_VER}/images/linux/bl31.elf                   ${VITIS_CONSOLIDATED_BOOT_FOLDER}
	cp -v ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_ROOTFS_NAME}_${PETALINUX_PROJECT_NAME}_${PLNX_VER}/images/linux/pmufw.elf                  ${VITIS_CONSOLIDATED_BOOT_FOLDER}
	cp -v ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_ROOTFS_NAME}_${PETALINUX_PROJECT_NAME}_${PLNX_VER}/images/linux/zynqmp_fsbl.elf            ${VITIS_CONSOLIDATED_BOOT_FOLDER}/fsbl.elf
	cp -v ../../zynqmp_qemu_args.txt                                                                                                          ${VITIS_CONSOLIDATED_FOLDER}
	cp -v ../../pmu_args.txt                                                                                                                  ${VITIS_CONSOLIDATED_FOLDER}
else ifeq ($(VITIS_ARCHITECTURE),ps7_cortexa9)
	@echo -e '${CSTR} Copying Build Articles for Zynq 7000'
	cp -v ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_ROOTFS_NAME}_${PETALINUX_PROJECT_NAME}_${PLNX_VER}/images/linux/zynq_fsbl.elf              ${VITIS_CONSOLIDATED_BOOT_FOLDER}/fsbl.elf
	cp -v ../../zynq_qemu_args.txt                                                                                                            ${VITIS_CONSOLIDATED_FOLDER}
endif
	echo ${HDL_BOARD_NAME}                                                                                                                    > ${VITIS_CONSOLIDATED_IMAGE_FOLDER}/platform_desc.txt
	cp -v ../../init.sh                                                                                                                       ${VITIS_CONSOLIDATED_IMAGE_FOLDER}
	cp -v ${HDL_PROJECTS_FOLDER}/${HDL_BOARD_NAME}_${HDL_PROJECT_NAME}_${PLNX_VER}/${HDL_BOARD_NAME}_${HDL_PROJECT_NAME}.xsa ${VITIS_CONSOLIDATED_XSA_FOLDER}
	
	@echo -e '${CSTR} Executing Platform Generation'

	$(XSCT) -sdx ${PFM_TCL_FILENAME} \
	             ${HDL_BOARD_NAME}_${HDL_PROJECT_NAME} \
	             ${VITIS_PLATFORM_PLATFORM_WORKSPACE}  \
	             ${VITIS_CONSOLIDATED_FOLDER}          \
	             ${VITIS_CONSOLIDATED_BOOT_FOLDER}     \
	             ${VITIS_CONSOLIDATED_IMAGE_FOLDER}    \
	             ${VITIS_CONSOLIDATED_XSA_FOLDER}      \
	             ${VITIS_CONSOLIDATED_SYSROOTS_FOLDER} \
	             ${PROJECT_ROOT_FOLDER}                \
	             ${VITIS_ARCHITECTURE}                 \
	             ${VITIS_PROJECT_DESCRIPTION}          \
	             ${VITIS_CONSOLIDATED_ROOTFS_FOLDER}
	@echo -e '${CSTR} Copying Platform from workspace to platform_repo'
	if [ ! -d "${VITIS_PLATFORM_REPO_FOLDER}" ]; then mkdir ${VITIS_PLATFORM_REPO_FOLDER}; fi
	# do not automatically delete - force user to clean first
	# can use make cleanpfm pfm to make this ann up arrow enter action
	#if [ -d "${VITIS_PLATFORM_REPO_FOLDER}/${HDL_BOARD_NAME}" ]; then rm -rf ${VITIS_PLATFORM_REPO_FOLDER}/${HDL_BOARD_NAME}; fi
	# for now force overwrite the platform
	cp -rf ./${VITIS_PLATFORM_PLATFORM_WORKSPACE}/${HDL_BOARD_NAME}_${HDL_PROJECT_NAME}/export/${HDL_BOARD_NAME}_${HDL_PROJECT_NAME}        ${VITIS_PLATFORM_REPO_FOLDER}/
	#cp -vf ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/images/linux/pmufw.elf            ${VITIS_PLATFORM_REPO_FOLDER}/${HDL_BOARD_NAME}/sw/${HDL_BOARD_NAME}/boot
	@echo -e '${CSTR} Platform build complete'
endif

vadd:
	@echo -e '${CSTR} Creating Application Project'
	mkdir -p ../../projects
	# keep using HDL name as there are instances where one wants to make a baremetal design!
	mkdir -p ../../projects/${HDL_BOARD_NAME}_${HDL_PROJECT_NAME}_${PLNX_VER}_vadd
	cp -r ../../app/vadd/* ../../projects/${HDL_BOARD_NAME}_${HDL_PROJECT_NAME}_${PLNX_VER}_vadd/.
	export VITIS_PLATFORM=${HDL_BOARD_NAME}_${HDL_PROJECT_NAME} ; \
	export VITIS_PLATFORM_DIR=../../../platform_repo/${HDL_BOARD_NAME}_${HDL_PROJECT_NAME} ; \
	export VITIS_PLATFORM_PATH=../../../platform_repo/${HDL_BOARD_NAME}_${HDL_PROJECT_NAME}/${HDL_BOARD_NAME}_${HDL_PROJECT_NAME}.xpfm ; \
	export SYSROOTTYPE=${SYSROOTTYPE} ; \
	make -C ../../projects/${HDL_BOARD_NAME}_${HDL_PROJECT_NAME}_${PLNX_VER}_vadd/hw
	@echo -e '${LGRN}***********************'
	@echo -e '  ${CSTR}'
	@echo -e ' To write image to SDCARD:'
	@echo -e '  $ sudo dd bs=4M if=${HDL_BOARD_NAME}_${HDL_PROJECT_NAME}_${PLNX_VER}_vadd.img of=/dev/sd{x} status=progress conv=fsync'
	@echo -e ' Where {x} is a smaller case letter that specifies the device of your SD card'
	@echo -e '   Note: use df -h to determine which device corresponds to your SD card'
	@echo -e '${LGRN}***********************${NC}'

dpu:
	@echo -e '${CSTR} Creating DPU-TRD Project'
	if [ ! -d "../../${VITIS_AI_FOLDER}" ]; then git clone ${VITIS_AI_BRANCH} https://github.com/Xilinx/Vitis-AI ../../${VITIS_AI_FOLDER} ; fi
	mkdir -p ../../projects
	mkdir -p ../../projects/${DPU_PROJECT_NAME}
	cp -r ../../${VITIS_AI_FOLDER}/dsa/DPU-TRD/* ../../projects/${DPU_PROJECT_NAME}/.
	cp -r ../../app/dpu/Makefile ../../projects/${DPU_PROJECT_NAME}/prj/Vitis/.
	sed -i 's/DEVICE={DEVICE}/DEVICE=${HDL_BOARD_NAME}/' ../../projects/${DPU_PROJECT_NAME}/prj/Vitis/Makefile
	cp -r ../../app/dpu/${HDL_BOARD_NAME}/* ../../projects/${DPU_PROJECT_NAME}/prj/Vitis/.
	export SDX_PLATFORM=../../../../platform_repo/${HDL_BOARD_NAME}_${HDL_PROJECT_NAME}/${HDL_BOARD_NAME}_${HDL_PROJECT_NAME}.xpfm ; \
	export SDX_ROOTFS_EXT4=../../../../platform_repo/${HDL_BOARD_NAME}_${HDL_PROJECT_NAME}/sw/${HDL_BOARD_NAME}_${HDL_PROJECT_NAME}/PetaLinux/rootfs/rootfs.ext4 ; \
	make -C ../../projects/${DPU_PROJECT_NAME}/prj/Vitis

zoo:
ifeq (,$(wildcard ../../projects/${DPU_PROJECT_NAME}/prj/Vitis/binary_container_1/sd_card/arch.json))
	@echo -e '${CSTR} ERROR : DPU-TRD Project not found, run step=dpu first' 
else
	@echo -e '${CSTR} Compiling AI Model Zoo'
	if [ ! -d "../../${VITIS_AI_FOLDER}" ]; then git clone ${VITIS_AI_BRANCH} https://github.com/Xilinx/Vitis-AI ../../${VITIS_AI_FOLDER} ; fi
	mkdir -p ../../projects
	mkdir -p ../../projects/${ZOO_PROJECT_NAME}
	@echo -e 'Copying AI Model Zoo files'
	cp -r ../../${VITIS_AI_FOLDER}/models/AI-Model-Zoo/model-list ../../projects/${ZOO_PROJECT_NAME}/.
	@echo -e 'Copying docker files'
	cp -r ../../${VITIS_AI_FOLDER}/docker_run.sh ../../projects/${ZOO_PROJECT_NAME}/.
	mkdir -p ../../projects/${ZOO_PROJECT_NAME}/setup
	cp -r ../../${VITIS_AI_FOLDER}/setup/docker ../../projects/${ZOO_PROJECT_NAME}/setup/.
	@echo -e 'Copying arch.json file for ${HDL_BOARD_NAME} platform'
	cp ../../projects/${DPU_PROJECT_NAME}/prj/Vitis/binary_container_1/sd_card/arch.json ../../projects/${ZOO_PROJECT_NAME}/.
	@echo -e 'Copying compilation script (compile_modelzoo.sh)'
	cp -r ../../app/zoo/compile_modelzoo.sh ../../projects/${ZOO_PROJECT_NAME}/.
	@echo -e '=================================================================='
	@echo -e 'Instructions to build AI-Model-Zoo for ${HDL_BOARD_NAME} platform:'
	@echo -e '=================================================================='
	@echo -e '   cd projects/${ZOO_PROJECT_NAME}/.'
	@echo -e '   ./docker_run.sh xilinx/vitis-ai:1.3.411'
	@echo -e '   source ./compile_modelzoo.sh'
	@echo -e '=================================================================='
	@echo -e 'Additional Information:'
	@echo -e '- to compile only one (or a few) models,'
	@echo -e '  remove unwanted model sub-directories from model-list directory'
	@echo -e '=================================================================='
endif
		
cleanxsa:
	@echo -e '${CSTR} Deleting Vivado Project...'
	# faster to just delete
	#@echo -e 'clean: \n	@vivado -mode batch -source make.tcl -notrace -tclargs board=${HDL_BOARD_NAME} project=${HDL_PROJECT_NAME} clean=yes' > ${HDL_SCRIPTS_FOLDER}/${MAKENAME}
	#$(MAKE) -f ${MAKENAME} -C ${HDL_SCRIPTS_FOLDER}
	${RM} -r ${HDL_PROJECTS_FOLDER}/${HDL_BOARD_NAME}_${HDL_PROJECT_NAME}_${PLNX_VER}
	${RM} ${HDL_SCRIPTS_FOLDER}/${MAKENAME}

cleanplnx:
	@echo -e '${CSTR} Deleting PetaLinux Project...'
	${RM} -r ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_ROOTFS_NAME}_${PETALINUX_PROJECT_NAME}_${PLNX_VER}
	${RM} ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_ROOTFS_NAME}_${PETALINUX_PROJECT_NAME}_${PLNX_VER}.bsp
	${RM} ${PETALINUX_SCRIPTS_FOLDER}/${MAKENAME}

cleansysroot:
	@echo -e '${CSTR} Deleting Sysroot...'
	${RM} ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_ROOTFS_NAME}_${PETALINUX_PROJECT_NAME}_${PLNX_VER}/${MAKENAME}
	${RM} ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_ROOTFS_NAME}_${PETALINUX_PROJECT_NAME}_${PLNX_VER}/images/linux/sdk.sh
	${RM} -r ${VITIS_CONSOLIDATED_SYSROOT_FOLDER}

cleanpfm:
	@echo -e '${CSTR} Deleting platform and project configuration!'
	${RM} -r ${VITIS_PLATFORM_PLATFORM_WORKSPACE}
	${RM} -r ${VITIS_PLATFORM_REPO_FOLDER}/${HDL_BOARD_NAME}_${HDL_PROJECT_NAME}
	${RM} -r ${VITIS_CONSOLIDATED_FOLDER}/linux.bif
	${RM} -r ${VITIS_CONSOLIDATED_BOOT_FOLDER}
	${RM} -r ${VITIS_CONSOLIDATED_IMAGE_FOLDER}
	${RM} -r ${VITIS_CONSOLIDATED_XSA_FOLDER}
	${RM} -r .Xil

cleanvadd:
	@echo -e '${CSTR} Deleting Application Project...'
	${RM} -r ../../projects/${HDL_BOARD_NAME}_${HDL_PROJECT_NAME}_${PLNX_VER}_vadd

cleandpu:
	@echo -e '${CSTR} Deleting DPU-TRD Project...'
	${RM} -r ../projects/${DPU_PROJECT_NAME}
	${RM} -r ../${VITIS_AI_FOLDER}

cleanzoo:
	@echo -e '${CSTR} Deleting AI-Model-Zoo Project...'
	${RM} -r ../projects/${ZOO_PROJECT_NAME}
	${RM} -r ../${VITIS_AI_FOLDER}

cleanall: ${CLNTARGETS}
	@echo -e '${CSTR} Deleted all of the things!!'

	
