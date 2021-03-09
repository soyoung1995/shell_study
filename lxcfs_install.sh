#!/bin/bash

redEcho() {
        echo -e "\033[31m$*\033[0m"
}

greenEcho() {
        echo -e "\033[32m$*\033[0m"
}

# get os type
ID=$(grep '^ID=' /etc/os-release|awk -F = '{print $NF}')
VERSION_ID=$(grep '^VERSION_ID=' /etc/os-release|awk -F = '{print $NF}')
OS=$(echo $ID$VERSION_ID|sed 's/"//g')
greenEcho "Get OS: $OS"
echo

# install
cd /k8s_pkgs/
if echo $OS|grep "centos" || echo $OS|grep "rhel" ; then
        greenEcho "Install fuse-devel lxcfs-3.1.2-lp151.2.3.1.aarch64.rpm"
        yum install -y fuse-devel
        yum install -y lxcfs-3.1.2-lp151.2.3.1.aarch64.rpm
        cp -f lxcfs.service /usr/lib/systemd/system/lxcfs.service
elif echo $OS|grep "debian" || echo $OS|grep "ubuntu" || echo $OS|grep "kylin" ; then
        greenEcho "Install lxcfs_3.1.2-netease_arm64.deb"
        dpkg -i lxcfs_3.1.2-netease_arm64.deb || apt-get install -f -y
else
        redEcho "Can not support os: $OS"
        exit 1
fi

mkdir -p /usr/local/lxcfs/bin/
cp -f container_remount_lxcfs.sh /usr/local/lxcfs/bin/container_remount_lxcfs.sh
chmod +x /usr/local/lxcfs/bin/container_remount_lxcfs.sh

# start service
greenEcho "Start lxcfs service..."
systemctl daemon-reload
systemctl start lxcfs && systemctl enable lxcfs
if [ $? -eq 0 ]; then
        greenEcho "Start lxcfs service successfully."
        exit 0
else
        redEcho "Failed to start lxcfs."
        exit 1
fi

