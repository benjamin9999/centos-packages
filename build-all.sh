#!/bin/bash

pushd python2
./build.sh
echo 'install python2:'
sudo ./build.sh install
popd

wget -c https://bootstrap.pypa.io/get-pip.py
echo 'bootstrap setuptools:'
sudo /opt/rqdq/bin/python2.7 ./get-pip.py

for pkg in libxml2 libxslt mod_wsgi python2-setuptools python2-pip python2-virtualenv
do
	pushd $pkg
	./build.sh
	echo "install ${pkg}:"
	sudo ./build.sh install
	popd
done

