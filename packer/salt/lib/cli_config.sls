#!pyobjects

import logging as log

from salt://lib/role_settings.sls import csv
from salt://lib/role_settings.sls import StringIO
from salt://lib/role_settings.sls import RoleSettings
from salt://lib/paths.sls import os
from salt://lib/paths.sls import RC_Paths

class CliConfig(object):
  """Ensures minimum common account configuration"""

  def __init__(self, options={}):
    self.options = options

    # deployment stage and organization of minion
    self.settings = RoleSettings()
    self.as_stg = self.settings.as_stages[0]
    self.as_org = self.settings.as_organizations[0]

    # account
    # HACK: https://github.com/saltstack/salt/issues/12803
    account = options['account'] if 'account' in options else 'nobody'
    if '\\' in account:
      domain, acct = account.split('\\')
      self.ad_domain = domain
      self.as_account = account
      self.smb_account = acct
      if True: # TODO: detect 'winbind use default domain = true' in samba
        self.fs_account = self.smb_account
      else:
        self.fs_account = self.as_account
    else:
      self.ad_domain = None
      self.as_account = account
      self.fs_account = self.as_account
    self.as_uid = __salt__['file.user_to_uid'](self.as_account)
    self.as_uid = None if not self.as_uid else self.as_uid

    # group
    # ultimately this calls https://docs.python.org/2/library/pwd.html#pwd.getpwnam
    account_info = __salt__['user.info'](self.as_account)
    self.as_group = options['group'] if 'group' in options else 'nobody'
    if account_info:
      self.account_exists = True
      self.as_gid = account_info['gid']
      self.as_group = __salt__['file.gid_to_group'](self.as_gid)
      if self.as_gid == self.as_group:
        if grains('kernel') == 'Linux':
          self.as_group = 'users'
        elif grains('kernel') == 'Darwin':
          self.as_group = 'staff'
        else:
          self.as_group = 'users'
    else:
      self.account_exists = False
      self.as_gid = __salt__['file.gid_to_group'](self.as_group)

    # ${HOME}
    paths = RC_Paths()
    self.home_path = paths.home_account_path(self.as_account)

    # password
    self.pw = pillar('passwords:%s:system:%s:%s' % (self.as_org, self.as_stg, self.as_account),
                     'changeme')

    # directories (keys) with the assigned bits (values)
    # e.g. {'bin': 755, 'tmp': 700}
    self.rc_paths = {}

    # placeholder
    if grains('os_family') == 'RedHat':
      self.ssh_pkg = 'openssh-clients'
    elif grains('os_family') == 'Debian':
      self.ssh_pkg = 'openssh-client'
    elif grains('os_family') == 'MacOS':
      self.ssh_pkg = 'libssh2'
    else:
      log.warn('unknown OS Family: %s' % grains('os_family'))

    # host
    self.host = grains('localhost', 'localhost')
    self.total_ram_in_megs = int(grains('mem_total', 4096))
    self.processor_count = int(grains('num_cpus', 1))

  # Can not create accounts in the Active Directory domain, so make a placeholder
  def state_requires(self):
    if self.ad_domain:
      return [Pkg(self.ssh_pkg)]
    else:
      return [User(self.as_account)]

  def mk_dirs(self):
    for path, mode in self.rc_paths.iteritems():
      File.directory(path, mode=mode, user=self.fs_account, group=self.as_group, makedirs=True,
                     creates=[path],
                     recurse=['user', 'group'], require=self.state_requires())
