#!/bin/bash
workdir=`pwd`

pkgname=firefox
pkgver=41.0.1
pkgrel=1
makedepends=()
sources=(https://ftp.mozilla.org/pub/mozilla.org/firefox/releases/latest/linux-x86_64/en-US/firefox-${pkgver}.tar.bz2)


fetch() {
    wget -c ${sources[0]}
    cd $srcdir
    tar xjf "${workdir}/firefox-${pkgver}.tar.bz2"
}


build() {
    echo no build step
}

package() {
    cd ${srcdir}
    mkdir -p $pkgdir/opt/firefox-${pkgver}
    mkdir -p $pkgdir/usr/bin
    cp -a firefox/* $pkgdir/opt/firefox-${pkgver}
    ln -sfn firefox-${pkgver} $pkgdir/opt/firefox
    ln -sfn /opt/firefox/firefox $pkgdir/usr/bin/firefox
    
    cd $workdir
    fpm -s dir -t rpm -e \
        -n "${pkgname}" \
        -C "${pkgdir}" \
        -v "${pkgver}" \
	--iteration $pkgrel \
	--rpm-user root --rpm-group root \
	--directories /opt/firefox-${pkgver} \
        opt usr
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
srcdir="$workdir/src"
pkgdir="$workdir/pkg"

if [ "$1" == "install" ]; then
    install
    exit 0
fi

fetch
build
package

