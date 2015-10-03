#!/bin/bash
workdir=`pwd`

pkgname=archiveopteryx
pkgver=3.2.0.1
pkgrel=1
makedepends=('jam')

git_source="https://github.com/aox/aox"
git_checkout="master"


fetch() {
    git clone $git_source $srcdir

    cd $srcdir
    git checkout $git_checkout
    patch -p1 < $workdir/Jamsettings.patch
}


build() {
    cd ${srcdir}
    jam
}

package() {
    cd ${srcdir}
    INSTALLROOT="${pkgdir}" jam install

    cd $workdir
#        -d "${pkgname}-libs == ${pkgver}-${pkgrel}" \
#	--rpm-attr '0701,aox,aox:/var/run/aox' \

    fpm -s dir -t rpm -e \
        -n "${pkgname}" \
        -C "${pkgdir}" \
        -v "${pkgver}" \
	--iteration $pkgrel \
	--rpm-use-file-permissions \
	--rpm-user root --rpm-group root \
	--directories /var/run/aox \
	--directories /usr/lib/archiveopteryx \
	--directories /usr/share/doc/archiveopteryx \
        usr var
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

