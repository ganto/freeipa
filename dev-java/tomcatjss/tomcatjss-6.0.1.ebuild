# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 java-ant-2

DESCRIPTION="JSSE implementation using JSS for Tomcat"
HOMEPAGE="http://pki.fedoraproject.org"
SRC_URI="http://pki.fedoraproject.org/pki/sources/${PN}/${P}.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE=""

COMMON_DEP="dev-java/commons-logging
            =dev-java/jss-4.2.6
            !!dev-java/tomcat-native
            www-servers/tomcat:6"

RDEPEND=">=virtual/jre-1.6
         ${COMMON_DEP}"
DEPEND=">=virtual/jdk-1.6
        ${COMMON_DEP}"

EANT_BUILD_TARGET="dist"
EANT_DOC_TARGET=""

src_compile() {
	eant \
		-Djss.jar="$(java-pkg_getjars jss-3.4)" \
		-Dtomcat-coyote.jar="$(java-pkg_getjar tomcat-6 tomcat-coyote.jar)" \
		-Dcommons-logging.jar="$(java-pkg_getjar commons-logging commons-logging-api.jar)"
		${antflags}
}

src_install() {
	java-pkg_dojar ${S}/build/jars/"${PN}.jar"
	dodoc README
	use doc && java-pkg_dojavadoc build/javadoc
	use source && java-pkg_dosrc src
}
