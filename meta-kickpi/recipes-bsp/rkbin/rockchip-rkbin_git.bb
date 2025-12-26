DESCRIPTION = "Rockchip Firmware and Tool Binaries"
# Ref: https://git.yoctoproject.org/meta-rockchip/tree/recipes-bsp/rkbin/rockchip-rkbin_git.bb?h=kirkstone
LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE;md5=15faa4a01e7eb0f5d33f9f2bcc7bff62"

SRC_URI = "git://github.com/rockchip-linux/rkbin;protocol=https;branch=master"
SRCREV = "b4558da0860ca48bf1a571dd33ccba580b9abe23"

PROVIDES += "trusted-firmware-a"
PROVIDES += "optee-os"

inherit deploy


COMPATIBLE_MACHINE:kickpi-k3 = "kickpi-k3"
PACKAGE_ARCH = "${MACHINE_ARCH}"

do_install() {
	# Nothing in this recipe is useful in a filesystem
	:
}
ALLOW_EMPTY:${PN} = "1"

SHAREDDIR = "${TMPDIR}/work-shared/${PN}"
do_deploy:kickpi-k3() {
	# Prebuilt TF-A (BL31) - to firmware directory
	install -D -m 644 ${S}/bin/rk35/rk3562_bl31_v*.elf ${SHAREDDIR}/rk3562-bl31.bin
	# Prebuilt OPTEE-OS (BL32) - to firmware directory
	install -D -m 644 ${S}/bin/rk35/rk3562_bl32_v*.bin ${SHAREDDIR}/rk3562-bl32.bin
	# Prebuilt U-Boot TPL (DDR init)
	install -D -m 644 ${S}/bin/rk35/rk3562_ddr_1332MHz_v*.bin ${SHAREDDIR}/sdram-init.bin
}

do_deploy() {
	bbfatal "COMPATIBLE_MACHINE requires a corresponding do_deploy:<MACHINE>() override"
}

addtask deploy after do_install

