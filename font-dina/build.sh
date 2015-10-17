#!/bin/bash
workdir=`pwd`

pkgname=rqdq-font-dina
pkgver=2.92
pkgrel=1
makedepends=('xorg-x11-font-utils')
sources=(https://www.donationcoder.com/Software/Jibz/Dina/downloads/Dina.zip)

fetch() {
    wget -c ${sources[0]}
    unzip Dina.zip -d $srcdir
}


build() {
    cd $srcdir
    mkdir build
    cd BDF
    for fn in *.bdf; do
	echo ${fn}
        bdftopcf -o $srcdir/build/${fn%.bdf}.pcf ${fn}
    done
    cd $srcdir/build
    mkfontdir
}

package() {
    cd ${srcdir}/
    mkdir -p $pkgdir/etc/X11/fontpath.d
    mkdir -p $pkgdir/usr/share/fonts/dina
    cp $srcdir/build/* $pkgdir/usr/share/fonts/dina/
    ln -sfn /usr/share/fonts/dina $pkgdir/etc/X11/fontpath.d/dina

    cd $workdir

    fpm -s dir -t rpm \
        -n "${pkgname}" \
        -C "${pkgdir}" \
        -v "${pkgver}" \
	-a all \
	--iteration $pkgrel \
        --rpm-user root --rpm-group root \
	--after-install $workdir/after-install \
	--directories usr/share/fonts/dina \
	usr etc
}

install() {
    yum -y install "${pkgname}-${pkgver}-${pkgrel}.noarch.rpm"
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

