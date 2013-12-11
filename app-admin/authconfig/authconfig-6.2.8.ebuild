# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

PYTHON_DEPEND="2:2.6"

inherit autotools-utils eutils gnome2-utils python

DESCRIPTION="Command line tool for setting up authentication from network services"
HOMEPAGE="https://fedorahosted.org/authconfig"
SRC_URI="https://fedorahosted.org/releases/a/u/authconfig/${P}.tar.bz2"
LICENSE="GPL-2"

SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="fingerprint gtk kerberos ldap nls sssd static-libs smartcard winbind"

DEPEND="dev-libs/newt
        dev-libs/openssl
        dev-libs/popt
        dev-perl/XML-Parser
        dev-util/desktop-file-utils
        nls? ( virtual/libintl )
        sys-devel/gettext"

RDEPEND=">=dev-libs/libpwquality-1.2.0-r1
         fingerprint? ( sys-auth/pam_fprint )
         gtk? ( gnome-base/libglade:2.0
                x11-themes/hicolor-icon-theme )
         kerberos? ( sys-auth/pam_krb5 )
         ldap? ( sys-auth/pam_ldap
                 >=sys-auth/nss_ldap-254 )
         sssd? ( sys-auth/sssd )
         smartcard? ( sys-auth/pam_pkcs11 )
         virtual/pam
         winbind? ( net-fs/samba[winbind] )
         ${RDEPEND}"

pkg_setup() {
    python_set_active_version 2
    python_pkg_setup
}

src_prepare() {
    epatch "${FILESDIR}"/${PN}-openrc.patch
}

src_configure() {
    local myeconfargs=(
        --localstatedir=/var
        $(use_enable nls)
        $(use_enable static-libs static))

    autotools-utils_src_configure
}

src_install() {
    autotools-utils_src_install
    dodoc ChangeLog AUTHORS NEWS NOTES README README.samba3 TODO

    if ! use static-libs; then
        rm "${ED}"/$(python_get_sitedir)/*.la
    fi
}

pkg_preinst() {
    use gtk && gnome2_icon_savelist
}

pkg_postinst() {
    use gtk && gnome2_icon_cache_update
    python_need_rebuild

    einfo "Before running \`authconfig\` make sure you have a backup of"
    einfo "  /etc/pam.d/system-auth"
}
