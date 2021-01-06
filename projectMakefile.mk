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

HDL_PROJECTS_FOLDER                := ../../hdl/Projects
HDL_SCRIPTS_FOLDER                 := ../../hdl/Scripts
PETALINUX_APPS_FOLDER              := ../../petalinux/apps
PETALINUX_CONFIGS_FOLDER           := ../../petalinux/configs
PETALINUX_PROJECTS_FOLDER          := ../../petalinux/projects
PETALINUX_SCRIPTS_FOLDER           := ../../petalinux/scripts
PETALINUX_TO_VITIS_FOLDER          := ../../../vitis

VITIS_PLATFORM_REPO_FOLDER         := ../platform_repo
VITIS_PLATFORM_PLATFORM_WORKSPACE  := platform_workspace
VITIS_CONSOLIDATED_FOLDER          := consolidated
VITIS_CONSOLIDATED_BOOT_FOLDER     := ${VITIS_CONSOLIDATED_FOLDER}/boot
VITIS_CONSOLIDATED_IMAGE_FOLDER    := ${VITIS_CONSOLIDATED_FOLDER}/image
VITIS_CONSOLIDATED_XSA_FOLDER      := ${VITIS_CONSOLIDATED_FOLDER}/xsa
VITIS_CONSOLIDATED_ROOTFS_FOLDER   := ${VITIS_CONSOLIDATED_FOLDER}/rootfs
VITIS_CONSOLIDATED_SYSROOT_FOLDER  := ${VITIS_CONSOLIDATED_FOLDER}/sysroot
VITIS_CONSOLIDATED_SYSROOTS_FOLDER := ${VITIS_CONSOLIDATED_SYSROOT_FOLDER}/sysroots/${SYSROOTTYPE}

#-=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-

TARGETS=' all allplus xsa plnx sysroot pfm app dpu '
CLNTARGETS=' cleanxsa cleanplnx cleansysroot cleanpfm cleanapp cleandpu '
.PHONY:  ${TARGETS} ${CLNTARGETS}
.SILENT: ${TARGETS}


all: xsa plnx sysroot pfm

	@echo -e '${CSTR} Make all complete'

allplus: all app

	@echo -e '${CSTR} Make all plus complete'

set_bif_filename:
ifneq (,$(wildcard linux.bif))
$(info /_\VNET  Found Platform Specific linux.bif, using platform specific)
BIF_FILENAME   := linux.bif
else ifeq ($(VITIS_ARCHITECTURE),psu_cortexa53)
BIF_FILENAME   := ../mpsoc_linux.bif
$(info /_\VNET  No Platform Specific file located, using ${BIF_FILENAME})
else ifeq ($(VITIS_ARCHITECTURE),ps7_cortexa9)
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
$(info /_\VNET  No platform specific project_pfm.tcl, using ../project_pfm.tcl)
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
	#@echo
	#@echo
	#@echo -e '${LGRN}***********************'
	#@echo -e '  ${CSTR}'
	#@echo
	#@echo -e '  Please execute the XSA build script from the '
	#@echo -e ' ../hdl/Scripts folder'
	#@echo -e ' From the above folder, you can copy/paste the below command:'
	#@echo -e '    vivado -mode batch -notrace -source make_${HDL_PROJECT_NAME}.tcl -tclargs ${HDL_BOARD_NAME} ${HDL_PROJECT_NAME}'
	#@echo -e ' or execute the build script from the PetaLinux flow,'
	#@echo -e ' which will auto generate the XSA'
	#@echo -e ' Scripting should be located:'
	#@echo -e ' ../petalinux/scripts'
	#@echo -e '    ./make_${HDL_PROJECT_NAME}_bsp.sh ${HDL_BOARD_NAME}'
	#@echo	
	#@echo -e '${LGRN}***********************'
endif

plnx:
ifneq (,$(wildcard ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}.bsp))
	@echo -e '${CSTR} BSP Exists, cleanbsp before rebuild' 
	@echo -e '${CSTR}         Skipping BSP creation'
	@echo '        ' ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}.bsp
else
	@echo -e '${CSTR} Making PLNX Project'
	@echo -e 'plnx: \n	./make_${PETALINUX_ROOTFS_NAME}.sh' > ${PETALINUX_SCRIPTS_FOLDER}/${MAKENAME}
	$(MAKE) -f ${MAKENAME} -C ${PETALINUX_SCRIPTS_FOLDER} plnx  
	#@echo
	#@echo
	#@echo -e '${LGRN}***********************'
	#@echo -e '  ${CSTR}'
	#@echo
	#@echo -e ' execute the build script from the PetaLinux flow,'
	#@echo -e ' which will auto generate the XSA'
	#@echo -e ' Scripting should be located:'
	#@echo -e ' ../petalinux/scripts'
	#@echo -e '    ./make_${HDL_PROJECT_NAME}_bsp.sh ${HDL_BOARD_NAME}'
	#@echo	
	#@echo -e '${LGRN}***********************'
endif

sysroot:
# removed fast mechanism as appears to be missing pieces for AI/ML
#ifneq (,$(wildcard ${VITIS_CONSOLIDATED_SYSROOT_FOLDER}))
#	@echo -e '${CSTR} SYSROOT Exists, cleansysroot before rebuild'
#	@echo -e '${CSTR}         Skipping extract sysroot'
#else
#	@echo -e '${CSTR} Extracting sysroot'
#	mkdir -p ${VITIS_CONSOLIDATED_SYSROOT_FOLDER}
#	tar -xvf ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/images/linux/rootfs.tar.gz -C ${VITIS_CONSOLIDATED_SYSROOT_FOLDER} ./usr ./lib
#	cp -rf ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/build/tmp/work/aarch64-xilinx-linux ${VITIS_CONSOLIDATED_SYSROOT_FOLDER}
#endif

	#
	# patch to force inclusion of rootfs packages in sdk.sh
	#    "petalinux-build --sdk" will not include all content in sdk.sh for avnet-image-minimal build target, unless it is specified in rootfs_config
	@echo -e '${CSTR} Applying patch to force inclusion of rootfs packages in sdk.sh'
	cp ../add_petalinux_packages.sh ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/.
	cd ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}; source ./add_petalinux_packages.sh
	# 
	#
# mechanism that uses sdk.sh method (recomended by Xilinx)
# although takes longer for this flow
ifneq (,$(wildcard ${VITIS_CONSOLIDATED_SYSROOTS_FOLDER}))
	@echo -e '${CSTR} SYSROOT Exists, cleansysroot before rebuild'
	@echo -e '${CSTR}         Skipping sysroot generation'
else
	@echo -e '${CSTR} Generating sysroot'
	mkdir -p ${VITIS_CONSOLIDATED_SYSROOT_FOLDER}
	@echo -e 'all: sdk\n  \nsdk:\n	petalinux-build -s\n	petalinux-package --sysroot -d' ${PETALINUX_TO_VITIS_FOLDER}/${BASENAME_FOLDER}/${VITIS_CONSOLIDATED_SYSROOT_FOLDER} > ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/${MAKENAME}
	if [ ! -f "${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/images/linux/sdk.sh" ];                                                      \
              then make -f ${MAKENAME} -C ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME} all;                                              \
              else echo -e '${CSTR} sdk.sh already packaged';                                                                                      \
    fi
	if [ ! -d "${VITIS_CONSOLIDATED_SYSROOT_FOLDER}/sysroots" ];                                                                                   \
              then ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/images/linux/sdk.sh -y -d ${VITIS_CONSOLIDATED_SYSROOT_FOLDER};          \
              else echo -e '${CSTR} sdk.sh already Installed to SYSROOT';                                                                          \
    fi
endif

pfm:
ifneq (,$(wildcard ${VITIS_PLATFORM_REPO_FOLDER}/${HDL_BOARD_NAME}))
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
	cp -v ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/images/linux/boot.scr                   ${VITIS_CONSOLIDATED_IMAGE_FOLDER}
	cp -v ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/images/linux/image.ub                   ${VITIS_CONSOLIDATED_IMAGE_FOLDER}
	cp -v ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/images/linux/rootfs.tar.gz              ${VITIS_CONSOLIDATED_IMAGE_FOLDER}
	cp -v ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/images/linux/rootfs.ext4                ${VITIS_CONSOLIDATED_ROOTFS_FOLDER}
	cp -v ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/images/linux/u-boot.elf                 ${VITIS_CONSOLIDATED_BOOT_FOLDER}
ifeq ($(VITIS_ARCHITECTURE),psu_cortexa53)
	@echo -e '${CSTR} Starting Platform Generation'
	cp -v ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/images/linux/bl31.elf                   ${VITIS_CONSOLIDATED_BOOT_FOLDER}
	cp -v ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/images/linux/pmufw.elf                  ${VITIS_CONSOLIDATED_BOOT_FOLDER}
	cp -v ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/images/linux/zynqmp_fsbl.elf            ${VITIS_CONSOLIDATED_BOOT_FOLDER}/fsbl.elf
	cp -v ../zynqmp_qemu_args.txt                                                                        ${VITIS_CONSOLIDATED_FOLDER}
	cp -v ../pmu_args.txt                                                                                ${VITIS_CONSOLIDATED_FOLDER}
else ifeq ($(VITIS_ARCHITECTURE),ps7_cortexa9)
	@echo -e '${CSTR} Starting Platform Generation'
	cp -v ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/images/linux/zynq_fsbl.elf              ${VITIS_CONSOLIDATED_BOOT_FOLDER}/fsbl.elf
	cp -v ../zynq_qemu_args.txt                                                                          ${VITIS_CONSOLIDATED_FOLDER}
endif
	echo ${HDL_BOARD_NAME}                                                                             > ${VITIS_CONSOLIDATED_IMAGE_FOLDER}/platform_desc.txt
	cp -v ../init.sh                                                                                     ${VITIS_CONSOLIDATED_IMAGE_FOLDER}
	cp -v ${HDL_PROJECTS_FOLDER}/${HDL_PROJECT_NAME}/${HDL_BOARD_NAME}_${PLNX_VER}/${HDL_BOARD_NAME}.xsa ${VITIS_CONSOLIDATED_XSA_FOLDER}
	
	@echo -e '${CSTR} Executing Platform Generation'

	$(XSCT) -sdx ${PFM_TCL_FILENAME} \
	             ${HDL_BOARD_NAME}                     \
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
	cp -rf ./${VITIS_PLATFORM_PLATFORM_WORKSPACE}/${HDL_BOARD_NAME}/export/${HDL_BOARD_NAME}        ${VITIS_PLATFORM_REPO_FOLDER}/
	#cp -vf ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/images/linux/pmufw.elf            ${VITIS_PLATFORM_REPO_FOLDER}/${HDL_BOARD_NAME}/sw/${HDL_BOARD_NAME}/boot
	@echo -e '${CSTR} Platform build complete'
endif

app:
	@echo -e '${CSTR} Creating Application Project'
	mkdir -p ../build
	mkdir -p ../build/vadd-${HDL_BOARD_NAME}
	cp -r ../app/vadd/* ../build/vadd-${HDL_BOARD_NAME}/.
	@echo -e 'VITIS_PLATFORM=${HDL_BOARD_NAME}'
	@echo -e 'VITIS_PLATFORM_DIR=../../../platform_repo/${HDL_BOARD_NAME}'
	@echo -e 'VITIS_PLATFORM_PATH=../../../platform_repo/${HDL_BOARD_NAME}/${HDL_BOARD_NAME}.xpfm'
	export VITIS_PLATFORM=${HDL_BOARD_NAME} ; \
	export VITIS_PLATFORM_DIR=../../../platform_repo/${HDL_BOARD_NAME} ; \
	export VITIS_PLATFORM_PATH=../../../platform_repo/${HDL_BOARD_NAME}/${HDL_BOARD_NAME}.xpfm ; \
	export SYSROOTTYPE=${SYSROOTTYPE} ; \
	make -C ../build/vadd-${HDL_BOARD_NAME}/hw

dpu:
	@echo -e '${CSTR} Creating DPU-TRD Project'
	if [ ! -d "../Vitis-AI-1.2.1" ]; then git clone -b v1.2.1 https://github.com/Xilinx/Vitis-AI ../Vitis-AI-1.2.1 ; fi
	mkdir -p ../build
	mkdir -p ../build/DPU-TRD-${HDL_BOARD_NAME}
	cp -r ../Vitis-AI-1.2.1/DPU-TRD/* ../build/DPU-TRD-${HDL_BOARD_NAME}/.
	cp -r DPU-TRD/* ../build/DPU-TRD-${HDL_BOARD_NAME}/prj/Vitis/.
	export SDX_PLATFORM=../../../../platform_repo/${HDL_BOARD_NAME}/${HDL_BOARD_NAME}.xpfm ; \
	export SDX_ROOTFS_EXT4=../../../../platform_repo/${HDL_BOARD_NAME}/sw/${HDL_BOARD_NAME}/PetaLinux/rootfs/rootfs.ext4 ; \
	make -C ../build/DPU-TRD-${HDL_BOARD_NAME}/prj/Vitis
		
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
	${RM} ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/${MAKENAME}
	${RM} ${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/images/linux/sdk.sh
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
	${RM} -r ../build/vadd-${HDL_BOARD_NAME}

cleandpu:
	@echo -e '${CSTR} Deleting DPU-TRD Project...'
	${RM} -r ../build/DPU-TRD-${HDL_BOARD_NAME}
	${RM} -r ../Vitis-AI-1.2.1

cleanall: cleanxsa cleanplnx cleansysroot cleanpfm cleanapp cleandpu
	@echo -e '${CSTR} Deleted all of the things!!'

	
