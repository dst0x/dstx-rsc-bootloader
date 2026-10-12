RSC_ROOT := $(abspath $(CURDIR)/..)
WEST := $(RSC_ROOT)/.venv/bin/west
PYTHON := $(RSC_ROOT)/.venv/bin/python
MCUBOOT_APP := $(RSC_ROOT)/bootloader/mcuboot/boot/zephyr
IMGTOOL := $(RSC_ROOT)/bootloader/mcuboot/scripts/imgtool.py
BUILD_DIR := $(CURDIR)/build
PRIVATE_KEY := $(CURDIR)/keys/dev-signing-private.pem
PUBLIC_KEY := $(CURDIR)/keys/dev-signing-public.pem
BOARD := weact_stm32f412_core

export ZEPHYR_BASE := $(RSC_ROOT)/zephyr
export ZEPHYR_TOOLCHAIN_VARIANT := gnuarmemb
export GNUARMEMB_TOOLCHAIN_PATH := /usr
export USE_CCACHE := 0

.PHONY: all build key flash clean

all: build

key: $(PRIVATE_KEY) $(PUBLIC_KEY)

$(PRIVATE_KEY) $(PUBLIC_KEY):
	@RSC_BOOT_PYTHON="$(PYTHON)" \
	 RSC_BOOT_IMGTOOL="$(IMGTOOL)" \
	 "$(CURDIR)/scripts/generate-dev-key.sh"

build: key
	"$(WEST)" build -p always -b "$(BOARD)" \
		-s "$(MCUBOOT_APP)" -d "$(BUILD_DIR)" -- \
		-DBOARD_ROOT="$(CURDIR)" \
		-DEXTRA_CONF_FILE="$(CURDIR)/prj.conf"

flash: build
	"$(WEST)" flash -d "$(BUILD_DIR)" -r openocd

clean:
	"$(WEST)" build -d "$(BUILD_DIR)" -t pristine

