#!pyobjects

import logging as log

import csv
import StringIO
import re
from salt://lib/role_settings.sls import RoleSettings

import os
from salt://lib/paths.sls import RC_Paths

from salt://lib/cli_config.sls import CliConfig

# addresses a chicken-and-egg issue
class BootstrapManagedHost(CliConfig):
  """installs packages required for salt-recipes to work"""

  def __init__(self, options={}):
    super(BootstrapManagedHost, self).__init__(options)
    lopts = {}.copy()
    lopts.update(options)
    self.settings = lopts

  def common_pkgs(self):
    pkgs = ['git']

    if grains('kernel') == 'Linux':
      if grains('os_family') == 'RedHat':
        pkgs = pkgs + ['yum-cron', 'dkms']
      elif grains('os_family') == 'Debian':
        pkgs = pkgs + ['apt-transport-https']
    elif grains('kernel') == 'Darwin':
      pkgs = pkgs + []

    return pkgs

  def install_salt_dependencies(self):
    reqs = []
    packages = self.common_pkgs()
    packages = packages + ['virt-what']

    if grains('os_family') == 'RedHat':
      reqs = reqs + [Pkg('pkg install epel-release')]
      Pkg.installed('install python-M2Crypto dependencies',
                    pkgs=['swig', 'm2crypto'],
                    require=reqs)
    elif grains('os_family') == 'Debian':
      packages = packages + ['python-pyghmi']
      Pkg.installed('pkg install pycurl dependencies', pkgs=['libcurl4-openssl-dev'],
                    require=reqs)
      Pkg.installed('install python-M2Crypto dependencies', pkgs=['swig'], require=reqs)
    elif grains('kernel') == 'Darwin':
      packages = packages + ['brew-pip', 'osquery']
      Pkg.installed('install python-M2Crypto dependencies', pkgs=['swig'], require=reqs)

    Pkg.installed('pkg install salt dependencies', pkgs=packages, require=reqs)
    #Cmd.run('pip install --upgrade pip')
    #Pip.uptodate('pip upgrade', require=[Cmd('pip install --upgrade pip')])
    #Pip.uptodate('as %s: pip upgrade' % self.as_account, user=self.as_account)
    Pip.installed('pkg install python modules # for salt and its recipes',
                  pkgs=['semantic_version', 'virtualenvwrapper'],
                  require=reqs + [Pkg('install pip')])

  def install_pip(self):
    pkgs = []
    reqs = []

    if grains('kernel') == 'Linux':
      pkgs = pkgs + ['python2-pip']
      if grains('os_family') == 'RedHat':
        reqs = reqs + [Pkg('pkg install epel-release')]
    elif grains('kernel') == 'Darwin':
      pkgs = pkgs + ['brew-pip']

    Pkg.installed('install pip', pkgs=pkgs, require=reqs)

  def install_epel_release(self):
    if grains('os_family') == 'RedHat':
      Pkg.installed('pkg install epel-release', name='epel-release')


pkg = BootstrapManagedHost()
pkg.install_epel_release()
pkg.install_pip()
pkg.install_salt_dependencies()
