#!/bin/bash
workdir=`pwd`

pkgname=rqdq-font-classic-console
pkgver=1.0
pkgrel=1
makedepends=()
sources=(http://webdraft.hu/fonts/classic-console/fonts/clacon.ttf)

prefix="opt/rqdq"

fetch() {
    wget -c ${sources[0]}
    cp clacon.ttf $srcdir/
}


build() {
    echo "no build step"
}

package() {
    cd ${srcdir}/
    mkdir -p $pkgdir/etc/X11/fontpath.d
    mkdir -p $pkgdir/usr/share/fonts/classic-console
    cp $srcdir/clacon.ttf $pkgdir/usr/share/fonts/classic-console/
    ln -sfn /usr/share/fonts/classic-console $pkgdir/etc/X11/fontpath.d/classic-console

    cd $workdir

    fpm -s dir -t rpm \
        -n "${pkgname}" \
        -C "${pkgdir}" \
        -v "${pkgver}" \
	-a all \
	--iteration $pkgrel \
        --rpm-user root --rpm-group root \
	--after-install $workdir/after-install \
	--directories usr/share/fonts/classic-console \
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

