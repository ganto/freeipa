# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit cmake-utils java-pkg-2

DESCRIPTION="Operating System Utilities JNI Package"
HOMEPAGE="http://pki.fedoraproject.org"
SRC_URI="http://pki.fedoraproject.org/pki/sources/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE="source"

COMMON_DEP="dev-libs/nspr
			dev-libs/nss"

RDEPEND="virtual/jre:1.6
         ${COMMON_DEP}"

DEPEND="source? ( app-arch/zip )
        virtual/jdk:1.6
        ${COMMON_DEP}"

src_configure() {
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
}

src_install() {
	java-pkg_doso "${CMAKE_BUILD_DIR}"/src/com/netscape/osutil/*.so
	java-pkg_newjar "${CMAKE_BUILD_DIR}"/src/${PN}.jar
	use source && java-pkg_dosrc src/*
}
