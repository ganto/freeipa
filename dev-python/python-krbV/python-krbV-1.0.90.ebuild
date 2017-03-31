# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 )

inherit python-any-r1

DESCRIPTION="Python extension module for Kerberos 5"
HOMEPAGE="https://fedorahosted.org/python-krbV"
SRC_URI="https://fedorahosted.org/python-krbV/raw-attachment/wiki/Releases/${P}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=app-crypt/mit-krb5-1.2.2"
DEPEND="${RDEPEND}
	virtual/awk
"

DOCS=( README ChangeLog AUTHORS NEWS krbV-code-snippets.py )

src_install() {
	default

	# Get rid of the .la files.
	find "${D}" -name '*.la' -delete
}
