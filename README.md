# RSC bootloader

MCUboot configuration for the WeAct Studio STM32F412RET6 CoreBoard used by
RSC. The bootloader verifies ECDSA-P256 signed firmware and supports a
test/confirm upgrade flow with automatic rollback.

## Flash layout

The STM32F412RET6 has 512 KiB of internal flash with non-uniform erase
sectors. All application and scratch partitions are aligned to the 128 KiB
sectors.

| Region | Address | Size |
| --- | ---: | ---: |
| MCUboot | `0x08000000` | 128 KiB |
| Primary image (`slot0`) | `0x08020000` | 128 KiB |
| Secondary image (`slot1`) | `0x08040000` | 128 KiB |
| Swap scratch | `0x08060000` | 128 KiB |

The maximum signed application image is slightly less than 128 KiB because
the slot also contains the MCUboot header, TLVs, and trailer.

## Dependencies

This project is expected at `RSC1.0/rsc-boot` inside the existing Zephyr west
workspace. It uses:

- `RSC1.0/zephyr`
- `RSC1.0/bootloader/mcuboot`
- `RSC1.0/.venv`

Fetch MCUboot once if it is not present:

```sh
cd RSC1.0
.venv/bin/west update mcuboot
```

Install MCUboot's Python requirements if `imgtool` reports a missing module:

```sh
.venv/bin/pip install -r bootloader/mcuboot/scripts/requirements.txt
```

## Development key

`make build` generates an unencrypted ECDSA-P256 development key on the first
run. The private key is stored at `keys/dev-signing-private.pem` and is ignored
by Git. The public key is stored at `keys/dev-signing-public.pem` and embedded
in the bootloader.

Do not use this development key for production devices. A production build
should receive only a production public key; the production private key must
remain in the release signing system.

## Build and flash

```sh
cd RSC1.0/rsc-boot
make build
make flash
```

Initial MCUboot installation requires ST-Link. OTA can only be used after the
bootloader and a compatible signed application have been provisioned.

Build artifacts are placed in `build/zephyr/`. The bootloader image is
`build/zephyr/zephyr.hex`.

## Application requirements

The application must use the same board flash layout and enable at least:

```conf
CONFIG_BOOTLOADER_MCUBOOT=y
CONFIG_FLASH=y
CONFIG_FLASH_MAP=y
CONFIG_STREAM_FLASH=y
CONFIG_MCUBOOT_IMG_MANAGER=y
```

It must write the signed upgrade image to `slot1`, request a test upgrade,
reboot, and call `boot_write_img_confirmed()` only after its health checks
pass. The present `rsc-app` firmware still needs this integration before OTA
updates can be performed.

