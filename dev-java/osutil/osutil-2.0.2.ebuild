# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit cmake-utils eutils java-pkg-opt-2

DESCRIPTION="Operating System Utilities JNI Package"
HOMEPAGE="http://pki.fedoraproject.org"
SRC_URI="http://pki.fedoraproject.org/pki/sources/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

COMMON_DEP="dev-libs/nspr
			dev-libs/nss"

RDEPEND="virtual/jre:1.6
		${COMMON_DEP}"
DEPEND="virtual/jdk:1.6
		${COMMON_DEP}"

src_prepare() {
	epatch "${FILESDIR}"/${P}_fix-base64-header.patch
}

src_install() {
	java-pkg_doso "${CMAKE_BUILD_DIR}"/src/com/netscape/osutil/libosutil.so
	java-pkg_dojar "${CMAKE_BUILD_DIR}"/src/osutil.jar
}
