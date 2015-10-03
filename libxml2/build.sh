#!/bin/bash
workdir=`pwd`

pkgname=rqdq-libxml2
pkgver=2.9.2
pkgrel=2
makedepends=('zlib-devel' 'rqdq-python2-devel')
sources=(ftp://xmlsoft.org/libxml2/libxml2-${pkgver}.tar.gz)

prefix="opt/rqdq"

fetch() {
    wget -c ${sources[0]}
    cd $srcdir
    tar xzf "${workdir}/libxml2-${pkgver}.tar.gz"
    patch -p1 < fix-duplicate-qname-message.patch
}


build() {
    cd ${srcdir}/libxml2-${pkgver}/
    ./configure --prefix=/${prefix} --with-python=/${prefix}/bin/python
    make -j2
}

package() {
    cd ${srcdir}/libxml2-${pkgver}/
    DESTDIR="${pkgdir}" make install
    mkdir -p "${pkgdir}/etc/ld.so.conf.d"
    echo "/${prefix}/lib" > "${pkgdir}/etc/ld.so.conf.d/${pkgname}.conf"

    cd $workdir

    fpm -s dir -t rpm \
        -n "${pkgname}" \
        -C "${pkgdir}" \
        -d "zlib >= 1.2.3" \
        -v "${pkgver}" \
	--iteration $pkgrel \
        --rpm-user root --rpm-group root \
	--after-install "${workdir}/${pkgname}.postinstall" \
        ${prefix}/bin/xmlcatalog \
	${prefix}/bin/xmllint \
	${prefix}/lib/libxml2.so.2 \
	${prefix}/lib/libxml2.so.2.9.2 \
	${prefix}/share/man/man1/xmlcatalog.1 \
	${prefix}/share/man/man1/xmllint.1 \
	${prefix}/share/man/man3

    fpm -s dir -t rpm \
        -n "${pkgname}-devel" \
        -C "${pkgdir}" \
        -d "${pkgname} == ${pkgver}-${pkgrel}" \
        -v "${pkgver}" \
	--iteration $pkgrel \
        --rpm-user root --rpm-group root \
	${prefix}/bin/xml2-config \
	${prefix}/include/libxml2 \
	${prefix}/lib/libxml2.so \
	${prefix}/lib/pkgconfig \
	${prefix}/lib/xml2Conf.sh \
	${prefix}/share/aclocal/libxml.m4 \
	${prefix}/share/doc/libxml2-2.9.2 \
	${prefix}/share/gtk-doc \
	${prefix}/share/man/man1/xml2-config.1

    fpm -s dir -t rpm \
        -n "${pkgname}-python" \
        -C "${pkgdir}" \
        -d "${pkgname} == ${pkgver}-${pkgrel}" \
	-d "rqdq-python2-libs >= 2.7.10" \
        -v "${pkgver}" \
	--iteration $pkgrel \
        --rpm-user root --rpm-group root \
	${prefix}/lib/python2.7 \
	${prefix}/share/doc/libxml2-python-2.9.2
}

install() {
    yum -y install \
        "${pkgname}-${pkgver}-${pkgrel}.x86_64.rpm" \
        "${pkgname}-devel-${pkgver}-${pkgrel}.x86_64.rpm" \
        "${pkgname}-python-${pkgver}-${pkgrel}.x86_64.rpm"
}

if [ ${#makedepends[@]} -ne 0 ];
then
    depout=`rpm -q ${makedepends[@]}`
    if [ "$?" -ne 0 ];
    then
        echo 'Build Dependencies not satisified.'
        echo $depout
        exit 1
    fi
fi

mkdir -p pkg src
srcdir="$workdir/src"
pkgdir="$workdir/pkg"

if [ "$1" == "install" ]; then
    install
    exit 0
fi

fetch
build
package

