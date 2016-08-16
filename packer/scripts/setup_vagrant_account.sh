#!/bin/sh

set -e

#if [ ! -d ~/.ssh ]; then
#  mkdir -m 700 ~/.ssh
#fi

#cd ~/.ssh
#touch ~/.ssh/authorized_keys
#chmod 600 ~/.ssh/authorized_keys

#wget --no-check-certificate \
#    'https://github.com/mitchellh/vagrant/raw/master/keys/vagrant.pub' \
#    -O- > ~/.ssh/authorized_keys
#cp ~/.ssh/authorized_keys ~/.ssh/authorized_keys.github_vagrant

mkdir ~/vendor
