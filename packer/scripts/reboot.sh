#!/bin/sh
set -e

# runtime kernel must match kernel-devel before installing VBoxGuestAdditions
echo "rebooting system for kernel upgrade"
shutdown -r now
sleep 60
