#!/bin/bash

# Expects Ubuntu 16.06 (xenial) and kernel 4.x.
# Based upon a blog post by Zach at http://zachzimm.com/blog/?p=191

set -eux

# Have the user call sudo early so the credentials is valid later on
sudo whoami 

KERN_VERSION=$(uname -r |cut -d'-' -f1)
cd /var/tmp
wget https://www.kernel.org/pub/linux/kernel/v4.x/linux-${KERN_VERSION}.tar.xz
tar xf linux-${KERN_VERSION}.tar.xz -C /var/tmp/
KERN_DIR="/var/tmp/linux-${KERN_VERSION}"
cd "${KERN_DIR}"
zcat /proc/config.gz > .config

for x in xenial xenial-security xenial-updates; do 
  egrep -qe "deb-src.* $x " /etc/apt/sources.list || echo "deb-src http://archive.ubuntu.com/ubuntu ${x} main universe" | tee -a /etc/apt/sources.list
done

sudo apt update

# Fetch the tools necessary to build the kernel. Using generic because there may not be a package for our $KERN_VERSION.
sudo apt-get build-dep linux-image-generic -y
sudo apt-get install libssl-dev -y # Also needed, not identified above.

NUM_CORES=$(cat /proc/cpuinfo|grep vendor_id|wc -l)
make -j${NUM_CORES}

/sbin/rcvboxdrv setup