# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

PYTHON_DEPEND="2:2.7"

inherit python

DESCRIPTION="Python extension module for Kerberos 5"
HOMEPAGE="https://fedorahosted.org/python-krbV"
SRC_URI="https://fedorahosted.org/python-krbV/raw-attachment/wiki/Releases/${P}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~i386"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

pkg_setup() {
    python_set_active_version 2
    python_pkg_setup
}

src_install() {
    insinto $( python_get_sitedir )
    doins .libs/krbVmodule.so
    dodoc README ChangeLog AUTHORS NEWS krbV-code-snippets.py
}

pkg_postinst() {
	python_need_rebuild
}
