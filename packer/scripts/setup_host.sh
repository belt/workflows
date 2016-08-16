#!/bin/bash

set -e

# make yum spiffy
yum install -y wget deltarpm yum-plugin-priorities yum-plugin-protectbase yum-cron

os_major_release="${OS_MAJOR_RELEASE:=7}"
os_minor_release="${OS_MINOR_RELEASE:=3}"

yum install -y wget epel-release-${os_major_release:=7}-${os_minor_release:=3} net-tools

box_name="${BOX_NAME}"

update_etc_hosts() {
  echo 'updating /etc/hosts'
  sed -i'.orig' \
  -e "s/127\.0\.0\.1   vagrant-centos/127.0.0.1   ${box_name}/" \
  /etc/hosts
}

update_etc_sysconfig_network() {
  echo 'updating /etc/sysconfig/network'
  sed -i'.orig' \
  -e "s/HOSTNAME=vagrant-centos/HOSTNAME=${box_name}/" \
  /etc/sysconfig/network
}

bootstrap_yum_cron() {
  sed -i -e 's/^\s*apply_updates\s*=.*$/apply_updates = yes/' /etc/yum/yum-cron.conf
}

update_etc_hosts
update_etc_sysconfig_network
bootstrap_yum_cron
