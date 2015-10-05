#!/bin/bash
workdir=`pwd`

pkgname=pycharm
pkgver=4.5.3
pkgrel=1
makedepends=()
sources=(http://download-cf.jetbrains.com/python/pycharm-professional-${pkgver}.tar.gz)


fetch() {
    wget -c ${sources[0]}
    cd $srcdir
    tar xzf "${workdir}/pycharm-professional-${pkgver}.tar.gz"
}


build() {
    echo no build step
}

package() {
    cd ${srcdir}
    mkdir -p $pkgdir/opt
    mkdir -p $pkgdir/usr/bin
    cp -a * $pkgdir/opt/
    ln -sfn pycharm-4.5.3 $pkgdir/opt/pycharm
    ln -sfn /opt/pycharm/bin/pycharm.sh $pkgdir/usr/bin/pycharm
    
    cd $workdir
    fpm -s dir -t rpm -e \
        -n "${pkgname}" \
        -C "${pkgdir}" \
        -v "${pkgver}" \
	-d "java-1.8.0-openjdk" \
	--iteration $pkgrel \
	--rpm-user root --rpm-group root \
	--directories /opt/pycharm-${pkgver} \
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

