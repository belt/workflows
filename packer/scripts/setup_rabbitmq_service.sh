#!/bin/bash

set -e

os_major_release="${OS_MAJOR_RELEASE:=7}"
os_minor_release="${OS_MINOR_RELEASE:=3}"

ensure_rabbitmq_repo() {
cat > /etc/yum.repos.d/rabbitmq.repo << EOF
[rabbitmq]
name=rabbitmq_rabbitmq-server
baseurl=https://packagecloud.io/rabbitmq/rabbitmq-server/el/${os_major_release:=7}/\$basearch
repo_gpgcheck=1
gpgcheck=0
enabled=1
gpgkey=https://packagecloud.io/rabbitmq/rabbitmq-server/gpgkey
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
EOF
}

ensure_service_starts_on_boot() {
  rl=`runlevel | cut -f2 -d' '`
  chkconfig rabbitmq --level ${rl}
  if [ "$?" == 0 ]; then
    echo "rabbitmq already in runlevel ${rl}"
  else
    chkconfig rabbitmq on
  fi
}

ensure_salt_minion() {
  yum install -y python swig m2crypto
  yum install -y rabbitmq
}

ensure_salt_repo
#ensure_salt_minion
#ensure_service_starts_on_boot

