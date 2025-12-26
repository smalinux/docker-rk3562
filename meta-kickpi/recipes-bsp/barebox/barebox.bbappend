SRCBRANCH = "kickpi-demo"
SRCREV = "${AUTOREV}"

SRC_URI = "git://github.com/smalinux/barebox.git;protocol=https;branch=${SRCBRANCH}"

PV = "git${SRCPV}"
#SRCREV = "3921fdbb8884f632091f98a09f5aeb92e51bb8c3"

# First stage bootloader, ATF blob and OPTEE blob
DEPENDS += "rockchip-rkbin"

SHAREDDIR = "${TMPDIR}/work-shared/rockchip-rkbin"
BAREBOX_FIRMWARE_DIR = "${SHAREDDIR}"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += " \
    file://kickpi-k3.cfg \
"

DTB_FILES = "rk3562-kickpi-k3.dtb"
IMAGE_BOOT_FILES = "barebox-rk3562-kickpi-k3.img:barebox.img"
BAREBOX_ENV_DIR = "${THISDIR}/files/defaultenv-2-kickpi/nv"

# Copy board data before compilation
BBAPPEND_DIR := "${THISDIR}"
do_configure:prepend() {
    # Copy firmware blobs
    install -D -m 644 ${SHAREDDIR}/rk3562-bl31.bin ${S}/firmware/rk3562-bl31.bin
    install -D -m 644 ${SHAREDDIR}/rk3562-bl32.bin ${S}/firmware/rk3562-bl32.bin
    install -D -m 644 ${SHAREDDIR}/sdram-init.bin ${S}/arch/arm/boards/rockchip-rk3562-kickpi-k3/sdram-init.bin

    # Copy custom defaultenv for kickpi
    cp -r ${BBAPPEND_DIR}/files/defaultenv-2-kickpi/init/* ${S}/defaultenv/defaultenv-2-base/init/
}

