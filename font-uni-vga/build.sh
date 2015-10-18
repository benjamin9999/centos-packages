#!/bin/bash
workdir=`pwd`

pkgname=rqdq-font-uni-vga
pkgver=1.0
pkgrel=1
makedepends=('xorg-x11-font-utils')
sources=(http://www.inp.nsk.su/~bolkhov/files/fonts/univga/uni-vga.tgz)

fetch() {
    wget -c ${sources[0]}
    cd $srcdir
    tar xzf "${workdir}/uni-vga.tgz"
}


build() {
    cd $srcdir/uni_vga
    for fn in *.bdf; do
        bdftopcf -o ${fn%.bdf}.pcf ${fn}
    done
}

package() {
    cd ${srcdir}/
    mkdir -p $pkgdir/etc/X11/fontpath.d
    mkdir -p $pkgdir/usr/share/fonts/uni_vga
    cp $srcdir/uni_vga/*.pcf $pkgdir/usr/share/fonts/uni_vga/
    ln -sfn /usr/share/fonts/uni_vga $pkgdir/etc/X11/fontpath.d/uni_vga
    cd $pkgdir/usr/share/fonts/uni_vga
    mkfontdir

    cd $workdir

    fpm -s dir -t rpm \
        -n "${pkgname}" \
        -C "${pkgdir}" \
        -v "${pkgver}" \
        -a all \
        --iteration $pkgrel \
        --rpm-user root --rpm-group root \
        --after-install $workdir/after-install \
        --directories usr/share/fonts/uni_vga \
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

