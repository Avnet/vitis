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
# Define Colors for Echo
#-=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-

# Light Green (Avnet color)
LGRN=\033[1;32m
# Red 
LRED=\033[1;31m
# BLUE
LBLU=\033[1;34m
# White
LWHT=\033[1;37m
# Magenta
LMAG=\033[1;35m
# Black
LBLK=\033[1;30m
# Dk Black
DBLK=\033[0;30m
# Yellow
LYEL=\033[1;33m
# No Color
NC=\033[0m

CSTR=\033[1;32m /_\\VNET\033[0m

#-=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-
# Defined Platforms as phony and silent
#-=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-=-=-=-=-=--=-=-

PLATFORMS=' minized_sbc mz7010_som mz7020_som pz7010_fmc2 pz7015_fmc2 pz7020_fmc2 pz7030_fmc2 u96v2_sbc uz3eg_iocc uz3eg_pciec uz7ev_evcc '
.PHONY:  ${PLATFORMS} list all clean cleanall
.SILENT: ${PLATFORMS} list all clean cleanall

list:
	@echo
	@echo
	@echo -e '${LGRN}***********************'
	@echo -e '  ${CSTR}'
	@echo
	@echo -e 'Possible make targets:'
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' -e 'cleanall'
	@echo
	@echo -e 'No step defaults to xsa plnx sysroot pfm:'
	@echo -e '${LYEL}  make <target>${NC}'
	@echo
	@echo -e 'See help for more options'
	@echo -e '${LYEL}  make help'
	@echo
	@echo -e '${LGRN}***********************'
	@echo
help:
	@echo -e '${LGRN}***********************'
	@echo -e '  ${CSTR}'
	@echo -e '${LYEL}  make <target>${NC}'
	@echo -e '      build a specific target platform'
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' -e 'cleanall'
	@echo -e '${LYEL}  make <target> step=<step>${NC}'
	@echo -e '      builds a specific target to a specific build point'
	@echo -e "${LYEL}  make <trgt1> <trgt2>...<trgtn> 'step=<step1> <step2>...<stepn>'${NC}"
	@echo -e '      builds a specific target to multiple build points'
	@echo -e '  steps:  xsa          - Builds up to Vivado Project (xsa output)'
	@echo -e '          plnx         - Builds up to PetaLinux Project (bsp output)'
	@echo -e '          sysroot      - Builds up to sysroot generation (see ./consolidated)'
	@echo -e '          pfm          - Builds up to Platform Generation (see ./platform_repo)'
	@echo -e '          app          - Builds Vector Add Example'
	@echo -e '          dpu          - Builds the DPU-TRD'
	@echo -e '          cleanxsa     - Cleans the Vivado Project'
	@echo -e '          cleanplnx    - Cleans the PetaLinux Project'
	@echo -e '          cleansysroot - Cleans the sysroot'
	@echo -e '          cleanpfm     - Cleans the Platform'
	@echo -e '          cleanapp     - Cleans Vector Add Example'
	@echo -e '          cleandpu     - Cleans the DPU-TRD'
	@echo -e '          cleanall     - Cleans all steps'
	@echo
	@echo -e '${LGRN}***********************'
all: $(PLATFORMS)
	@echo -e '${CSTR} Mega Platform build complete'
minized_sbc: 
	@echo -e '${CSTR} Building Vitis Platform for Minized 7007'
	$(MAKE) -C pfm_def/minized_sbc ${step}
mz7010_som: 
	@echo -e '${CSTR} Building Vitis Platform for MicroZed 7010'
	$(MAKE) -C pfm_def/mz7010_som ${step}
mz7020_som: 
	@echo -e '${CSTR} Building Vitis Platform for MicroZed 7020'
	$(MAKE) -C pfm_def/mz7020_som ${step}
pz7010_fmc2: 
	@echo -e '${CSTR} Building Vitis Platform for PicoZed 7010'
	$(MAKE) -C pfm_def/pz7010_fmc2 ${step}
pz7015_fmc2: 
	@echo -e '${CSTR} Building Vitis Platform for PicoZed 7015'
	$(MAKE) -C pfm_def/pz7015_fmc2 ${step}
pz7020_fmc2: 
	@echo -e '${CSTR} Building Vitis Platform for PicoZed 7020'
	$(MAKE) -C pfm_def/pz7020_fmc2 ${step}
pz7030_fmc2: 
	@echo -e '${CSTR} Building Vitis Platform for PicoZed 7030'
	$(MAKE) -C pfm_def/pz7030_fmc2 ${step}
u96v2_sbc: 
	@echo -e '${CSTR} Building Vitis Platform for Ultra96V2 Out Of Box'
	$(MAKE) -C pfm_def/u96v2_sbc ${step}
uz3eg_iocc: 
	@echo -e '${CSTR} Building Vitis Platform for UltraZed-EG with IOCC Carrier Card'
	$(MAKE) -C pfm_def/uz3eg_iocc ${step}
uz3eg_pciec: 
	@echo -e '${CSTR} Building Vitis Platform for UltraZed-EG with PCIe Carrier Card'
	$(MAKE) -C pfm_def/uz3eg_pciec ${step}
uz7ev_evcc: 
	@echo -e '${CSTR} Building Vitis Platform for UltraZed-EV with EV Carrier Card'
	$(MAKE) -C pfm_def/uz7ev_evcc ${step}
clean: cleanall
	@echo -e '${CSTR} Executed make cleanall instead'
cleanall: 
	@echo -e '${CSTR} Delete All the Things!'
	@echo -e '${DBLK}'
	@echo -e "                             ▄██▄"
	@echo -e "                             ▀███"
	@echo -e "               ▄▄▄▄▄            █"
	@echo -e "              ▀▄    ▀▄          █"
	@echo -e "          ▄▀▀▀▄ █▄▄▄▄█▄▄ ▄▀▀▀▄  █"
	@echo -e "         █  ▄  █        █   ▄ █ █"
	@echo -e "         ▀▄   ▄▀        ▀▄   ▄▀ █"
	@echo -e "▄▀▄▄▀▄    █▀▀▀            ▀▀▀ █ █"
	@echo -e "█${LYEL}▒▒▒▒${DBLK}█    █  ▄█▀█▀█▀█▀█▀█▄    █ █"
	@echo -e "█${LYEL}▒▒▒▒${DBLK}█    █  █${LBLK}████████████${DBLK}█▄  █ █"
	@echo -e "█${LYEL}▒▒▒▒${DBLK}█    █   █${LBLK}████████████${DBLK}█▄ █ █"
	@echo -e "█${LYEL}▒▒▒▒${DBLK}█    █    █${LBLK}████████████${DBLK}█ █ █"
	@echo -e "█${LYEL}▒▒▒▒${DBLK}█    █   █${LBLK}████████████${DBLK}█▀ █ █"
	@echo -e "▀████▀  ██▀█  █████████████▀  █▄█"
	@echo -e "  ██   ██  ▀█  █▄█▄█▄█▄█▄█▀  ▄█▀ "
	@echo -e "  ██  ██    ▀█             ▄▀▓█  "
	@echo -e "  ██ ██      ▀█▀▄▄▄▄▄▄▄▄▄▀▀▓▓▓█  "
	@echo -e "  ████        █${LMAG}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${DBLK}█  "
	@echo -e "  ███         █${LMAG}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${DBLK}█  "
	@echo -e "  ██          █${LMAG}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${DBLK}█  "

	$(MAKE) all step=cleanall
