#!/bin/sh

box_name="${BOX_NAME}"
vagrant box list ${box_name} | egrep "\b${box_name}\b" > /dev/null
if [ $? != 0 ]; then
  echo "vagrant box add ${box_name} boxes/${box_name}-virtualbox-iso.box"
  vagrant box add --name ${box_name} ${box_name} boxes/${box_name}-virtualbox-iso.box
fi

if [ ! -f Vagrantfile ]; then
  echo "vagrant init ${box_name}"
  vagrant init ${box_name}
fi

grep "node\.vm\.box = \"${box_name}\"" Vagrantfile > /dev/null
if [ $? != 0 -a -f Vagrantfile ]; then
  echo "updating Vagrantfile"
  sed -i '.orig' \
  -e "/config.vm.box = \"${box_name}\"/i \\
  \ \ config.vm.define \"${box_name}\" do |node|" \
  -e "/config.vm.box = \"${box_name}\"/a \\
  \ \ end\\" \
  -e "s/config.vm.box = \"${box_name}\"/\ \ node.vm.box = \"${box_name}\"/" \
  Vagrantfile
fi

vagrant plugin list | grep vagrant-vbguest > /dev/null
if [ $? != 0 ]; then
  echo 'vagrant plugin install vagrant-vbguest'
  vagrant plugin install vagrant-vbguest
fi
