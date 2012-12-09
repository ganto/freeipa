# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit base java-pkg-2 linux-info versionator

DESCRIPTION="Network Security Services for Java (JSS)"
HOMEPAGE="http://www.mozilla.org/projects/security/pki/jss/"
SRC_URI="http://pki.fedoraproject.org/pki/sources/${PN}/${P}-26.el6/${P}.tar.gz"

LICENSE="MPL-1.1"
SLOT="3.4"
KEYWORDS="~amd64 ~x86"
IUSE="doc examples source"

RDEPEND=">=virtual/jre-1.6
		>=dev-libs/nspr-4.3
		>=dev-libs/nss-3.9.2"
DEPEND=">=virtual/jdk-1.6
		${RDEPEND}
		app-arch/zip
		virtual/pkgconfig
		>=sys-apps/sed-4"

S=${WORKDIR}/${P}/mozilla

# all jss-4.2.6 patches found in:
# http://pki.fedoraproject.org/pki/sources/jss/jss-4.2.6-26.el6/
PATCHES=(
	"${FILESDIR}/${PN}-3.4-target_source.patch"
	"${FILESDIR}/${PN}-4.2.5-use_pkg-config.patch"
	"${FILESDIR}/${P}_key_pair_usage_with_op_flags.patch"
	"${FILESDIR}/${P}_javadocs-param.patch"
	"${FILESDIR}/${P}_ipv6.patch"
	"${FILESDIR}/${P}_ECC-pop.patch"
	"${FILESDIR}/${P}_loadlibrary.patch"
	"${FILESDIR}/${P}_ocspSettings.patch"
	"${FILESDIR}/${P}_ECC_keygen_byCurveName.patch"
	"${FILESDIR}/${P}_VerifyCertificate.patch"
	"${FILESDIR}/${P}_bad-error-string-pointer.patch"
	"${FILESDIR}/${P}_VerifyCertificateReturnCU.patch"
	"${FILESDIR}/${P}_ECC-HSM-FIPS.patch"
	"${FILESDIR}/${P}_eliminate-native-compiler-warnings.patch"
	"${FILESDIR}/${P}_eliminate-java-compiler-warnings.patch"
	"${FILESDIR}/${P}_PKCS12-FIPS.patch"
	"${FILESDIR}/${P}_eliminate-native-coverity-defects.patch"
	"${FILESDIR}/${P}_PBE-PKCS5-V2-secure-P12.patch"
	"${FILESDIR}/${P}_wrapInToken.patch"
	"${FILESDIR}/${P}_HSM-manufacturerID.patch"
	"${FILESDIR}/${P}_ECC-Phase2KeyArchivalRecovery.patch"
	"${FILESDIR}/${P}_undo-JCA-deprecations.patch"
	"${FILESDIR}/${P}_undo-BadPaddingException-deprecation.patch"
)

src_compile() {
	export JAVA_GENTOO_OPTS="-target $(java-pkg_get-target) -source $(java-pkg_get-source)"
	use amd64 && export USE_64=1
	cd "${S}/security/coreconf" || die

    # Hotfix for kernel 3.x #379283
    get_running_version || die "Failed to determine kernel version"
    if [[ ${KV_MAJOR} -ge 3 ]]; then
        cp Linux2.6.mk Linux${KV_MAJOR}.${KV_MINOR}.mk || die
    fi

	emake -j1 BUILD_OPT=1 || die "coreconf make failed"

	cd "${S}/security/jss" || die
	emake -j1 BUILD_OPT=1 USE_PKGCONFIG=1 NSS_PKGCONFIG=nss NSPR_PKGCONFIG=nspr || die "jss make failed"
	if use doc; then
		emake -j1 BUILD_OPT=1 javadoc || die "failed to create javadocs"
	fi
}

# Investigate why this fails
RESTRICT="test"

src_test() {
	BUILD_OPT=1 perl security/jss/org/mozilla/jss/tests/all.pl dist \
		"${S}"/dist/Linux*.OBJ/
}

src_install() {
	java-pkg_dojar dist/*.jar
	# Use this instead of the one in dist because it is a symlink
	# and doso handles symlinks by just symlinking to the original
	java-pkg_doso ./security/${PN}/lib/*/*.so
	use doc && java-pkg_dojavadoc dist/jssdoc
	use source && java-pkg_dosrc ./security/jss/org
	use examples && java-pkg_doexamples ./security/jss/samples
}
