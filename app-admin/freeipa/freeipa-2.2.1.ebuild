# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

PYTHON_DEPEND="2:2.6"
RESTRICT_PYTHON_ABIS="*-jython *-pypy-*"

inherit autotools-utils bash-completion depend.apache distutils eutils python

DESCRIPTION="The Identity, Policy and Audit system"
HOMEPAGE="http://www.freeipa.org"
SRC_URI="http://freeipa.org/downloads/src/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="autofs dns nis ntp server static-libs systemd test"

DEPEND="app-admin/authconfig
        dev-libs/cyrus-sasl[kerberos,ssl]
        dev-libs/libgcrypt
        dev-libs/libgpg-error
        dev-libs/nspr
        dev-libs/popt
        dev-libs/xmlrpc-c[curl]
        dev-python/dnspython
        dev-python/lxml
        >=dev-python/netaddr-0.7.5
        dev-python/setuptools
        net-misc/curl[kerberos]
        net-nds/openldap[ssl,-gnutls]
        !server? ( app-crypt/mit-krb5 )
        server? ( app-crypt/mit-krb5[openldap]
                  dev-libs/svrcore
                  dns? ( >=net-dns/bind-9.8.2[ldap,dlz] )
                  >=net-nds/389-ds-base-1.2.10
                  nis? ( sys-auth/slapi-nis )
                  test? ( dev-python/nose
                          dev-python/paste )
                  www-apache/mod_python
                  www-servers/apache[ssl]
        )
        sys-apps/util-linux
        sys-libs/e2fsprogs-libs
        systemd? ( sys-apps/systemd )"

RDEPEND="app-crypt/certmonger
        app-crypt/gnupg
        autofs? ( net-fs/autofs )
        dev-libs/nss[utils]
        dev-python/pyopenssl
        dev-python/pykerberos
        dev-python/python-krbV
        dev-python/python-ldap
        dev-python/python-nss
        dns? ( net-dns/bind-tools[gssapi] )
        server? (
            bash-completion? ( app-shells/bash-completion )
            dev-python/pyasn1
            dev-python/python-memcached
            net-misc/memcached
            >=www-apache/mod_auth_kerb-5.4
            >=www-apache/mod_nss-1.0.8
            www-apache/mod_wsgi
            virtual/cron
        )
        net-misc/wget[ssl]
        ntp? ( net-misc/ntp )
        sys-apps/iproute2
        sys-auth/pam_krb5
        >=sys-auth/sssd-1.8.0[autofs?,python]
        ${DEPEND}"

want_apache2_2 server

pkg_setup() {
    python_set_active_version 2
    python_pkg_setup
    depend.apache_pkg_setup server
}

src_prepare() {
    # various Gentoo specific fixes
    epatch "${FILESDIR}"/${P}_fix-ntpdate-call.patch
    epatch "${FILESDIR}"/${P}_fix-nscd-checks.patch
    epatch "${FILESDIR}"/${P}_fix-nss-headers.patch

    # add Gentoo platform support
    epatch "${FILESDIR}"/${P}_gentoo-platform.patch

    # don't use traditional sysvinit services API
    rm -f ${S}/ipapython/services.py
    if use systemd; then
        export SUPPORTED_PLATFORM=fedora16
    else
        export SUPPORTED_PLATFORM=gentoo
    fi
    emake -s IPA_VERSION_IS_GIT_SNAPSHOT=no version-update || \
        die "update API failed, bug mantainer"

    cd ${S}/ipa-client
    eautoreconf

    cd ${S}
    if ! use server; then
        sed -i '/ipaserver/d' setup.py
    fi
    distutils_src_prepare

    cd ${S}/ipapython
    distutils_src_prepare

    if use server; then
        cd ${S}/daemons
        eautoreconf

        cd ${S}/install
        eautoreconf
    fi
}

src_configure() {
    cd ${S}/ipa-client
    econf $(use_enable static-libs static)

    if use server; then
        cd ${S}/install
        econf

        cd ${S}/daemons
        econf --with-openldap
    fi
}

src_compile() {
    cd ${S}/ipa-client
    emake

    if use server; then
        cd ${S}/install
        emake

        cd ${S}/daemons
        emake
    fi

    cd ${S}
    distutils_src_compile

    cd ${S}/ipapython
    distutils_src_compile
}

src_install() {
    strip-linguas install/po

    cd ${S}/ipa-client
    emake DESTDIR="${ED}" install

    if use server; then
        cd ${S}/install
        emake DESTDIR="${ED}" install

        cd ${S}/daemons
        emake DESTDIR="${ED}" install

        # Some user-modifiable HTML files are provided. Move these to /etc
        # and link back.
        for file in ffconfig.js ffconfig_page.js ssbrowser.html unauthorized.html browserconfig.html ipa_error.css
        do
            dosym ../../../../etc/ipa/html/${file} /usr/share/ipa/html/${file}
        done

        if use bash-completion; then
            dobashcompletion ${S}/contrib/completion/ipa.bash_completion ipa
        fi

        insinto /etc/cron.d
        newins ${S}/ipa-compliance.cron ipa-compliance

        dodir /var/run/ipa_memcached
        dodir /var/lib/ipa/sysrestore
    fi

    dodir /var/lib/ipa-client/sysrestore

    python_convert_shebangs -r 2 ${ED}

    cd ${S}
    distutils_src_install

    cd ${S}/ipapython
    distutils_src_install

    cd ${S}
    dodoc Contributors.txt README TODO VERSION

    insinto /etc/ipa
    newins ipapython/ipa.conf default.conf
    touch ${ED}/etc/ipa/ca.crt

    find "${ED}" -type f -name *\.la -exec rm {} \;
}

pkg_postinst() {
    if ! use server; then
        ewarn "If you don't want authconfig to overwrite your /etc/pam.d/system-auth"
        ewarn "configuration use the '--noac' option when running \`ipa-client-install\`."
        ewarn "You then have to manually add SSSD to nsswitch.conf and the PAM config."
    fi
    einfo
    einfo "Public key authentication for IPA users via SSSD won't be supported before"
    einfo "the OpenSSH 6.3 release. For more information check:"
    einfo "    https://bugzilla.mindrot.org/show_bug.cgi?id=1663"
}
