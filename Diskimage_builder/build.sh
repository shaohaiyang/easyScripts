#!/bin/bash
export DIB_DEV_USER_SHELL="/bin/bash"
export DIB_DEV_USER_USERNAME="geminis"
export DIB_DEV_USER_PASSWORD="upyun.com123"
export DIB_DEV_USER_PWDLESS_SUDO=true
export DIB_DISTRIBUTION_MIRROR="http://mirrors.aliyun.com/centos"
export DIB_EPEL_MIRROR="http://mirrors.aliyun.com/epel"
export DIB_CLOUD_INIT_DATASOURCES="ConfigDrive,OpenStack,NoCloud"
export DIB_TIMEZONE="Asia/Shanghai"
export DIB_BOOTLOADER_DEFAULT_CMDLINE="ixgbe.allow_unsupported_sfp=1"
export DIB_MODPROBE_BLACKLIST="nvidiafb,nouveau"
export ELEMENTS_PATH="$(dirname "$0")/elements"

readonly CMD="disk-image-create"
readonly LABEL="--root-label /Amy"
readonly OPTS="centos-minimal baremetal epel yum-minimal \
		grub2 bootloader modprobe-blacklist disable-selinux \
		dhcp-all-interfaces openssh-server devuser"
readonly PKGS="nmon,supervisor"

readonly EXTRA_ELEMENTS="setup-timezone install-mybin"

$CMD $LABEL $OPTS -p $PKGS $EXTRA_ELEMENTS -o mochaos
#qemu-img convert mochaos.qcow2 -f qcow2 -O raw mochaos.raw
#losetup -f -P mochaos.raw
