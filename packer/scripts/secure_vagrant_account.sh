#!/bin/sh

box_name="${BOX_NAME}"

# secure vagrant-account
if [ ! packer/salt/keys/id_rsa.vagrant.${box_name} ]; then
  dt=`date +'%d %b %Y %H:%M:%S' | sed -e 's/://g;s/ /./'g`
  comment="packer.vagrant.${dt}@`hostname`"
  ssh-keygen -q -N "" -C "${comment}" -o -f packer/salt/keys/id_rsa.vagrant.${box_name}
fi
