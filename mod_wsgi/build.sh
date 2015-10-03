#!/bin/bash
WORKDIR=`pwd`

pkgname=rqdq-mod_wsgi
pkgver=4.4.13
pkgrel=1
makedepends=('httpd-devel' 'rqdq-python2-devel')
sources=(https://github.com/GrahamDumpleton/mod_wsgi/archive/${pkgver}.tar.gz)

prefix="opt/rqdq"

fetch() {
    wget -c ${sources[0]}
    cd $srcdir
    tar xzf "${WORKDIR}/${pkgver}.tar.gz"
}


build() {
    cd ${srcdir}/mod_wsgi-${pkgver}/
    ./configure --with-python=/${prefix}/bin/python
    make -j2
}

package() {
    cd ${srcdir}/mod_wsgi-${pkgver}/
    make DESTDIR="${pkgdir}" install

    cd $WORKDIR

    fpm -s dir -t rpm \
        -n "${pkgname}" \
        -C "${pkgdir}" \
        -d "rqdq-python2-libs == 2.7.10" \
        -d "httpd == 2.2.15" \
        -v "${pkgver}" \
	--iteration $pkgrel \
        --rpm-user root --rpm-group root \
	usr
}

install() {
    yum -y install \
        "${pkgname}-${pkgver}-${pkgrel}.x86_64.rpm"
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
srcdir="$WORKDIR/src"
pkgdir="$WORKDIR/pkg"

if [ "$1" == "install" ]; then
    install
    exit 0
fi

fetch
build
package

