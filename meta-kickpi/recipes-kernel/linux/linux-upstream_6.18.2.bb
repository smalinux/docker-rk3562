require linux-upstream.inc

LINUX_VERSION = "6.18.2"
PV = "${LINUX_VERSION}+git${SRCPV}"
#SRCREV = "2d8cf373e2fac8b62f09cbaa83322f5c326c70a3"
SRCREV = "${AUTOREV}"

COMPATIBLE_MACHINE = "kickpi-k3"

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}-${LINUX_VERSION}:"

SRC_URI = " \
    git://github.com/smalinux/linux.git;protocol=https;branch=kickpi-demo;destsuffix=git \
    file://kickpi-k3/defconfig \
"

EXTRA_OECONF += "--enable-debug"
python do_symlink_kernsrc() {
    import shutil
    s = d.getVar("UNPACKDIR") + "/git"
    kernsrc = d.getVar("STAGING_KERNEL_DIR")

    if s != kernsrc:
        bb.utils.mkdirhier(kernsrc)
        bb.utils.remove(kernsrc, recurse=True)
        bb.note(f"Moving kernel source from {s} to {kernsrc}")
        shutil.move(s, kernsrc)
        os.symlink(kernsrc, s)
}

#do_configure:prepend() {
#    cp ${WORKDIR}/*.dts ${S}/arch/arm46/boot/dts/rockchip/
#}

do_rootfs:append() {
    install -d ${IMAGE_ROOTFS}/boot

    install -m 0644 ${DEPLOY_DIR_IMAGE}/zImage ${IMAGE_ROOTFS}/boot/zImage

    for dtb in ${KERNEL_DEVICETREE}; do
        if [ -f ${DEPLOY_DIR_IMAGE}/$dtb ]; then
            install -m 0644 ${DEPLOY_DIR_IMAGE}/$dtb ${IMAGE_ROOTFS}/boot/
        fi
    done
}
