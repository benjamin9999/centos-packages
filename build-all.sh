#!/bin/bash

pushd python2
makepkg -i
popd

wget -c https://bootstrap.pypa.io/get-pip.py
echo 'bootstrap setuptools:'
sudo /opt/rqdq/bin/python2.7 ./get-pip.py

for pkg in libxml2 libxslt mod_wsgi python2-setuptools python2-pip python2-virtualenv; do
  pushd $pkg
  makepkg -i
  popd
done

