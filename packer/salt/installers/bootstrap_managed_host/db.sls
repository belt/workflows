#!pyobjects

import logging as log

from salt://lib/role_settings.sls import csv
from salt://lib/role_settings.sls import StringIO
from salt://lib/role_settings.sls import re
from salt://lib/role_settings.sls import RoleSettings

from salt://lib/paths.sls import os
from salt://lib/paths.sls import RC_Paths

from salt://lib/cli_config.sls import CliConfig

from salt://installers/mysql/installer.sls import semantic_version
from salt://installers/mysql/installer.sls import MysqlInstaller


# addresses a chicken-and-egg issue
class BootstrapManagedHostDb(CliConfig):
  """installs packages required for salt-recipes to work"""

  def __init__(self, options={}):
    super(BootstrapManagedHostDb, self).__init__(options)
    lopts = {}.copy()
    lopts.update(options)
    self.settings = lopts

  def install_mysql_dependencies(self):
    reqs = []
    packages = []

    if grains('os_family') == 'RedHat':
      packages = packages + ['MySQL-python']
    elif grains('os_family') == 'Debian':
      packages = packages + ['python-mysql']

    Pkg.installed('pkg install mysql dependencies', pkgs=packages, require=reqs)


settings = RoleSettings()
if settings.has_role('db') and (settings.has_role('mysql') or settings.has_role('mariadb')):
  if grains('kernel') == 'Linux':
    pkg = BootstrapManagedHostDb()
    pkg.install_mysql_dependencies()
