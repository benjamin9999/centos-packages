#!/bin/bash
WORKDIR=`pwd`

pkgname=rqdq-python2-pip
pkgver=7.1.2
pkgrel=1
makedepends=()
sources=()

prefix="opt/rqdq"

fetch() {
    echo no fetch
}


build() {
    echo no build
}

package() {
    fpm -s python -t rpm \
        -n "${pkgname}" \
        -v "${pkgver}" \
	-d "rqdq-python2-libs >= 2.7.10" \
	-d "rqdq-python2-setuptools >= 18.3.2" \
	--iteration $pkgrel \
	--python-bin /${prefix}/bin/python \
	pip
}

install() {
    yum -y install \
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

#fetch
#build
package

