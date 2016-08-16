#!pyobjects

import logging as log
import semantic_version

import csv
import StringIO
import re
from salt://lib/role_settings.sls import RoleSettings

import os
from salt://lib/paths.sls import RC_Paths

from salt://lib/cli_config.sls import CliConfig

# bootstraps one of several mysql repositories-and-packages, sometimes paying
# attention to version number
#
# examples: maria-10.1.0 distro-5.6.25 enterprise-5.6.25 percona-?.?.? mysql-5.6.x
class MysqlInstaller(CliConfig):
  """installs mysql relational database"""

  def __init__(self, options={}):
    super(MysqlInstaller, self).__init__(options)
    lopts = {
      'version': 'maria-10.1.0'
    }.copy()
    lopts.update(options)
    self.settings = lopts

    # version
    # examples: maria-10.1.0 distro-5.6.25 enterprise-5.6.25 percona-?.?.? mysql-5.6.x
    #
    # distro - debian, redhat or macos... determined by grains('os_family')
    # enterprise - enterprise tarball
    # percona - percona packages
    # mysql - oracle packages
    # maria - maria packages
    self.version = lopts['version']

    # package manager or source install and which version?
    self.install_via_source = False

    # mysql license / packaging selection and version parsing
    mysql_license, mysql_version = self.version.split('-', 2)
    self.mysql_license = mysql_license.lower()
    import semantic_version
    mysql_version = semantic_version.Version(mysql_version)
    self.major_version = mysql_version.major
    self.minor_version = mysql_version.minor
    self.patch_version = mysql_version.patch

    if self.mysql_license == 'enterprise':
      self.settings['lc-messages-dir'] = os.path.join('/usr', 'local', 'share')
      self.settings['basedir'] = os.path.join('/usr', 'local')
    else:
      self.settings['lc-messages-dir'] = os.path.join('/usr', 'share', 'mysql')
      self.settings['basedir'] = os.path.join('/usr')

  def semantic_license(self):
    re_mysql = re.compile('\A\s*mysql(?:db)?\Z')
    re_maria = re.compile('\A\s*maria(?:db)?\Z')
    re_percona = re.compile('\A\s*percona(?:db)?\Z')
    if re_maria.search(self.mysql_license):
      return 'maria'
    elif re_mysql.search(self.mysql_license):
      return 'mysql'
    elif re_percona.search(self.mysql_license):
      return 'percona'
    elif self.mysql_license == 'enterprise':
      return 'enterprise'
    else:
      return 'distro'

  def ensure_repository(self):
    if self.semantic_license() == 'distro':
      if grains('os_family') == 'RedHat':
        params = 'release=$releasever&arch=$basearch&repo=centosplus&infra=$infra'
        mirror_path = 'http://mirrorlist.centos.org/?%s' % params
        Pkgrepo.managed('repo.mysql', name='centosplus', humanname='CentOS-$releasever - Plus',
                      mirrorlist=mirror_path, disabled=False,
                      gpgkey='file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7', gpgcheck=1)
      elif grains('os_family') == 'Debian':
        Pkgrepo.managed('repo.universe', humanname='Community maintained software',
                        name='deb http://us.archive.ubuntu.com/ubuntu/ %s universe' %
                             grains('lsb_distrib_codename'),
                        refresh=1, gpgcheck=1,
                        file='/etc/apt/sources.list.d/universe.list')
      else:
        log.error('unknown os_family: %s' % grains('os_family'))
    elif self.semantic_license() == 'maria':
      name_with_version = 'MariaDB-%s-%s' % (self.major_version, self.minor_version)
      Cmd.run('gpg sign mariadb repo',
              name='rpm --import https://yum.mariadb.org/RPM-GPG-KEY-MariaDB',
              unless="rpm -q gpg-pubkey --qf '%{name}-%{version}-%{release} --> %{summary}\\n'  | grep 'MariaDB Package Signing Key'")
      Pkgrepo.managed('repo.mysql', name='%s.repo' % name_with_version.lower(),
                      humanname=name_with_version,
                      disabled=False, refresh=1, gpgcheck=1,
                      baseurl='http://yum.mariadb.org/10.1/centos7-amd64',
                      key_url='https://yum.mariadb.org/RPM-GPG-KEY-MariaDB',
                      require=['gpg sign mariadb repo'])
    elif self.semantic_license() == 'mysql':
      if grains('os_family') == 'Debian':
        repo = 'deb http://repo.mysql.com/apt/ubuntu/'
        repo = "%s %s mysql-%s" % repo, grains('lsb_distrib_codename'), release_version()
        gpg_key_path = 'http://keyserver.ubuntu.com:11371/pks/lookup?op=get&search=0x5072E1F5'
        Pkgrepo.managed('repo.mysql', humanname='MySQL offical repository', name=repo,
                        refresh=True, file='/etc/apt/sources.list.d/mysql.list',
                        key_url=gpg_key_path, gpgcheck=1)
      else:
        log.error('unknown os_family: %s' % grains('os_family'))
    elif self.semantic_license() == 'percona':
      if grains('os_family') == 'Debian':
        Pkgrepo.managed('repo.mysql', humanname='Percona offical repository', refresh=True,
                        name='deb https://repo.percona.com/apt %s main' % grains('lsb_distrib_codename'),
                        file='/etc/apt/sources.list.d/percona.list',
                        key_url='http://keyserver.ubuntu.com:11371/pks/lookup?op=get&search=0x1AC84755480F2F02',
                        gpgcheck=1)
      else:
        log.error('unknown os_family: %s' % grains('os_family'))
    elif self.semantic_license() == 'enterprise':
      True
    else:
      log.error('unknown mysql license: %s' % self.semantic_license())

  def ensure_dependencies(self):
    if self.install_via_source:
      return

    True

  def install_via_package_manager(self):
    self.packages = ['mysql-server']
    mysql_python_pkg_name = 'MySQL-python'

    if grains('os_family') == 'RedHat':
      if self.semantic_license() == 'maria':
        self.packages = ['MariaDB-server', 'MariaDB-client']
      else:
        log.warn('unknown mysql_license: %s' % self.semantic_license())
    elif grains('os_family') == 'Debian':
      mysql_python_pkg_name = 'python-mysqldb'
    else:
      log.warn('unknown os_family: %s' % grains('os_family'))

    Pkg.installed('pkg install mysql', pkgs=self.packages, require=[Pkgrepo('repo.mysql')])
    Pkg.installed('pkg install python-mysql # bindings', name=mysql_python_pkg_name,
      require=[Pkg('pkg install mysql')])

  def install_package(self):
    if self.install_via_source:
      True
      #self.mk_dirs()
      #self.fetch_src()
      #self.autoreconf()
      #self.dot_slash_configure()
      #self.make()
      #self.make_install()
      #self.make_clean()
      #self.stow_package()
    else:
      self.install_via_package_manager()
