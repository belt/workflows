#!/bin/bash

set -e

os_major_release="${OS_MAJOR_RELEASE:=7}"
os_minor_release="${OS_MINOR_RELEASE:=3}"
salt_short_release="${SALT_SHORT_RELEASE:=2016.11}"

ensure_salt_repo() {
cat > /etc/yum.repos.d/Saltstack.repo << EOF
[Saltstack]
name=Saltstack EL${os_major_release:=7}
key_url=https://repo.saltstack.com/yum/redhat/${os_major_release:=7}/x86_64/${salt_short_release}/SALTSTACK-GPG-KEY.pub
enabled=True
baseurl=https://repo.saltstack.com/yum/redhat/${os_major_release:=7}/x86_64/${salt_short_release}/
refresh=True
humanname=Saltstack EL${os_major_release:=7}
file=/etc/yum.repos.d/salt-${salt_short_release}.repo
gpgcheck=False
EOF
}

# NOTE has the effect of "sourcing" salt-repo without a full `yum update -y`
ensure_dependencies() {
  yum install -y python
}

ensure_salt_repo
ensure_dependencies
