#!/bin/bash
workdir=`pwd`

pkgname=rqdq-libxslt
pkgver=1.1.28
pkgrel=2
makedepends=('rqdq-libxml2-devel')
sources=(ftp://xmlsoft.org/XSLT/libxslt-${pkgver}.tar.gz)

prefix="opt/rqdq"

fetch() {
    wget -c ${sources[0]}
    cd $srcdir
    tar xzf "${workdir}/libxslt-${pkgver}.tar.gz"
}


build() {
    cd ${srcdir}/libxslt-${pkgver}/
    ./configure --prefix=/${prefix} --with-python=/${prefix}/bin/python --with-libxml-prefix=/${prefix}
    make -j2
}

package() {
    cd ${srcdir}/libxslt-${pkgver}/
    DESTDIR="${pkgdir}" make install
    mkdir -p "${pkgdir}/etc/ld.so.conf.d"
    echo "/${prefix}/lib" > "${pkgdir}/etc/ld.so.conf.d/${pkgname}.conf"

    cd $workdir

    fpm -s dir -t rpm \
        -n "${pkgname}" \
        -C "${pkgdir}" \
        -d "zlib >= 1.2.3" \
        -d "rqdq-libxml2 == 2.9.2-2" \
        -v "${pkgver}" \
	--iteration $pkgrel \
        --rpm-user root --rpm-group root \
	--after-install "${workdir}/${pkgname}.postinstall" \
        ${prefix}/bin/xsltproc \
        ${prefix}/lib/libexslt.so.0 \
        ${prefix}/lib/libexslt.so.0.8.17 \
        ${prefix}/lib/libxslt.so.1 \
        ${prefix}/lib/libxslt.so.1.1.28 \
        ${prefix}/share/man/man1

    fpm -s dir -t rpm \
        -n "${pkgname}-devel" \
        -C "${pkgdir}" \
        -d "${pkgname} == ${pkgver}-${pkgrel}" \
        -v "${pkgver}" \
	--iteration $pkgrel \
        --rpm-user root --rpm-group root \
	${prefix}/bin/xslt-config \
	${prefix}/include/libexslt \
	${prefix}/include/libxslt \
	${prefix}/lib/libexslt.a \
	${prefix}/lib/libexslt.so \
	${prefix}/lib/libxslt.a \
	${prefix}/lib/libxslt.so \
	${prefix}/lib/pkgconfig \
	${prefix}/lib/xsltConf.sh \
	${prefix}/share/aclocal/libxslt.m4 \
	${prefix}/share/doc/libxslt-1.1.28 \
        ${prefix}/share/man/man3

    fpm -s dir -t rpm \
        -n "${pkgname}-python" \
        -C "${pkgdir}" \
        -d "${pkgname} == ${pkgver}-${pkgrel}" \
	-d "rqdq-python2-libs == 2.7.10" \
        -v "${pkgver}" \
	--iteration $pkgrel \
        --rpm-user root --rpm-group root \
	${prefix}/lib/python2.7 \
	${prefix}/share/doc/libxslt-python-1.1.28
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

