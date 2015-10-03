#!/bin/bash
WORKDIR=`pwd`

pkgname=rqdq-python2
pkgver=2.7.10
pkgrel=2
makedepends=('zlib-devel' 'openssl-devel' 'libffi-devel' 'readline-devel' 'bzip2-devel')
sources=(http://www.python.org/ftp/python/${pkgver}/Python-${pkgver}.tgz)

prefix="opt/rqdq"

fetch() {
    wget -c ${sources[0]}
    cd $srcdir
    tar xzf "${WORKDIR}/Python-${pkgver}.tgz"
}


build() {
    cd ${srcdir}/Python-${pkgver}/
    ./configure --enable-shared --prefix=/${prefix}
    make -j2
}

package() {
    cd ${srcdir}/Python-${pkgver}/
    DESTDIR="${pkgdir}" make install
    mkdir -p "${pkgdir}/etc/ld.so.conf.d"
    echo "/${prefix}/lib" > "${pkgdir}/etc/ld.so.conf.d/${pkgname}.conf"

    cd $WORKDIR

    fpm -s dir -t rpm \
        -n "${pkgname}" \
        -C "${pkgdir}" \
        -d "${pkgname}-libs == ${pkgver}-${pkgrel}" \
        -v "${pkgver}" \
	--iteration $pkgrel \
        --rpm-user root --rpm-group root \
        ${prefix}/bin/pydoc \
        ${prefix}/bin/python \
        ${prefix}/bin/python2 \
        ${prefix}/bin/python2.7 \
	${prefix}/share/man

    fpm -s dir -t rpm \
        -n "${pkgname}-libs" \
        -C "${pkgdir}" \
        -d "zlib >= 1.2.3" \
        -d "openssl >= 1.0.1" \
        -d "libffi >= 3.0.5" \
        -d "readline >= 6.0" \
        -d "bzip2 >= 1.0.5" \
        -v "${pkgver}" \
	--iteration $pkgrel \
        --rpm-user root --rpm-group root \
	--post-install ./${pkgname}.postinstall \
	etc \
	${prefix}/include/python2.7/pyconfig.h \
	${prefix}/lib/libpython2.7.so.1.0 \
	${prefix}/lib/python2.7

    fpm -s dir -t rpm \
        -n "${pkgname}-devel" \
        -C "${pkgdir}" \
        -d "${pkgname}-libs == ${pkgver}-${pkgrel}" \
        -v "${pkgver}" \
	--iteration $pkgrel \
        --rpm-user root --rpm-group root \
	${prefix}/bin/python-config \
	${prefix}/bin/python2.7-config \
	${prefix}/include/python2.7 \
	${prefix}/lib/libpython2.7.so
}

install() {
    yum -y install \
        "${pkgname}-${pkgver}-libs-${pkgrel}.x86_64.rpm" \
        "${pkgname}-${pkgver}-devel-${pkgrel}.x86_64.rpm" \
        "${pkgname}-${pkgver}-${pkgrel}.x86_64.rpm"
}


if [ ${#makedepends[@]} -ne 0 ];
then

    echo rpm -q ${makedepends[@]}
    depout=`rpm -q ${makedepends[@]}`
    if [ "$?" -ne 0 ];
    then
        echo 'Build Dependencies not satisified.'
        echo $depout
        exit 1
    fi
fi

mkdir -p pkg src
srcdir="$WORKDIR/src"
pkgdir="$WORKDIR/pkg"

if [ "$1" == "install" ]; then
    install
    exit 0
fi

fetch
build
package

