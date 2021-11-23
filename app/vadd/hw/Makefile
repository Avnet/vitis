#
# this file was created by a computer. trust it.
# it was then modified by a human...be weary traveler.
#

# compiler tools
#XILINX_VITIS ?= /tools/Xilinx/Vitis/2020.1
#XILINX_VIVADO ?= /tools/Xilinx/Vivado/2020.1
XILINX_VIVADO_HLS ?= $(XILINX_VITIS)/Vivado_HLS

ifeq ($(SYSROOTTYPE),cortexa72-cortexa53-xilinx-linux)
HOST_CXX ?= aarch64-linux-gnu-g++
else ifeq ($(SYSROOTTYPE),cortexa9t2hf-neon-xilinx-linux-gnueabi)
HOST_CXX ?= arm-linux-gnueabihf-g++
else
$(error /_\VNET  Did not set CRITICAL variables)
endif

$(info /_\VNET  Sysroot  ${SYSROOTTYPE})
$(info /_\VNET  HOST_CXX  ${HOST_CXX})
# variables pulled from projectMakefile.mk
#VITIS_PLATFORM = $(TARGET)
#VITIS_PLATFORM_DIR = ../../../platform_repo/$(TARGET)
#VITIS_PLATFORM_PATH = ../../../platform_repo/$(TARGET)/$(TARGET).xpfm
$(info /_\VNET  VITIS_PLATFORM      = ${VITIS_PLATFORM})
$(info /_\VNET  VITIS_PLATFORM_DIR  = ${VITIS_PLATFORM_DIR})
$(info /_\VNET  VITIS_PLATFORM_PATH = ${VITIS_PLATFORM_PATH})

VPP ?= ${XILINX_VITIS}/bin/v++
RM = rm -f
RMDIR = rm -rf

# host compiler global settings
CXXFLAGS += -std=c++0x -DVITIS_PLATFORM=$(VITIS_PLATFORM) -D__USE_XOPEN2K8 -I$(XILINX_VIVADO)/include/ -I$(VITIS_PLATFORM_DIR)/sw/$(VITIS_PLATFORM)/PetaLinux/sysroot/${SYSROOTTYPE}/usr/include/xrt/ -O2 -g -Wall -c -fmessage-length=0 --sysroot=$(VITIS_PLATFORM_DIR)/sw/$(VITIS_PLATFORM)/PetaLinux/sysroot/${SYSROOTTYPE}
LDFLAGS += -lxilinxopencl -lpthread -lrt -ldl -lcrypt -lstdc++ -L$(VITIS_PLATFORM_DIR)/sw/$(VITIS_PLATFORM)/PetaLinux/sysroot/${SYSROOTTYPE}/usr/lib/ --sysroot=$(VITIS_PLATFORM_DIR)/sw/$(VITIS_PLATFORM)/PetaLinux/sysroot/${SYSROOTTYPE}

# hardware compiler shared settings
VPP_OPTS = --target hw
#/tools/Xilinx/Vitis/2020.1/bin/v++ --target hw --compile -I"../src" --config common-config.cfg --config binary_container_1-krnl_vadd-compile.cfg -o"binary_container_1.build/krnl_vadd.xo" "../src/krnl_vadd.cpp"
#
# OpenCL kernel files
#

BINARY_CONTAINERS += binary_container_1.xclbin

BUILD_SUBDIRS += binary_container_1.build
BINARY_CONTAINER_1_OBJS += binary_container_1.build/krnl_vadd.xo
ALL_KERNEL_OBJS += binary_container_1.build/krnl_vadd.xo

ALL_MESSAGE_FILES = $(subst .xo,.mdb,$(ALL_KERNEL_OBJS)) $(subst .xclbin,.mdb,$(BINARY_CONTAINERS))

#
# host files
#

HOST_OBJECTS += src/vadd.o

HOST_EXE = vadd

BUILD_SUBDIRS += src/

#
# primary build targets
#

.PHONY: all clean
all: $(BINARY_CONTAINERS) $(HOST_EXE)

.NOTPARALLEL: clean

clean-host:
	-$(RM) $(HOST_EXE) $(HOST_OBJECTS)

clean-accelerators:
	-$(RM) $(BINARY_CONTAINERS) $(ALL_KERNEL_OBJS) $(ALL_MESSAGE_FILES) 
	-$(RM) *.xclbin.sh *.xclbin.info *.xclbin.link_summary*
	-$(RMDIR) $(BUILD_SUBDIRS)
	-$(RMDIR) .Xil

clean-package:
	-${RMDIR} package
	-${RMDIR} package.build

clean: clean-host clean-accelerators clean-package

.PHONY: incremental
incremental: all


nothing:

#
# binary container: binary_container_1.xclbin
#

binary_container_1.build/krnl_vadd.xo: ../src/krnl_vadd.cpp krnl_vadd-compile.cfg common-config.cfg
	-@mkdir -p $(@D)
	-@$(RM) $@
	$(VPP) $(VPP_OPTS) --compile -I"$(<D)" --platform ${VITIS_PLATFORM_PATH} --config common-config.cfg --config krnl_vadd-compile.cfg -o"$@" "$<"

binary_container_1.xclbin: $(BINARY_CONTAINER_1_OBJS) link.cfg common-config.cfg
	-@echo $(VPP) $(VPP_OPTS) --link --platform ${VITIS_PLATFORM_PATH} --config common-config.cfg --config ink.cfg -o"$@" $(BINARY_CONTAINER_1_OBJS) > binary_container_1.xclbin.sh
	$(VPP) $(VPP_OPTS) --link --platform ${VITIS_PLATFORM_PATH} --config common-config.cfg --config link.cfg -o"$@" $(BINARY_CONTAINER_1_OBJS)

#
# host rules
#

src/vadd.o: ../src/vadd.cpp ../src/vadd.h
	-@mkdir -p $(@D)
	$(HOST_CXX) $(CXXFLAGS) -o "$@" "$<"

$(HOST_EXE): $(HOST_OBJECTS)
	$(HOST_CXX) -o "$@" $(+) $(LDFLAGS)
	-@echo $(VPP) $(VPP_OPTS) --platform ${VITIS_PLATFORM_PATH} -p binary_container_1.xclbin \
		--package.out_dir package \
		--package.rootfs $(VITIS_PLATFORM_DIR)/sw/$(VITIS_PLATFORM)/PetaLinux/rootfs/rootfs.ext4 \
		--package.sd_file $(HOST_EXE)
	-@$(VPP) $(VPP_OPTS) --platform ${VITIS_PLATFORM_PATH} -p binary_container_1.xclbin \
		--package.out_dir package \
		--package.rootfs $(VITIS_PLATFORM_DIR)/sw/$(VITIS_PLATFORM)/PetaLinux/rootfs/rootfs.ext4 \
		--package.sd_file $(HOST_EXE)


