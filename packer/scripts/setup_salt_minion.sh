#!/bin/bash

set -e

box_name="${BOX_NAME:=localhost}"
os_major_release="${OS_MAJOR_RELEASE:=7}"
os_minor_release="${OS_MINOR_RELEASE:=3}"
salt_short_release="${SALT_SHORT_RELEASE:=2016.11}"
salt_master="${SALT_MASTER:=10.0.2.2}"
enable_mysql_support="${ENABLE_MYSQL_SUPPORT:=0}"

ensure_minion_starts_on_boot() {
  #systemctl is-enabled salt-minion.service
  rl=`runlevel | cut -f2 -d' '`
  chkconfig salt-minion --level ${rl}
  if [ "$?" == 0 ]; then
    echo "salt-minion already in runlevel ${rl}"
  else
    #chkconfig salt-minion on
    systemctl enable salt-minion.service
  fi
}

ensure_dependencies() {
  if [ "${enable_mysql_support}" -gt 0 ]; then
    salt-call --local state.sls installers/bootstrap_managed_host/db
  fi
  #yum install -y salt-minion
  #yum install -y swig m2crypto # used by salt recipes?
}

ensure_salt_minion_minimal_roles() {
  roles='as-development,org_as-m,deploy,rbenv'
  if [ "${enable_mysql_support}" -gt 0 ]; then
    roles="${roles},db,mariadb"
  fi
  salt-call --local grains.setval roles ${roles}
}

bootstrap_salt_minion() {
  sed -i -e "s/^#*\s*master:.*$/master: ${salt_master}/" /etc/salt/minion
  sed -i -e "s/^.*id:.*$/id: ${box_name}/" /etc/salt/minion
}

ensure_minion_id() {
  mkdir -p /etc/salt
  echo "${box_name}" > /etc/salt/minion_id
}

bootstrap_salt_minion
#ensure_minion_starts_on_boot
ensure_salt_minion_minimal_roles
ensure_dependencies
ensure_minion_id
