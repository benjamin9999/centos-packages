#!/bin/bash
#sudo yum -y install createrepo
mkdir -p CentOS/6/x86_64/RPMS
mv rpms/* CentOS/6/x86_64/RPMS/
createrepo ./CentOS/6/x86_64

