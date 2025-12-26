SUMMARY = "Install loader configuration files"
LICENSE = "CLOSED"

SRC_URI = "file://kickpi.conf"


do_install() {
    # Create the target directory where the file should be installed
    install -d ${D}/loader/entries

    install -m 0644 ${UNPACKDIR}/kickpi.conf ${D}/loader/entries/kickpi.conf
}

FILES:${PN} += "/loader/entries/kickpi.conf"
