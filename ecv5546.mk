TOPDIR = ./
MAK_WRAPPER_ENV=Y
#NO_PARALLEL_BUILD=1
#include $(TOPDIR)build/core/config_gemini.mak

TFA_ROOT = $(TOPDIR)/boot/trusted-firmware-a/
TFA_OUT_ROOT = $(TFA_ROOT)build/
BL31_BIN_NAME = bl31.img
BUILD_TOOLS_ROOT_ABS = $(TOPDIR)crossgcc
CONFIG_GLB_GMNCFG_MODEL_TFA_CFG = "ecv5546"
ECHO = echo
MAKE_JOBS = -j 30 -l 24

GIT_COMMIT_FILE = tempfile

###################################
#  Define this project parameter  #
###################################
PRJ_NAME               = "TFA"
PRJ_BUILD_ROOT         = $(TFA_ROOT)
PRJ_OUTPUT_FILE        = $(TFA_OUT_ROOT)$(BL31_BIN_NAME)
TARGET_OUTPUT_FILE     = $(GEMINI_BL31_IMAGE)

TARGET_OUTPUT_DEL_FILE = $(TARGET_OUTPUT_FILE)
PRJ_EXT_PARA           =

CROSS     = $(TOOLCHAIN_AARCH64_PATH)/bin/$(TOOLCHAIN_AARCH64_PREFIX)-

BL31_LADDR = 0x1fffc0
BL31_RADDR = 0x200000
BL32_BIN = ../../optee/optee_os/out/arm/core/tee-pager_v2.bin

.PHONY: all init build install update clean distclean

all:
	@:

init:
	@echo "Init TFA"
	@$(CROSS)gcc -v 2>/dev/null ; \
	 if [ "$$?" != "0" ];then \
		echo "Not found compiler: $(CROSS)gcc" ; \
		exit 1; \
	 fi
#	@$(ECHO) "sinclude $(GEMINI_PLF_CFG_PATH)" > $(PRJ_EXT_CFG_ROOT)$(PRJ_EXT_CFG_FILE)
#	@$(CALL_WRAPPER_TARGET) update_global_cfg_h
	@$(MAKE) $(PRJ_EXT_PARA) -C $(PRJ_BUILD_ROOT) \
		CROSS_COMPILE=$(CROSS) PLAT=$(CONFIG_GLB_GMNCFG_MODEL_TFA_CFG) DEBUG=0 clean

build: get_commit
#	@$(PRJ_SHOWBUILDMESG)
	@echo "Build TFA"
	$(RM) -f $(PRJ_OUTPUT_FILE)
	$(MAKE) ${MAKE_JOBS} $(PRJ_EXT_PARA) -C $(PRJ_BUILD_ROOT) \
		BUILD_STRING=$(shell cat $(PRJ_BUILD_ROOT)/$(GIT_COMMIT_FILE)) CROSS_COMPILE=$(CROSS) PLAT=$(CONFIG_GLB_GMNCFG_MODEL_TFA_CFG) SPD=opteed DEBUG=0 LOG_LEVEL=40 \
		ENABLE_PMF=0 ARM_ETHOSN_NPU_DRIVER=1 BL32=$(BL32_BIN) all fip 
	@cd $(PRJ_BUILD_ROOT) ; \
	cp -f build/ecv5546/release/bl31.bin build/bl31.bin ;\
	cp -f build/ecv5546/release/fip.bin build/fip.bin;\
	rm -rf $(GIT_COMMIT_FILE)

#	@$(PRJ_CHKBUILDRESULT)

get_commit:
#	@cd $(PRJ_BUILD_ROOT) ; git rev-parse --short HEAD > $(GIT_COMMIT_FILE)
	@cd $(PRJ_BUILD_ROOT) ; echo "" >> $(GIT_COMMIT_FILE)

install:
	@:
update:
#	@$(PRJ_BUILDUPDTAE)

distclean clean:
	@$(MAKE) ${MAKE_JOBS} $(PRJ_EXT_PARA) -C $(PRJ_BUILD_ROOT) \
		CROSS_COMPILE=$(CROSS) PLAT=ecv5546 DEBUG=0 $@
	@$(RM) -f $(PRJ_OUTPUT_FILE)
#	@$(PRJ_CHKCLEANRESULT)
