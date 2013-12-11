# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit autotools autotools-utils eutils

DESCRIPTION="D-Bus -based service to simplify interaction with certificate authorities"
HOMEPAGE="https://fedorahosted.org/certmonger"
SRC_URI="https://fedorahosted.org/released/certmonger/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="nls systemd test"

DEPEND="app-crypt/mit-krb5
        dev-libs/libxml2
        dev-libs/nspr
        dev-libs/nss[utils]
        dev-libs/openssl:0
        dev-libs/xmlrpc-c[curl,libxml2]
        net-misc/curl[ssl]
        sys-apps/dbus
        sys-apps/keyutils
        sys-apps/util-linux
        sys-devel/gettext
        sys-libs/e2fsprogs-libs
        sys-libs/talloc
        >=sys-libs/tevent-0.9.14
		systemd? ( sys-apps/systemd )
		test? ( dev-tcltk/expect )"

RDEPEND="app-text/dos2unix
         sys-apps/diffutils
         ${DEPEND}"

src_prepare() {
    epatch ${FILESDIR}/${PN}-0.61_fix-header.patch
}

src_configure() {
    local myeconfargs=(
        --disable-tmpfiles
        --localstatedir=/var
        --with-openssl
        --with-tmpdir=/var/run/certmonger
        $(use_enable nls)
        $(use_enable systemd) )

    autotools-utils_src_configure
}

src_install() {
    autotools-utils_src_install

    if ! use systemd ; then
        newinitd "${FILESDIR}"/${PN}-initd ${PN}
        newconfd "${FILESDIR}"/${PN}-confd ${PN}
    fi

    dodoc README STATUS doc/*
}
